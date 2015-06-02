//
//  SectionCell.m
//  hxqm_mobile
//
//  Created by HelloWorld on 2/3/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "SectionCell.h"
#import "MyMacros.h"

@implementation SectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)initViewWithData:(NSDictionary *)data type:(NSString *)type {
    if (data != nil) {
        if ([type isEqualToString:@"type_section"]) {// 分段界面Cell
            _titleLabel.text = [data objectForKey:@"section_name"];
            _leftLabel.text = [NSString stringWithFormat:@"已拍/应拍：%@", [data objectForKey:@"section_upload_amount"]];
            _rightLabel.hidden = YES;
        } else if ([type isEqualToString:@"type_table_info"]) {// 关键控制点界面Cell
            NSString *type = [data objectForKey:@"content_type"];
            _titleLabel.text = [data objectForKey:@"bo_content_name"];
            _rightLabel.hidden = NO;
            
            // 判断类别，设置cell样式
            if ([@"1" isEqualToString:type]) {// 巡检记录
                _leftLabel.text = [NSString stringWithFormat:@"已拍/应拍：%@/%@", [data objectForKey:@"bo_current_num"], [data objectForKey:@"bo_total_num"]];
                NSString *cur_num = [data objectForKey:@"cur_num"];
                if (IsStringEmpty(cur_num) || [@"(null)" isEqualToString:cur_num]) {
                    cur_num = @"0";
                }
                
                _rightLabel.text = [NSString stringWithFormat:@"巡检进度：%@/%@", cur_num, [data objectForKey:@"bo_total_num"]];
            } else if ([@"2" isEqualToString:type]) {// 问题检查
                NSString *limitTime = [data objectForKey:@"limit_time"];
                if (IsStringEmpty(limitTime) || [@"(null)" isEqualToString:limitTime]) {
                    limitTime = @"";
                }
                _leftLabel.text = [NSString stringWithFormat:@"截止时间：%@", limitTime];
                NSString *totalNum = [data objectForKey:@"bo_total_num"];
                _rightLabel.text = [NSString stringWithFormat:@"%@", [@"-1" isEqualToString:totalNum] ? @"已完成" : @"未完成"];
            } else if ([@"3" isEqualToString:type]) {// 整改记录
                NSString *mendTimeLimit = [data objectForKey:@"mend_time_limit"];
                if (IsStringEmpty(mendTimeLimit) || [@"(null)" isEqualToString:mendTimeLimit]) {
                    mendTimeLimit = @"";
                }
                _leftLabel.text = [NSString stringWithFormat:@"截止时间：%@", mendTimeLimit];
                NSString *statusNum = [data objectForKey:@"status"];
                NSString *status = @"";
                if ([@"(null)" isEqualToString:statusNum]) {
                    // 为空值
                }else if ([@"1" isEqualToString:statusNum] || [@"2" isEqualToString:statusNum] || [@"6" isEqualToString:statusNum]) {
                    status = @"待审核";
                } else if ([@"3" isEqualToString:statusNum] || [@"7" isEqualToString:statusNum] || [@"10" isEqualToString:statusNum] || [@"13" isEqualToString:statusNum]) {
                    status = @"待处理";
                } else if ([@"4" isEqualToString:statusNum] || [@"8" isEqualToString:statusNum] || [@"11" isEqualToString:statusNum] || [@"14" isEqualToString:statusNum]) {
                    status = @"待确认";
                }
                _rightLabel.text = [NSString stringWithFormat:@"%@", status];
            } else if ([@"-1" isEqualToString:type]) {// 整改草稿
                NSString *createDate = [data objectForKey:@"create_date"];
                if (IsStringEmpty(createDate) || [@"(null)" isEqualToString:createDate]) {
                    createDate = @"";
                }
                _leftLabel.text = [NSString stringWithFormat:@"创建时间：%@", createDate];
                _rightLabel.text = @"草稿";
            }
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
