//
//  DeptManager.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/15/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "DeptManager.h"

@implementation DeptManager

- (NSString *) test {
    return @"DeptManager";
}

/**
 * 批量保存大项
 *
 * @param deptList
 * @return
 */
- (BOOL)saveDeptProjectList:(NSArray *)deptList userid:(NSString *)userid {
    BOOL result = YES;
    for (NSDictionary *dept in deptList) {
        result = [self saveDeptProject:dept userid:userid] && result;
    }
    
    return result;
}

/**
 * 单个保存大项
 *
 * @param jo
 * @return
 */
- (BOOL)saveDeptProject:(NSDictionary *)jo userid:(NSString *)userid {
    return [self insertOneRecord:jo userid:userid];
}

/**
 * 得到大项专业列表
 *
 * @return
 */
- (NSMutableArray *)getDeptProjectList:(NSString *)userid {
    NSArray *sqlArray = @[@" SELECT T.BO_DEPT_PROJECT_ID KEYID,",
                          @"        PROJECT_NAME||'('||IFNULL(T1.COUNTS,0)||')' KEYNAME,",
                          @"        MAJOR_ID PARENTID",
                          @"   FROM BO_DEPT_PROJECT T",
                          @"   LEFT JOIN (SELECT BO_DEPT_PROJECT_ID, COUNT(1) COUNTS,USERID",
                          @"                FROM BO_SINGLE_PROJECT",
                          @"               GROUP BY BO_DEPT_PROJECT_ID,USERID) T1",
                          @"     ON T.BO_DEPT_PROJECT_ID = T1.BO_DEPT_PROJECT_ID",
                          @"    AND T.USERID = T1.USERID",
                          @"    WHERE T.USERID = ?",
                          @"  ORDER BY T.MAJOR_ID"];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[userid];
    
    return [self getListBySql:sql params:params];
}

- (BOOL)insertOneRecord:(NSDictionary *)jsonDictionary userid:(NSString *)userid {
    NSString *sql = @"REPLACE INTO BO_DEPT_PROJECT(BO_DEPT_PROJECT_ID, PROJECT_NAME, MAJOR_ID,USERID) VALUES(?,?,?,?)";
    NSArray *params = @[[jsonDictionary objectForKey:@"BO_DEPT_PROJECT_ID"],
                        [jsonDictionary objectForKey:@"PROJECT_NAME"],
                        [jsonDictionary objectForKey:@"MAJOR_ID"],
                        userid];
    
    return [self executeUpdate:sql params:params];
}

@end
