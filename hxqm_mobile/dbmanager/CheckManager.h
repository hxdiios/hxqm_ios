//
//  CheckManager.h
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/14.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "ClientDBManager.h"
#import "IGsonDataSaver.h"

@interface CheckManager : ClientDBManager<IGsonDataSaver>

/**
 * 批量保存抽查任务
 *
 * @param selectionList
 * @return
 * @author hubo
 */
- (BOOL)saveCheckProjectList:(NSArray *)checkProjectList userid:(NSString *)userid;

/**
 * 保存抽查任务
 *
 * @param jso
 * @return
 * @author hubo
 */
- (BOOL)saveCheckProject:(NSDictionary *)project userid:(NSString *)userid;

@end
