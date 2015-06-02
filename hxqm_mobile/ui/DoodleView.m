//
//  DoodleView.m
//  hxqm_mobile
//
//  Created by HelloWorld on 3/7/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "DoodleView.h"
#import "LogUtils.h"
#import "MyScrollView.h"

#define TAG @"_DoodleView"

@implementation DoodleView {
    BOOL allline;
}

- (id)initWithFrame:(CGRect)frame {
    NSLog(@"DoodleView initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    
    return self;
}

#pragma mark -
// 手指开始触屏开始
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"%@", NSStringFromSelector(_cmd)]];
    NSUInteger touchesNum = [touches count];
    if (touchesNum > 1) {
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"touchesBegan, touchesNum = %ld, nextResponder", touchesNum]];
        [self.nextResponder touchesBegan:touches withEvent:event];
    } else {
        [((MyScrollView *) ([[self superview] superview])) setScrollEnabled:NO];
//        [self showTouchesLog:touches withEvent:event];
        
        UITouch *touch = [touches anyObject];
        MyBeganPoint = [touch locationInView:self];
//        NSLog(@"Segment = %d", Segment);
//        NSLog(@"SegmentWidth = %d", SegmentWidth);
//        NSLog(@"MyBeganpoint = %@", NSStringFromCGPoint(MyBeganPoint));
        [self introductionPoint4:Segment];
        [self introductionPoint5:SegmentWidth];
        [self introductionPoint1];
        [self introductionPoint3:MyBeganPoint];
    }
}
// 手指移动时候发出
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"%@", NSStringFromSelector(_cmd)]];
    NSUInteger touchesNum = [touches count];
    if (touchesNum > 1) {
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"touchesMoved, touchesNum = %ld, nextResponder", touchesNum]];
        [self.nextResponder touchesMoved:touches withEvent:event];
    } else {
//        [self showTouchesLog:touches withEvent:event];
        
        NSArray *MovePointArray = [touches allObjects];
        MyMovePoint = [[MovePointArray objectAtIndex:0] locationInView:self];
        [self introductionPoint3:MyMovePoint];
        [self setNeedsDisplay];
    }
}
// 当手指离开屏幕时候
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"%@", NSStringFromSelector(_cmd)]];
    [((MyScrollView *) ([[self superview] superview])) setScrollEnabled:YES];
    NSUInteger touchesNum = [touches count];
    if (touchesNum > 1) {
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"touchesEnded, touchesNum = %ld, nextResponder", touchesNum]];
        [self.nextResponder touchesEnded:touches withEvent:event];
    } else {
//        [self showTouchesLog:touches withEvent:event];
        
        [self introductionPoint2];
        [self setNeedsDisplay];
    }
}

- (void)showTouchesLog:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger tapsNum = [[touches anyObject] tapCount];
    NSUInteger touchesNum = [touches count];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"tapsNum = %ld, touchesNum = %ld", tapsNum, touchesNum]];
}

//电话呼入等事件取消时候发出
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark -
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect  {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"myAllLines.count = %ld, myClearLines.count = %ld", myAllLines.count, myClearLines.count]];
    if ([_delegate respondsToSelector:@selector(currentDrawLinesCount:clearLinesCount:)]) {
        [_delegate currentDrawLinesCount:myAllLines.count clearLinesCount:myClearLines.count];
    }
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置笔帽
    CGContextSetLineCap(context, kCGLineCapRound);
    // 设置画线的连接处，拐点圆滑
    CGContextSetLineJoin(context, kCGLineJoinRound);
    // 初始化数组
    if (!allline) {
        myAllLines = [[NSMutableArray alloc] initWithCapacity:10];
        myAllColors = [[NSMutableArray alloc] initWithCapacity:10];
        myAllWidths = [[NSMutableArray alloc] initWithCapacity:10];
        
        myClearLines = [[NSMutableArray alloc] initWithCapacity:10];
        myClearColors = [[NSMutableArray alloc] initWithCapacity:10];
        myClearWidths = [[NSMutableArray alloc] initWithCapacity:10];
        
        allline = YES;
    }
    // 画之前线
    if ([myAllLines count] > 0) {
        for (int i = 0; i < [myAllLines count]; i++) {
            NSArray *tempArray = [NSArray arrayWithArray:[myAllLines objectAtIndex:i]];
            if ([myAllColors count] > 0){
                intSegmentColor = [[myAllColors objectAtIndex:i] intValue];
                intSegmentWidth = [[myAllWidths objectAtIndex:i] floatValue] + 1;
            }
            if ([tempArray count] > 1) {
                CGContextBeginPath(context);
                CGPoint myStartPoint = [[tempArray objectAtIndex:0] CGPointValue];
                CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                
                for (int j = 0; j < [tempArray count] - 1; j++) {
                    CGPoint myEndPoint = [[tempArray objectAtIndex:j + 1] CGPointValue];
                    CGContextAddLineToPoint(context, myEndPoint.x, myEndPoint.y);
                }
                [self IntsegmentColor];
                CGContextSetStrokeColorWithColor(context, segmentColor);
                CGContextSetLineWidth(context, intSegmentWidth);
                CGContextStrokePath(context);
            }
        }
    }
    // 画当前的线
    if ([myAllPoints count] > 1) {
        CGContextBeginPath(context);
        // 起点
        CGPoint myStartPoint = [[myAllPoints objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
        // 把move的点全部加入数组
        for (int i = 0; i < [myAllPoints count] - 1; i++) {
            CGPoint myEndPoint = [[myAllPoints objectAtIndex:i + 1] CGPointValue];
            CGContextAddLineToPoint(context, myEndPoint.x, myEndPoint.y);
        }
        // 在颜色和画笔大小数组里面取不相应的值
        intSegmentColor = [[myAllColors lastObject] intValue];
        intSegmentWidth = [[myAllWidths lastObject] floatValue] + 1;
        
        // 绘制画笔颜色
        [self IntsegmentColor];
        CGContextSetStrokeColorWithColor(context, segmentColor);
        CGContextSetFillColorWithColor(context, segmentColor);
        // 绘制画笔宽度
        CGContextSetLineWidth(context, intSegmentWidth);
        // 把数组里面的点全部画出来
        CGContextStrokePath(context);
    }
}

// 初始化
-(void)introductionPoint1 {
    NSLog(@"in init allPoint");
    myAllPoints = [[NSMutableArray alloc] initWithCapacity:10];
    myClearPoints = [[NSMutableArray alloc] initWithCapacity:10];
}

// 把画过的当前线放入　存放线的数组
-(void)introductionPoint2 {
    [myAllLines addObject:myAllPoints];
}

// 将当前画的点加入到数组
-(void)introductionPoint3:(CGPoint)sender {
    NSValue *pointvalue = [NSValue valueWithCGPoint:sender];
    [myAllPoints addObject:pointvalue];
}

// 接收颜色segement反过来的值
-(void)introductionPoint4:(int)sender {
    NSLog(@"Palette sender:%i", sender);
    NSNumber *Numbersender = [NSNumber numberWithInt:sender];
    [myAllColors addObject:Numbersender];
}

// 接收线条宽度按钮反回来的值
-(void)introductionPoint5:(int)sender {
    NSLog(@"Palette sender:%i", sender);
    NSNumber *Numbersender = [NSNumber numberWithInt:sender];
    [myAllWidths addObject:Numbersender];
}

// 清屏
-(void)clearAllLines {
    if ([myAllLines count] > 0) {
        [myAllLines removeAllObjects];
        [myAllColors removeAllObjects];
        [myAllWidths removeAllObjects];
        [myAllPoints removeAllObjects];
        
        [myClearLines  removeAllObjects];
        [myClearColors removeAllObjects];
        [myClearWidths removeAllObjects];
        [myClearPoints removeAllObjects];
        
        myAllLines = [[NSMutableArray alloc] initWithCapacity:10];
        myAllColors = [[NSMutableArray alloc] initWithCapacity:10];
        myAllWidths = [[NSMutableArray alloc] initWithCapacity:10];
        
        myClearLines = [[NSMutableArray alloc] initWithCapacity:10];
        myClearColors = [[NSMutableArray alloc] initWithCapacity:10];
        myClearWidths = [[NSMutableArray alloc] initWithCapacity:10];
        
        [self setNeedsDisplay];
    }
}

// 撤销
-(void)undo {
    NSInteger allLines = [myAllLines count];
    NSLog(@"[myAllLines count] = %ld", allLines);
    if (allLines > 0) {
        NSLog(@"------------undo");
        NSArray *undoArray = [NSArray arrayWithArray:[myAllLines lastObject]];
        [myClearLines addObject:undoArray];
        [myClearColors addObject:[myAllColors lastObject]];
        [myClearWidths addObject:[myAllWidths lastObject]];
        [myClearPoints removeAllObjects];
        [myClearPoints addObjectsFromArray:myAllPoints];
        
        [myAllLines  removeLastObject];
        [myAllColors removeLastObject];
        [myAllWidths removeLastObject];
        [myAllPoints removeAllObjects];
    }
    NSLog(@"[myAllLines count] = %ld", [myAllLines count]);
    [self setNeedsDisplay];
}

- (void)redo {
    NSInteger clearLines = [myClearLines count];
    NSLog(@"[myClearLines count] = %ld", clearLines);
    if (clearLines > 0) {
        NSLog(@"------------redo");
        NSArray *redoArray = [NSArray arrayWithArray:[myClearLines lastObject]];
        [myAllLines addObject:redoArray];
        [myAllColors addObject:[myClearColors lastObject]];
        [myAllWidths addObject:[myClearWidths lastObject]];
        [myAllPoints removeAllObjects];
        [myAllPoints addObjectsFromArray:myClearPoints];
        
        [myClearLines  removeLastObject];
        [myClearColors removeLastObject];
        [myClearWidths removeLastObject];
        [myClearPoints removeAllObjects];
    }
    NSLog(@"[myClearLines count] = %ld", [myClearLines count]);
    [self setNeedsDisplay];
}

-(void)IntsegmentColor {
    switch (intSegmentColor) {
        case 0:
            segmentColor = [[UIColor greenColor] CGColor];
            break;
        case 1:
            segmentColor = [[UIColor redColor] CGColor];
            break;
        case 2:
            segmentColor = [[UIColor blueColor] CGColor];
            break;
        case 3:
            segmentColor = [[UIColor blackColor] CGColor];
            break;
        case 4:
            segmentColor = [[UIColor yellowColor] CGColor];
            break;
        case 5:
            segmentColor = [[UIColor orangeColor] CGColor];
            break;
        case 6:
            segmentColor = [[UIColor grayColor] CGColor];
            break;
        case 7:
            segmentColor = [[UIColor purpleColor] CGColor];
            break;
        case 8:
            segmentColor = [[UIColor brownColor] CGColor];
            break;
        case 9:
            segmentColor = [[UIColor magentaColor] CGColor];
            break;
        case 10:
            segmentColor = [[UIColor whiteColor] CGColor];
            break;
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
