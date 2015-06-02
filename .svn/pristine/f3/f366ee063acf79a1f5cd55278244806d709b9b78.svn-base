//
//  SectionManager.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/16/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "SectionManager.h"
#import "LogUtils.h"
#import "MyMacros.h"

#define TAG @"SectionManager"

@implementation SectionManager

- (NSString *) test {
    return @"SectionManager";
}

/**
 * 批量保存分段
 *
 * @param selectionList
 * @return
 * @author hubo
 */
- (BOOL)saveSelectionList:(NSArray *)selectionList userid:(NSString *)userid {
    [LogUtils Log:TAG content:@"分段插入开始"];
    
    BOOL result = YES;
    
    for (NSDictionary *selection in selectionList) {
        result = [self saveSelection:selection userid:userid] && result;
    }
    
    [LogUtils Log:TAG content:@"分段插入结束"];
    
    return result;
}

/**
 * 单个保存分段
 *
 * @param jo
 * @return
 * @author hubo
 */
- (BOOL)saveSelection:(NSDictionary *)jo userid:(NSString *)userid {
    return [self insertOneRecord:jo userid:userid];
}

/**
 * 获得默认分段已拍/应拍
 *
 * @param id
 * @return num
 * @author yanghua
 */
- (NSString *)getDefaultSectionUploadAmount:(NSString *)sid {
    NSString *num = @"";
    
    NSString *sql = @"SELECT T.SECTION_UPLOAD_AMOUNT ,T.SECTION_NEED_AMOUNT FROM BO_PROJECT_SECTION T WHERE T.BO_SINGLE_PROJECT_ID = ?";
    
    NSArray *list = [self getListBySql:sql params:@[sid]];
    
    if (list != nil && [list count] > 0) {
        NSDictionary *dic = [list objectAtIndex:0];
        num = [NSString stringWithFormat:@"%@/%@", [dic objectForKey:@"section_need_amount"], [dic objectForKey:@"section_upload_amount"]];
    }
    
    return num;
}

/**
 * 根据项目ID获取分段
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getSectionListByProjectId:(NSString *)boSingleProejctId userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT     S.BO_PROJECT_SECTION_ID,                                                      ",
                          @"              S.BO_SINGLE_PROJECT_ID,                                                    ",
                          @"              S.SECTION_NAME,                                                            ",
                          @"				 S.SECTION_UPLOAD_AMOUNT                                                 ",
                          @"          FROM BO_PROJECT_SECTION  S                                                     ",
                          @"          WHERE S.BO_SINGLE_PROJECT_ID = ?                                               ",
                          @"          AND  S.USERID = ?                                                              ",
                          @"          ORDER BY SECTION_NUMBER DESC                                                   "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    return [self getListBySql:sql params:@[boSingleProejctId, userid]];
}

/**
 * 根据项目ID获取分段
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getSectionTaskByProjectId:(NSString *)boSingleProejctId userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT     S.BO_PROJECT_SECTION_ID,                                                      ",
                          @"              S.BO_SINGLE_PROJECT_ID,                                                    ",
                          @"              S.SECTION_NAME PROJECT_NAME,                                               ",
                          @"				 S.SECTION_UPLOAD_AMOUNT,                                                ",
                          @"				 BB.P_NUM COUNTS                                                         ",
                          @"          FROM BO_PROJECT_SECTION  S                                                     ",
                          @"      LEFT JOIN (SELECT COUNT(1) P_NUM, B.BO_PROJECT_SECTION_ID                          ",
                          @"                  FROM BO_CHECK_PROJECT B WHERE B.USERID = ?                             ",
                          @"                   GROUP BY B.BO_PROJECT_SECTION_ID) BB                                  ",
                          @" ON S.BO_PROJECT_SECTION_ID = BB.BO_PROJECT_SECTION_ID                                   ",
                          @"          WHERE S.BO_SINGLE_PROJECT_ID = ?                                               ",
                          @"          AND  P_NUM IS NOT NULL                                                         ",
                          @"          AND  S.USERID = ?                                                              ",
                          @"          ORDER BY SECTION_NUMBER DESC                                                   "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    NSArray *params = @[userid, boSingleProejctId, userid];
    
    return [self getListBySql:sql params:params];
}

/**
 * 根据项目ID判断是否有分段
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (BOOL)getHasSelectionByProjectId:(NSString *)boSingleProejctId userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT COUNT(1) COUNTS                                          ",
                          @"          FROM BO_PROJECT_SECTION                                  ",
                          @"          WHERE BO_SINGLE_PROJECT_ID = ?                           ",
                          @"          AND USERID = ?                                           "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSString *countStr = [self getStringBySql:sql params:@[boSingleProejctId, userid] key:@"COUNTS"];
    
    int count = [countStr intValue];
    if (count > 0) {
        return YES;
    }
    
    return NO;
}

/**
 * 得到分段的序号
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (int)getCurrentSectionNumber:(NSString *)boSingleProejctId userid:(NSString *)userid {
    NSString *sql = @"SELECT MAX(SECTION_NUMBER) SECTION_NUMBER FROM BO_PROJECT_SECTION BP WHERE BP.BO_SINGLE_PROJECT_ID = ? AND BP.USERID = ?";
    
    NSString *numberStr = [self getStringBySql:sql params:@[boSingleProejctId, userid] key:@"SECTION_NUMBER"];
    int sectionNumber = IsStringEmpty(numberStr) ? 0 : [numberStr intValue];
    
    return sectionNumber;
}

- (BOOL)insertOneRecord:(NSDictionary *)jso userid:(NSString *)userid {
    NSArray *sqlArray = @[@"REPLACE INTO BO_PROJECT_SECTION(BO_PROJECT_SECTION_ID, ",
                          @"                                   BO_SINGLE_PROJECT_ID,  ",
                          @"                                   SECTION_NAME,          ",
                          @"                                   SECTION_NUMBER,        ",
                          @"                                   CREATE_USERID,         ",
                          @"                                   CREATE_DATE,           ",
                          @"                                   USERID,                ",
                          @"                                   SECTION_NEED_AMOUNT,   ",
                          @"                                   SECTION_UPLOAD_AMOUNT) ",
                          @"   VALUES(?,?,?,?,?,?,?,?,?)                              "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[[jso objectForKey:@"BO_PROJECT_SECTION_ID"],
                        [jso objectForKey:@"BO_SINGLE_PROJECT_ID"],
                        [jso objectForKey:@"SECTION_NAME"],
                        [jso objectForKey:@"SECTION_NUMBER"],
                        [jso objectForKey:@"CREATE_USERID"],
                        [jso objectForKey:@"CREATE_DATE"],
                        userid,
                        [jso objectForKey:@"SECTION_NEED_AMOUNT"] == nil ? @"0" : [jso objectForKey:@"SECTION_NEED_AMOUNT"],
                        [jso objectForKey:@"SECTION_UPLOAD_AMOUNT"] == nil ? @"0" : [jso objectForKey:@"SECTION_UPLOAD_AMOUNT"]];
    
    return [self executeUpdate:sql params:params];
}

@end
