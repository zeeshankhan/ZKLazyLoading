//
//  ZKImageDownloadOperation.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 03/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKImageDownloadOperation.h"

#define kAppIconSize 48

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
        if (imgData) {
            
            UIImage *image = [UIImage imageWithData:imgData];
            
            if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
            {
                CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
                UIGraphicsBeginImageContext(itemSize);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [image drawInRect:imageRect];
                [self setThumbImage:UIGraphicsGetImageFromCurrentImageContext()];
                UIGraphicsEndImageContext();
            }
            else
                [self setThumbImage:image];
        }
        else
            [self setThumbImage:[UIImage imageNamed:@"errorImg.jpeg"]];
        
        if (![self isCancelled] && _delegate != nil)
            [_delegate imageDidLoad:self];

    }
}

- (UIImage*)thumb {
    return [self thumbImage];
}

@end
