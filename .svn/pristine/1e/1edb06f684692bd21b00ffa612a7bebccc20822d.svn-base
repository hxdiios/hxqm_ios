//
//  UploadLocationViewController.m
//  hxqm_mobile
//
//  Created by panqw on 4/22/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "UploadLocationViewController.h"
#import "SVProgressHUD.h"
#import "LogUtils.h"
#import "Constants.h"
#import "AppConfigure.h"
#import "SingleProjectManager.h"
#import "BaseFunction.h"

#define TAG @"_UploadLocationViewController"
#define VERTIFY_ 1
#define DISTANCE_ 2

@interface UploadLocationViewController () {
    
    FMDatabase *db;
    float projectLongitude;
    float projectLatitude;
    float currentLongitude;
    float currentLatitude;
    NSString *currentProjectId;
    NSString *currentDistance;
}
@property (weak, nonatomic) IBOutlet UILabel *projectName;

@property (weak, nonatomic) IBOutlet UILabel *projectLocation;

@property (weak, nonatomic) IBOutlet UITextField *lastestLongitude;

@property (weak, nonatomic) IBOutlet UITextField *lastestLatitude;

@property (weak, nonatomic) IBOutlet UILabel *distanceInfo;
@property (weak, nonatomic) IBOutlet UIView *distanceView;

@end

@implementation UploadLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    db = [BaseFunction createDB];
    [db open];
    // 设置标题
    [self setTitle:@"上传坐标"];
    // 设置标题文字的样式
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // 添加导航栏返回按钮
    [self addNavBackBtn:@"返回"];
    //隐藏距离视图
    _distanceView.hidden = YES;
    //显示经纬度
    currentLatitude = [[AppConfigure objectForKey:LATITUDE] floatValue];
    currentLongitude = [[AppConfigure objectForKey:LONGITUDE] floatValue];
    [self initLocation:currentLongitude latitude:currentLatitude];
}

//定位当前坐标
-(void)initLocation:(float)everLongitude latitude:(float)everLatitude{
    if(everLatitude==0 || everLongitude==0){
        UIAlertView *verifyAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"目前尚未定位，是否立即定位？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        verifyAlert.tag = VERTIFY_;
        [verifyAlert show];
    }else{
        _lastestLongitude.text = [NSString stringWithFormat:@"%f",everLongitude];
        _lastestLatitude.text = [NSString stringWithFormat:@"%f",everLatitude];
        _lastestLongitude.enabled = NO;
        _lastestLatitude.enabled = NO;
    }
}

//alertview处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == VERTIFY_ &&buttonIndex == 1) {
        ValidateViewController *validateViewController = [[ValidateViewController alloc] initWithNibName:@"ValidateViewController" bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:validateViewController];
        validateViewController.delegate = self;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    if(alertView.tag == DISTANCE_ &&buttonIndex == 1) {
        [self doUpload];
    }
}

//上传坐标
- (void)doUpload{
    NSURL *url = [NSURL URLWithString:UPLOAD_LOCATION_URL];
    BaseAjaxHttpRequest *request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    NSDictionary *params = @{@"BO_SINGLE_PROJECT_ID" : currentProjectId, @"LONGITUDE" :[NSString stringWithFormat:@"%f",currentLongitude], @"LATITUDE" : [NSString stringWithFormat:@"%f",currentLatitude]};
    
    [request setPostBody:params];
    
    [request setCompletionBlock:^{
        NSError *err;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[weakRequest responseData] options:kNilOptions error:&err];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"result = %@", result]];
        NSLog(@"err = %@", err);
        
        if (result != nil && [result objectForKey:@"RESULT"]) {
            //保存返回的经纬度
            SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
            [singleProjectManager updateLocation:result userid:[AppConfigure objectForKey:USERID]];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"上传成功！"]];
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"上传失败！"]];
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
    }];
    [request startAsynchronous];
}

- (void)getLocation:(float)longitude latitude:(float)latitude{
    currentLongitude = longitude;
    currentLatitude = latitude;
    [self initLocation:currentLongitude latitude:currentLatitude];
}

- (void)getProjectId:(NSString *)projectId{
    NSLog(@"当前的项目ID是%@",projectId);
    currentProjectId = projectId;
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    NSDictionary *projectDict = [singleProjectManager getSinglerProjectInfoById:projectId userid:[AppConfigure objectForKey:USERID]];
    projectLongitude = [[projectDict objectForKey:@"longitude"] floatValue];
    projectLatitude = [[projectDict objectForKey:@"latitude"]floatValue];
    _projectName.text = [projectDict objectForKey:@"project_name"];
    _projectLocation.text = [@"经度：" stringByAppendingFormat:@"%f 纬度：%f",projectLongitude,projectLatitude];
    //显示距离视图
    _distanceView.hidden = NO;
    //获取视图中的经纬度
    if(projectLongitude!=0&&projectLatitude!=0&&currentLongitude!=0&&currentLatitude!=0){
        currentDistance = [BaseFunction calculateDistance:projectLongitude latitude:projectLatitude longitude2:[NSString stringWithFormat:@"%f",currentLongitude] latitude2:[NSString stringWithFormat:@"%f",currentLatitude]];
        _distanceInfo.text = [@"当前位置坐标离原项目坐标位置的距离为：" stringByAppendingFormat:currentDistance];
    }
}

- (IBAction)uploadLocation:(UIButton *)sender {
    if(currentLongitude==0||currentLatitude==0){
        [SVProgressHUD showErrorWithStatus:@"当前经纬度不能为空或零，请重新定位！"];
        return;
    }
    if(projectLongitude==0||projectLatitude==0){
        [SVProgressHUD showErrorWithStatus:@"所选项目经纬度不能为空或零，请重新定位！"];
        return;
    }
//    else if(currentLatitude<27.03 || currentLatitude>28.36){
//        [SVProgressHUD showErrorWithStatus:@"纬度不在温州范围内，请重新定位！"];
//        return;
//    }else if(currentLongitude<119.37||currentLongitude>121.18){
//        [SVProgressHUD showErrorWithStatus:@"经度不在温州范围内，请重新定位！"];
//        return;
//    }
    if(!currentProjectId || [currentProjectId isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:@"请先选择需要上传坐标的工程！"];
        return;
    }
    NSRange kmRange=[currentDistance rangeOfString:@"KM"];
    NSRange mRange=[currentDistance rangeOfString:@"M"];
    if(kmRange.location!= NSNotFound){
        NSString *str = [currentDistance stringByReplacingCharactersInRange:kmRange withString:@""];
        if([str floatValue]>2){
            UIAlertView *distanceAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前坐标与原坐标之间距离已超过2公里！请慎重！您是否确定上传坐标？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            distanceAlert.tag = DISTANCE_;
            [distanceAlert show];
        }else{
            [self doUpload];
        }
    }else if(mRange.location!= NSNotFound){
        [self doUpload];
    }
}

- (IBAction)selectProj:(id)sender {
    ProjsViewController *projsViewController = [[ProjsViewController alloc] initWithNibName:@"ProjsViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:projsViewController];
    projsViewController.projectDelegate = self;
    projsViewController.chooseFlag = @"1";
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark -
- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
