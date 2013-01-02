//
//  ZKViewController.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 02/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKViewController.h"

@interface ZKViewController ()
@property (nonatomic, strong) UITableView *tblTopApps;
@property (nonatomic, strong) NSArray *arrRows;
@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Top Paid Apps";
    
    _tblTopApps = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tblTopApps.dataSource = self;
    _tblTopApps.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [[self view] addSubview:_tblTopApps];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray*)arrRows {
    if (_arrRows == nil) {

        NSString *strUrl = @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=50/json";
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            // Downloading data
            NSURL *url = [NSURL URLWithString:strUrl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSDictionary *dicResponse = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
            _arrRows = [[dicResponse objectForKey:@"feed"] objectForKey:@"entry"];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Reloading table view
                [_tblTopApps reloadData];
            });
            
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

    NSDictionary *dicCell = [[self arrRows] objectAtIndex:indexPath.row];
    cell.textLabel.text = [[dicCell objectForKey:@"im:name"] objectForKey:@"label"];
    return cell;
}


@end
