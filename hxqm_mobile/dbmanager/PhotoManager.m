//
//  PhotoManager.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/15/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "PhotoManager.h"
#import "MyMacros.h"
#import "LogUtils.h"
#import "Constants.h"
#import "BaseFunction.h"

#define TAG @"PhotoManager"

@implementation PhotoManager

/**
 * 得到本次总共上传大小，已经上传大小
 *
 * @param boSingleProjectId
 * @return
 */
- (NSMutableArray *)getContentListBySingleProjectId:(NSString *)boSingleProjectId boProjectSectionId:(NSString *)boProjectSectionId type:(NSString *)type auth:(NSArray *)auth userid:(NSString *)userid {
    
    NSString *condition = @"";
    NSArray *params;
    if (IsStringNotEmpty(boProjectSectionId)) {
        params = @[userid, userid, userid, userid, userid, userid, boSingleProjectId, boProjectSectionId, userid, boSingleProjectId, userid, userid];
        condition = @"AND P.BO_PROJECT_SECTION_ID = ?";
    } else {
        params = @[userid, userid, userid, userid, userid, userid, boSingleProjectId,  userid, boSingleProjectId, userid, userid];
    }
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT P.BO_CONTENT_ID,                                                                 "];
    [sql appendString:@"       P.BO_CONTENT_NAME,                                                               "];
    [sql appendString:@"       P.BO_TEMPLATE_DETAIL_VER_ID,                                                     "];
    [sql appendString:@"       P.BO_SINGLE_PROJECT_ID,                                                          "];
    [sql appendString:@"       P.BO_PROJECT_SECTION_ID,                                                         "];
    [sql appendString:@"       P.BO_TOTAL_NUM,                                                                  "];
    [sql appendString:@"       P.BO_CURRENT_NUM,                                                                "];
    [sql appendString:@"       P.CREATE_DATE,                                                                   "];
    [sql appendString:@"       P.UPDATE_DATE,                                                                   "];
    [sql appendString:@"       P.IS_DOWNLOAD,                                                                   "];
    [sql appendString:@"       P.DOMAIN_ID,                                                                     "];
    [sql appendString:@"       V1.TOTAL_SIZE TOTAL_PHOTO_SIZE,                                                  "];
    [sql appendString:@"       V2.UPLOAD_SIZE CURRENT_UPLOAD_SIZE,                                              "];
    [sql appendString:@"       P.CONTENT_TYPE,                                                                  "];
    [sql appendString:@"       P.OTHER_TYPE,                                                                    "];
    [sql appendString:@"       P.BO_CHECK_PROJECT_ID,                                                           "];
    [sql appendString:@"       V3.LIMIT_TIME,                                                                   "];
    [sql appendString:@"       V3.CHECK_STATE,                                                                  "];
    [sql appendString:@"       V3.CHECK_TYPE,                                                                   "];
    [sql appendString:@"       V4.CUR_NUM,                                                                      "];
    [sql appendString:@"       R.BO_PROBLEM_ID,                                                                 "];
    [sql appendString:@"       R.BO_PROBLEM_REPLY_ID,                                                           "];
    [sql appendString:@"       R.STATUS,                                                                        "];
    [sql appendString:@"       R.TYPES,                                                                         "];
    [sql appendString:@"       R.MEND_TIME_LIMIT                                                                "];
    [sql appendString:@"  FROM BO_CONTENT P                                                                     "];
    [sql appendString:@"  LEFT JOIN (SELECT COUNT(PHOTO_SIZE) TOTAL_SIZE, BO_CONTENT_ID                         "];
    [sql appendString:@"               FROM BO_PHOTO                                                            "];
    [sql appendString:@"               WHERE USERID = ?                                                         "];
    [sql appendString:@"              GROUP BY BO_CONTENT_ID) V1 ON P.BO_CONTENT_ID = V1.BO_CONTENT_ID          "];
    [sql appendString:@"  LEFT JOIN (SELECT COUNT(PHOTO_SIZE) UPLOAD_SIZE, BO_CONTENT_ID                        "];
    [sql appendString:@"               FROM BO_PHOTO                                                            "];
    [sql appendString:@"              WHERE IS_UPLOAD = '2'                                                     "];
    [sql appendString:@"              AND USERID = ?                                                            "];
    [sql appendString:@"              GROUP BY BO_CONTENT_ID) V2 ON P.BO_CONTENT_ID = V2.BO_CONTENT_ID          "];
    [sql appendString:@"  LEFT JOIN (SELECT CP.BO_CHECK_PROJECT_ID,CP.LIMIT_TIME,CP.CHECK_STATE,CP.CHECK_TYPE   "];
    [sql appendString:@"               FROM BO_CHECK_PROJECT CP WHERE CP.USERID =?) V3                          "];
    [sql appendString:@"            ON P.BO_CHECK_PROJECT_ID = V3.BO_CHECK_PROJECT_ID                           "];
    [sql appendString:@"  LEFT JOIN(SELECT W.BO_CONTENT_ID, COUNT(1) CUR_NUM                                    "];
    [sql appendString:@"            FROM (SELECT V.BO_CONTENT_ID, CPV.POINT_NAME                                "];
    [sql appendString:@"                    FROM BO_PHOTO V, BO_CRITICAL_POINT_VER CPV                          "];
    [sql appendString:@"                    WHERE V.BO_CRITICAL_POINT_VER_ID = CPV.BO_CRITICAL_POINT_VER_ID     "];
    [sql appendString:@"                      AND V.USERID = ?                                                  "];
    [sql appendString:@"                      AND CPV.NEED_VALIDATE = '1'                                       "];
    [sql appendString:@"                    GROUP BY V.BO_CONTENT_ID, CPV.POINT_NAME) W                         "];
    [sql appendString:@"            GROUP BY W.BO_CONTENT_ID) V4 ON P.BO_CONTENT_ID = V4.BO_CONTENT_ID          "];
    [sql appendString:@"  LEFT JOIN (SELECT PR.BO_PROBLEM_ID,PR.BO_PROBLEM_REPLY_ID,PR.STATUS,PR.PROBLEM_STATE, "];
    [sql appendString:@"                    BP.MEND_TIME_LIMIT,BP.TYPES                                         "];
    [sql appendString:@"             FROM BO_PROBLEM_REPLY PR,BO_PROBLEM BP                                     "];
    [sql appendString:@"             WHERE PR.BO_PROBLEM_ID = BP.BO_PROBLEM_ID  AND PR.USERID = ?               "];
    [sql appendString:@"               AND BP.USERID = ?) R                                                     "];
    [sql appendString:@"  ON P.BO_PROBLEM_ID = R.BO_PROBLEM_ID                                                  "];
    [sql appendString:@"WHERE P.BO_SINGLE_PROJECT_ID = ?                                                        "];
    [sql appendString:@" AND (                                                                                  "];
    if ((![type isEqualToString:@"2"]) && [auth containsObject:@"巡检"]) {// 待办页面进入看不到巡检
        [sql appendString:@" CONTENT_TYPE =1 OR                                                                 "];
    }
    [sql appendString:@" (CONTENT_TYPE = 3 AND R.PROBLEM_STATE = 1 AND R.TYPES IN ('1','4') )                   "];// 项目和签证整改待办
    [sql appendString:@" OR  (CONTENT_TYPE = 2 AND V3.CHECK_STATE = 2 AND BO_TOTAL_NUM = 0 AND P.OTHER_TYPE != '10'))                "];
    [sql appendString:condition];
    [sql appendString:@" AND P.USERID = ?                                              						    "];
    // 新增整改草稿
    [sql appendString:@" UNION ALL "];
    [sql appendString:@"SELECT PP.BO_CONTENT_ID,                                                                "];
    [sql appendString:@"       PP.BO_CONTENT_NAME,                                                              "];
    [sql appendString:@"       PP.BO_TEMPLATE_DETAIL_VER_ID,                                                    "];
    [sql appendString:@"       PP.BO_SINGLE_PROJECT_ID,                                                         "];
    [sql appendString:@"       PP.BO_PROJECT_SECTION_ID,                                                        "];
    [sql appendString:@"       PP.BO_TOTAL_NUM,                                                                 "];
    [sql appendString:@"       PP.BO_CURRENT_NUM,                                                               "];
    [sql appendString:@"       PP.CREATE_DATE,                                                                  "];
    [sql appendString:@"       PP.UPDATE_DATE,                                                                  "];
    [sql appendString:@"       PP.IS_DOWNLOAD,                                                                  "];
    [sql appendString:@"       PP.DOMAIN_ID,                                                                    "];
    [sql appendString:@"       '' TOTAL_PHOTO_SIZE,                                                             "];
    [sql appendString:@"       '' CURRENT_UPLOAD_SIZE,                                                          "];
    [sql appendString:@"       PP.CONTENT_TYPE,                                                                 "];
    [sql appendString:@"       PP.OTHER_TYPE,                                                                   "];
    [sql appendString:@"       PP.BO_CHECK_PROJECT_ID,                                                          "];
    [sql appendString:@"       '' LIMIT_TIME,                                                                   "];
    [sql appendString:@"       '' CHECK_STATE,                                                                  "];
    [sql appendString:@"       '' CUR_NUM,                                                                      "];
    [sql appendString:@"       '' CHECK_TYPE,                                                                   "];
    [sql appendString:@"       BP1.BO_PROBLEM_ID,                                                               "];
    [sql appendString:@"       '' BO_PROBLEM_REPLY_ID,                                                          "];
    [sql appendString:@"       '' STATUS,                                                                       "];
    [sql appendString:@"       BP1.TYPES,                                                                       "];
    [sql appendString:@"       BP1.MEND_TIME_LIMIT                                                              "];
    [sql appendString:@"  FROM BO_CONTENT PP,BO_PROBLEM BP1                                                     "];
    [sql appendString:@"WHERE PP.OTHER_TYPE = '10' AND BO_TOTAL_NUM = 0 AND PP.BO_PROBLEM_ID = BP1.BO_PROBLEM_ID AND PP.BO_SINGLE_PROJECT_ID = ? AND PP.USERID = ?  AND BP1.USERID = ?"];
    return [self getListBySql:sql params:params];
}

/**
 * 更新照片为已上传
 *
 * @param boPhotoId
 * @param status
 * @return
 */
- (BOOL)updataPhotoUploadStatus:(NSString *)boPhotoId status:(NSString *)status userid:(NSString *)userid {
    NSString *sql = @"UPDATE BO_PHOTO SET IS_UPLOAD = ? WHERE BO_PHOTO_ID = ? AND USERID = ?";
    NSArray *params = @[status, boPhotoId, userid];
    
    return [self executeSql:sql params:params];
}

/**
 * 得到上传照片列表
 *
 * @return
 */
- (NSMutableArray *)getCheckUploadPhotoList:(NSMutableDictionary *)inputData userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT T.BO_PHOTO_ID,   ",
                          @"          T.PHOTO_NAME, ",
                          @"          T.PHOTO_PATH, ",
                          @"         T.BO_CRITICAL_POINT_VER_ID, ",
                          @"          T.POINT_NAME, ",
                          @"          T.BO_SINGLE_PROJECT_ID, ",
                          @"          T.BO_PROJECT_SECTION_ID, ",
                          @"          T.FILE_PREFIX, ",
                          @"          T.FILE_SUFFIX, ",
                          @"          T.CREATE_USERID, ",
                          @"          T.MEMO, ",
                          @"          T.LATITUDE, ",
                          @"          T.LONGITUDE, ",
                          @"          T.CREATE_DATE, ",
                          @"          T.REF_MINEIMAGE_ID, ",
                          @"         T.IS_FORMAL,  ",
                          @"          T.PHOTO_TYPE, ",
                          @"          T.PHOTO_SIZE,  ",
                          @"          T.IMAGE_QUALITY, ",
                          @"          T.IS_DOODLED, ",
                          @"          P.BO_CONTENT_NAME, ",
                          @"          P.BO_TEMPLATE_DETAIL_VER_ID, ",
                          @"          P.E, ",
                          @"          P.N, ",
                          @"          T.SERIALIZE_NUM,  ",
                          @"          P.BO_CHECK_PROJECT_ID,  ",
                          @"          T.BO_CONTENT_ID, ",
                          @"          T.BO_PROBLEM_ID, ",
                          @"          T.BO_PROBLEM_REPLY_ID ",
                          @"   FROM BO_PHOTO T LEFT JOIN (                                       ",
                          @"     SELECT M.BO_CONTENT_ID MBO_CONTENT_ID,N.LONGITUDE E,N.LATITUDE N,",
                          @"            M.BO_CONTENT_NAME BO_CONTENT_NAME,  ",
                          @"            M.BO_TEMPLATE_DETAIL_VER_ID BO_TEMPLATE_DETAIL_VER_ID,   ",
                          @"            M.BO_CHECK_PROJECT_ID BO_CHECK_PROJECT_ID                ",
                          @"     FROM BO_CONTENT M,BO_SINGLE_PROJECT N                           ",
                          @"     WHERE M.BO_SINGLE_PROJECT_ID = N.BO_SINGLE_PROJECT_ID           ",
                          @"     AND M.USERID = N.USERID                                         ",
                          @"     AND N.USERID = ?                                                ",
                          @"     AND N.DELETE_FLAG != '2'                                        ",
                          @"   )P ON T.BO_CONTENT_ID = P.MBO_CONTENT_ID                          ",
                          @"   WHERE T.IS_UPLOAD = 1 AND T.USERID =?                             ",
                          @"   AND T.BO_CONTENT_ID = ?                                           ",
                          @"   UNION ALL                                                         ",
                          @"  SELECT TT.BO_PHOTO_ID,                                             ",
                          @"          TT.PHOTO_NAME,                                              ",
                          @"          TT.PHOTO_PATH,                                              ",
                          @"          TT.BO_CRITICAL_POINT_VER_ID,                                ",
                          @"          TT.POINT_NAME,                                              ",
                          @"          TT.BO_SINGLE_PROJECT_ID,                                    ",
                          @"          TT.BO_PROJECT_SECTION_ID,                                   ",
                          @"          TT.FILE_PREFIX,                                             ",
                          @"          TT.FILE_SUFFIX,                                             ",
                          @"          TT.CREATE_USERID,                                           ",
                          @"          TT.MEMO,                                                    ",
                          @"          TT.LATITUDE,                                                ",
                          @"          TT.LONGITUDE,                                               ",
                          @"          TT.CREATE_DATE,                                             ",
                          @"          TT.REF_MINEIMAGE_ID,                                        ",
                          @"          TT.IS_FORMAL,                                               ",
                          @"          TT.PHOTO_TYPE,                                              ",
                          @"          TT.PHOTO_SIZE,                                              ",
                          @"          TT.IMAGE_QUALITY,                                           ",
                          @"          TT.IS_DOODLED,                                        	     ",
                          @"          '' BO_CONTENT_NAME,                                         ",
                          @"          '' BO_TEMPLATE_DETAIL_VER_ID,                               ",
                          @"          '' E,                                                       ",
                          @"          '' N,                                                       ",
                          @"          TT.SERIALIZE_NUM,                                           ",
                          @"          '' BO_CHECK_PROJECT_ID,                                     ",
                          @"          TT.BO_CONTENT_ID,                                           ",
                          @"          TT.BO_PROBLEM_ID,                                            ",
                          @"          TT.BO_PROBLEM_REPLY_ID                                       ",
                          @"   FROM BO_PHOTO TT                                                   ",
                          @"   WHERE TT.BO_CONTENT_ID = '' AND TT.IS_FORMAL = ''                  ",
                          @"   AND TT.IS_UPLOAD = 1 AND USERID = ?                                "];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }

    NSArray *params = @[userid, userid, [inputData objectForKey:@"BO_CONTENT_ID"], userid];
    
    return [self getListBySql:sql params:params];
}

/**
 * 得到上传照片列表
 *
 * @return
 */
- (NSMutableArray *)getXjUploadPhotoList:(NSMutableDictionary *)inputData userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT T.BO_PHOTO_ID,    ",
                          @"          T.PHOTO_NAME,                                              ",
                          @"          T.PHOTO_PATH,                                              ",
                          @"          T.BO_CRITICAL_POINT_VER_ID,                                ",
                          @"          T.POINT_NAME,                                              ",
                          @"          T.BO_SINGLE_PROJECT_ID,                                    ",
                          @"          T.BO_PROJECT_SECTION_ID,                                   ",
                          @"          T.FILE_PREFIX,                                             ",
                          @"          T.FILE_SUFFIX,                                             ",
                          @"          T.CREATE_USERID,                                           ",
                          @"          T.MEMO,                                                    ",
                          @"          T.LATITUDE,                                                ",
                          @"          T.LONGITUDE,                                               ",
                          @"          T.CREATE_DATE,                                             ",
                          @"          T.REF_MINEIMAGE_ID,                                        ",
                          @"          T.IS_FORMAL,                                               ",
                          @"          T.PHOTO_TYPE,                                              ",
                          @"          T.PHOTO_SIZE,                                              ",
                          @"          T.IMAGE_QUALITY,                                           ",
                          @"          T.IS_DOODLED,                                        	    ",
                          @"          P.BO_CONTENT_NAME,                                         ",
                          @"          P.BO_TEMPLATE_DETAIL_VER_ID,                               ",
                          @"          P.E,                                                       ",
                          @"          P.N,                                                       ",
                          @"          T.SERIALIZE_NUM                                            ",
                          @"   FROM BO_PHOTO T LEFT JOIN (                                       ",
                          @"     SELECT M.BO_CONTENT_ID MBO_CONTENT_ID,N.LONGITUDE E,N.LATITUDE N,",
                          @"            M.BO_CONTENT_NAME BO_CONTENT_NAME,                       ",
                          @"            M.BO_TEMPLATE_DETAIL_VER_ID BO_TEMPLATE_DETAIL_VER_ID    ",
                          @"     FROM BO_CONTENT M,BO_SINGLE_PROJECT N                           ",
                          @"     WHERE M.BO_SINGLE_PROJECT_ID = N.BO_SINGLE_PROJECT_ID           ",
                          @"     AND M.USERID = N.USERID                                         ",
                          @"     AND N.USERID = ?                                                ",
                          @"     AND N.DELETE_FLAG != '2'                                        ",
                          @"   )P ON T.BO_CONTENT_ID = P.MBO_CONTENT_ID                          ",
                          @"   WHERE T.IS_UPLOAD = 1 AND T.USERID =?                             ",
                          @"   AND IS_FORMAL !='3'                                               ",
                          @"   ORDER BY BO_CONTENT_ID                                            "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = @[userid, userid];
    
    return [self getListBySql:sql params:params];
}

/**
 * 得到上传照片总数
 *
 * @return
 */
- (NSString *)getUploadPhotoCounts:(NSString *)userid {
    NSString *sql = @"SELECT COUNT(*) COUNTS FROM BO_PHOTO T  WHERE T.IS_UPLOAD = 1 AND USERID = ? AND (T.PHOTO_TYPE = 2 OR (T.IS_FORMAL=1 AND T.PHOTO_TYPE=1))";
    NSArray *params = @[userid];
    
    return [self getStringBySql:sql params:params key:@"COUNTS"];
}

/**
 * 得到上传基站数量，表单数量，照片数量
 *
 * @return
 */
- (NSDictionary *)getUploadMsg:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT COUNT(SITECOUNTS) SITECOUNTS, ",
                          @"       SUM(FORMCOUNTS) FORMCOUNTS, ",
                          @"       SUM(PHOTOCOUNTS) PHOTOCOUNTS ",
                          @"  FROM (SELECT COUNT(BO_SINGLE_PROJECT_ID) SITECOUNTS, ",
                          @"               COUNT(BO_CONTENT_ID) FORMCOUNTS, ",
                          @"               SUM(PHOTOCOUNTS) PHOTOCOUNTS ",
                          @"          FROM (SELECT F.BO_SINGLE_PROJECT_ID, ",
                          @"                       F.BO_CONTENT_ID BO_CONTENT_ID, ",
                          @"                       COUNT(P.BO_PHOTO_ID) PHOTOCOUNTS ",
                          @"                  FROM BO_CONTENT F, ",
                          @"                       (SELECT * FROM BO_PHOTO P WHERE P.IS_UPLOAD = '1' AND P.BO_CONTENT_ID IS NOT NULL AND P.USERID = ?) P ",
                          @"                 WHERE F.BO_CONTENT_ID = P.BO_CONTENT_ID ",
                          @"                 AND  F.USERID = ?",
                          @"                 GROUP BY F.BO_SINGLE_PROJECT_ID, F.BO_CONTENT_ID) T ",
                          @"         GROUP BY BO_SINGLE_PROJECT_ID) "];
    NSArray *params = @[userid, userid];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    return [self getMapBySql:sql params:params];
}

/**
 * 更改照片对于的检查照片
 *
 * @param photoId
 */
- (BOOL)updateChildPhoto:(NSString *)photoId userid:(NSString *)userid {
    NSArray *sqlArray = @[@"UPDATE BO_PHOTO",
                          @"  SET PARENT_PHOTO_ID = ?",
                          @"  WHERE EXISTS(",
                          @"  SELECT 1  FROM BO_PHOTO P ",
                          @"  WHERE BO_PHOTO.T_DATE + 1> P.T_DATE ",
                          @"  AND BO_PHOTO.T_DATE-1 <P.T_DATE ",
                          @"  AND BO_PHOTO.BO_FORM_ID = P.BO_FORM_ID",
                          @"  AND P.PHOTO_ID=?",
                          @")",
                          @"  AND PARENT_PHOTO_ID != '0' AND USERID = ?"];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    NSArray *params = @[photoId, photoId, userid];
    
    return [self executeSql:sql params:params];
}

/**
 * 更新照片信息
 */
- (BOOL)updatePhoto:(NSString *)photoId photoName:(NSString *)photoName path:(NSString *)path date:(NSString *)date fileSize:(long)fileSize longitude:(float)longitude latitude:(float)latitude parentPhtotId:(NSString *)parentPhtotId userid:(NSString *)userid {
    NSString *sql = @"UPDATE BO_PHOTO SET PHOTO_ID = ?,PHOTO_NAME = ?,T_DATE = ?,PHOTO_URI = ?,PHOTO_SIZE=?, LONGITUDE=?, LATITUDE=?,   WHERE PHOTO_ID = ? AND USERID = ?";
    
    NSArray *params = @[photoId, photoName, date, path, [NSString stringWithFormat:@"%ld", fileSize] , [NSString stringWithFormat:@"%f", longitude], [NSString stringWithFormat:@"%f", latitude], parentPhtotId, userid];
    
    return [self executeSql:sql params:params];
}

/**
 * 插入照片信息
 */
- (BOOL)insertPhoto:(NSString *)boPhotoId photoName:(NSString *)photoName photoPath:(NSString *)photoPath boCriticalPointVerId:(NSString *)boCriticalPointVerId pointName:(NSString *)pointName boSingleProjectId:(NSString *)boSingleProjectId boProjectSelectionId:(NSString *)boProjectSelectionId boContentId:(NSString *)boContentId filePrefix:(NSString *)filePrefix fileSuffix:(NSString *)fileSuffix description:(NSString *)description memo:(NSString *)memo longitude:(NSString *)longitude latitude:(NSString *)latitude createDate:(NSString *)createDate refMineImageId:(NSString *)refMineImageId isFormal:(NSString *)isFormal photoType:(NSString *)photoType isUpload:(NSString *)isUpload photoSize:(NSString *)photoSize serializeNum:(NSString *)serializeNum boProblemId:(NSString *)boProblemId boProblemReplyId:(NSString *)boProblemReplyId userid:(NSString *)userid {
    NSArray *sqlArray = @[@"INSERT INTO BO_PHOTO(BO_PHOTO_ID,                              ",
                          @"                          PHOTO_NAME,                          ",
                          @"                          PHOTO_PATH,                          ",
                          @"                          BO_CRITICAL_POINT_VER_ID,            ",
                          @"                          POINT_NAME,                          ",
                          @"                          BO_SINGLE_PROJECT_ID,                ",
                          @"                          BO_PROJECT_SECTION_ID,               ",
                          @"                          BO_CONTENT_ID,                       ",
                          @"                          FILE_PREFIX,                         ",
                          @"                          FILE_SUFFIX,                         ",
                          @"                          CREATE_USERID,                       ",
                          @"                          DISCRIPTION,                         ",
                          @"                          MEMO,                                ",
                          @"                          LONGITUDE,                           ",
                          @"                          LATITUDE,                            ",
                          @"                          CREATE_DATE,                         ",
                          @"                          REF_MINEIMAGE_ID,                    ",
                          @"                          IS_FORMAL,                           ",
                          @"                          PHOTO_TYPE,                          ",
                          @"                          IS_UPLOAD,                           ",
                          @"                          PHOTO_SIZE,                          ",
                          @"                          IMAGE_QUALITY,                       ",
                          @"                          IS_DOWNLOAD,                         ",
                          @"                          SERIALIZE_NUM,                       ",
                          @"                          DOWNLOAD_URL,                        ",
                          @"                          BO_PROBLEM_REPLY_ID,                 ",
                          @"                          BO_PROBLEM_ID,                       ",
                          @"                          USERID)                              ",
                          @"  VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)  "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSArray *params = [NSArray arrayWithObjects:boPhotoId, photoName, photoPath, boCriticalPointVerId, pointName, boSingleProjectId, boProjectSelectionId, boContentId, filePrefix, fileSuffix, userid, description, memo, longitude, latitude, createDate, refMineImageId, isFormal, photoType, isUpload, photoSize, @"1", @"2", serializeNum, [NSString stringWithFormat:@"%@%@%@%@", photoPath, @"/", filePrefix, fileSuffix], boProblemReplyId, boProblemId, userid, nil];
    
    return [self executeSql:sql params:params];
}

/**
 * 根据表单 得到每个拍照点照片数量
 *
 * @param boFormId
 * @return
 */
- (NSMutableArray *)getPhotoCountList:(NSString *)boContentId userid:(NSString *)userid {
    NSString *sql = @"SELECT COUNT(1) FROM BO_PHOTO WHERE BO_CONTENT_ID = ? AND USERID = ? GROUP BY POINT_NAME";
    NSArray *params = @[boContentId, userid];
    
    return [self getListBySql:sql params:params];
}

/**
 * 删除照片信息
 *
 * @param boPhotoId
 * @return
 */
- (BOOL)deletePhoto:(NSString *)boPhotoId userid:(NSString *)userid {
    NSString *sql = @"DELETE FROM BO_PHOTO WHERE BO_PHOTO_ID = ? AND USERID = ?";
    NSArray *params = @[boPhotoId, userid];
    
    return [self executeSql:sql params:params];
}

/**
 * 通过控制点ID得到照片列表
 *
 * @param boFormId
 * @return
 */
- (NSMutableArray *)getPhotoListByContentId:(NSString *)boContentId {
    NSString *sql = @"SELECT BO_PHOTO_ID,PHOTO_NAME,PHOTO_PATH||'/'||FILE_PREFIX||FILE_SUFFIX FILE_PATH FROM BO_PHOTO WHERE BO_CONTENT_ID = ? AND IS_DOWNLOAD = '2'  AND USERID = ?";
    return [self getListBySql:sql params:@[boContentId]];
}

/**
 * 根据拍照点Id获取照片列表
 *
 * @param boCriticalPointId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getPhotoListByPointId:(NSString *)boCriticalPointVerId boContentId:(NSString *)boContentId userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT BO_PHOTO_ID,PHOTO_NAME,IS_DOODLED,PHOTO_PATH||'/_SMall'||FILE_PREFIX||FILE_SUFFIX FILE_PATH,DOWNLOAD_URL,IS_DOWNLOAD ",
                          @" FROM BO_PHOTO WHERE BO_CRITICAL_POINT_VER_ID = ?",
                          @" AND BO_CONTENT_ID = ? AND USERID = ?"];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSMutableArray *photoList = [self getListBySql:sql params:@[boCriticalPointVerId, boContentId, userid]];
    
    NSString *MergePhotoPath = [NSString stringWithFormat:@"%@/qm%@", PATH_OF_DOCUMENT, @"/mergedPic/"];
    
    for (NSMutableDictionary *photoDic in photoList) {
        NSString *isDoodle = [photoDic objectForKey:@"is_doodled"];
        if ([isDoodle isEqualToString:@"1"]) {
            [photoDic setObject:[NSString stringWithFormat:@"%@%@%@", MergePhotoPath, [photoDic objectForKey:@"bo_photo_id"], @".jpg"] forKey:@"file_path"];
//            [photoDic setObject:[NSString stringWithFormat:@"%@%@%@", MergePhotoPath, [photoDic objectForKey:@"bo_photo_id"], @".png"] forKey:@"download_url"];
        }
    }
    
    return photoList;
}

/**
 * 通过照片ID得到照片详细信息
 *
 * @param boPhotoId
 * @return
 */
- (NSDictionary *)getPhotoInfoById:(NSString *)boPhotoId userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT * FROM BO_PHOTO  O                               ",
                          @"LEFT JOIN BO_CRITICAL_POINT_VER V                          ",
                          @"  ON O.BO_CRITICAL_POINT_VER_ID = V.BO_CRITICAL_POINT_VER_ID ",
                          @"WHERE BO_PHOTO_ID = ? AND USERID = ?                        "];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    NSArray *params = @[boPhotoId, userid];
    
    return [self getMapBySql:sql params:params];
}

/**
 * 更改照片详细信息
 *
 * @param photoId
 * @param memo
 * @return
 */
- (BOOL)updatePhotoMemo:(NSString *)photoId memo:(NSString *)memo quality:(NSString *)quality isFormal:(NSString *)isFormal photoName:(NSString *)photoName userid:(NSString *)userid {
    NSString *sql = @"UPDATE BO_PHOTO SET MEMO= ?,IMAGE_QUALITY= ?,IS_FORMAL=?,PHOTO_NAME=? WHERE BO_PHOTO_ID = ? AND USERID = ?";
    NSArray *params = @[memo, quality, isFormal, photoName, photoId, userid];
    
    return [self executeSql:sql params:params];
}

/**
 * 更新照片为已涂鸦
 *
 * @param boPhotoId
 *            照片ID
 * @param isDoodle
 *            涂鸦状态
 * @return 是否执行成功
 * @author panqw
 */
- (BOOL)updataPhotoDoodleStatus:(NSString *)boPhotoId status:(NSString *)status userid:(NSString *)userid {
    NSString *sql = @"UPDATE BO_PHOTO SET IS_DOODLED = ? WHERE BO_PHOTO_ID = ? AND USERID = ?";
    NSArray *params = @[status, boPhotoId, userid];
    
    return [self executeSql:sql params:params];
}

/**
 * 通过搜索条件得到已上传的照片列表
 *
 * @param searchDate
 *            照片拍摄或下载日期
 * @param clearContent
 *            清理内容
 * @return List 搜索条件得到已上传或已下载的照片列表
 * @author panqw
 */
- (NSMutableArray *)getPhotoBySizeAndDate:(NSString *)searchDate clearContent:(NSString *)clearContent userid:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT BO_PHOTO_ID,IS_DOODLED,PHOTO_PATH||'/'||FILE_PREFIX||FILE_SUFFIX FILE_PATH,",
                          @"PHOTO_PATH||'/_SMall'||FILE_PREFIX||FILE_SUFFIX DOWNLOAD_SMALL_PATH,IS_DOWNLOAD,DOWNLOAD_URL FROM BO_PHOTO ",
                          @"WHERE  USERID = ?"];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    [sql appendString:[self getPhotoCondition:searchDate clearContent:clearContent]];
    
    return [self getListBySql:sql params:@[userid]];
}

/**
 * 获得搜索条件
 *
 * @param searchDate
 *            照片拍摄或下载日期
 * @param clearContent
 *            清理内容
 * @return String 搜索条件
 * @author panqw
 */
- (NSString *)getPhotoCondition:(NSString *)searchDate clearContent:(NSString *)clearContent {
    NSMutableString *sql = [[NSMutableString alloc] init];
    if ([@"1" isEqualToString:clearContent]) {
        [sql appendString:@" AND IS_UPLOAD=2 AND IS_DOWNLOAD != 1"];
    } else if ([@"2" isEqualToString:clearContent]) {
        [sql appendString:@" AND IS_DOWNLOAD=1"];
    } else if ([@"3" isEqualToString:clearContent]) {
        [sql appendString:@" AND (IS_UPLOAD=2 OR IS_DOWNLOAD=1)"];
    } else if ([@"4" isEqualToString:clearContent]) {
        [sql appendString:@" AND 1=2"];
    }
    
    if (IsStringNotEmpty(searchDate)) {
        [sql appendString:[NSString stringWithFormat:@"%@%@%@", @" AND CREATE_DATE <= '", searchDate, @" 23:59:59'"]];
    }
    
    return sql;
}

- (void)savePreDownloadPhotos:(NSArray *)jsonArray userid:(NSString *)userid {
    BOOL result = YES;
    [LogUtils Log:TAG content:@"照片插入开始"];
    
    for (NSDictionary *jsonDic in jsonArray) {
        if (![self existsPhoto:[jsonDic objectForKey:@"BO_PHOTO_ID"] userid:userid]) {
            result = [self savePreDownloadPhoto:jsonDic userid:userid] && result;
        }
    }
    
    [LogUtils Log:TAG content:@"照片插入结束"];
}

/**
 * 图片预下载
 *
 * @return
 * @author hubo
 */
- (BOOL)savePreDownloadPhoto:(NSDictionary *)jso userid:(NSString *)userid {
    NSArray *sqlArray = @[@"REPLACE INTO BO_PHOTO(BO_PHOTO_ID,PHOTO_NAME,BO_CRITICAL_POINT_VER_ID,",
                          @"POINT_NAME,PHOTO_PATH,BO_SINGLE_PROJECT_ID,BO_PROJECT_SECTION_ID,BO_CONTENT_ID,FILE_PREFIX,FILE_SUFFIX, ",
                          @"CREATE_USERID,DISCRIPTION,MEMO,LATITUDE,LONGITUDE,CREATE_DATE,REF_MINEIMAGE_ID,",
                          @"IS_FORMAL,PHOTO_TYPE,IS_UPLOAD,IMAGE_QUALITY,DOMAIN_ID,IS_DOWNLOAD,DOWNLOAD_URL,USERID,BO_PROBLEM_REPLY_ID,BO_PROBLEM_ID) ",
                          @"VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    NSString *IMAGE_QUALITY = [jso objectForKey:@"IMAGE_QUALITY"];
    if (IsStringEmpty(IMAGE_QUALITY)) {
        IMAGE_QUALITY = @"";
    }
    
    NSArray *params = @[[BaseFunction safeGetValueByKey:jso Key:@"BO_PHOTO_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"PHOTO_NAME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_CRITICAL_POINT_VER_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"POINT_NAME"],
                        [BaseFunction safeGetValueByKey:jso Key:@"PHOTO_PATH"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_SINGLE_PROJECT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROJECT_SECTION_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_CONTENT_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"FILE_PREFIX"],
                        [BaseFunction safeGetValueByKey:jso Key:@"FILE_SUFFIX"],
                        [BaseFunction safeGetValueByKey:jso Key:@"CREATE_USERID"],
                        @"0",
                        [BaseFunction safeGetValueByKey:jso Key:@"MEMO"],
                        [BaseFunction safeGetValueByKey:jso Key:@"LATITUDE"],
                        [BaseFunction safeGetValueByKey:jso Key:@"LONGITUDE"],
                        [BaseFunction safeGetValueByKey:jso Key:@"CREATE_DATE"],
                        [BaseFunction safeGetValueByKey:jso Key:@"REF_MINEIMAGE_ID"],
                        @"1",
                        [BaseFunction safeGetValueByKey:jso Key:@"PHOTO_TYPE"],
                        @"2",
                        IMAGE_QUALITY,
                        [BaseFunction safeGetValueByKey:jso Key:@"DOMAIN_ID"],
                        @"1",
                        [BaseFunction safeGetValueByKey:jso Key:@"DOWNLOAD_URL"],
                        userid,
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_REPLY_ID"],
                        [BaseFunction safeGetValueByKey:jso Key:@"BO_PROBLEM_ID"]];
    
    return [self executeSql:sql params:params];
}

- (BOOL)existsPhoto:(NSString *)boPhotoId userid:(NSString *)userid {
    NSString *sql = @"SELECT COUNT(1) COUNTS FROM BO_PHOTO WHERE BO_PHOTO_ID = ? AND USERID = ?";
    NSString *count = [self getStringBySql:sql params:@[boPhotoId, userid] key:@"COUNTS"];
    
    return [count integerValue] > 0;
}

/**
 * 路径更新
 *
 * @param path
 * @param boPhotoId
 * @return
 * @author hubo
 */
- (BOOL)updateImageDir:(NSString *)path boPhotoId:(NSString *)boPhotoId userid:(NSString *)userid {
    NSString *sql = @"UPDATE BO_PHOTO SET PHOTO_PATH = ? WHERE BO_PHOTO_ID = ? AND USERID = ?";
    
    return [self executeSql:sql params:@[path, boPhotoId, userid]];
}

/**
 * 大图路径更新
 *
 * @param path
 * @param boPhotoId
 * @return
 * @author hubo
 */
- (BOOL)updateBigImageDir:(NSString *)path boPhotoId:(NSString *)boPhotoId {
    NSString *sql = @"UPDATE BO_PHOTO SET DOWNLOAD_URL = ? WHERE BO_PHOTO_ID = ?";
    
    return [self executeSql:sql params:@[path, boPhotoId]];
}

- (void)doDeleteNotExistPhoto:(NSMutableDictionary *)inputData userid:(NSString *)userid {
    NSArray *list = [self getXjUploadPhotoList:inputData userid:userid];
    for (NSMutableDictionary *photoDic in list) {
        NSString *filePath = [NSString stringWithFormat:@"%@%@%@%@", [photoDic objectForKey:@"photo_path"], @"/", [photoDic objectForKey:@"file_prefix"], [photoDic objectForKey:@"file_suffix"]];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:filePath]) {
            NSString *photoId = [photoDic objectForKey:@"bo_photo_id"];
            NSString *sql = @" DELETE FROM BO_PHOTO WHERE BO_PHOTO_ID = ?";
            [self executeSql:sql params:@[photoId]];
        }
    }
}

/**
 * 是否存在已拍照片
 *
 * @param boContentId
 * @return true or false
 * @author yanghua
 */
- (BOOL)isExistsProblemPhotos:(NSString *)boContentId userid:(NSString *)userid {
    NSString *sql = @"SELECT COUNT(1) COUNTS FROM BO_PHOTO P WHERE P.BO_CONTENT_ID = ? AND P.USERID = ? AND P.IS_DOWNLOAD = '2'";
    NSString *count = [self getStringBySql:sql params:@[boContentId, userid] key:@"COUNTS"];
    
    return [count intValue] > 0;
}

/**
 * 更改照片详细信息
 *
 * @param photoId
 * @param memo
 * @return yanghua
 */
- (BOOL)updateMemoByPhotoId:(NSString *)photoId memo:(NSString *)memo userid:(NSString *)userid {
    NSString *sql = @"UPDATE BO_PHOTO SET MEMO= ? WHERE BO_PHOTO_ID = ? AND USERID = ?";
    
    return [self executeSql:sql params:@[memo, photoId, userid]];
}

/**
 * 更新控制点ID
 *
 * @param oldContentId
 * @param newContentId
 * @return
 * @author hubo
 */
- (BOOL)updateContent:(NSString *)oldContentId newContentId:(NSString *)newContentId {
    NSString *sql = @"UPDATE BO_PHOTO SET BO_CONTENT_ID = ? WHERE BO_CONTENT_ID=?        ";
    
    return [self executeSql:sql params:@[newContentId, oldContentId]];
}

/**
 * 获取照片列表
 *
 * @return
 * @author zhangff
 */
- (NSMutableArray *)getPhotoList:(NSString *)userid {
    NSArray *sqlArray = @[@"SELECT BO_PHOTO_ID,PHOTO_TYPE,PHOTO_NAME,IS_DOODLED,PHOTO_PATH||'/'||FILE_PREFIX||FILE_SUFFIX FILE_PATH,",
                          @"PHOTO_PATH||'/_SMall'||FILE_PREFIX||FILE_SUFFIX DOWNLOAD_SMALL_PATH,IS_DOWNLOAD,DOWNLOAD_URL FROM BO_PHOTO ",
                          @"WHERE  USERID = ? AND DOWNLOAD_URL like '",
                          PATH_OF_DOCUMENT,
                          @"%' OR IS_DOWNLOAD=2 ",
                          @"ORDER BY CREATE_DATE DESC",];
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (NSString *apart in sqlArray) {
        [sql appendString:apart];
    }
    
    return [self getListBySql:sql params:@[userid]];
}

/**
 * 获得最近一次自拍照片信息
 *
 * @return Map
 * @author panqw
 */
- (NSDictionary *)getLastestRefPhoto {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@" SELECT BO_PHOTO_ID"];
    [sql appendString:@"   FROM BO_PHOTO"];
    [sql appendString:@"  WHERE PHOTO_TYPE = '2'"];
    [sql appendString:@"  ORDER BY CREATE_DATE DESC LIMIT 1"];
    
    return [self getMapBySql:sql params:@[]];
}

/**
 * 通过照片ID得到项目信息
 *
 * @param boPhotoId
 * @return
 */
- (NSDictionary *)getProjectInfoByPhotoId:(NSString *)boPhotoId userid:(NSString *)userid {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT * FROM BO_PHOTO  O,BO_SINGLE_PROJECT V           "];
    [sql appendString:@" WHERE O.BO_SINGLE_PROJECT_ID = V.BO_SINGLE_PROJECT_ID  "];
    [sql appendString:@" AND O.USERID = V.USERID                                "];
    [sql appendString:@" AND O.BO_PHOTO_ID = ? AND O.USERID = ?                 "];
    
    return [self getMapBySql:sql params:@[boPhotoId, userid]];
}

- (BOOL) insertOneRecord:(NSDictionary *)inputData userid:(NSString *)userid{
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc]init];
    [jsonDictionary setValuesForKeysWithDictionary:inputData];
    //拼接download_url
    NSString *imageDownloadUrl = [NSString stringWithFormat:@"%@%@%@", BASE_URL, Prefix, @"/imagedir"];
    NSString *_photoPathUrl = [NSString stringWithFormat:@"%@%@", imageDownloadUrl, [jsonDictionary objectForKey:@"PHOTO_PATH"]];
    _photoPathUrl = [_photoPathUrl stringByReplacingOccurrencesOfString:@"\\\\" withString:@"/"];
    _photoPathUrl = [_photoPathUrl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    [jsonDictionary setObject:_photoPathUrl forKey:@"PHOTO_PATH"];
    NSString *downloadUrl = [NSString stringWithFormat:@"%@%@%@", _photoPathUrl, [jsonDictionary objectForKey:@"FILE_PREFIX"], [jsonDictionary objectForKey:@"FILE_SUFFIX"]];
    downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@"/_SMALL" withString:@""];
    [jsonDictionary setObject:downloadUrl forKey:@"DOWNLOAD_URL"];
    //设定类型
    NSString *isFormal = [jsonDictionary objectForKey:@"IS_FORMAL"];
    if([@"3" isEqualToString:isFormal]){
        [jsonDictionary setValue:@"1" forKey:@"TYPE"];
    }else if([@"1" isEqualToString:isFormal]||[@"2" isEqualToString:isFormal]){
        [jsonDictionary setValue:@"0" forKey:@"TYPE"];
    }
    return [self savePreDownloadPhoto:jsonDictionary userid:userid];
}
@end
