//
//  ToDoListCell.m
//  hxqm_mobile
//
//  Created by HuaXin on 15-5-10.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "ToDoListCell.h"
#import "BaseFunction.h"

@implementation ToDoListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)initViewWithData:(NSDictionary *)data {
    if (data != nil) {
        NSString *item_type = [NSString stringWithFormat:@"%@", [data objectForKey:@"item_type"]];
        NSString *deal_type = [BaseFunction safeGetValueByKey:data Key:@"deal"];
        NSString *item_type_name = @"整改";
        if([@"4" isEqualToString:item_type]&&[@"2" isEqualToString:deal_type]){
            item_type_name = @"整改草稿";
        }else if([item_type isEqualToString:@"3"]){
            _problem_item.hidden = YES;
            item_type_name = @"检查";
        }else{
            item_type_name = @"整改";
        }
        _majorName.text = [data objectForKey:@"major_name"];
        _projectName.text = [NSString stringWithFormat:@"【%@】%@", item_type_name,[data objectForKey:@"project_name"]];
        _problem_item.text = [data objectForKey:@"problem_item_name"];
        _createUserName.text = [NSString stringWithFormat:@"发起人:%@",[data objectForKey:@"create_user_name"]];
        //格式化开始日期和结束日期
        NSString *start_time = [data objectForKey:@"start_time"];
        NSString *limit_time = [data objectForKey:@"limit_time"];
        _start_date.text = [NSString stringWithFormat:@"开始:%@", [BaseFunction getFormatDateString:start_time format_input:@"yyyy-MM-dd HH:mm:ss" format_output:@"MM-dd"]];
        _limit_date.text = [NSString stringWithFormat:@"截止:%@",[BaseFunction getFormatDateString:limit_time format_input:@"yyyy-MM-dd HH:mm:ss" format_output:@"MM-dd"]];
    } else {
        NSLog(@"data is nil");
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
