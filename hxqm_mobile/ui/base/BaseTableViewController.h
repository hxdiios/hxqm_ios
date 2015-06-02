//
//  BaseTableViewController.h
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "BaseViewController.h"
#import "EGORefreshTableFooterView.h"
#import "EGORefreshTableHeaderView.h"
#import "EmptyView.h"

@interface BaseTableViewController : BaseViewController<EGORefreshTableFooterDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate, Refresh>{
    
    EGORefreshTableHeaderView *refreshHeaderView;
    EGORefreshTableFooterView *refreshFooterView;
    BOOL isLoading;
    int page;
    BOOL isListeningScrolling;
    
    int totalNumber;
    int loadedNumber;
    
    EmptyView *emptyView;
}

- (void)reqData;
- (void)doneLoadingTableView:(UIScrollView *)scroll height:(float)height;
- (void)refreshFooterView:(UIScrollView *)scroll height:(float)height;
//重新加载列表page = 1
- (void)reloadData;
- (void)initEmptyViewWithFrame:(CGRect)frame;
- (void)setIsListeningScrolling:(BOOL)isListeningScrolling;

@end
