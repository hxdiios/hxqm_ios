//
//  EGORefreshTableHeaderView.h
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGORefreshTableHeaderView.h"

//typedef enum{
//	EGOOPullRefreshPulling = 0,
//	EGOOPullRefreshNormal,
//	EGOOPullRefreshLoading,	
//} EGOPullRefreshState;

@protocol EGORefreshTableFooterDelegate;
@interface EGORefreshTableFooterView : UIView {
	
    id _delegate;
	EGOPullRefreshState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	

}

@property(nonatomic, retain)  id<EGORefreshTableFooterDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *) textColor arrowImage:(UIImage *) arrowImage;
@end
@protocol EGORefreshTableFooterDelegate
- (void)egoRefreshTableFooterDidTriggerRefresh:(EGORefreshTableFooterView*)view;
- (BOOL)egoRefreshTableFooterDataSourceIsLoading:(EGORefreshTableFooterView*)view;
@optional
- (NSDate*)egoRefreshTableFooterDataSourceLastUpdated:(EGORefreshTableFooterView*)view;
- (NSString*)egoRefreshTableFooterDataSourceSubTitle:(EGORefreshTableFooterView*)view;
@end
