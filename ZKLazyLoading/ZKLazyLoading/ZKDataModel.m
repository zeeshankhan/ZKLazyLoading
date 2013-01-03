//
//  ZKModel.m
//  ZKLazyLoading
//
//  Created by Zeeshan on 02/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import "ZKDataModel.h"

@interface ZKDataModel ()
@property (nonatomic, strong) NSDictionary *dicResponse;
@end

@implementation ZKDataModel

- (id)initWithData:(NSDictionary *)dictionary {
    self = [super init];
    if( self != nil ) {
        [self setDicResponse:dictionary];
    }
    return self;
}

- (NSString*)title {
    NSString *strTitle = [[[self dicResponse] objectForKey:@"im:name"] objectForKey:@"label"];
    //NSLog(@"Title: %@", strTitle);
    return strTitle;
}

- (NSString*)imgUrl {
    NSArray *arrImgs = [[self dicResponse] objectForKey:@"im:image"];
    if (arrImgs && arrImgs.count > 0) {
        NSString *strImgUrl = [[arrImgs lastObject] objectForKey:@"label"];
        //NSLog(@"Img Url: %@", strImgUrl);
        return strImgUrl;
    }
    return nil;
}

@end
