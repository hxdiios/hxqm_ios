//
//  ListHeadView.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/27/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeadViewDelegate <NSObject>

@optional
- (void)clickHeadView;

@end

@interface ListHeadView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSMutableDictionary *datas;

@property (nonatomic, weak) id<HeadViewDelegate> delegate;

+ (instancetype)headViewWithTableView:(UITableView *)tableView data:(NSMutableDictionary *)data;

@end
