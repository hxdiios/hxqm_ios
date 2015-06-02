//
//  SingleProjectManager.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/16/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ClientDBManager.h"
#import "IGsonDataSaver.h"

@interface SingleProjectManager : ClientDBManager<IGsonDataSaver>

/**
 * gson格式插入数据
 *
 * @param singleProject
 */
- (BOOL)insertOneRecord:(NSDictionary *)jso userid:(NSString *)userid;

/**
 * 批量保存站点
 *
 * @param sites
 */
- (void)saveSites:(NSArray *)list userid:(NSString *)userid;

- (NSMutableArray *)getUserSitesMap:(NSString *)userid;

/**
 * 得到基站列表最晚更新时间
 *
 * @return
 */
- (NSString *)getLatestUpdateDate:(NSString *)userid;

/**
 * @param keyWord
 *            查询关键词
 * @param longtitude
 *            当前经度
 * @param latitude
 *            当前纬度
 * @param target
 *            查询目标(站点/项目)
 * @return
 */
- (NSMutableArray *)searchSites:(NSString *)majorId deptProjectId:(NSString *)deptProjectId keyinfo:(NSString *)keyinfo longtitude:(float)longtitude latitude:(float)latitude endNum:(int)endNum userid:(NSString *)userid;

/**
 * 增量获取数据
 *
 * @return
 */
- (NSMutableArray *)searchSitesIncrement:(NSString *)majorId deptProjectId:(NSString *)deptProjectId keyinfo:(NSString *)keyinfo longtitude:(float)longtitude latitude:(float)latitude offSetNum:(int)offSetNum endNum:(int)endNum userid:(NSString *)userid;

/**
 * @param keyWord
 *            查询关键词
 * @param longtitude
 *            当前经度
 * @param latitude
 *            当前纬度
 * @param target
 *            查询目标(站点/项目)
 * @return
 */
- (int)searchSiteNum:(NSString *)majorId deptProjectId:(NSString *)deptProjectId keyinfo:(NSString *)keyinfo longtitude:(float)longtitude latitude:(float)latitude userid:(NSString *)userid;

/**
 * 得到最近date天未巡检站点数
 *
 * @param date
 * @return 未巡检站点数
 */
- (NSString *)getSiteCountByDate:(NSString *)date userid:(NSString *)userid;

/**
 * 得到项目总数
 *
 * @return 基站总数
 */
- (NSString *)getTotalSiteCount:(NSString *)userid;

/**
 * 更改单项巡检时间
 *
 * @param boSiteId
 */
- (BOOL)modifyEnterDate:(NSString *)boSingleProjectId;

/**
 * 得到任务列表
 *
 * @return
 * @author hubo
 */
- (NSMutableArray *)getTaskList:(float)longtitude latitude:(float)latitude userid:(NSString *)userid type:(NSString *)type;

/**
 * 得到整改数量
 *
 * @return
 * @author hubo
 */
- (NSString *)getProblemReplyNum:(NSString *)userid;

/**
 * 得到检查数量
 *
 * @return
 * @author hubo
 */
- (NSString *)getCheckNum:(NSString *)userid;

/**
 * 得到整改列表
 *
 * @return
 * @author panqw
 */
- (NSMutableArray *)getProblemReplyList:(NSString *)userid;

/**
 * 得到检查列表
 *
 * @return
 * @author panqw
 */
- (NSMutableArray *)getCheckList:(NSString *)userid;

/**
 * 根据ID修改工程收藏状态
 *
 * @param id
 * @return
 * @author zhangff
 */
- (BOOL)changeFavoriteStatus:(NSString *)sid userid:(NSString *)userid;

/**
 * 根据ID获取工程收藏状态
 *
 * @param id
 * @return
 * @author zhangff
 */
- (BOOL)getFavoriteStatus:(NSString *)sid userid:(NSString *)userid;

/**
 * 获取当前用户收藏数据
 *
 * @return 结果集
 * @author zhangff
 */
- (FMResultSet *)getFavoriteCursor:(NSString *)userid;

/**
 * 获得项目信息
 *
 * @param boSinglerProjectId
 * @return map
 * @author yanghua
 */
- (NSDictionary *)getSinglerProjectInfoById:(NSString *)boSinglerProjectId userid:(NSString *)userid;

/**
 * 更新经纬度
 *
 * @param map
 * @return true or false
 * @author yanghua
 */
- (BOOL)updateLocation:(NSDictionary *)map userid:(NSString *)userid;

/**
 * 获取当前用户最近浏览数据
 *
 * @return 结果集（20条）
 * @author zhangff
 */
- (FMResultSet *)getBrowseCursor:(NSString *)userid;

- (NSMutableArray *)getRandomProjectInfo:(NSString *)userid;

/**
 * 更新经纬度
 *
 * @param latitude 纬度
 *        longtitude 经度
 * @return map
 * @author yanghua
 */
- (NSDictionary *)getNearestProject:(float)longtitude latitude:(float)latitude userid:(NSString *)userid;
@end
