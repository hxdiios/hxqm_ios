//
//  TestDBViewController.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/13.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "TestDBViewController.h"
#import "FMDatabase.h"
#import "MyMacros.h"
#import "CheckManager.h"
#import "AppConfigure.h"

@interface TestDBViewController ()

@end

@implementation TestDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /*NSMutableString *documentPath = PATH_OF_DOCUMENT;
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"test.db"];
    FMDatabase *db = [[FMDatabase alloc] initWithPath:dbPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //数据库未创建时，创建数据库
    if(![fileManager fileExistsAtPath:dbPath]) {
        if ([db open]) {
            NSString * sql = @"CREATE TABLE 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'name' VARCHAR(30), 'password' VARCHAR(30))";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"succ to creating db table");
            }
            [db close];
        } else {
            NSLog(@"error when open db");
        }
    }
    
    [db open];
    //insert data
    int idx = 1;
    for (int i = 0 ; i < 20; i++) {
        NSString *sql = @"insert into user (name, password) values(?, ?)";
        NSString *idStr = [[NSString alloc] initWithFormat:@"%d",idx];
        BOOL result = [db executeUpdate:sql,idStr,idStr];
        if(result) {
            NSLog(@"insert success");
        } else {
            NSLog(@"insert fail");
        }
    }
    [db close];*/
   
    CheckManager *checkManager = [[CheckManager alloc] init];
    NSDictionary *project = @{@"BO_CHECK_PROJECT_ID":@"1",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project1 = @{@"BO_CHECK_PROJECT_ID":@"2",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project2 = @{@"BO_CHECK_PROJECT_ID":@"3",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project3 = @{@"BO_CHECK_PROJECT_ID":@"4",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project4 = @{@"BO_CHECK_PROJECT_ID":@"5",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project5 = @{@"BO_CHECK_PROJECT_ID":@"6",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project6 = @{@"BO_CHECK_PROJECT_ID":@"7",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project7 = @{@"BO_CHECK_PROJECT_ID":@"8",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    NSDictionary *project8 = @{@"BO_CHECK_PROJECT_ID":@"9",
                              @"BO_SINGLE_PROJECT_ID":@"1",
                              @"BO_PROJECT_SECTION_ID":@"1",
                              @"BO_CHECK_ID":@"1",
                              @"CHECK_STATE":@"1",
                              @"LIMIT_TIME":@"20140901",
                              @"COMPLETE_TIME":@"20140901",
                              @"USERID":@"1",
                              @"CHECK_TYPE":@"1"};
    
    NSArray *array = [[NSArray alloc] initWithObjects:project1,project2,project3,project4,project5,project6,project7,project8,nil];
    [checkManager saveCheckProjectList:array userid:[AppConfigure objectForKey:USERID]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
