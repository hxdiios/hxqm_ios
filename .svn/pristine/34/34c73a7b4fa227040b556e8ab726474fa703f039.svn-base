//
//  ViewController.m
//  navigation
//
//  Created by huaxin_mac2 on 15/4/10.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "LinearLayoutViewTest.h"
#import "CSLinearLayoutView.h"

@interface LinearLayoutViewTest ()

@end

@implementation LinearLayoutViewTest

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createView];
    [self initLinearLayoutView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initLinearLayoutView {
    //
    CSLinearLayoutView * linearLayoutView = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(10, 30, [[UIScreen mainScreen] bounds].size.width, 220)];
    linearLayoutView.orientation = CSLinearLayoutViewOrientationHorizontal;
    [self.view addSubview:linearLayoutView];
    CSLinearLayoutView * linearLayoutView1 = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(10, 240, [[UIScreen mainScreen] bounds].size.width, 220)];
    linearLayoutView1.orientation = CSLinearLayoutViewOrientationHorizontal;
    [self.view addSubview:linearLayoutView1];
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"我的工程",@"同步更新",@"出工计划",@"待办任务", nil];
    NSArray *numArray = [[NSArray alloc]initWithObjects:@"在建项目:2901",@"未上传图片:(0)",@"出工计划:(0)",@"待办任务:(0)", nil];
    for (int i=0; i<4; i++) {
        if(i < 2){
            UIView * itemView = [self createItemView:titleArray[i] viewNum:numArray[i]];
            //
            CSLinearLayoutItem *linearLayerItem = [CSLinearLayoutItem layoutItemForView:itemView];
            linearLayerItem.padding = CSLinearLayoutMakePadding(10, 5, 5, 5);
            linearLayerItem.horizontalAlignment = CSLinearLayoutItemVerticalAlignmentCenter;
            linearLayerItem.fillMode = CSLinearLayoutItemFillModeNormal;
            [linearLayoutView addItem: linearLayerItem];
        }else{
            UIView * itemView1 = [self createItemView:titleArray[i] viewNum:numArray[i]];
            //
            CSLinearLayoutItem *linearLayerItem1 = [CSLinearLayoutItem layoutItemForView:itemView1];
            linearLayerItem1.padding = CSLinearLayoutMakePadding(10, 5, 5, 5);
            linearLayerItem1.horizontalAlignment = CSLinearLayoutItemVerticalAlignmentCenter;
            linearLayerItem1.fillMode = CSLinearLayoutItemFillModeNormal;
            [linearLayoutView1 addItem: linearLayerItem1];
        }
        
    }
   
    
}

- (UIView *)createItemView:(NSString *)title viewNum:(NSString *)num{
    NSArray *picArray = [[NSArray alloc] initWithObjects:@"hammerit.png",@"sunc_disk.png",@"image_capture.png",@"spellcheck.png", nil];
    NSString *picPath = @"";
    if ([title isEqualToString:@"我的工程"]) {
        picPath = picArray[0];
    } else if ([title isEqualToString:@"同步更新"]) {
        picPath = picArray[1];
    } else if ([title isEqualToString:@"出工计划"]) {
        picPath = picArray[2];
    } else if ([title isEqualToString:@"待办任务"]) {
        picPath = picArray[3];
    } else {
        picPath = nil;
    }
    if (picPath == nil) {
        return nil;
    }
    //我的工程navigation
    [self.view setBackgroundColor:[UIColor colorWithRed:70/255.0 green:130/255.0 blue:180/255.0 alpha:1]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 170, 180)];
    [bgView.layer setCornerRadius:5];
    [bgView.layer setBorderWidth:1];
    [bgView.layer setBorderColor:[UIColor colorWithRed:53/255.0 green:83/255.0 blue:153/255.0 alpha:1].CGColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = bgView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:66/255.0 green:97/255.0 blue:185/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:80/255.0 green:109/255.0 blue:189/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:93/255.0 green:119/255.0 blue:193/255.0 alpha:1].CGColor, nil];
    [bgView.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:bgView];
    
    UIImage *prjImage = [UIImage imageNamed:picPath];
    UIImageView *prjImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [prjImageView setImage:prjImage];
    [prjImageView.layer setCornerRadius:5];
    [prjImageView.layer setBorderWidth:1];
    [prjImageView.layer setBorderColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1].CGColor];
    [prjImageView setBackgroundColor:[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1]];
    [bgView addSubview:prjImageView];
    [prjImageView setCenter:CGPointMake(bgView.center.x, bgView.center.y - 30)];
    UILabel *prjTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    prjTitle.text = title;
    prjTitle.textColor = [UIColor whiteColor];
    prjTitle.font = [UIFont systemFontOfSize:18];
    UILabel *prjNum = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    [prjNum setFont:[UIFont fontWithName:@"Helvetice" size:13.0]];
    prjNum.text = num;
    prjNum.textColor = [UIColor whiteColor];
    prjNum.font = [UIFont systemFontOfSize:13];
    [prjTitle sizeToFit];
    [prjNum sizeToFit];
    [bgView addSubview:prjTitle];
    [bgView addSubview:prjNum];
    [prjTitle setCenter:CGPointMake(bgView.center.x, bgView.center.y +45)];
    [prjNum setCenter:CGPointMake(bgView.center.x, bgView.center.y +70)];
//    [bgView setCenter:CGPointMake(self.view.center.x/2,self.view.center.y/2)];
    return bgView;
}



- (void)createView {
    NSArray *picArray = [[NSArray alloc] initWithObjects:@"hammerit.png",@"sunc_disk.png",@"image_capture.png",@"spellcheck.png", nil];
    //我的工程navigation
    [self.view setBackgroundColor:[UIColor colorWithRed:70/255.0 green:130/255.0 blue:180/255.0 alpha:1]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 170, 180)];
    [bgView.layer setCornerRadius:5];
    [bgView.layer setBorderWidth:1];
    [bgView.layer setBorderColor:[UIColor colorWithRed:53/255.0 green:83/255.0 blue:153/255.0 alpha:1].CGColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = bgView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:66/255.0 green:97/255.0 blue:185/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:80/255.0 green:109/255.0 blue:189/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:93/255.0 green:119/255.0 blue:193/255.0 alpha:1].CGColor, nil];
    [bgView.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:bgView];
    UIImage *prjImage = [UIImage imageNamed:picArray[0]];
    UIImageView *prjImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [prjImageView setImage:prjImage];
    [prjImageView.layer setCornerRadius:5];
    [prjImageView.layer setBorderWidth:1];
    [prjImageView.layer setBorderColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1].CGColor];
    [prjImageView setBackgroundColor:[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1]];
    [bgView addSubview:prjImageView];
    [prjImageView setCenter:CGPointMake(bgView.center.x, bgView.center.y - 30)];
    UILabel *prjTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    prjTitle.text = @"我的工程";
    prjTitle.textColor = [UIColor whiteColor];
    prjTitle.font = [UIFont systemFontOfSize:18];
    UILabel *prjNum = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    [prjNum setFont:[UIFont fontWithName:@"Helvetice" size:13.0]];
    prjNum.text = @"在建工程:2907";
    prjNum.textColor = [UIColor whiteColor];
    prjNum.font = [UIFont systemFontOfSize:13];
    [prjTitle sizeToFit];
    [prjNum sizeToFit];
    [bgView addSubview:prjTitle];
    [bgView addSubview:prjNum];
    [prjTitle setCenter:CGPointMake(bgView.center.x, bgView.center.y +45)];
    [prjNum setCenter:CGPointMake(bgView.center.x, bgView.center.y +70)];
    [bgView setCenter:CGPointMake(self.view.center.x/2,self.view.center.y/2)];
    //上传照片navigation
    UIView *bgView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 170, 180)];
    [bgView1.layer setCornerRadius:5];
    [bgView1.layer setBorderWidth:1];
    [bgView1.layer setBorderColor:[UIColor colorWithRed:53/255.0 green:83/255.0 blue:153/255.0 alpha:1].CGColor];
    CAGradientLayer *gradient1 = [CAGradientLayer layer];
    gradient1.frame = bgView1.frame;
    gradient1.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:66/255.0 green:97/255.0 blue:185/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:80/255.0 green:109/255.0 blue:189/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:93/255.0 green:119/255.0 blue:193/255.0 alpha:1].CGColor, nil];
    [bgView1.layer insertSublayer:gradient1 atIndex:0];
    [self.view addSubview:bgView1];
    UIImage *prjImage1 = [UIImage imageNamed:@"sunc_disk.png"];
    UIImageView *prjImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [prjImageView1 setImage:prjImage1];
    [prjImageView1.layer setCornerRadius:5];
    [prjImageView1.layer setBorderWidth:1];
    [prjImageView1.layer setBorderColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1].CGColor];
    [prjImageView1 setBackgroundColor:[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1]];
    [bgView1 addSubview:prjImageView1];
    [prjImageView1 setCenter:CGPointMake(bgView1.center.x, bgView1.center.y - 30)];
    UILabel *prjTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    prjTitle1.text = @"同步更新";
    prjTitle1.textColor = [UIColor whiteColor];
    prjTitle1.font = [UIFont systemFontOfSize:18];
    UILabel *prjNum1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    [prjNum1 setFont:[UIFont fontWithName:@"Helvetice" size:13.0]];
    prjNum1.text = @"未上传图片:0";
    prjNum1.textColor = [UIColor whiteColor];
    prjNum1.font = [UIFont systemFontOfSize:13];
    [prjTitle1 sizeToFit];
    [prjNum1 sizeToFit];
    [bgView1 addSubview:prjTitle1];
    [bgView1 addSubview:prjNum1];
    [prjTitle1 setCenter:CGPointMake(bgView1.center.x, bgView1.center.y +45)];
    [prjNum1 setCenter:CGPointMake(bgView1.center.x, bgView1.center.y +70)];
    [bgView1 setCenter:CGPointMake(self.view.center.x/2*3,self.view.center.y/2)];
    //出工计划navigation
    UIView *bgView11 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 170, 180)];
    [bgView11.layer setCornerRadius:5];
    [bgView11.layer setBorderWidth:1];
    [bgView11.layer setBorderColor:[UIColor colorWithRed:53/255.0 green:83/255.0 blue:153/255.0 alpha:1].CGColor];
    CAGradientLayer *gradient11 = [CAGradientLayer layer];
    gradient11.frame = bgView11.frame;
    gradient11.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:66/255.0 green:97/255.0 blue:185/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:80/255.0 green:109/255.0 blue:189/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:93/255.0 green:119/255.0 blue:193/255.0 alpha:1].CGColor, nil];
    [bgView11.layer insertSublayer:gradient11 atIndex:0];
    [self.view addSubview:bgView11];
    UIImage *prjImage11 = [UIImage imageNamed:@"image_capture.png"];
    UIImageView *prjImageView11 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [prjImageView11 setImage:prjImage11];
    [prjImageView11.layer setCornerRadius:5];
    [prjImageView11.layer setBorderWidth:1];
    [prjImageView11.layer setBorderColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1].CGColor];
    [prjImageView11 setBackgroundColor:[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1]];
    [bgView11 addSubview:prjImageView11];
    [prjImageView11 setCenter:CGPointMake(bgView11.center.x, bgView11.center.y - 30)];
    UILabel *prjTitle11 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    prjTitle11.text = @"出工计划";
    prjTitle11.textColor = [UIColor whiteColor];
    prjTitle11.font = [UIFont systemFontOfSize:18];
    UILabel *prjNum11 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    [prjNum11 setFont:[UIFont fontWithName:@"Helvetice" size:13.0]];
    prjNum11.text = @"出工计划:(0)";
    prjNum11.textColor = [UIColor whiteColor];
    prjNum11.font = [UIFont systemFontOfSize:13];
    [prjTitle11 sizeToFit];
    [prjNum11 sizeToFit];
    [bgView11 addSubview:prjTitle11];
    [bgView11 addSubview:prjNum11];
    [prjTitle11 setCenter:CGPointMake(bgView11.center.x, bgView11.center.y +45)];
    [prjNum11 setCenter:CGPointMake(bgView11.center.x, bgView11.center.y +70)];
    [bgView11 setCenter:CGPointMake(self.view.center.x/2,self.view.center.y/2+190)];
    //待办任务
    UIView *bgView111 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 170, 180)];
    [bgView111.layer setCornerRadius:5];
    [bgView111.layer setBorderWidth:1];
    [bgView111.layer setBorderColor:[UIColor colorWithRed:53/255.0 green:83/255.0 blue:153/255.0 alpha:1].CGColor];
    CAGradientLayer *gradient111 = [CAGradientLayer layer];
    gradient111.frame = bgView111.frame;
    gradient111.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:66/255.0 green:97/255.0 blue:185/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:80/255.0 green:109/255.0 blue:189/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:93/255.0 green:119/255.0 blue:193/255.0 alpha:1].CGColor, nil];
    [bgView111.layer insertSublayer:gradient111 atIndex:0];
    [self.view addSubview:bgView111];
    UIImage *prjImage111 = [UIImage imageNamed:@"spellcheck.png"];
    UIImageView *prjImageView111 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [prjImageView111 setImage:prjImage111];
    [prjImageView111.layer setCornerRadius:5];
    [prjImageView111.layer setBorderWidth:1];
    [prjImageView111.layer setBorderColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1].CGColor];
    [prjImageView111 setBackgroundColor:[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1]];
    [bgView111 addSubview:prjImageView111];
    [prjImageView111 setCenter:CGPointMake(bgView111.center.x, bgView111.center.y - 30)];
    UILabel *prjTitle111 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    prjTitle111.text = @"待办任务";
    prjTitle111.textColor = [UIColor whiteColor];
    prjTitle111.font = [UIFont systemFontOfSize:18];
    UILabel *prjNum111 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 30)];
    [prjNum111 setFont:[UIFont fontWithName:@"Helvetice" size:13.0]];
    prjNum111.text = @"待办任务:(0)";
    prjNum111.textColor = [UIColor whiteColor];
    prjNum111.font = [UIFont systemFontOfSize:13];
    [prjTitle111 sizeToFit];
    [prjNum111 sizeToFit];
    [bgView111 addSubview:prjTitle111];
    [bgView111 addSubview:prjNum111];
    [prjTitle111 setCenter:CGPointMake(bgView111.center.x, bgView111.center.y +45)];
    [prjNum111 setCenter:CGPointMake(bgView111.center.x, bgView111.center.y +70)];
    [bgView111 setCenter:CGPointMake(self.view.center.x/2*3,self.view.center.y/2+190)];
    
}
@end
