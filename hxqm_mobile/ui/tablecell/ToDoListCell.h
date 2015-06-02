//
//  ToDoListCell.h
//  hxqm_mobile
//
//  Created by HuaXin on 15-5-10.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToDoListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *majorName;
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UILabel *problem_item;
@property (weak, nonatomic) IBOutlet UILabel *start_date;
@property (weak, nonatomic) IBOutlet UILabel *limit_date;
@property (weak, nonatomic) IBOutlet UILabel *createUserName;

- (void)initViewWithData:(NSDictionary *)data;

@end
