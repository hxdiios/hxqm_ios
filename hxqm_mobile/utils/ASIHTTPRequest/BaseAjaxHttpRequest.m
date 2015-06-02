//
//  BaseAjaxHttpRequest.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/21.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "BaseAjaxHttpRequest.h"

@implementation BaseAjaxHttpRequest

- (id) initWithURL:(NSURL *)newURL {
    self = [super initWithURL:newURL];
    if(self) {
        [self setAllowCompressedResponse:YES];
        [self setRequestMethod:@"POST"];
        [self addRequestHeader:@"Content-Type" value:@"application/json"];
        [self addRequestHeader:@"Charset" value:@"UTF-8"];
        [self addRequestHeader:@"Accept-Encoding" value:@"gzip"];
        [self setUserAgentString:@"iphone"];
        self.timeOutSeconds = 30;
    }
    return self;
}

- (void) setPostBody:(NSDictionary *)params {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&err];
    NSMutableData *mutableJsonData = [[NSMutableData alloc] initWithData:jsonData];
    [super setPostBody:mutableJsonData];
}

@end
