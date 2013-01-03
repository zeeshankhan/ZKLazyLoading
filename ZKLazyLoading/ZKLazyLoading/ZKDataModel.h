//
//  ZKModel.h
//  ZKLazyLoading
//
//  Created by Zeeshan on 02/01/13.
//  Copyright (c) 2013 zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKDataModel : NSObject

@property (nonatomic, strong) UIImage *thumb;

- (id)initWithData:(NSDictionary *)dictionary;

- (NSString*)title;
- (NSString*)imgUrl;

@end
