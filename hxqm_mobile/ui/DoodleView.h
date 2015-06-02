//
//  DoodleView.h
//  hxqm_mobile
//
//  Created by HelloWorld on 3/7/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol DoodleViewDelegate <NSObject>

- (void)currentDrawLinesCount:(NSInteger)drawLinesCount clearLinesCount:(NSInteger)clearLinesCount;

@end

@interface DoodleView : UIView {
    CGPoint MyBeganPoint;
    CGPoint MyMovePoint;
    int Segment;
    int SegmentWidth;
    
    float x;
    float y;

    int intSegmentColor;
    float intSegmentWidth;
    CGColorRef segmentColor;

    NSMutableArray *myAllPoints;
    // 保存所有画的线
    NSMutableArray *myAllLines;
    NSMutableArray *myAllColors;
    NSMutableArray *myAllWidths;
    // 保存清除的线
    NSMutableArray *myClearLines;
    NSMutableArray *myClearColors;
    NSMutableArray *myClearWidths;
    NSMutableArray *myClearPoints;
}

@property id<DoodleViewDelegate> delegate;

/**
 *  初始化数据
 */
-(void)introductionPoint1;

/**
 *  把画过的当前线放入　存放线的数组
 */
-(void)introductionPoint2;

/**
 *  将当前画的点加入到数组
 *
 *  @param sender 当前的点
 */
-(void)introductionPoint3:(CGPoint)sender;

/**
 *  接收颜色segement反过来的值
 */
-(void)introductionPoint4:(int)sender;

/**
 *  接收线条宽度按钮反回来的值
 */
-(void)introductionPoint5:(int)sender;

/**
 *  清屏
 */
-(void)clearAllLines;

/**
 *  撤销
 */
-(void)undo;

/**
 *  重做
 */
- (void)redo;

@end
