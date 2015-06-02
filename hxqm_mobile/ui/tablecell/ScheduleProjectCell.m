//
//  ScheduleProjectCell.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/19/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ScheduleProjectCell.h"

@implementation ScheduleProjectCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)initViewWithData:(NSDictionary *)data {
    if (data != nil) {
        _projectName.text = [data objectForKey:@"project_name"];
        _missionCount.text = [NSString stringWithFormat:@"任务数：%d", [NSString stringWithFormat:@"%@", [data objectForKey:@"counts"]].intValue];
        
        NSString *checkTimeString = [NSString stringWithFormat:@"%@", [data objectForKey:@"num_xj"]];
        NSString *checkCountString = [NSString stringWithFormat:@"%@", [data objectForKey:@"num_all"]];
        int rectification = [NSString stringWithFormat:@"%@", [data objectForKey:@"num_zg"]].intValue;
        int checkTime = [checkTimeString isEqualToString:@"(null)"] ? 0 : checkTimeString.intValue;
        int checkCount = [checkCountString isEqualToString:@"(null)"] ? 0 : checkCountString.intValue;
        if (rectification == 0 && checkCount == 0) {
            _checkAndRectification.text = [NSString stringWithFormat:@"未查看"];
        } else {
            _checkAndRectification.text = [NSString stringWithFormat:@"检查：%d/%d　整改：%d", checkTime, checkCount, rectification];
        }
    } else {
        NSLog(@"data is nil");
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
