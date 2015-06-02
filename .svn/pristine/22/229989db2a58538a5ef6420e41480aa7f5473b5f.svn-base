//
//  MajorProjectListView.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/27/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListHeadView.h"

@protocol ProjectSelectDelegate <NSObject>

@optional
- (void)projectSelectAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MajorProjectListView : UIView <UITableViewDataSource, UITableViewDelegate, HeadViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id<ProjectSelectDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)setDatas:(NSArray *)data;

@end
