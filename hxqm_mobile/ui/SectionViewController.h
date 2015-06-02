//
//  SectionViewController.h
//  hxqm_mobile
//
//  Created by HelloWorld on 2/3/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseAjaxHttpRequest.h"

@interface SectionViewController : BaseTableViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (copy, nonatomic) NSDictionary *projectDict;
@property (copy, nonatomic) NSString *projectID;
@property (copy, nonatomic) NSString *type;

@end
