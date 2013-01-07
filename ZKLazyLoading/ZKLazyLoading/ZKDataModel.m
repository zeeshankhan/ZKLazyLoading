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

- (NSString*)imgName {
    NSArray *arrImgs = [[self dicResponse] objectForKey:@"im:image"];
    if (arrImgs && arrImgs.count > 0) {
        NSString *strImgUrl = [[arrImgs lastObject] objectForKey:@"label"];
        NSString *strImgName = [self stringBetween:@"http://" and:@".phobos.apple.com" from:strImgUrl];
        strImgName = [NSString stringWithFormat:@"%@.png",strImgName];
        //NSLog(@"Img Name: %@", strImgName);
        return strImgName;
    }
    return nil;
}

- (NSString *)stringBetween:(NSString*)string1 and:(NSString*)string2 from:(NSString *)sourceString {
	
	//Find the range of the first string
	NSRange range1 = [sourceString rangeOfString:string1 options:(NSCaseInsensitiveSearch)];
	if(range1.length > 0) {
        
		//Make a new range to search for the next string
		NSRange searchRange;
		searchRange.location = range1.location;
		searchRange.length = [sourceString length] - range1.location;
		
		//Find the next string
		NSRange range2 = [sourceString rangeOfString:string2 options:(NSCaseInsensitiveSearch) range:searchRange];
		if(range2.length > 0) {
			searchRange.location = range1.location + range1.length;
			searchRange.length = range2.location - searchRange.location;
			return [sourceString substringWithRange:searchRange];
		}
        else
            return @"";
	}
    else
        return @"";
}


@end
