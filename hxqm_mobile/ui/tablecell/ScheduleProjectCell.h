//
//  ScheduleProjectCell.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/19/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleProjectCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UILabel *missionCount;
@property (weak, nonatomic) IBOutlet UILabel *checkAndRectification;

- (void)initViewWithData:(NSDictionary *)data;

@end
