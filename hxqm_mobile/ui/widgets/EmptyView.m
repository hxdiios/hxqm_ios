//
//  EmptyView.m
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "EmptyView.h"

@implementation EmptyView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"empty" owner:self options:nil];
        for(NSObject *obj in objects) {
            if([obj isKindOfClass:[EmptyView class]]) {
                self = (EmptyView *) obj;
                break;
            }
        }
        self.frame = frame;
        [_netErr addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

//显示无结果
- (void) showEmpty {
    _empty.hidden = NO;
    _netErr.hidden = YES;
    _loading.hidden = YES;
}

- (void) showLoading {
    _loading.hidden = NO;
    _empty.hidden = YES;
    _netErr.hidden = YES;
}

//显示网络异常
- (void) showNetErr {
    _netErr.hidden = NO;
    _loading.hidden = YES;
    _empty.hidden = YES;
}

//从父控件中移除
- (void) dismiss {
    if(self.superview) {
        [self removeFromSuperview];
    }
}

- (void)reload {
    [_delegate refresh:self];
}

@end
