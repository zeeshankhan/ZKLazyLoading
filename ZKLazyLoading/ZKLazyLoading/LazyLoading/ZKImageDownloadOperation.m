//
//  ZKImageDownloadOperation.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 03/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKImageDownloadOperation.h"

@interface ZKImageDownloadOperation ()
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *thumbImage;
@end

@implementation ZKImageDownloadOperation

- (id)initWithImageUrl:(NSString*)url andIndexPath:(NSIndexPath*)indexPath {
    
    self = [super init];
    if( self != nil ) {
        [self setImageUrl:url];
        [self setCellPath:indexPath];
    }
    return self;

}

- (void)main {
    
    if ([self isCancelled])
        return;
    
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:[self imageUrl]];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        [self setThumbImage:[UIImage imageWithData:imgData]];
        if (![self isCancelled] && _delegate != nil)
            [_delegate imageDidDownload:self];
    }
    
}

- (UIImage*)thumb {
    return [self thumbImage];
}

@end
