//
//  SectionManager.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/16/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ClientDBManager.h"
#import "IGsonDataSaver.h"

@interface SectionManager : ClientDBManager<IGsonDataSaver>

/**
 * 批量保存分段
 *
 * @param selectionList
 * @return
 * @author hubo
 */
- (BOOL)saveSelectionList:(NSArray *)selectionList userid:(NSString *)userid;

/**
 * 单个保存分段
 *
 * @param jo
 * @return
 * @author hubo
 */
- (BOOL)saveSelection:(NSDictionary *)jo userid:(NSString *)userid;

/**
 * 获得默认分段已拍/应拍
 *
 * @param id
 * @return num
 * @author yanghua
 */
- (NSString *)getDefaultSectionUploadAmount:(NSString *)sid;

/**
 * 根据项目ID获取分段
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getSectionListByProjectId:(NSString *)boSingleProejctId userid:(NSString *)userid;

/**
 * 根据项目ID获取分段
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (NSMutableArray *)getSectionTaskByProjectId:(NSString *)boSingleProejctId userid:(NSString *)userid;

/**
 * 根据项目ID判断是否有分段
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (BOOL)getHasSelectionByProjectId:(NSString *)boSingleProejctId userid:(NSString *)userid;

/**
 * 得到分段的序号
 *
 * @param boSingleProejctId
 * @return
 * @author hubo
 */
- (int)getCurrentSectionNumber:(NSString *)boSingleProejctId userid:(NSString *)userid;

@end
