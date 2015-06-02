//
//  BaseTableViewController.m
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isListeningScrolling = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setIsListeningScrolling:(BOOL)isListening {
    isListeningScrolling = isListening;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (isListeningScrolling) {
        [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
        [self refreshFooterView:scrollView height:1];
        [refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerat{
    if (isListeningScrolling) {
        [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
        [refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	isLoading = YES;
    [self reqData];
}

- (void)doneLoadingTableView:(UIScrollView *)scroll height:(float)height{
	//  model should call this when its done loading
	isLoading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:scroll];
    [self refreshFooterView:scroll height:height];
}

//重新加载列表page = 1
- (void)reloadData{
    page = 1;
    [self reloadTableViewDataSource];
}

- (void)reqData {
    //reqData要完成数据获取 page++
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark -
#pragma mark EGORefreshTableFooterDelegate Methods

- (void)egoRefreshTableFooterDidTriggerRefresh:(EGORefreshTableFooterView*)view{
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableFooterDataSourceIsLoading:(EGORefreshTableFooterView*)view{
	return isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableFooterDataSourceLastUpdated:(EGORefreshTableFooterView*)view{
	return [NSDate date]; // should return date data source was last changed
}

//- (NSString *)egoRefreshTableFooterDataSourceSubTitle:(EGORefreshTableFooterView *)view {
//    return [NSString stringWithFormat:@"%d/%d",loadedNumber,totalNumber];
//}

- (void)refreshFooterView:(UIScrollView *)scroll height:(float)height
{
    isLoading = NO;
    if (refreshFooterView == nil)
        return;
    
    //refreshFooterView
    if (scroll.contentSize.height > height) {
        height = scroll.contentSize.height;
    }else{
        scroll.contentSize = CGSizeMake(scroll.frame.size.width, height);
    }
    
    refreshFooterView.frame = CGRectMake(0, height, scroll.frame.size.width, 400);
    
    //页面刷新完毕调用此方法
    [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:scroll];
}

#pragma mark EmptyViewDelegate
- (void)refresh{
    page = 1;
    [self reqData];
}

- (void)initEmptyViewWithFrame:(CGRect)frame {
    emptyView = [[EmptyView alloc] initWithFrame:frame];
    emptyView.delegate = self;
}

@end
