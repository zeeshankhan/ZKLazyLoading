//
//  ZKLazyLoadingWithCache.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 04/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKLazyLoadingWithCache.h"

@interface ZKLazyLoadingWithCache ()
@property (nonatomic, strong) NSOperationQueue     *imageDownloadQueue;
@end

@implementation ZKLazyLoadingWithCache

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Lazy Loading With Cache";
    
    _imageDownloadQueue = [[NSOperationQueue alloc] init];
    [_imageDownloadQueue setMaxConcurrentOperationCount:10];
}

- (void)didReceiveMemoryWarning {
    [_imageDownloadQueue cancelAllOperations];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTblCache:nil];
    [self setArrRows:nil];
    [[self imageDownloadQueue] cancelAllOperations];
    [self setImageDownloadQueue:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrRows] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *strIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }
    ZKDataModel *dataModel = [[self arrRows] objectAtIndex:indexPath.row];
    cell.textLabel.text = dataModel.title;
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[self imagePath] stringByAppendingPathComponent:dataModel.imgName]];
    if (image == nil)
    {
        cell.imageView.image = [UIImage imageNamed:@"noImg.jpeg"];
        if (_tblCache.dragging == NO && _tblCache.decelerating == NO)
            [self startIconDownloadForUrl:dataModel.imgUrl forIndexPath:indexPath];
    }
    else
        cell.imageView.image = image;
    
    return cell;
}

- (void)startIconDownloadForUrl:(NSString*)strUrl forIndexPath:(NSIndexPath *)indexPath {
    
    ZKImageDownloadOperation	*op = [[ZKImageDownloadOperation alloc] initWithImageUrl:strUrl andIndexPath:indexPath];
    op.delegate	= self;
    [_imageDownloadQueue addOperation:op];
}

- (void)loadImagesForOnscreenRows {
    
    NSArray *visiblePaths = [_tblCache indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        ZKDataModel *model = [[self arrRows] objectAtIndex:indexPath.row];
        UIImage *image = [UIImage imageWithContentsOfFile:[[self imagePath] stringByAppendingPathComponent:model.imgName]];
        if (image == nil) // avoid the app icon download if the app already has an icon
            [self startIconDownloadForUrl:model.imgUrl forIndexPath:indexPath];
    }
}

#pragma mark - Delegate callback

- (void)imageDidLoad:(ZKImageDownloadOperation*)operation {
    
    if (operation.isCancelled == NO) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            UIImage *image = [operation thumb];

            UITableViewCell *cell = [_tblCache cellForRowAtIndexPath:operation.cellPath];
            cell.imageView.image = image;
            
            dispatch_queue_t imageWrite = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(imageWrite, ^{
                ZKDataModel *dataModel = [[self arrRows] objectAtIndex:operation.cellPath.row];
                [self writeImageFileIntoDisc:image withName:dataModel.imgName];
            });
        });
    }
}

- (NSString*)imagePath {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    documentsDirectory=[documentsDirectory stringByAppendingPathComponent:@"Images"];
    return documentsDirectory;
}

- (BOOL)writeImageFileIntoDisc:(UIImage*)image withName:(NSString*)filename {
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Images"];

    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDir] && isDir)
    {
        [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    documentsDirectory=[documentsDirectory stringByAppendingPathComponent:filename];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    return [imageData writeToFile:documentsDirectory atomically:YES];
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
        [self loadImagesForOnscreenRows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

@end
