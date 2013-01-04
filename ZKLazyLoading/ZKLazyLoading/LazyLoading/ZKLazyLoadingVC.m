//
//  ZKLazyLoadingVC.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 03/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKLazyLoadingVC.h"

@interface ZKLazyLoadingVC ()
@property (nonatomic, strong) NSOperationQueue     *imageDownloadQueue;
@end

@implementation ZKLazyLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Lazy Loading";

    _imageDownloadQueue = [[NSOperationQueue alloc] init];
    [_imageDownloadQueue setMaxConcurrentOperationCount:10];
}

- (void)didReceiveMemoryWarning {
    [_imageDownloadQueue cancelAllOperations];
    [super didReceiveMemoryWarning];
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
    
    if (dataModel.thumb == nil)
    {
        cell.imageView.image = [UIImage imageNamed:@"noImg.jpeg"];
        if (_tblLazyLoading.dragging == NO && _tblLazyLoading.decelerating == NO)
            [self startIconDownloadForUrl:dataModel.imgUrl forIndexPath:indexPath];
    }
    else
        cell.imageView.image = dataModel.thumb;

    return cell;
}

- (void)startIconDownloadForUrl:(NSString*)strUrl forIndexPath:(NSIndexPath *)indexPath {

    ZKImageDownloadOperation	*op = [[ZKImageDownloadOperation alloc] initWithImageUrl:strUrl andIndexPath:indexPath];
    op.delegate	= self;
    [_imageDownloadQueue addOperation:op];
}

- (void)loadImagesForOnscreenRows {
    
    NSArray *visiblePaths = [_tblLazyLoading indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        ZKDataModel *model = [[self arrRows] objectAtIndex:indexPath.row];
        if (model.thumb == nil) // avoid the app icon download if the app already has an icon
            [self startIconDownloadForUrl:model.imgUrl forIndexPath:indexPath];
    }
}

#pragma mark - Delegate callback

- (void)imageDidLoad:(ZKImageDownloadOperation*)operation {

    if (operation.isCancelled == NO) {

        dispatch_sync(dispatch_get_main_queue(), ^{
            
            ZKDataModel *dataModel = [[self arrRows] objectAtIndex:operation.cellPath.row];
            dataModel.thumb = operation.thumb;
            
            UITableViewCell *cell = [_tblLazyLoading cellForRowAtIndexPath:operation.cellPath];
            cell.imageView.image = operation.thumb;
        });
    }
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
