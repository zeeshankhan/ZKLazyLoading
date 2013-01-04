//
//  ZKLazyLoadingVC.h
//  ZKLazyLoading
//
//  Created by Zeeshan on 03/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKLazyLoadingVC : UIViewController <ImageDownloadDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblLazyLoading;
@property (nonatomic, strong) NSArray                   *arrRows;

@end
