//
//  ToDoListViewController.h
//  hxqm_mobile
//
//  Created by HuaXin on 15-5-10.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//
#import "BaseTableViewController.h"
#import "BaseAjaxHttpRequest.h"
#import "BadgeNumManageDelegate.h"
#import "PulldownMenu.h"

@interface ToDoListViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate,BadgeNumManageDelegate,PulldownMenuDelegate> {
    NSMutableArray *taskList;
    BOOL isInitLoading;
    PulldownMenu *pulldownMenu;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, retain) PulldownMenu *pulldownMenu;

@end

