//
//  MyScrollView.m
//  hxqm_mobile
//
//  Created by HelloWorld on 3/7/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "MyScrollView.h"
#import "LogUtils.h"

#define TAG @"_MyScrollView"

@implementation MyScrollView

#pragma mark -
//手指开始触屏开始
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}
//手指移动时候发出
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}
//当手指离开屏幕时候
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)showTouchesLog:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger tapsNum = [[touches anyObject] tapCount];
    NSUInteger touchesNum = [touches count];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"tapsNum = %ld, touchesNum = %ld", tapsNum, touchesNum]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
