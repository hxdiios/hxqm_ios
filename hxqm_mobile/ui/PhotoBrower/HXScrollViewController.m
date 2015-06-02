//
//  HXScrollViewController.m
//  hxqm_mobile
//
//  Created by HuaXin on 15-5-4.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "HXScrollViewController.h"
#import "BaseFunction.h"

@interface HXScrollViewController()

@end

@implementation HXScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"示例照片";
    [self addNavBackBtn];
    [self setupPage];
}

- (void)setupPage{
    //设置委托
    self.scrollView.delegate = self;
    //设置背景颜色
    self.scrollView.backgroundColor = [UIColor blackColor];
    //设置取消触摸
    self.scrollView.canCancelContentTouches = NO;
    //设置滚动条类型
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    //是否自动裁切超出部分
    self.scrollView.clipsToBounds = YES;
    //设置是否可以缩放
    self.scrollView.scrollEnabled = YES;
    //设置是否可以进行画面切换
    self.scrollView.pagingEnabled = YES;
    //设置在拖拽的时候是否锁定其在水平或者垂直的方向
    self.scrollView.directionalLockEnabled = NO;
    //隐藏滚动条设置（水平、跟垂直方向）
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    UIImageView *firstView=[[UIImageView alloc] initWithImage:[_images lastObject]];
    CGFloat Width=self.scrollView.frame.size.width;
    CGFloat Height=self.scrollView.frame.size.height;
    firstView.frame=CGRectMake(0, 0, Width, Height);
    [self.scrollView addSubview:firstView];
    //set the last as the first
    
    for (int i=0; i<[_images count]; i++) {
        UIImageView *subViews=[[UIImageView alloc] initWithImage:[_images objectAtIndex:i]];
        subViews.frame=CGRectMake(Width*(i+1), 0, Width, Height);
        [self.scrollView addSubview: subViews];
    }
    
    UIImageView *lastView=[[UIImageView alloc] initWithImage:[_images objectAtIndex:0]];
    lastView.frame=CGRectMake(Width*(_images.count+1), 0, Width, Height);
    [self.scrollView addSubview:lastView];
    //set the first as the last
    
    [self.scrollView setContentSize:CGSizeMake(Width*(_images.count+2), Height)];
    [self.view addSubview:self.scrollView];
    [self.scrollView scrollRectToVisible:CGRectMake(Width, 0, Width, Height) animated:NO];
    //show the real first image,not the first in the scrollView
    self.pageControl.numberOfPages=_images.count;
    self.pageControl.currentPage=0;
    self.pageControl.enabled=YES;
    [self.view addSubview:self.pageControl];
}

//改变页码的方法实现
- (IBAction)changPage:(id)sender {
    int pageNum=self.pageControl.currentPage;
    CGSize viewSize=self.scrollView.frame.size;
    CGRect rect=CGRectMake((pageNum+2)*viewSize.width, 0, viewSize.width, viewSize.height);
    [self.scrollView scrollRectToVisible:rect animated:NO];
    pageNum++;
    if (pageNum==_images.count) {
        CGRect newRect=CGRectMake(viewSize.width, 0, viewSize.width, viewSize.height);
        [self.scrollView scrollRectToVisible:newRect animated:NO];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth=self.scrollView.frame.size.width;
    int currentPage=floor((self.scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    if (currentPage==0) {
        self.pageControl.currentPage=_images.count-1;
    }else if(currentPage==_images.count+1){
        self.pageControl.currentPage=0;
    }
    self.pageControl.currentPage=currentPage-1;
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth=self.scrollView.frame.size.width;
    CGFloat pageHeigth=self.scrollView.frame.size.height;
    int currentPage=floor((self.scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    NSLog(@"the current offset==%f",self.scrollView.contentOffset.x);
    NSLog(@"the current page==%d",currentPage);
    
    if (currentPage==0) {
        [self.scrollView scrollRectToVisible:CGRectMake(pageWidth*_images.count, 0, pageWidth, pageHeigth) animated:NO];
        self.pageControl.currentPage=_images.count-1;
        NSLog(@"pageControl currentPage==%d",self.pageControl.currentPage);
        NSLog(@"the last image");
        return;
    }else  if(currentPage==[_images count]+1){
        [self.scrollView scrollRectToVisible:CGRectMake(pageWidth, 0, pageWidth, pageHeigth) animated:NO];
        self.pageControl.currentPage=0;
        NSLog(@"pageControl currentPage==%d",self.pageControl.currentPage);
        NSLog(@"the first image");
        return;
    }
    self.pageControl.currentPage=currentPage-1;
    NSLog(@"pageControl currentPage==%d",self.pageControl.currentPage);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}
@end
