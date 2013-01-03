//
//  ZKLazyLoadingVC.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 03/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKLazyLoadingVC.h"
#import "ZKDataModel.h"

@interface ZKLazyLoadingVC ()
@property (nonatomic, strong) NSArray                   *arrRows;
@property (nonatomic, strong) NSOperationQueue     *imageDownloadQueue;
@end

@implementation ZKLazyLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Lazy Loading";
    _imageDownloadQueue = [[NSOperationQueue alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray*)arrRows {
    if (_arrRows == nil) {
        
        NSString *strUrl = @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=200/json";
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            // Downloading data
            NSURL *url = [NSURL URLWithString:strUrl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (data != nil) {
                
                // Parsing and setting data model objects
                NSDictionary *dicResponse = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
                
                __block NSMutableArray *arrItems = [NSMutableArray new];
                NSArray *arrTemp = [[dicResponse objectForKey:@"feed"] objectForKey:@"entry"];
                __block ZKDataModel *dataModel = nil;
                [arrTemp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    dataModel = [[ZKDataModel alloc] initWithData:(NSDictionary*)obj];
                    [arrItems addObject:dataModel];
                    dataModel = nil;
                }];
                
                _arrRows = [[NSArray alloc] initWithArray:arrItems];
                
                arrItems = nil;
                arrTemp = nil;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Reloading table view
                    [_tblLazyLoading reloadData];
                });
            }
        });
    }
    return _arrRows;
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
    
    if (dataModel.thumb != nil)
        cell.imageView.image = dataModel.thumb;
    else {
        cell.imageView.image = [UIImage imageNamed:@"noImg.jpeg"];
        if ( [_imageDownloadQueue operationCount] < 10 )
            [self didRequestForImageUrl:dataModel.imgUrl andIndexPath:indexPath];
    }

    return cell;
}

- (void)didRequestForImageUrl:(NSString*)strUrl andIndexPath:(NSIndexPath*)path {
    ZKImageDownloadOperation	*op = [[ZKImageDownloadOperation alloc] initWithImageUrl:strUrl andIndexPath:path];
    op.delegate	= self;
    [_imageDownloadQueue addOperation:op];
    NSLog(@"Count %d",[_imageDownloadQueue operationCount]);
}

- (void)cancelAllOperations {
    NSArray	*arrTemp = [_imageDownloadQueue operations];
	for( ZKImageDownloadOperation *operation in arrTemp ) {
        
        // we only care about non-cancelled operations
		if( operation.isCancelled == NO )
            [operation cancel];
	}
}

- (void)loadImagesForOnscreenRows {
    NSArray *visibleRows = [_tblLazyLoading indexPathsForVisibleRows];
    [_tblLazyLoading reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Delegate callback

- (void)imageDidDownload:(ZKImageDownloadOperation*)operation {

    if (operation.isCancelled == NO) {

        dispatch_async(dispatch_get_main_queue(), ^{
            
            ZKDataModel *dataModel = [[self arrRows] objectAtIndex:operation.cellPath.row];
            dataModel.thumb = operation.thumb;
            
            UITableViewCell *cell = [_tblLazyLoading cellForRowAtIndexPath:operation.cellPath];
            cell.imageView.image = operation.thumb;
        });
    }
}

// Implement cancelOperationsForOffscreenRows to optimize to balance the cancelling the number of operations
- (void)cancelOperationsForOffScreenRows {

	NSArray	*arrTemp = [_imageDownloadQueue operations];
	for( ZKImageDownloadOperation *operation in arrTemp ) {
        
        // we only care about non-cancelled operations
		if( operation.isCancelled == NO ) {
			UITableViewCell *cell	= [_tblLazyLoading cellForRowAtIndexPath:operation.cellPath];
        
            // then the row is NO longer visible so cancel the operation associated with that cell
            if( cell == nil ) {
				[operation cancel];
                NSLog(@"After Cancel Count %d",[_imageDownloadQueue operationCount]);
            }
		}
	}
}

#pragma mark - Scroll view delegates

// Implement ScrollView Delegate method i.e scrollViewDidScroll to cancel the operation by 	calling a method cancelOperationsForOffscreenRows
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cancelOperationsForOffScreenRows];
    //[self cancelAllOperations];
}

//Implement ScrollView Delegate method i.e scrollViewDidEndDecelerating to cancel the operation by
//                      calling a method cancelOperationsForOffscreenRows and reload the tableview
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//
//    [self cancelOperationsForOffScreenRows];
//	
//	NSArray *visibleCells = [_tblLazyLoading indexPathsForVisibleRows];
//    for (NSIndexPath *indexpath in visibleCells)
//    {
//        int flag = 0;
//        NSArray	*arrTemp = [_imageDownloadQueue operations];
//        for( ZKImageDownloadOperation *op in arrTemp )
//        {
//            NSUInteger		row		= op.cellPath.row;
//            
//            if (indexpath.row == row) {
//                
//                flag = 1;
//                break;
//            }
//            else{
//                flag = 2;
//            }
//        }
//        if(flag==2)
//        {
//            [_tblLazyLoading reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
//        }
//        else if(flag==0){
//            
//            ZKDataModel *entity = [[self arrRows] objectAtIndex:indexpath.row];
//            if (entity.thumb == nil) {
//                [_tblLazyLoading reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
//            }
//        }
//    }
//}

//// Cancel any operations for offscreen rows - if we are decelerating we will do it in scrollViewDidScroll
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	if( !decelerate )
//        [self cancelOperationsForOffScreenRows];	
//}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
    else [self cancelOperationsForOffScreenRows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cancelOperationsForOffScreenRows];
    [self loadImagesForOnscreenRows];
}


@end
