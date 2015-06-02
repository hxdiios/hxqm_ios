//
//  MyFavoriteViewController.h
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/28.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "BaseTableViewController.h"

@interface MyFavoriteViewController : BaseTableViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myFavTable;
@end
