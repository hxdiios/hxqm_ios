//
//  TableInfoViewController.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/27/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseAjaxHttpRequest.h"
#import "BadgeNumManageDelegate.h"

@interface TableInfoViewController : BaseTableViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIActionSheetDelegate> {
    BOOL isInitLoading;
}

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (copy, nonatomic) NSDictionary *projectDict;
@property (copy, nonatomic) NSString *projectID;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *sectionID;

@property (nonatomic,assign) id<BadgeNumManageDelegate> delegate;

- (IBAction)favoriteBtnClick:(id)sender;


@end
