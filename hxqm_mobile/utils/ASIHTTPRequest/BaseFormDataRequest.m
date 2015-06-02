//
//  BaseFormDataRequest.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/19.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "BaseFormDataRequest.h"

@implementation BaseFormDataRequest

- (id) initWithURL:(NSURL *)newURL {
    self = [super initWithURL:newURL];
    if(self) {
        [self addRequestHeader:@"Charset" value:@"UTF-8"];
        [self addRequestHeader:@"Accept-Encoding" value:@"gzip"];
        [self setUserAgentString:@"iphone"];
        self.timeOutSeconds = 30;
    }
    return self;
}
@end
