//
//  Constants.h
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/16.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#ifndef hxqm_mobile_Constants_h
#define hxqm_mobile_Constants_h

//#define BASE_URL @"http://115.29.3.106:8080"
#define BASE_URL @"http://192.168.0.52:8088"

#define UPDATE_IPA_URL @"itms-services://?action=download-manifest&url=https://www.telsoft.cn:8443/projectweb/ios/hztt_528088.plist"

#define Prefix   @""

//xmpp的连接ip
#define XMPP_IP @"115.29.3.106"

//xmpp连接端口
#define XMPP_PORT 81

// 版本号
#define VERSION_CODE @"1.0.0"

#define SHOW_DLG_VALUE 500

#define SESSION_TIMEOUT @"dwr.engine.http.1000"

#define APPEND_URL(suffix) [BASE_URL stringByAppendingString:suffix]

#define CHECK_UPDATE     APPEND_URL(@"/qm/service/ComMobile/GetMobileBasicData.ajax")
#define LOGIN            APPEND_URL(@"/j_acegi_security_check")
#define LOGIN_FULLNAME   APPEND_URL(@"/qm/service/User/GetLoginName.ajax")
#define TOTAL_RECEIVE    APPEND_URL(@"/qm/service/ComMobile/GetMobileInfoCount.ajax")
#define MOBILE_RECEIVE   APPEND_URL(@"/qm/service/ComMobile/GetMobileInfo.ajax")
#define FILEUPLOAD       APPEND_URL(@"/picupload")
#define LOGUPLOAD        APPEND_URL(@"/fileupload")
// 工程列表
#define LATER_RECEIVE    APPEND_URL(@"/qm/service/ComMobile/GetSingleProjectData.ajax")
// 任务列表
#define TASK_LIST        APPEND_URL(@"/qm/service/ComMobile/GetTask.ajax")
// 分段
#define SAVE_SECTION_URL APPEND_URL(@"/qm/service/PhotoManager/SaveSection.ajax")
// 关键控制点
#define CONTENT_RECEIVE  APPEND_URL(@"/qm/service/PhotoManager/GetContentList.ajax")
// 上传坐标
#define UPLOAD_LOCATION_URL  APPEND_URL(@"/qm/service/ComMobile/UploadLocation.ajax")
// 获取对应的单位
#define checkCompleteUrl  APPEND_URL(@"/qm/service/ComMobile/SubmitCheck.ajax")
// 获取对应的单位
#define REFERENCE_ORGS_URL  APPEND_URL(@"/qm/service/ComMobile/GetReferenceOrgs.ajax")
// 用户角色
#define SEE_GC @"SEE_GC"
#define SEE_UPLOAD @"SEE_UPLOAD"
#define SEE_SG @"SEE_SG"
#define SEE_TASK @"SEE_TASK"
#define AUDIT_COOPERATE @"AUDIT_COOPERATE"
#define SEE_JC @"SEE_JC"

#define SMALL_PHOTO_SIZE 100

// 照片大图界面跳转MODE
#define MODE_DETAIL @"1"
#define MODE_SCAN @"2"
// 照片压缩比
#define kCompressionQuality 0.5
#define kCompressionQualityLow 0.3

#define LG_LOCATION_ERR @"请在设置->隐私->定位服务中设置智检通为开启状态"

#define LG_CAMERA_ERR @"请在设置->隐私->相机中设置质检通为开启状态"

#define CITY_QUALITY_MANAGER @"15605"
#define CITY_MAJOR_MANAGER @"15612"
#define AREA_EXECUTIVE_USER @"15607"
#define SUPERVISION @"15601"

#endif
