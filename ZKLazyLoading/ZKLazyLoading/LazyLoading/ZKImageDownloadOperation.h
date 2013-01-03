//
//  ZKImageDownloadOperation.h
//  ZKLazyLoading
//
//  Created by Zeeshan on 03/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDownloadDelegate;

@interface ZKImageDownloadOperation : NSOperation

@property (nonatomic, weak) id <ImageDownloadDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *cellPath;

- (id)initWithImageUrl:(NSString*)url andIndexPath:(NSIndexPath*)indexPath;
- (UIImage*)thumb;

@end

@protocol ImageDownloadDelegate <NSObject>
- (void)imageDidDownload:(ZKImageDownloadOperation*)operation;
@end
