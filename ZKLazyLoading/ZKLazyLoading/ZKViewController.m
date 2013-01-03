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
@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"List Items";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray*)arrRows {
    if (_arrRows == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ListItems" ofType:@"plist"];
        _arrRows = [[NSArray alloc] initWithContentsOfFile:filePath];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [[self arrRows] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            ZKLazyLoadingVC *Obj = [[ZKLazyLoadingVC alloc] initWithNibName:@"ZKLazyLoadingVC" bundle:nil];
            [self.navigationController pushViewController:Obj animated:YES];
        }
            break;
    }
}

@end
