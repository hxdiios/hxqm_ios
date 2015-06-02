//
//  CooperateManager.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/15/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ClientDBManager.h"
#import "MyMacros.h"
#import "LogUtils.h"
#import "IGsonDataSaver.h"

@interface CooperateManager : ClientDBManager<IGsonDataSaver>

/**
 * 获取代办列表
 *
 * @return sites
 */
- (NSMutableArray *)getTaskList: (NSString *)workDate orgName:(NSString *)orgName areaName:(NSString *)areaName userid:(NSString *)userid;

/**
 * 获取数量
 *
 * @return count
 */
- (NSString *)getTaskNum: (NSString *)workDate userid:(NSString *)userid;

/**
 * 批量保存
 *
 * @param sites
 */
- (void)saveCooperate:(NSArray *)list;

/**
 * 插入执行sql
 *
 * @param cooperateList
 */
- (void)insertCooperate: (NSDictionary *)cooperate;

/**
 * 根据合作id获得明细
 *
 * @param cooperateId
 * @return map
 */
- (NSDictionary *)getUserBaseInfo:(NSString *)cooperateId userid:(NSString *)userid;

/**
 * 更新状态
 *
 * @param id
 */
- (void)updateCooperate:(NSString *)sid state:(NSString *)state;

/**
 * 获取出工计划项目信息
 *
 * @param id
 */
- (NSDictionary *)getProjectInfoByCooperateId:(NSString *)sid;

/**
 * 获得出工计划施工单位
 *
 * @param workDate
 * @return list
 */
- (NSMutableArray *)getCooperateOrgList:(NSString *)workDate userid:(NSString *)userid;

/**
 * 获得出工计划地区
 *
 * @param workDate
 * @return list
 */
- (NSMutableArray *)getCooperateAreaList:(NSString *)workDate userid:(NSString *)userid;

@end
