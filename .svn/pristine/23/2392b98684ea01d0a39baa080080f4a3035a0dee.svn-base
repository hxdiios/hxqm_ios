//
//  LoadingProgress.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/23.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "LoadingProgress.h"

@implementation LoadingProgress

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LoadingProgress" owner:self options:nil];
        for(NSObject *obj in objects) {
            if([obj isKindOfClass:[LoadingProgress class]]) {
                self = (LoadingProgress *) obj;
                break;
            }
        }
        self.frame = frame;
    }
    return  self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) showState:(int)state {
    if(state == DOWNLOADING) {
        //下载状态
        _progressBar.hidden = YES;
        _detailPercent.hidden = YES;
        _percent.hidden = YES;
        _downloadingProcess.hidden = NO;
        _label.text = @"已下载0k";
    } else {
        //数据插入状态
        _progressBar.hidden = NO;
        _detailPercent.hidden = NO;
        _percent.hidden = NO;
        _downloadingProcess.hidden = YES;
        _label.text = @"载入数据进度";
    }
}

@end
