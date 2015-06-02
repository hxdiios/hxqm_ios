//
//  CheckManager.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/14.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "CheckManager.h"
#import "LogUtils.h"
#import "MyMacros.h"

#define TAG @"CheckManager"

@implementation CheckManager

- (NSString *) test {
    return @"CheckManager";
}

- (id) init {
    self = [super init];
    if(self) {
       
    }
    return self;
}

- (BOOL) insertOneRecord:(NSDictionary *)jsonDictionary userid : (NSString *) userid {
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *sqlAparts = @[@"REPLACE INTO BO_CHECK_PROJECT(                        ",
                           @"BO_CHECK_PROJECT_ID,                                  ",
                           @"BO_SINGLE_PROJECT_ID,                                 ",
                           @"BO_PROJECT_SECTION_ID,                                ",
                           @"BO_CHECK_ID,                                          ",
                           @"CHECK_STATE,                                          ",
                           @"LIMIT_TIME,                                           ",
                           @"UPDATE_TIME,                                           ",
                           @"COMPLETE_TIME,                                        ",
                           @"USERID,                                               ",
                           @"CREATE_USER_NAME,                                               ",
                           @"CHECK_TYPE)                                           ",
                           @"VALUES(?,?,?,?,?,?,?,?,?,?,?)                             "];
    for(NSString *apart in sqlAparts) {
        [sql appendString:apart];
    }
    
    NSString *checkProjectID = [jsonDictionary objectForKey:@"BO_CHECK_PROJECT_ID"];
    NSString *singleProjectID = [jsonDictionary objectForKey:@"BO_SINGLE_PROJECT_ID"];
    NSString *sectionID = [jsonDictionary objectForKey:@"BO_PROJECT_SECTION_ID"];
    sectionID = IsStringEmpty(sectionID) ? @"" : sectionID;
    NSString *checkID = [jsonDictionary objectForKey:@"BO_CHECK_ID"];
    checkID = IsStringEmpty(checkID) ? @"" : checkID;
    NSString *checkState = [jsonDictionary objectForKey:@"CHECK_STATE"];
    NSString *limitTime = [jsonDictionary objectForKey:@"LIMIT_TIME"];
    NSString *startTime = [jsonDictionary objectForKey:@"UPDATE_TIME"];
    NSString *completeTime = [jsonDictionary objectForKey:@"COMPLETE_TIME"];
    NSString *createUserName = [jsonDictionary objectForKey:@"CREATE_USER_NAME"];
    completeTime = IsStringEmpty(completeTime) ? @"" : completeTime;
    NSString *checkType = [jsonDictionary objectForKey:@"CHECK_TYPE"];
    
    NSArray *params = [[NSArray alloc] initWithObjects:checkProjectID,
                       singleProjectID,
                       sectionID,
                       checkID,
                       checkState,
                       limitTime,
                       startTime,
                       completeTime,
                       userid,
                       createUserName,
                       checkType,nil];
    return [self executeUpdate:sql params:params];
}

/**
 * 批量保存抽查任务
 *
 * @param selectionList
 * @return
 * @author hubo
 */
- (BOOL)saveCheckProjectList:(NSArray *)checkProjectList userid:(NSString *)userid {
    BOOL result = YES;
    [LogUtils Log:TAG content:@"检查任务插入开始"];
    for (NSDictionary *project in checkProjectList) {
        result = [self saveCheckProject:project userid:userid] && result;
    }
    [LogUtils Log:TAG content:@"检查任务插入结束"];
    
    return result;
}

/**
 * 保存抽查任务
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)saveCheckProject:(NSDictionary *)project userid:(NSString *)userid {
    return [self insertOneRecord:project userid:userid];
}

@end
