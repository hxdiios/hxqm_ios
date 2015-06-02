//
//  ProjsViewController.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "BaseTableViewController.h"
#import "MyMacros.h"
#import "BaseAjaxHttpRequest.h"
#import "GroupMenu.h"

@protocol ProjectIdDelegate <NSObject>
@required
-(void)getProjectId:(NSString *) projectId;
@end

@interface ProjsViewController : BaseTableViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, GroupMenuDelegate,ProjectIdDelegate> {
    // 原始数据
    NSMutableArray *data;
    // 保存排好序的列表数据，按照排序类型分组
    NSMutableDictionary *groupedData;
    BOOL isInitLoading;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *currentDept;
@property (weak, nonatomic) IBOutlet UIView *currentMajorView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *chooseFlag;
@property id<ProjectIdDelegate> projectDelegate;
@end
