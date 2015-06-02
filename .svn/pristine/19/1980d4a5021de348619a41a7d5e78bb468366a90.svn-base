//
//  TemplateManager.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/16/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "TemplateManager.h"
#import "LogUtils.h"

#define TAG @"TemplateManager"

@implementation TemplateManager

- (NSString *) test {
    return @"TemplateManager";
}

/**
 * 保存模板
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)saveTemplateInfo:(NSDictionary *)jso {
    NSArray *sqlArray = @[@"REPLACE INTO BO_TEMPLATE_DETAIL_VER(              ",
                          @"  BO_TEMPLATE_DETAIL_VER_ID,                      ",
                          @"  BO_TEMPLATE_ID,                                 ",
                          @"  BO_NAME,                                        ",
                          @"  BO_PARENT_ID,                                   ",
                          @"  IS_CHECK,                                       ",
                          @"  IS_XJ,                                          ",
                          @"  BO_TOTAL,                                       ",
                          @"  ORDER_POS,                                      ",
                          @"  BO_TEMPLATE_VER_ID,                             ",
                          @"  DOMAIN_ID)                                      ",
                          @"  VALUES(?,?,?,?,?,?,?,?,?,?)                     "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[[jso objectForKey:@"BO_TEMPLATE_DETAIL_VER_ID"],
                        [jso objectForKey:@"BO_TEMPLATE_ID"],
                        [jso objectForKey:@"BO_NAME"],
                        [jso objectForKey:@"BO_PARENT_ID"],
                        [jso objectForKey:@"IS_CHECK"],
                        [jso objectForKey:@"IS_XJ"],
                        [jso objectForKey:@"BO_TOTAL"],
                        [jso objectForKey:@"ORDER_POS"],
                        [jso objectForKey:@"BO_TEMPLATE_VER_ID"],
                        [jso objectForKey:@"DOMAIN_ID"]];
    
    return [self executeSql:sql params:params];
    
}

/**
 * 保存拍照点信息
 *
 * @param result
 * @return
 * @author hubo
 */
- (BOOL)savePointInfo:(NSDictionary *)jso {
    NSArray *sqlArray = @[@"REPLACE INTO BO_CRITICAL_POINT_VER(                ",
                          @"  BO_CRITICAL_POINT_VER_ID,                           ",
                          @"  POINT_NAME,                                         ",
                          @"  BO_TEMPLATE_DETAIL_VER_ID,                          ",
                          @"  BO_TEMPLATE_VER_ID,                                 ",
                          @"  NEED_VALIDATE,                                      ",
                          @"  POINT_RULE,                                         ",
                          @"  PHOTO_NAME_RULE,                                    ",
                          @"  PHOTO_NAME_REGEX,                                   ",
                          @"  IS_CHECK,                                           ",
                          @"  IS_XJ,                                              ",
                          @"  NEED_COUNT,                                         ",
                          @"  ORD_NUM,                                            ",
                          @"  DOMAIN_ID)                                          ",
                          @"  VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)                   "];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[[jso objectForKey:@"BO_CRITICAL_POINT_VER_ID"],
                        [jso objectForKey:@"POINT_NAME"],
                        [jso objectForKey:@"BO_TEMPLATE_DETAIL_VER_ID"],
                        [jso objectForKey:@"BO_TEMPLATE_VER_ID"],
                        [jso objectForKey:@"NEED_VALIDATE"],
                        [jso objectForKey:@"POINT_RULE"],
                        [jso objectForKey:@"PHOTO_NAME_RULE"],
                        [jso objectForKey:@"PHOTO_NAME_REGEX"],
                        [jso objectForKey:@"IS_CHECK"],
                        [jso objectForKey:@"IS_XJ"],
                        [jso objectForKey:@"NEED_COUNT"],
                        [jso objectForKey:@"ORD_NUM"],
                        [jso objectForKey:@"DOMAIN_ID"]];
    
    return [self executeSql:sql params:params];
}

/**
 * 保存示例照片
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)savePointImage:(NSDictionary *)jso userid:(NSString *)userid {
    NSString *bodyId = [jso objectForKey:@"BO_DOC_BODY_ID"];
    if((!bodyId || [@"" isEqualToString:bodyId])) {
        return FALSE;
    }
    
    NSArray *sqlArray = @[@"INSERT INTO BO_FILE(                                  ",
                          @"BO_DOC_BODY_ID,                                       ",
                          @"BO_CRITICAL_POINT_VER_ID,                             ",
                          @"PHOTO_PATH)                                           ",
                          @"VALUES(?,?,?)                                         "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[[jso objectForKey:@"BO_DOC_BODY_ID"],
                        [jso objectForKey:@"BO_CRITICAL_POINT_VER_ID"],
                        [jso objectForKey:@"FILE_FULLPATH"]];
    
    return [self executeSql:sql params:params];
}

/**
 * 得到模板列表
 *
 * @param boTemplateVerId
 * @param boTemplateId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getTemplateList:(NSString *)boTemplateVerId boTemplateId:(NSString *)boTemplateId boSingleProjectId:(NSString *)boSingleProjectId type:(NSString *)type userid:(NSString *)userid {
    NSString *condition;
    NSString *vals = @"1";
    
    if ([type isEqualToString:@"0"]) {
        condition = @"   AND V.IS_XJ = ?                                                   ";
    } else if ([type isEqualToString:@"1"]) {
        condition = @"   AND V.IS_CHECK = ?                                                ";
    } else if ([type isEqualToString:@"2"]) {
        condition = @"   AND V.IS_CHECK = ?                                                ";
        boTemplateId = @"09E6374935BF6D4BE050A8C0CE007643";
    } else {
        condition = @"   AND V.IS_XJ = ?                                                   ";
    }
    
    NSArray *sqlArray = @[@"SELECT BO_TEMPLATE_DETAIL_VER_ID,                                 ",
                          @"          BO_TEMPLATE_ID,                                            ",
                          @"          BO_NAME,                                                   ",
                          @"          BO_PARENT_ID,                                              ",
                          @"          BO_TYPE,                                                   ",
                          @"          BO_TOTAL,                                                  ",
                          @"          ORDER_POS,                                                 ",
                          @"          BO_TEMPLATE_VER_ID,                                        ",
                          @"          DOMAIN_ID                                                  ",
                          @" FROM BO_TEMPLATE_DETAIL_VER V                                       ",
                          @" WHERE V.BO_TEMPLATE_VER_ID = ?                                      ",
                          @"   AND V.BO_TEMPLATE_ID = ?                                          ",
                          condition,
                          @"   AND NOT EXISTS                                                    ",
                          @"   (SELECT 1                                                         ",
                          @"      FROM BO_TEMPLATE_EXCLUDE E                                     ",
                          @"      WHERE E.BO_TEMPLATE_DETAIL_VER_ID = V.BO_TEMPLATE_DETAIL_VER_ID",
                          @"        AND E.BO_SINGLE_PROJECT_ID = ? AND E.USERID = ?)             "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[boTemplateVerId, boTemplateId, vals, boSingleProjectId, userid];
    
    return [self getListBySql:sql params:params];
    
}

/**
 * 根据模板获得拍照点
 *
 * @param boTemplateDetailVerId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getCriticalByTemplateId:(NSString *)boTemplateDetailVerId {
    NSArray *sqlArray = @[@"SELECT V.BO_CRITICAL_POINT_VER_ID,                                 ",
                          @"          POINT_NAME,                                               ",
                          @"          BO_TEMPLATE_DETAIL_VER_ID,                                ",
                          @"          BO_TEMPLATE_VER_ID,                                       ",
                          @"          NEED_VALIDATE,                                            ",
                          @"          POINT_RULE,                                               ",
                          @"          PHOTO_NAME_RULE,                                          ",
                          @"          PHOTO_NAME_REGEX,                                         ",
                          @"          NEED_COUNT,                                                ",
                          @"          IFNULL(T.COUNTS,0) COUNTS                                                ",
                          @" FROM BO_CRITICAL_POINT_VER  V                                       ",
                          @" LEFT JOIN(SELECT BO_CRITICAL_POINT_VER_ID,COUNT(1)COUNTS                                         ",
                          @" FROM BO_FILE F GROUP BY F.BO_CRITICAL_POINT_VER_ID)T                                         ",
                          @" ON V.BO_CRITICAL_POINT_VER_ID = T.BO_CRITICAL_POINT_VER_ID                                         ",
                          @" WHERE BO_TEMPLATE_DETAIL_VER_ID = ?                                ",
                          @" ORDER BY ORD_NUM                                                   "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    return [self getListBySql:sql params:@[boTemplateDetailVerId]];
}

/**
 * 批量保存分段
 *
 * @param selectionList
 * @return
 * @author hubo
 */
- (BOOL)saveExcludeTemplate:(NSArray *)excludeTemplateList {
    [LogUtils Log:TAG content:@"模板排除插入开始"];
    
    BOOL result = YES;
    
    for (int i = 0; i < [excludeTemplateList count]; i++) {
        result = [self saveExcludeTemplate:[excludeTemplateList objectAtIndex:i]] && result;
    }
    
    [LogUtils Log:TAG content:@"模板排除插入结束"];
    
    return result;
}

/**
 * 保存示例照片
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)saveExcludeTemplate:(NSDictionary *)jso userid:(NSString *)userid {
    return [self insertOneRecord:jso userid:userid];
}

- (BOOL)insertOneRecord:(NSDictionary *)jso userid:(NSString *)userid {
    NSArray *sqlArray = @[@"REPLACE INTO BO_TEMPLATE_EXCLUDE(                   ",
                          @"BO_TEMPLATE_EXCLUDE_ID,                               ",
                          @"BO_SINGLE_PROJECT_ID,                                 ",
                          @"BO_TEMPLATE_DETAIL_VER_ID,USERID)                     ",
                          @"VALUES(?,?,?,?)                                       "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[[jso objectForKey:@"BO_TEMPLATE_EXCLUDE_ID"],
                        [jso objectForKey:@"BO_SINGLE_PROJECT_ID"],
                        [jso objectForKey:@"BO_TEMPLATE_DETAIL_VER_ID"],
                        userid];
    
    return [self executeUpdate:sql params:params];
}

/**
 * 根据模板获得拍照点
 *
 * @param boTemplateDetailVerId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getInstanceImageByPortId:(NSString *)boCriticalPointVerId {
    NSArray *sqlArray = @[@"SELECT * FROM BO_FILE F ",
                          @" WHERE BO_CRITICAL_POINT_VER_ID = ?"];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    return [self getListBySql:sql params:@[boCriticalPointVerId]];
}

@end
