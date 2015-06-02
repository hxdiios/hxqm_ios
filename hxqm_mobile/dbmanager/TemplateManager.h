//
//  TemplateManager.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/16/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ClientDBManager.h"
#import "IGsonDataSaver.h"

@interface TemplateManager : ClientDBManager<IGsonDataSaver>

/**
 * 保存模板
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)saveTemplateInfo:(NSDictionary *)jso;

/**
 * 保存拍照点信息
 *
 * @param result
 * @return
 * @author hubo
 */

- (BOOL)savePointInfo:(NSDictionary *)jso;

/**
 * 保存示例照片
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)savePointImage:(NSDictionary *)jso userid:(NSString *)userid;

/**
 * 得到模板列表
 *
 * @param boTemplateVerId
 * @param boTemplateId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getTemplateList:(NSString *)boTemplateVerId boTemplateId:(NSString *)boTemplateId boSingleProjectId:(NSString *)boSingleProjectId type:(NSString *)type userid:(NSString *)userid;

/**
 * 根据模板获得拍照点
 *
 * @param boTemplateDetailVerId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getCriticalByTemplateId:(NSString *)boTemplateDetailVerId;

/**
 * 批量保存分段
 *
 * @param selectionList
 * @return
 * @author hubo
 */
- (BOOL)saveExcludeTemplate:(NSArray *)excludeTemplateList;

/**
 * 保存示例照片
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)saveExcludeTemplate:(NSDictionary *)jso userid:(NSString *)userid;

/**
 * 获得样例图片
 *
 * @param boCriticalPointVerId
 * @return
 * @author panqw
 */
- (NSMutableArray *)getInstanceImageByPortId:(NSString *)boCriticalPointVerId;
@end
