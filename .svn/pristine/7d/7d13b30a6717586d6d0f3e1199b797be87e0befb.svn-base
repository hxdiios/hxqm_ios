//
//  ScheduleViewController.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseAjaxHttpRequest.h"
#import "BadgeNumManageDelegate.h"

@interface ScheduleViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate,BadgeNumManageDelegate> {
    NSMutableArray *taskList;
    BOOL isInitLoading;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *lastLocationTimeLabel;

@property (copy, nonatomic) NSString *needBack;

@end
