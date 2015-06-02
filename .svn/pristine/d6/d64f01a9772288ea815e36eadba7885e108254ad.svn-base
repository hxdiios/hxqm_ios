#import "CatchCrash.h"
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "BaseFormDataRequest.h"
#import "Constants.h"

@implementation CatchCrash

void uncaughtExceptionHandler(NSException *exception)
{
    //异常抛出的时间
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *errTime = [formatter stringFromDate:date];
    //发生异常的用户信息
    NSString *uid = [AppConfigure objectForKey:USERID];
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    // 出现异常的原因
    NSString *reason = [exception reason];
    // 异常名称
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception time:%@\nException userid:%@\nException reason：%@\nException name：%@\nException stack：%@",errTime,uid,name, reason, stackArray];
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:stackArray];
    [tmpArr insertObject:reason atIndex:0];
    
    //保存到本地,下次启动的时候，上传这个log
    NSString *errPath = [BaseFunction getErrorLogFolderPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:errPath]) {
        [fileManager createDirectoryAtPath:errPath withIntermediateDirectories:NSOSF1OperatingSystem attributes:nil error:nil];
    }
    NSString *logFilePath = [errPath stringByAppendingPathComponent:@"err.txt"];
    NSLog(@"%@",logFilePath);
    [exceptionInfo writeToFile:logFilePath  atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end