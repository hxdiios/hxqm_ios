//
//  ProblemManager.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/16/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ClientDBManager.h"
#import "IGsonDataSaver.h"

@interface ProblemManager : ClientDBManager<IGsonDataSaver>

/**
 * 下载整改记录
 *
 * @param list
 * @author hubo
 */
- (void)saveProblemList:(NSArray *)list userid:(NSString *)userid;

/**
 * 保存整改逾期
 *
 * @param list
 * @author yanghua
 */
- (void)saveProblemDelayList:(NSArray *)list userid:(NSString *)userid;

/**
 * 更新整改记录
 *
 * @param problemRecord
 * @return
 * @author hubo
 * @editor yanghua
 */
- (BOOL)saveProblem:(NSDictionary *)jso userid:(NSString *)userid;

/**
 * 保存问题责任方扣分
 *
 * @param problemRecord
 * @return
 * @author hubo
 * @editor yanghua
 */
- (BOOL)saveProblemOrg:(NSDictionary *)jso userid:(NSString *)userid;

/**
 * 保存施工回复
 *
 * @param problemRecord
 * @return
 * @author hubo
 */
- (BOOL)saveProblemReply:(NSDictionary *)jso userid:(NSString *)userid;

/**
 * 保存与整改相关扣分单位
 *
 * @return
 * @author yanghua
 */
- (BOOL)saveRelativeOrg:(NSDictionary *)jso;

/**
 * 得到整改问题列表
 *
 * @return
 * @author hubo
 */
- (NSMutableArray *)getProblemList:(float)longtitude latitude:(float)latitude;

/**
 * 根据照片标识
 *
 * @param boProblemId
 * @return map
 * @author yanghua
 */
- (NSDictionary *)getProblemInfo:(NSString *)boProblemId userid:(NSString *)userid;

/**
 * 更新待办
 *
 * @param massRecord
 * @author yanghua
 */
- (BOOL)updateProblem:(NSDictionary *)jso;

/**
 * 得到施工单位列表
 *
 * @return list
 * @author yanghua
 */
- (NSMutableArray *)getProblemOrgList:(NSString *)boProblemId boProblemReplyId:(NSString *)boProblemReplyId state:(NSString *)state userid:(NSString *)userid;

/**
 * 得到下一家单位
 *
 * @return list
 * @author yanghua
 */
- (NSMutableArray *)getNextOrgList:(NSString *)boProblemId boProblemReplyId:(NSString *)boProblemReplyId curStatus:(NSString *)curStatus userid:(NSString *)userid;

/**
 * 得到施工单位列表
 *
 * @return list
 * @author yanghua
 */
- (NSMutableArray *)getProblemOrg:(NSString *)boProblemOrgId userid:(NSString *)userid;

/**
 * 删除
 *
 * @param boProblemOrgId
 * @return true or false
 * @author yanghua
 */
- (BOOL)deleteProblemOrg:(NSString *)boProblemOrgId userid:(NSString *)userid;

/**
 * 获得草稿id
 *
 * @param boContentId
 * @return boProblemId
 * @author yanghua
 */
- (NSString *)getDraftProblemId:(NSString *)boContentId userid:(NSString *)userid;

/**
 * 得到草稿信息
 *
 * @param boProblemId
 * @return map
 * @author yanghua
 */
- (NSDictionary *)getDraftInfo:(NSString *)boProblemId userid:(NSString *)userid;

/**
 * 校验扣分单位唯一性
 *
 * @param boProblemId
 * @param orgId
 * @return true or false
 * @author yanghua
 */
- (BOOL)doVolidate:(NSString *)boProblemId orgId:(NSString *)orgId boProblemOrgId:(NSString *)boProblemOrgId userid:(NSString *)userid;

/**
 * 获得当前已选合作单位
 *
 * @param boProblemReplyId
 * @return list
 * @author yanghua
 */
- (NSString *)getProblemOrgIds:(NSString *)boProblemId userid:(NSString *)userid;

/**
 * 删除草稿
 *
 * @param boProblemId
 * @return true or false
 * @author yanghua
 */
- (BOOL)deleteProblemDraft:(NSString *)boProblemId userid:(NSString *)userid;

/**
 * 获得下级扣分单位
 *
 * @author yanghua
 */
- (NSArray *)getOrgList:(NSString *)boSingleProjectId roleId:(NSString *)roleId userid:(NSString *)userid;

/**
 * 获得整改照片列表
 *
 * @author yanghua
 */
- (NSArray *)getProblemPhotoList:(NSString *)boProblemId boProblemReplyId:boProblemReplyId userid:(NSString *)userid;

/**
 * 更新整改临时记录
 * @param problemRecord
 * @return true or false
 * @author yanghua
 */
- (BOOL) saveDraftProblem:(NSDictionary *)jso userid:(NSString *)userid;

/**
 * 是否存在与整改相关单位
 *
 * @author yanghua
 */
-(BOOL)isRelativeOrgExists:(NSString *)boSingleProjectId userId:(NSString *)userid;

/**
 * 保存问题回复记录
 *
 * @author yanghua
 */
-(BOOL)saveProblemReplyRecord:(NSDictionary *)jso state:(NSString *)state userid:(NSString *)userid;

/**
 * 获得ORG_TYPE
 *
 * @author yanghua
 */
-(NSString *) getOrgTypeByOrgId:(NSString *)orgId;
@end
