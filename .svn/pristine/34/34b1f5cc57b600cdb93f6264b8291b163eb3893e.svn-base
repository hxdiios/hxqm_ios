//
//  ListHeadView.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/27/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ListHeadView.h"
#import "MajorCell.h"
#import "MyMacros.h"

@interface ListHeadView() {
    BOOL isOpened;
}
@end

@implementation ListHeadView

+ (instancetype)headViewWithTableView:(UITableView *)tableView data:(NSMutableDictionary *)data {
    static NSString *headIdentifier = @"major_cell";
    
    ListHeadView *headView = [tableView dequeueReusableCellWithIdentifier:headIdentifier];
    if (headView == nil) {
        NSLog(@"headView is nil");
        headView = [[ListHeadView alloc] initWithReuseIdentifier:headIdentifier data:data];
    }
    
    return headView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier data:(NSMutableDictionary *)data {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MajorCell" owner:nil options:nil];
        MajorCell *header = [nib lastObject];
        CGRect oldFrame = header.frame;
        header.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, UI_SCREEN_WIDTH, oldFrame.size.height);
        NSString *majorName = [[data objectForKey:@"major_dictionary"] objectForKey:@"BO_DICT_NAME"];
        header.majorName.text = majorName;
        // 随机生成颜色
        CGFloat red = arc4random_uniform(256) / 255.0;
        CGFloat green = arc4random_uniform(256) / 255.0;
        CGFloat blue = arc4random_uniform(256) / 255.0;
//        NSLog(@"red = %f, green = %f, blue = %f", red, green, blue);
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        header.leftColorView.backgroundColor = color;
        UIImage *expand = [UIImage imageNamed:@"icon_expand"];
        UIImage *contract = [UIImage imageNamed:@"icon_contract"];
        NSString *openedString = [data objectForKey:@"isOpened"];
        BOOL isOpen = [openedString isEqualToString:@"YES"];
        header.rightImg.image = isOpen ? contract : expand;
        NSArray *projectList = [data objectForKey:@"project_list"];
        if (projectList.count <= 0) {
            header.rightImg.hidden = YES;
        } else {
            header.rightImg.hidden = NO;
        }
        [header.headerBtn addTarget:self action:@selector(headBtnClick) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:header];
    }
    
    return self;
}

/**
 *  背景按钮点击方法
 */
- (void)headBtnClick {
    NSString *openedString = [_datas objectForKey:@"isOpened"];
    isOpened = [openedString isEqualToString:@"YES"];
    NSString *open = isOpened ? @"NO" : @"YES";
    [_datas setObject:open forKey:@"isOpened"];
    
    if ([_delegate respondsToSelector:@selector(clickHeadView)]) {
        [_delegate clickHeadView];
    }
}

- (void)setDatas:(NSMutableDictionary *)data {
    _datas = data;
}

- (void)didMoveToSuperview {
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
