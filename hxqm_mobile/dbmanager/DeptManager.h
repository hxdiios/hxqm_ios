//
//  DeptManager.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/15/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ClientDBManager.h"
#import "IGsonDataSaver.h"

@interface DeptManager : ClientDBManager<IGsonDataSaver>

/**
 * 批量保存大项
 *
 * @param deptList
 * @return
 */
- (BOOL)saveDeptProjectList:(NSArray *)deptList userid:(NSString *)userid;

/**
 * 单个保存大项
 *
 * @param jo
 * @return
 */
- (BOOL)saveDeptProject:(NSDictionary *)jo userid:(NSString *)userid;

/**
 * 得到大项专业列表
 *
 * @return
 */
- (NSMutableArray *)getDeptProjectList:(NSString *)userid;

@end
