//
//  ZKLazyLoadingWithCache.h
//  ZKLazyLoading
//
//  Created by Zeeshan on 04/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKLazyLoadingWithCache : UIViewController <ImageDownloadDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblCache;
@property (nonatomic, strong) NSArray                   *arrRows;

@end
