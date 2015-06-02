//
//  ProblemManager.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/16/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ProblemManager.h"
#import "LogUtils.h"
#import "MyMacros.h"
#import "BaseFunction.h"
#import "Constants.h"
#import "ContentManager.h"

#define TAG @"ProblemManager"

@implementation ProblemManager

- (NSString *) test {
    return @"ProblemManager";
}

/**
 * 下载整改记录
 *
 * @param list
 * @author hubo
 */
- (void)saveProblemList:(NSArray *)list userid:(NSString *)userid {
    [LogUtils Log:TAG content:@"整改插入开始"];
    
    for (NSDictionary *problemDic in list) {
        [self saveProblem:problemDic userid:userid];
        [self saveProblemOrg:problemDic userid:userid];
        [self saveProblemReply:problemDic userid:userid];
    }
    //更新与整改相关的content
    ContentManager *contentManager = [[ContentManager alloc] init];
    [contentManager saveDownloadContents:list userid:userid];
    [LogUtils Log:TAG content:@"整改插入结束"];
}

/**
 * 保存整改逾期
 *
 * @param list
 * @author yanghua
 */
- (void)saveProblemDelayList:(NSArray *)list userid:(NSString *)userid {
    [LogUtils Log:TAG content:@"整改逾期插入开始"];
    
    for (NSDictionary *problemDelyDic in list) {
        [self saveProblemReply:problemDelyDic userid:userid];
    }
    
    [LogUtils Log:TAG content:@"整改逾期插入开始"];
}

/**
 * 更新整改记录
 *
 * @param problemRecord
 * @return
 * @author hubo
 * @editor yanghua
 */
- (BOOL)saveProblem:(NSDictionary *)jso userid:(NSString *)userid {
    NSArray *sqlArray = @[@"REPLACE INTO BO_PROBLEM(BO_PROBLEM_ID,BO_SINGLE_PROJECT_ID,IS_MEND_FINISH,MEND_TIME_LIMIT,EXAM_BASIS,EXAM_BASIS_TEXT,REMARK,",
                          @"IS_MEND,PROBLEM_TYPE,PROBLEM_ITEM,BO_CHECK_PROJECT_ID,IS_DRAFT,USERID,CREATE_USER_ID,CREATE_TIME,TYPES,PAPER_CHECK_NUM,PAPER_PRM_NUM)",
                          @"VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[[BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_SINGLE_PROJECT_ID"],
                        ([jso objectForKey:@"IS_MEND_FINISH"] == nil) ? @"" : [jso objectForKey:@"IS_MEND_FINISH"],
                        [BaseFunction safeGetValueByKey:jso Key:@"MEND_TIME_LIMIT"],
                        [BaseFunction safeGetValueByKey:jso Key:@"EXAM_BASIS"],
                        ([jso objectForKey:@"EXAM_BASIS_TEXT"] == nil) ? @"" : [jso objectForKey:@"EXAM_BASIS_TEXT"],
                        ([jso objectForKey:@"REMARK"] == nil) ? @"" : [jso objectForKey:@"REMARK"],
                        ([jso objectForKey:@"IS_MEND"] == nil) ? @"" : [jso objectForKey:@"IS_MEND"],
                        ([jso objectForKey:@"PROBLEM_TYPE"] == nil) ? @"" : [jso objectForKey:@"PROBLEM_TYPE"],
                        ([jso objectForKey:@"PROBLEM_ITEM"] == nil) ? @"" : [jso objectForKey:@"PROBLEM_ITEM"],
                        ([jso objectForKey:@"BO_CHECK_PROJECT_ID"] == nil) ? @"" : [jso objectForKey:@"BO_CHECK_PROJECT_ID"],
                        ([jso objectForKey:@"IS_DRAFT"] == nil) ? @"" : [jso objectForKey:@"IS_DRAFT"],
                        userid,
                        ([jso objectForKey:@"CREATE_USER_ID"] == nil) ? @"" : [jso objectForKey:@"CREATE_USER_ID"],
                        ([jso objectForKey:@"PROBLEM_CREATE_TIME"] == nil) ? @"" : [jso objectForKey:@"PROBLEM_CREATE_TIME"],
                        ([jso objectForKey:@"TYPES"] == nil) ? @"" : [jso objectForKey:@"TYPES"],
                        ([jso objectForKey:@"PAPER_CHECK_NUM"] == nil) ? @"" : [jso objectForKey:@"PAPER_CHECK_NUM"],
                        ([jso objectForKey:@"PAPER_PRM_NUM"] == nil) ? @"" : [jso objectForKey:@"PAPER_PRM_NUM"]];
    
    return [self executeUpdate:sql params:params];
}

/**
 * 保存问题责任方扣分
 *
 * @param problemRecord
 * @return
 * @author hubo
 * @editor yanghua
 */
- (BOOL)saveProblemOrg:(NSDictionary *)jso userid:(NSString *)userid {
    NSString *sql = @"REPLACE INTO BO_PROBLEM_ORG(BO_PROBLEM_ORG_ID,BO_PROBLEM_ID,ORG_TYPE,ORG_ID,ORG_NAME,ORG_CHECK,ORG_CHECK_PAYMENT,IS_ORG_MOSTLY_MEND,USERID) VALUES(?,?,?,?,?,?,?,?,?)";
    
    NSArray *params = @[[BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ORG_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_TYPE"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_NAME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_CHECK"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_CHECK_PAYMENT"],
                        [BaseFunction safeGetValueByKey:jso Key:@"IS_ORG_MOSTLY_MEND"],
                        userid];
    
    return [self executeUpdate:sql params:params];
}

/**
 * 保存施工回复
 *
 * @param problemRecord
 * @return
 * @author hubo
 */
- (BOOL)saveProblemReply:(NSDictionary *)jso userid:(NSString *)userid {
    NSArray *sqlArray = @[@"REPLACE INTO BO_PROBLEM_REPLY(BO_PROBLEM_REPLY_ID,BO_PROBLEM_ID,BO_PROBLEM_ORG_ID,CREATE_TIME,UPDATE_TIME,",@"BO_SINGLE_PROJECT_ID,BO_PROJECT_SECTION_ID,REPLY_CONTENT,STATUS,PROBLEM_STATE,LIMIT_TIME,START_TIME,USERID,REJECT_ONE,REJECT_TWO,REJECT_THREE,REJECT_COUNT,CREATE_USER_NAME)",
                          @" VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    NSArray *params = @[[BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_REPLY_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ORG_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"REPLY_CREATE_TIME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"REPLY_UPDATE_TIME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_SINGLE_PROJECT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROJECT_SECTION_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"REPLY_CONTENT"],
                        [BaseFunction safeGetValueByKey:jso Key:@"STATUS"],
                        [BaseFunction safeGetValueByKey:jso Key:@"STATES"],
                        [BaseFunction safeGetValueByKey:jso Key:@"LIMIT_TIME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"START_TIME"],
                        userid,
                        [BaseFunction safeGetValueByKey:jso Key:@"REJECT_1"],
                        [BaseFunction safeGetValueByKey:jso Key:@"REJECT_2"],
                        [BaseFunction safeGetValueByKey:jso Key:@"REJECT_3"],
                        [BaseFunction safeGetValueByKey:jso Key:@"REJECT_COUNT"],
                        [BaseFunction safeGetValueByKey:jso Key:@"CREATE_USER_NAME"]];
    
    return [self executeUpdate:sql params:params];
}

/**
 * 保存与整改相关扣分单位
 *
 * @return
 * @author yanghua
 */
- (BOOL)saveRelativeOrg:(NSDictionary *)jso {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"REPLACE INTO BO_PROJ_ORG(BO_PROJ_ORG_ID,BO_SINGLE_PROJECT_ID,ORG_ID,ORG_NAME,ORG_TYPE)"];
    [sql appendString:@"VALUES(?,?,?,?,?)"];
    NSArray *params = @[[BaseFunction safeGetValueByKey:jso Key:@"BO_PROJ_ORG_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_SINGLE_PROJECT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_NAME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"ORG_TYPE"]];
    return [self executeUpdate:sql params:params];
}

/**
 * 得到整改问题列表
 *
 * @return
 * @author hubo
 */
- (NSMutableArray *)getProblemList:(float)longtitude latitude:(float)latitude {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT T.BO_SINGLE_PROJECT_ID, "];
    [sql appendString:@"       MAX(PROJECT_NUMBER) PROJECT_NUMBER, "];
    [sql appendString:@"       MAX(PROJECT_NAME) PROJECT_NAME, "];
    [sql appendString:@"       MAX(LONGITUDE) LONGITUDE, "];
    [sql appendString:@"       MAX(LATITUDE) LATITUDE, "];
    [sql appendString:@"       MAX(BO_TEMPLATE_VER_ID) BO_TEMPLATE_VER_ID, "];
    [sql appendString:@"       MAX(BO_TEMPLATE_ID) BO_TEMPLATE_ID, "];
    [sql appendString:@"       MAX(BO_DEPT_PROJECT_ID) BO_DEPT_PROJECT_ID, "];
    [sql appendString:@"       MAX(DEPT_PROJECT_NAME) DEPT_PROJECT_NAME, "];
    [sql appendString:@"       MAX(ENTER_DATE) ENTER_DATE, "];
    [sql appendString:@"       MAX(UPDATE_DATE) UPDATE_DATE, "];
    [sql appendString:@"       MAX(MAJOR_ID) MAJOR_ID, "];
    [sql appendString:@"       MAX(MAJOR_NAME) MAJOR_NAME, "];
    [sql appendString:@"       MAX(UPDATE_TIMESTAMP) UPDATE_TIMESTAMP, "];
    [sql appendString:@"       COUNT(1) UPLOAD_AMOUNT "];
    [sql appendString:@"  FROM BO_SINGLE_PROJECT T, BO_PROBLEM M "];
    [sql appendString:@" WHERE T.BO_SINGLE_PROJECT_ID = M.BO_SINGLE_PROJECT_ID "];
    [sql appendString:@"   AND M.TYPES IN ('1','4')"];
    [sql appendString:@" GROUP BY T.BO_SINGLE_PROJECT_ID "];
    
    NSMutableArray *list = [self getListBySql:sql params:@[]];
    for (NSMutableDictionary *problemDic in list) {
        if (longtitude == 0) {
            [problemDic setObject:@"未知" forKey:@"project_distance"];
        } else {
            NSString *site_distance = [BaseFunction calculateDistance:longtitude latitude:latitude longitude2:[problemDic objectForKey:@"longitude"] latitude2:[problemDic objectForKey:@"latitude"]];
            [problemDic setObject:site_distance forKey:@"project_distance"];
        }
        
        NSString *amount = IsStringEmpty([problemDic objectForKey:@"upload_amount"]) ? @"0/0" : [problemDic objectForKey:@"upload_amount"];
        [problemDic setObject:[NSString stringWithFormat:@"任务数：%@", amount] forKey:@"upload_amount"];
    }
    
    return list;
}

/**
 * 获得整改表单信息
 *
 * @param boProblemId
 * @return map
 * @author yanghua
 */
- (NSDictionary *)getProblemInfo:(NSString *)boProblemId userid:(NSString *)userid {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT P.*,"];
    [sql appendString:@"       P.TYPES TYPE,"];
    [sql appendString:@"       R.REPLY_CONTENT,"];
    [sql appendString:@"       R.STATUS,"];
    [sql appendString:@"       R.REJECT_ONE,"];
    [sql appendString:@"       R.REJECT_TWO,"];
    [sql appendString:@"       R.REJECT_THREE,"];
    [sql appendString:@"       R.REJECT_ONE REJECT_1,"];
    [sql appendString:@"       R.REJECT_TWO REJECT_2,"];
    [sql appendString:@"       R.REJECT_THREE REJECT_3,"];
    [sql appendString:@"       R.REJECT_COUNT,"];
    [sql appendString:@"       R.BO_PROBLEM_REPLY_ID,"];
    [sql appendString:@"       SP.PROJECT_NAME,"];
    [sql appendString:@"       SP.MAJOR_ID,"];
    [sql appendString:@"       C.BO_CONTENT_NAME,"];
    [sql appendString:@"       C.BO_TEMPLATE_DETAIL_VER_ID,"];
    [sql appendString:@"       C.BO_CHECK_PROJECT_ID,"];
    [sql appendString:@"       BO_CONTENT_ID"];
    [sql appendString:@"  FROM BO_PROBLEM P"];
    [sql appendString:@"  LEFT JOIN (SELECT PR.BO_PROBLEM_ID,"];
    [sql appendString:@"                    PR.REPLY_CONTENT,"];
    [sql appendString:@"                    PR.STATUS,"];
    [sql appendString:@"                    PR.REJECT_ONE,"];
    [sql appendString:@"                    PR.REJECT_TWO,"];
    [sql appendString:@"                    PR.REJECT_THREE,"];
    [sql appendString:@"                    PR.REJECT_COUNT,"];
    [sql appendString:@"                    PR.BO_PROBLEM_REPLY_ID,"];
    [sql appendString:@"                    PR.USERID"];
    [sql appendString:@"               FROM BO_PROBLEM_REPLY PR"];
    [sql appendString:@"              WHERE PR.STATUS != '5') R ON R.BO_PROBLEM_ID ="];
    [sql appendString:@"                                           P.BO_PROBLEM_ID"];
    [sql appendString:@"                                       AND R.USERID = P.USERID"];
    [sql appendString:@"  LEFT JOIN BO_SINGLE_PROJECT SP ON SP.BO_SINGLE_PROJECT_ID ="];
    [sql appendString:@"                                    P.BO_SINGLE_PROJECT_ID"];
    [sql appendString:@"                                AND SP.USERID = P.USERID"];
    [sql appendString:@"  LEFT JOIN BO_CONTENT C ON C.BO_PROBLEM_ID = P.BO_PROBLEM_ID"];
    [sql appendString:@"                        AND C.USERID = P.USERID"];
    [sql appendString:@" WHERE P.BO_PROBLEM_ID = ?"];
    [sql appendString:@"   AND P.USERID = ?"];
    NSArray *params = @[boProblemId, userid];
    return [self getUpperMapBySql:sql params:params];
}

/**
 * 更新待办
 *
 * @param massRecord
 * @author yanghua
 */
- (BOOL)updateProblem:(NSDictionary *)jso {
    NSString *sql = @"UPDATE BO_PROBLEM  SET EXAM_BASIS = ?,MASS_CHECK_TIME = ?,REMARK = ?, MEND_TIME_LIMIT = ?,ORG_CHECK = ?,ORG_CHECK_PAYMENT = ? WHERE BO_PROBLEM_ID = ?";
    
    NSArray *params = @[[jso objectForKey:@"EXAM_BASIS"],
                        [jso objectForKey:@"MASS_CHECK_TIME"],
                        [jso objectForKey:@"REMARK"],
                        [jso objectForKey:@"MEND_TIME_LIMIT"],
                        [jso objectForKey:@"ORG_CHECK"],
                        [jso objectForKey:@"ORG_CHECK_PAYMENT"],
                        [jso objectForKey:@"BO_PROBLEM_ID"]];
    
    return [self executeSql:sql params:params];
}

/**
 * 得到施工单位列表
 *
 * @return list
 * @author yanghua
 */
- (NSMutableArray *)getProblemOrgList:(NSString *)boProblemId boProblemReplyId:(NSString *)boProblemReplyId state:(NSString *)state userid:(NSString *)userid {
    NSArray *params;
    NSMutableString *sql = [[NSMutableString alloc] init];
    if ([state isEqualToString:@"QR"]) {
        [sql appendString:@"SELECT T.*"];
        [sql appendString:@"  FROM BO_PROBLEM_ORG T"];
        [sql appendString:@" WHERE T.BO_PROBLEM_ORG_ID IN (SELECT R.BO_PROBLEM_ORG_ID"];
        [sql appendString:@"                                 FROM BO_PROBLEM_REPLY R"];
        [sql appendString:@"                                WHERE R.BO_PROBLEM_REPLY_ID = ?"];
        [sql appendString:@"                                  AND R.USERID = ?)"];
        [sql appendString:@"   AND T.USERID = ?"];
        params = @[boProblemReplyId, userid, userid];
    } else {
        [sql appendString:@"SELECT T.* FROM BO_PROBLEM_ORG t WHERE t.BO_PROBLEM_ID = ? AND T.USERID = ? ORDER BY T.ORG_ID"];
        params = @[boProblemId, userid];
    }
    
    return [self getUpperListBySql:sql params:params];
}

/**
 * 得到下一家单位
 *
 * @return list
 * @author yanghua
 */
- (NSMutableArray *)getNextOrgList:(NSString *)boProblemId boProblemReplyId:(NSString *)boProblemReplyId curStatus:(NSString *)curStatus userid:(NSString *)userid {
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *params;
    if ([curStatus isEqualToString:@"4"] || [curStatus isEqualToString:@"8"] || [curStatus isEqualToString:@"11"] || [curStatus isEqualToString:@"14"]) {// 分公司确认时只取当前回复单位
        [sql appendString:@"SELECT T.*"];
        [sql appendString:@"  FROM BO_PROBLEM_ORG T"];
        [sql appendString:@" WHERE T.BO_PROBLEM_ORG_ID IN (SELECT R.BO_PROBLEM_ORG_ID"];
        [sql appendString:@"                                 FROM BO_PROBLEM_REPLY R"];
        [sql appendString:@"                                WHERE R.BO_PROBLEM_REPLY_ID = ?"];
        [sql appendString:@"                                  AND R.USERID = ?)"];
        [sql appendString:@"   AND T.USERID = ?"];
        
        params = @[boProblemReplyId, userid, userid];
    } else {
        [sql appendString:@"SELECT *"];
        [sql appendString:@"  FROM BO_PROBLEM_ORG O"];
        [sql appendString:@" WHERE O.BO_PROBLEM_ID = ?"];
        [sql appendString:@"   AND O.USERID = ?"];
        [sql appendString:@"   AND O.BO_PROBLEM_ORG_ID NOT IN"];
        [sql appendString:@"       (SELECT R.BO_PROBLEM_ORG_ID"];
        [sql appendString:@"          FROM BO_PROBLEM_REPLY R"];
        [sql appendString:@"         WHERE R.BO_PROBLEM_ID = ?"];
        [sql appendString:@"           AND R.STATUS = ?"];
        [sql appendString:@"           AND R.USERID = ?)"];
        
        params = @[boProblemId, userid, boProblemId, curStatus, userid];
    }

    return [self getUpperListBySql:sql params:params];
}

/**
 * 得到施工单位列表
 *
 * @return list
 * @author yanghua
 */
- (NSMutableArray *)getProblemOrg:(NSString *)boProblemOrgId userid:(NSString *)userid {
    NSString *sql = @"SELECT T.* FROM BO_PROBLEM_ORG t WHERE t.BO_PROBLEM_ORG_ID = ? AND T.USERID = ?";
    
    return [self getListBySql:sql params:@[boProblemOrgId, userid]];
}

/**
 * 删除
 *
 * @param boProblemOrgId
 * @return true or false
 * @author yanghua
 */
- (BOOL)deleteProblemOrg:(NSString *)boProblemOrgId userid:(NSString *)userid {
    NSString *sql = @"DELETE FROM BO_PROBLEM_ORG WHERE BO_PROBLEM_ORG_ID = ? AND USERID = ?";
    NSArray *params = @[boProblemOrgId, userid];
    
    return [self executeSql:sql params:params];
}

/**
 * 获得草稿id
 *
 * @param boContentId
 * @return boProblemId
 * @author yanghua
 */
- (NSString *)getDraftProblemId:(NSString *)boContentId userid:(NSString *)userid {
    NSString *sql = @"SELECT * FROM BO_PROBLEM P,BO_CONTENT T WHERE P.BO_PROBLEM_ID = T.BO_PROBLEM_ID AND T.BO_CONTENT_ID = ? AND P.USERID = ? AND T.USERID = ? AND P.IS_DRAFT = '1'";
    NSDictionary *draftProblem = [self getMapBySql:sql params:@[boContentId, userid, userid]];
    
    if (draftProblem != nil) {
        return [draftProblem objectForKey:@"bo_problem_id"];
    }
    
    return @"";
}

/**
 * 得到草稿信息
 *
 * @param boProblemId
 * @return map
 * @author yanghua
 */
- (NSDictionary *)getDraftInfo:(NSString *)boProblemId userid:(NSString *)userid {
    NSString *sql = @"SELECT * FROM BO_PROBLEM WHERE BO_PROBLEM_ID = ? AND IS_DRAFT = '1' AND USERID = ?";
    
    return [self getMapBySql:sql params:@[boProblemId, userid]];
}

/**
 * 校验扣分单位唯一性
 *
 * @param boProblemId
 * @param orgId
 * @return true or false
 * @author yanghua
 */
- (BOOL)doVolidate:(NSString *)boProblemId orgId:(NSString *)orgId boProblemOrgId:(NSString *)boProblemOrgId userid:(NSString *)userid {
    NSString *sql = @"SELECT * FROM BO_PROBLEM_ORG WHERE USERID = ? AND BO_PROBLEM_ID = ? AND ORG_ID = ? AND BO_PROBLEM_ORG_ID NOT IN (?)";
    NSArray *list = [self getListBySql:sql params:@[userid, boProblemId, orgId, boProblemOrgId]];
    
    if (list != nil && [list count] > 0) {
        return YES;
    }
    
    return NO;
}

/**
 * 获得当前已选合作单位
 *
 * @param boProblemReplyId
 * @return list
 * @author yanghua
 */
- (NSString *)getProblemOrgIds:(NSString *)boProblemId userid:(NSString *)userid {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT T.*"];
    [sql appendString:@"  FROM BO_PROBLEM_ORG T"];
    [sql appendString:@" WHERE T.BO_PROBLEM_ID = ?"];
    [sql appendString:@"   AND T.USERID = ?"];
    
    NSArray *list = [self getListBySql:sql params:@[boProblemId, userid]];
    
    NSMutableString *ids = [[NSMutableString alloc] init];
    
    if (list != nil && [list count] > 0) {
        int i = 0;
        for (NSDictionary *dic in list) {
            if (i != [list count] - 1) {
                [ids appendString:[NSString stringWithFormat:@"%@,", [dic objectForKey:@"org_id"]]];
            } else {
                [ids appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"org_id"]]];
            }
            i++;
        }
    }
    
    return ids;
}

/**
 * 删除草稿
 *
 * @param boProblemId
 * @return true or false
 * @author yanghua
 */
- (BOOL)deleteProblemDraft:(NSString *)boProblemId userid:(NSString *)userid {
    NSString *sql = @"DELETE FROM BO_PROBLEM WHERE BO_PROBLEM_ID = ? AND USERID = ?";
    NSArray *params = @[boProblemId, userid];
    
    return [self executeSql:sql params:params];
}

- (BOOL) insertOneRecord:(NSDictionary *)jsonDictionary userid:(NSString *)userid {
    BOOL result1 = NO;
    BOOL result2 = NO;
    BOOL result3 = NO;
    BOOL result4 = NO;
    BOOL result5 = NO;
    result1 = [self saveProblem:jsonDictionary userid:userid];
    result2 = [self saveProblemOrg:jsonDictionary userid:userid];
    result3 = [self saveProblemReply:jsonDictionary userid:userid];
    result4 = [self saveRelativeOrg:jsonDictionary];
    result5 = [self saveContent:jsonDictionary userid:userid];
    return result1 & result2 & result3 &result4 &result5;
}

/**
 * 获得下级扣分单位
 *
 * @author yanghua
 */
- (NSArray *)getOrgList:(NSString *)boSingleProjectId roleId:(NSString *)roleId userid:(NSString *)userid{
    if([@"" isEqualToString:roleId]){
        return nil;
    }
    NSArray *params;
    NSMutableString *condition = [[NSMutableString alloc] init];
    if([roleId rangeOfString:CITY_QUALITY_MANAGER].location != NSNotFound){
        [condition appendString:@" AND BO_SINGLE_PROJECT_ID = ? AND ORG_TYPE = ?"];
        params = @[boSingleProjectId, @"SZ"];
    }else if([roleId rangeOfString:CITY_MAJOR_MANAGER].location != NSNotFound){
        [condition appendString:@" AND BO_SINGLE_PROJECT_ID = ? AND ORG_TYPE = ?"];
        params = @[boSingleProjectId, @"FGS"];
    }else if([roleId rangeOfString:AREA_EXECUTIVE_USER].location != NSNotFound){
        [condition appendString:@" AND BO_SINGLE_PROJECT_ID = ? AND ORG_TYPE IN (?,?,?)"];
        params = @[boSingleProjectId, @"SG",@"JL",@"SJ"];
    }else if([roleId rangeOfString:SUPERVISION].location != NSNotFound){
        [condition appendString:@" AND BO_SINGLE_PROJECT_ID = ? AND ORG_TYPE IN (?,?)"];
        params = @[boSingleProjectId, @"SG",@"SJ"];
    }else {
        [condition appendString:@" AND BO_SINGLE_PROJECT_ID = ?"];
        params = @[boSingleProjectId];
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT ORG_ID,ORG_NAME FROM BO_PROJ_ORG WHERE 1=1"];
    [sql appendString:condition];
    return [self getUpperListBySql:sql params:params];
}

/**
 * 获得整改照片列表
 *
 * @author yanghua
 */
- (NSArray *)getProblemPhotoList:(NSString *)boProblemId boProblemReplyId:boProblemReplyId userid:(NSString *)userid{
    NSMutableString *condition = [[NSMutableString alloc] init];
    NSMutableArray *params = @[boProblemId,userid];
    if(boProblemReplyId !=nil && ![@"" isEqualToString:boProblemReplyId]){
        [condition appendString:@" OR P.BO_PROBLEM_REPLY_ID = ?"];
        params = @[boProblemId,boProblemReplyId,userid];
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT C.POINT_NAME, COUNT(1) PHOTO_COUNT"];
    [sql appendString:@"  FROM BO_CRITICAL_POINT_VER C, BO_PHOTO P"];
    [sql appendString:@" WHERE P.BO_CRITICAL_POINT_VER_ID = C.BO_CRITICAL_POINT_VER_ID"];
    [sql appendString:@"   AND (P.BO_PROBLEM_ID = ? "];
    [sql appendString:condition];
    [sql appendString:@"   ) AND P.USERID = ?"];
    [sql appendString:@" GROUP BY C.ORD_NUM"];
    NSMutableArray *list = [self getUpperListBySql:sql params:params];
    for(NSMutableDictionary *dict in list){
        NSString *pointName = [dict objectForKey:@"POINT_NAME"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"，共\\([0-9]*\\)张" options:NSRegularExpressionCaseInsensitive error:nil];
        pointName = [regex stringByReplacingMatchesInString:pointName options:0 range:NSMakeRange(0, [pointName length]) withTemplate:@""];
        [dict setValue:pointName forKey:@"POINT_NAME"];
    }
    return list;
}

/**
 * 是否存在与整改相关单位
 *
 * @author yanghua
 */
-(BOOL)isRelativeOrgExists:(NSString *)boSingleProjectId userId:(NSString *)userid{
    NSArray *list = [self getOrgList:boSingleProjectId roleId:@"" userid:userid];
    if(![BaseFunction isArrayEmpty:list]){
        return YES;
    }
    return NO;
}

/**
 * 保存整改content
 *
 * @author yanghua
 */
-(BOOL) saveContent:(NSDictionary *)jso userid:(NSString *) userid{
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"REPLACE INTO BO_CONTENT"];
    [sql appendString:@"  (BO_CONTENT_ID,"];
    [sql appendString:@"   BO_TEMPLATE_DETAIL_VER_ID,"];
    [sql appendString:@"   BO_SINGLE_PROJECT_ID,"];
    [sql appendString:@"   BO_PROJECT_SECTION_ID,"];
    [sql appendString:@"   BO_CONTENT_NAME,"];
    [sql appendString:@"   BO_TOTAL_NUM,"];
    [sql appendString:@"   BO_CURRENT_NUM,"];
    [sql appendString:@"   CREATE_DATE,"];
    [sql appendString:@"   IS_DOWNLOAD,"];
    [sql appendString:@"   UPDATE_DATE,"];
    [sql appendString:@"   DOMAIN_ID,"];
    [sql appendString:@"   USERID,"];
    [sql appendString:@"   CONTENT_TYPE,"];
    [sql appendString:@"   BO_CHECK_PROJECT_ID,"];
    [sql appendString:@"   OTHER_TYPE,"];
    [sql appendString:@"   BO_PROBLEM_ID)"];
    [sql appendString:@"VALUES"];
    [sql appendString:@"  (?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   DATETIME(CURRENT_TIMESTAMP, 'localtime'),"];
    [sql appendString:@"   '1',"];
    [sql appendString:@"   DATETIME(CURRENT_TIMESTAMP, 'localtime'),"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   ?,"];
    [sql appendString:@"   '1',"];
    [sql appendString:@"   ?)"];
    NSArray *params = @[[BaseFunction safeGetValueByKey:jso Key:@"BO_CONTENT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_TEMPLATE_DETAIL_VER_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_SINGLE_PROJECT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROJECT_SECTION_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_CONTENT_NAME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_TOTAL_NUM"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_CURRENT_NUM"],
                        [BaseFunction safeGetValueByKey:jso Key:@"DOMAIN_ID"],
                        userid,
                        [BaseFunction safeGetValueByKey:jso Key:@"CONTENT_TYPE"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_CHECK_PROJECT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ID"]];
    
    return [self executeSql:sql params:params];
}

/**
 * 更新整改临时记录
 * @param problemRecord
 * @return true or false
 * @author yanghua
 */
- (BOOL) saveDraftProblem:(NSDictionary *)jso userid:(NSString *)userid{
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"REPLACE INTO BO_PROBLEM"];
    [sql appendString:@"  (BO_PROBLEM_ID, BO_SINGLE_PROJECT_ID, MEND_TIME_LIMIT, USERID, CREATE_TIME, TYPES)"];
    [sql appendString:@"VALUES"];
    [sql appendString:@"  (?, ?, ?, ?, datetime(CURRENT_TIMESTAMP,'localtime'), ?)"];
    NSArray *params = @[[BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_SINGLE_PROJECT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"MEND_TIME_LIMIT"],
                        userid,
                        [BaseFunction safeGetValueByKey:jso Key:@"TYPES"],];
    return [self executeSql:sql params:params];
}

/**
 * 保存问题回复记录
 *
 * @author yanghua
 */
-(BOOL)saveProblemReplyRecord:(NSDictionary *)jso state:(NSString *)state userid:(NSString *)userid{
    NSString *zdStr = [[NSString alloc]init];
    NSArray *params;
    if([@"HF" isEqualToString:state]){
        zdStr = @"REPLY_CONTENT = ?";
        params = @[[jso objectForKey:@"REPLY_CONTENT"],
                   [jso objectForKey:@"BO_PROBLEM_REPLY_ID"],
                   userid];
    }else if([@"QR" isEqualToString:state]){
        zdStr = @"REJECT_ONE = ?,REJECT_TWO = ?,REJECT_THREE = ?";
        params = @[[jso objectForKey:@"REJECT_ONE"],
                   [jso objectForKey:@"REJECT_TWO"],
                   [jso objectForKey:@"REJECT_THREE"],
                   [jso objectForKey:@"BO_PROBLEM_REPLY_ID"],
                   userid];
    }else{
        return YES;
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@" UPDATE BO_PROBLEM_REPLY SET "];
    [sql appendString:zdStr];
    [sql appendString:@" WHERE BO_PROBLEM_REPLY_ID = ? AND USERID = ?"];
    return [self executeSql:sql params:params];
}

/**
 * 获得ORG_TYPE
 *
 * @author yanghua
 */
-(NSString *) getOrgTypeByOrgId:(NSString *)orgId{
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@" SELECT ORG_TYPE FROM BO_PROJ_ORG T WHERE T.ORG_ID = ?"];
    NSDictionary *dict = [self getUpperMapBySql:sql params:@[orgId]];
    return [BaseFunction safeGetValueByKey:dict Key:@"ORG_TYPE"];
}
@end
