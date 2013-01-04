//
//  ZKViewController.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 02/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKViewController.h"
#import "ZKLazyLoadingVC.h"

@interface ZKViewController ()
@property (nonatomic, strong) NSArray *arrRows;
@property (nonatomic, strong) NSArray *arrItems;
@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"List Items";

    // Load Plist items
    NSOperationQueue *queue = [NSOperationQueue new];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(loadDataWithOperation)
																			  object:nil];
	[queue addOperation:operation];

    // Download server data
    [self downloadDataUsingGCD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) loadDataWithOperation {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ListItems" ofType:@"plist"];
    _arrItems = [[NSArray alloc] initWithContentsOfFile:filePath];
	
    // either this
	//[[self tblListItems] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    // or
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_tblListItems reloadData];
    });
}


- (NSArray*)arrItems {
    if (_arrItems == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ListItems" ofType:@"plist"];
        _arrItems = [[NSArray alloc] initWithContentsOfFile:filePath];
    }
    return _arrItems;
}

- (void)downloadDataUsingGCD {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString *strUrl = @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=200/json";
    
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

            [self setArrRows:arrItems];
            
            arrItems = nil;
            arrTemp = nil;
        }
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrItems] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *strIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [[self arrItems] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_arrRows == nil || _arrRows.count == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    switch (indexPath.row) {
        case 0: {
            ZKLazyLoadingVC *Obj = [[ZKLazyLoadingVC alloc] initWithNibName:@"ZKLazyLoadingVC" bundle:nil];
            [Obj setArrRows:[self arrRows]];
            [self.navigationController pushViewController:Obj animated:YES];
        }
            break;
    }
}

@end
