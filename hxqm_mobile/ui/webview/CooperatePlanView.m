//
//  CooperatePlanView.m
//  hxqm_mobile
//
//  Created by HuaXin on 15-3-10.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "CooperatePlanView.h"
#import "ASIHTTPRequest.h"
#import "LogUtils.h"
#define TAG @"_CooperatePlanView"
@interface CooperatePlanView ()

@end

@implementation CooperatePlanView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBackBtn:@"返回"];
    NSString *strURL=[BASE_URL stringByAppendingString: @"/projectweb/pages/qm/mobile/workplan/workplanlist.html"];
    NSURL *url=[NSURL URLWithString:strURL];
    _previousUrl=url;
    [self loadWebByAsiHttpRequset:url];
    // Do any additional setup after loading the view.
}
//用ASIHTTPRequest加载web
- (void)loadWebByAsiHttpRequset:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCachePolicy: ASIDontLoadCachePolicy];
    [request setTimeOutSeconds:5];
    [request setValidatesSecureCertificate:NO];
    [request setDidFinishSelector:@selector(requestFinished:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //[self.detailWebView loadHTMLString:request.responseString baseURL:nil];
    [self.webview loadData:request.responseData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:_previousUrl];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request fail, error is:%@", request.error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)back:(id)sender {
 // if([self.webview canGoBack]){
    NSString *currenturl=self.webview.request.URL.absoluteString ;
    if([currenturl rangeOfString:@"workplanitem"].length > 0){
        //webview网页回退一层
        [LogUtils Log:TAG content:@"可以回退"];
        //[self.webview goBack];
        [self loadWebByAsiHttpRequset:_previousUrl];
    }else{
        //回到前一个view
         [LogUtils Log:TAG content:@"初始页面，退回上一view"];
        [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        
        }];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
//    CGSize contentSize = theWebView.scrollView.contentSize;
//    CGSize viewSize = self.view.bounds.size;
//    
//    float rw = viewSize.width / contentSize.width;
//    
//    theWebView.scrollView.minimumZoomScale = rw;
//    theWebView.scrollView.maximumZoomScale = rw;
//    theWebView.scrollView.zoomScale = rw;
    CGRect frame = theWebView.frame;
    CGSize fittingSize = [theWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    theWebView.frame = frame;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
