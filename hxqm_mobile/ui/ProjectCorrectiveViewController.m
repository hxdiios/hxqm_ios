//
//  ProjectCorrectiveViewController.m
//  hxqm_mobile
//
//  Created by HuaXin on 15/5/20.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "RectifyJsToObjectiveC.h"
#import "WebViewJavascriptBridge.h"
#import "AppConfigure.h"
#import "SVProgressHUD.h"
#import "FMDatabase.h"
#import "BaseFunction.h"
#import "ProblemManager.h"
#import "BaseFunction.h"
#import "TableDetailViewController.h"
#import "ContentManager.h"
#import "PhotoManager.h"
#import "Constants.h"
#import "BaseAjaxHttpRequest.h"
#import "TableInfoViewController.h"
#import "ProjectCorrectiveViewController.h"


@interface ProjectCorrectiveViewController (){
    NSString *state;
    NSString *boSingleProjectId;
    NSString *boCheckProjectId;
    NSString *problemType;
    NSString *problemItem;
    FMDatabase *db;
    NSString *isClose;
    NSString *curStatus;
    BOOL *hasSubmitted;
    UIWebView* webView;
}
@property WebViewJavascriptBridge* bridge;
@end

@implementation ProjectCorrectiveViewController
@synthesize boProblemReplyId;
@synthesize boProblemId;
@synthesize types;
@synthesize isZD;
@synthesize boContentId;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addNavBackBtn:@"返回"];
    db = [BaseFunction createDB];
    [db open];
    //初始化参数
    isClose = @"";
    curStatus = @"";
    hasSubmitted = NO;
    if(boContentId == nil||[@"" isEqualToString:boContentId]){
        //待办进入取参数
        ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
        NSDictionary *map1 = [problemManager getProblemInfo:boProblemId userid:[AppConfigure objectForKey:@"USERID"]];
        boContentId = [map1 objectForKey:@"BO_CONTENT_ID"];
        boSingleProjectId = [map1 objectForKey:@"BO_SINGLE_PROJECT_ID"];
        boProblemReplyId = ([map1 objectForKey:@"BO_PROBLEM_REPLY_ID"] == nil) ? @"" : [map1 objectForKey:@"BO_PROBLEM_REPLY_ID"];
        curStatus = ([map1 objectForKey:@"STATUS"] == nil) ? @"" : [map1 objectForKey:@"STATUS"];
        problemType = [map1 objectForKey:@"PROBLEM_TYPE"];
        problemItem = [map1 objectForKey:@"PROBLEM_ITEM"];
        state = [self setState:map1];
    } else {
        //非待办进入为FQ
        state = @"FQ";
        ContentManager *contentManager = [[ContentManager alloc] initWithDb:db];
        NSDictionary *map1 = [contentManager getFullInfoByBoContentId:boContentId userid:[AppConfigure objectForKey:@"USERID"]];
        boSingleProjectId = [map1 objectForKey:@"BO_SINGLE_PROJECT_ID"];
        boCheckProjectId = ([map1 objectForKey:@"BO_CHECK_PROJECT_ID"] == nil) ? @"" : [map1 objectForKey:@"BO_CHECK_PROJECT_ID"];
        problemType = [map1 objectForKey:@"MAJOR_ID"];
        problemItem = [map1 objectForKey:@"BO_TEMPLATE_DETAIL_VER_ID"];
    }
}

//实现UIScrollViewDelegate里面的方法，意在阻止UIWebView里的弹出窗口自动上浮
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView{
    return nil;
}

//注册桥接方法
- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) {
        [self LoadPage:webView];
        return;
    }
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    webView.scrollView.delegate = self;
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"");
    }];
    [_bridge registerHandler:@"showToast" handler:^(id data, WVJBResponseCallback responseCallback) {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:data]];
        responseCallback(@"");
    }];
    [_bridge registerHandler:@"doSubmit" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSMutableDictionary *inputData = [[NSMutableDictionary alloc]init];
        [inputData setValuesForKeysWithDictionary:[BaseFunction parseJsonToMap:data]];
        [self doSubmit:inputData];
        responseCallback(@"");
    }];
    [_bridge registerHandler:@"doClose" handler:^(id data, WVJBResponseCallback responseCallback) {
        isClose = @"0";
        NSMutableDictionary *inputData = [[NSMutableDictionary alloc]init];
        [inputData setValuesForKeysWithDictionary:[BaseFunction parseJsonToMap:data]];
        [self doSubmit:inputData];
        responseCallback(@"");
    }];
    [_bridge registerHandler:@"doReturn" handler:^(id data, WVJBResponseCallback responseCallback) {
        isClose = @"1";
        NSMutableDictionary *inputData = [[NSMutableDictionary alloc]init];
        [inputData setValuesForKeysWithDictionary:[BaseFunction parseJsonToMap:data]];
        [self doSubmit:inputData];
        responseCallback(@"");
    }];
    [_bridge registerHandler:@"goPhotoPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self jumpToTableDetailWithContentId:boContentId types:types];
        responseCallback(@"");
    }];
    
    [_bridge registerHandler:@"getData" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *retDict = [[NSMutableDictionary alloc] init];
        [db open];
        //表单数据
        ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
        NSDictionary *rectityMapInj = [problemManager getProblemInfo:boProblemId userid:[AppConfigure objectForKey:USERID]];
        NSMutableDictionary *rectityMap = [[NSMutableDictionary alloc]init];
        [rectityMap setValuesForKeysWithDictionary:rectityMapInj];
        NSString *mendTimeLimit = [rectityMap objectForKey:@"MEND_TIME_LIMIT"];
        NSDate *mendTimeDate = [[NSDate alloc]init];
        if(mendTimeLimit.length>10){
            mendTimeDate = [BaseFunction dateFromString:mendTimeLimit dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }else{
            mendTimeDate = [BaseFunction dateFromString:mendTimeLimit dateFormat:@"yyyy-MM-dd"];
        }
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [rectityMap setValue:[dateFormatter stringFromDate:mendTimeDate] forKey:@"MEND_TIME_LIMIT"];
        [retDict setValue:rectityMap forKey:@"rectityMap"];
        //表单元素控制
        NSDictionary *elerwMap = [self getFormItemState:state rejectCount:([rectityMap objectForKey:@"REJECT_COUNT"] == nil) ? @"0" : [rectityMap objectForKey:@"REJECT_COUNT"]];
        [retDict setValue:elerwMap forKey:@"ELE_RW"];
        //考核依据
        NSString *exambasis =[AppConfigure objectForKey:EXAM_BASIS_INDEX_LIST];
        NSData *data2 = [exambasis dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err = nil;
        NSDictionary *arr1  = [NSJSONSerialization JSONObjectWithData:data2 options:NSJSONReadingAllowFragments  error:&err];
        [retDict setValue:arr1 forKey:@"basisList"];
        //整改单位
        NSArray *problemOrgList = [self getProblemOrgList:boProblemId boProblemReplyId:boProblemReplyId state:state userid:[AppConfigure objectForKey:USERID]];
        [retDict setValue:problemOrgList forKey:@"problem_org_list"];
        //下级扣分单位
        NSArray *orgList = [problemManager getOrgList:boSingleProjectId roleId:[AppConfigure objectForKey:ROLEID] userid:[AppConfigure objectForKey:USERID]];
        [retDict setValue:orgList forKey:@"org_list"];
        //整改照片
        NSArray *problemPhotoList = [problemManager getProblemPhotoList:boProblemId boProblemReplyId:boProblemReplyId userid:[AppConfigure objectForKey:USERID]];
        [retDict setValue:problemPhotoList forKey:@"control_point_list"];
        NSString *retStr = [[NSString alloc] initWithData:[BaseFunction toJSONData:retDict]
                                                 encoding:NSUTF8StringEncoding];
        responseCallback(retStr);
    }];
    [_bridge registerHandler:@"saveFormData" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"saveFormData %@",data);
        NSData *inputData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err = nil;
        NSDictionary *inputDictInj  = [NSJSONSerialization JSONObjectWithData:inputData options:NSJSONReadingAllowFragments  error:&err];
        NSMutableDictionary *inputDict = [[NSMutableDictionary alloc]init];
        [inputDict setValuesForKeysWithDictionary:inputDictInj];
        [self saveFormData:inputDict];
        responseCallback(@"");
    }];
    [_bridge registerHandler:@"saveOrgData" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSData *inputData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err = nil;;
        NSDictionary *inputDictInj  = [NSJSONSerialization JSONObjectWithData:inputData options:NSJSONReadingAllowFragments  error:&err];
        NSMutableDictionary *inputDict = [[NSMutableDictionary alloc]init];
        [inputDict setValuesForKeysWithDictionary:inputDictInj];
        [inputDict setValue:boProblemId forKey:@"BO_PROBLEM_ID"];
        //获取ORG_TYPE
        ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
        NSString *orgType = [problemManager getOrgTypeByOrgId:[inputDict objectForKey:@"ORG_ID"]];
        [inputDict setValue:orgType forKey:@"ORG_TYPE"];
        [problemManager saveProblemOrg:inputDict userid:[AppConfigure objectForKey:USERID]];
        responseCallback(@"");
    }];
    [_bridge registerHandler:@"delRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
        ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
        [problemManager deleteProblemOrg:data userid:[AppConfigure objectForKey:USERID]];
        responseCallback(@"");
    }];
    [self LoadPage:webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

- (void)LoadPage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"/bootstrap/rectify_bootstrap" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (NSDictionary *)getFormItemState:(NSString *)item_state rejectCount:(NSString *)rejectCount {
    NSDictionary *stateMap = [[NSMutableDictionary alloc] init];
    if([@"FQ" isEqualToString:item_state]){
        [stateMap setValue:@"0" forKey:@"MEND_TIME_LIMIT"];
        [stateMap setValue:@"0" forKey:@"REMARK"];
        [stateMap setValue:@"0" forKey:@"EXAM_BASIS"];
    } else {
        [stateMap setValue:@"1" forKey:@"MEND_TIME_LIMIT"];
        [stateMap setValue:@"1" forKey:@"REMARK"];
        [stateMap setValue:@"1" forKey:@"EXAM_BASIS"];
    }
    
    if([@"HF" isEqualToString:item_state]){
        [stateMap setValue:@"0" forKey:@"REPLY_CONTENT"];
        [stateMap setValue:@"0" forKey:@"submitbtn"];
        [stateMap setValue:@"2" forKey:@"rejectbtn"];
        [stateMap setValue:@"2" forKey:@"newrecord"];
    } else if([@"QR" isEqualToString:item_state]){
        [stateMap setValue:@"1" forKey:@"REPLY_CONTENT"];
        [stateMap setValue:@"2" forKey:@"submitbtn"];
        [stateMap setValue:@"0" forKey:@"rejectbtn"];
        [stateMap setValue:@"2" forKey:@"newrecord"];
    } else {
        [stateMap setValue:@"2" forKey:@"REPLY_CONTENT"];
        [stateMap setValue:@"0" forKey:@"submitbtn"];
        [stateMap setValue:@"2" forKey:@"rejectbtn"];
        [stateMap setValue:@"0" forKey:@"newrecord"];
    }
    
    if([@"QR" isEqualToString:item_state]){
        if([@"0" isEqualToString:rejectCount]){
            [stateMap setValue:@"0" forKey:@"REJECT_ONE"];
            [stateMap setValue:@"2" forKey:@"REJECT_TWO"];
            [stateMap setValue:@"2" forKey:@"REJECT_THREE"];
        }else if([@"1" isEqualToString:rejectCount]){
            [stateMap setValue:@"1" forKey:@"REJECT_ONE"];
            [stateMap setValue:@"0" forKey:@"REJECT_TWO"];
            [stateMap setValue:@"2" forKey:@"REJECT_THREE"];
        }else if([@"2" isEqualToString:rejectCount]){
            [stateMap setValue:@"1" forKey:@"REJECT_ONE"];
            [stateMap setValue:@"1" forKey:@"REJECT_TWO"];
            [stateMap setValue:@"0" forKey:@"REJECT_THREE"];
        }
    } else if([@"HF" isEqualToString:item_state]){
        if([@"0" isEqualToString:rejectCount]){
            [stateMap setValue:@"2" forKey:@"REJECT_ONE"];
            [stateMap setValue:@"2" forKey:@"REJECT_TWO"];
            [stateMap setValue:@"2" forKey:@"REJECT_THREE"];
        }else if([@"1" isEqualToString:rejectCount]){
            [stateMap setValue:@"1" forKey:@"REJECT_ONE"];
            [stateMap setValue:@"2" forKey:@"REJECT_TWO"];
            [stateMap setValue:@"2" forKey:@"REJECT_THREE"];
        }else if([@"2" isEqualToString:rejectCount]){
            [stateMap setValue:@"1" forKey:@"REJECT_ONE"];
            [stateMap setValue:@"1" forKey:@"REJECT_TWO"];
            [stateMap setValue:@"2" forKey:@"REJECT_THREE"];
        }
    } else {
        [stateMap setValue:@"2" forKey:@"REJECT_ONE"];
        [stateMap setValue:@"2" forKey:@"REJECT_TWO"];
        [stateMap setValue:@"2" forKey:@"REJECT_THREE"];
    }
    return stateMap;
}

/**
 * 得到整改扣分单位列表
 *
 * @return list
 * @author yanghua
 */
- (NSMutableArray *)getProblemOrgList:(NSString *)_boProblemId boProblemReplyId:(NSString *)_boProblemReplyId state:(NSString *)_state userid:(NSString *)_userid {
    ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
    NSArray *list = [problemManager getProblemOrgList:_boProblemId boProblemReplyId:_boProblemReplyId state:_state userid:_userid];
    for(NSDictionary *map in list){
        if([@"SSH" isEqualToString:_state] && [@"SZ" isEqualToString:[map objectForKey:@"ORG_TYPE"]]){
            [map setValue:@"1" forKey:@"CAN_EDIT"];
        } else if (([@"FSH" isEqualToString:_state] || [@"QR" isEqualToString:_state]) && [@"FGS" isEqualToString:[map objectForKey:@"ORG_TYPE"]]){
            [map setValue:@"1" forKey:@"CAN_EDIT"];
        }else if ([@"HF" isEqualToString:_state]){
            [map setValue:@"1" forKey:@"CAN_EDIT"];
        }else{
            [map setValue:@"0" forKey:@"CAN_EDIT"];
        }
    }
    return list;
}


- (void)viewDidAppear:(BOOL)animated{
    [db open];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [db close];
    [super viewDidDisappear:animated];
}

- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
    }];
}

- (void) doSubmit :(NSMutableDictionary *)data{
    //扣分单位校验
    ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
    NSArray *orgList = [problemManager getNextOrgList:boProblemId boProblemReplyId:boProblemReplyId curStatus:curStatus userid:[AppConfigure objectForKey:@"USERID"]];
    if([BaseFunction isArrayEmpty:orgList] && ![@"HF" isEqualToString:state]){
        [SVProgressHUD showErrorWithStatus:@"请选择扣分单位，再提交！"];
        return ;
    }
    [SVProgressHUD showWithStatus:@"正在努力上传数据......"];
    [self saveFormData:data];
    NSDictionary *inputData = [[NSMutableDictionary alloc] init];
    [inputData setValue:@"2" forKey:@"PHOTO_TYPE"];
    [inputData setValue:boContentId forKey:@"BO_CONTENT_ID"];
    [super doUpload:inputData];
}

#pragma mark 跳转到TableDetail界面
- (void)jumpToTableDetailWithContentId:(NSString *)boContentId types:(NSString *)types {
    TableDetailViewController *tableDetailViewController = [[TableDetailViewController alloc] initWithNibName:@"TableDetailViewController" bundle:nil];
    tableDetailViewController.type = types;
    tableDetailViewController.contentID = boContentId;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableDetailViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (NSString *)setState:(NSDictionary *)map{
    NSString *status = ([map objectForKey:@"STATUS"] == nil) ? @"" : [map objectForKey:@"STATUS"];
    if([@"4" isEqualToString:status]||[@"8" isEqualToString:status]||[@"11" isEqualToString:status]||[@"14" isEqualToString:status]){
        return @"QR";
    }else if([@"3" isEqualToString:status]||[@"7" isEqualToString:status]||[@"10" isEqualToString:status]||[@"13" isEqualToString:status]){
        return @"HF";
    }else if([@"2" isEqualToString:status]||[@"6" isEqualToString:status]){
        return @"FSH";
    }else if([@"1" isEqualToString:status]){
        return @"SSH";
    }else{
        return @"FQ";
    }
}

- (void)doSucceedUpload{
    
    [self submitProblem];
}

-(void)noFileNeedUpload{
    [self submitProblem];
}

-(BOOL)submitProblem{
    ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
    NSMutableDictionary *map = [problemManager getProblemInfo:boProblemId userid:[AppConfigure objectForKey:@"USERID"]];
    if([@"FQ" isEqualToString:state]){
        if([@"TRUE" isEqualToString:isZD]){
            ContentManager *contentnManager = [[ContentManager alloc]initWithDb:db];
            [map setValuesForKeysWithDictionary:[contentnManager getFullInfoByBoContentId:boContentId userid:[AppConfigure objectForKey:@"USERID"]]];
            [map setValue:@"TRUE" forKey:@"IS_ZD"];
        }
        [map setValue:@"TRUE" forKey:@"IS_NEW"];
        [map setValue:@"TRUE" forKey:@"NEED_ZG"];
    }else if([@"QR" isEqualToString:state]){
        [map setValue:isClose forKey:@"IS_CLOSE"];
    }
    [map setValue:state forKey:@"STATE"];
    if(![@"" isEqualToString:[map objectForKey:@"EXAM_BASIS_TEXT"]]){
        [map removeObjectForKey:@"EXAM_BASIS_TEXT"];
    }
    NSString *remark = ([map objectForKey:@"REMARK"] == nil) ? @"" : [map objectForKey:@"REMARK"];
    [map setValue:[BaseFunction utf8Encode:remark] forKey:@"REMARK"];
    NSString *replyContent = ([map objectForKey:@"REPLY_CONTENT"] == nil) ? @"" : [map objectForKey:@"REPLY_CONTENT"];
    [map setValue:[BaseFunction utf8Encode:replyContent] forKey:@"REPLY_CONTENT"];
    NSString *boContentName = ([map objectForKey:@"BO_CONTENT_NAME"] == nil) ? @"" : [map objectForKey:@"BO_CONTENT_NAME"];
    [map setValue:[BaseFunction utf8Encode:boContentName] forKey:@"BO_CONTENT_NAME"];
    NSString *reject1 = ([map objectForKey:@"REJECT_ONE"] == nil) ? @"" : [map objectForKey:@"REJECT_ONE"];
    [map setValue:[BaseFunction utf8Encode:reject1] forKey:@"REJECT_ONE"];
    [map setValue:[BaseFunction utf8Encode:reject1] forKey:@"REJECT_1"];
    NSString *reject2 = ([map objectForKey:@"REJECT_TWO"] == nil) ? @"" : [map objectForKey:@"REJECT_TWO"];
    [map setValue:[BaseFunction utf8Encode:reject2] forKey:@"REJECT_TWO"];
    [map setValue:[BaseFunction utf8Encode:reject2] forKey:@"REJECT_2"];
    NSString *reject3 = ([map objectForKey:@"REJECT_THREE"] == nil) ? @"" : [map objectForKey:@"REJECT_THREE"];
    [map setValue:[BaseFunction utf8Encode:reject2] forKey:@"REJECT_THREE"];
    [map setValue:[BaseFunction utf8Encode:reject3] forKey:@"REJECT_3"];
    NSString *projectName = ([map objectForKey:@"PROJECT_NAME"] == nil) ? @"" : [map objectForKey:@"PROJECT_NAME"];
    [map setValue:[BaseFunction utf8Encode:projectName] forKey:@"PROJECT_NAME"];
    curStatus = ([map objectForKey:@"STATUS"] == nil) ? @"" : [map objectForKey:@"STATUS"];
    problemManager = [[ProblemManager alloc]initWithDb:db];
    NSArray *orgList = [problemManager getNextOrgList:boProblemId boProblemReplyId:boProblemReplyId curStatus:curStatus userid:[AppConfigure objectForKey:@"USERID"]];
    //对OrgList进行转码
    for(NSMutableDictionary *dict in orgList){
        NSString *orgName = ([dict objectForKey:@"ORG_NAME"] == nil) ? @"" : [dict objectForKey:@"ORG_NAME"];
        [dict setValue:[BaseFunction utf8Encode:orgName] forKey:@"ORG_NAME"];
    }
    [map setValue:orgList forKey:@"PROBLEM_ORG_LIST"];
    PhotoManager *photoManager = [[PhotoManager alloc]initWithDb:db];
    NSDictionary *lastestRefPhotoMap = [photoManager getLastestRefPhoto];
    if(lastestRefPhotoMap !=nil){
        [map setValue:[lastestRefPhotoMap objectForKey:@"bo_photo_id"] forKey:@"REF_PHOTO_ID"];
    }
    NSURL *url = [NSURL URLWithString:checkCompleteUrl];
    BaseAjaxHttpRequest *request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    [request setPostBody:map];
    
    [request setCompletionBlock:^{
        NSError *err;
        NSString *responseString = [weakRequest responseString];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
        bool *ret = [[result objectForKey:@"RESULT"] boolValue];
        if (result != nil && ret) {
            if([@"FQ" isEqualToString:state]){
                NSString *boContentId = [result objectForKey:@"BO_CONTENT_ID"];
                NSArray *contentList = [result objectForKey:@"CONTENT_LIST"];
                ContentManager *contentManager = [[ContentManager alloc]initWithDb:db];
                if(![BaseFunction isArrayEmpty:contentList]){
                    [contentManager saveDownloadContents:contentList userid:[AppConfigure objectForKey:@"USERID"]];
                }
                if(ret){
                    [contentManager doCompleteTaskWithBoContentId:boContentId userid:[AppConfigure objectForKey:@"USERID"]];
                    [contentManager updateOtherTypeStateWithBoContentId:boContentId userid:[AppConfigure objectForKey:@"USERID"]];
                }
            } else {
                ProblemManager *problemManager = [[ProblemManager alloc]initWithDb:db];
                NSArray *jsonList = [result objectForKey:@"REPLY_LIST"];
                if(![BaseFunction isArrayEmpty:jsonList]){
                    [problemManager saveProblemReply:[jsonList objectAtIndex:0]  userid:[AppConfigure objectForKey:@"USERID"]];
                }
            }
            hasSubmitted = ret;
            if(ret){
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"提交成功！"]];
                [self back:nil];
            }else{
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"提交失败！"]];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"解析失败！"]];
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
    }];
    [request startAsynchronous];
    return YES;
}

- (BOOL)saveFormData:(NSMutableDictionary *)data{
    if(hasSubmitted){
        return YES;
    }
    if([@"FQ" isEqualToString:state]){
        [data setValue:problemType forKey:@"PROBLEM_TYPE"];
        [data setValue:problemItem forKey:@"PROBLEM_ITEM"];
        [data setValue:boSingleProjectId forKey:@"BO_SINGLE_PROJECT_ID"];
        [data setValue:boCheckProjectId forKey:@"BO_CHECK_PROJECT_ID"];
        [data setValue:boProblemId forKey:@"BO_PROBLEM_ID"];
        [data setValue:types forKey:@"TYPES"];
        ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
        return [problemManager saveProblem:data userid:[AppConfigure objectForKey:USERID]];
    }else{
        [data setValue:boProblemReplyId forKey:@"BO_PROBLEM_REPLY_ID"];
        ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
        return [problemManager saveProblemReplyRecord:data state:state userid:[AppConfigure objectForKey:USERID]];
    }
}

@end
