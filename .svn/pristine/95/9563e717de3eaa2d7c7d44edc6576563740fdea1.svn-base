//
//  MyBrowseViewController.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/28.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "MyBrowseViewController.h"
#import "SingleProjectManager.h"
#import "FMDatabase.h"
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "LogUtils.h"
#import "SVProgressHUD.h"
#import "ProjectCell.h"
#import "SectionViewController.h"
#import "TableInfoViewController.h"
#import "SectionManager.h"

#define TAG @"_MyBrowseViewController"

@interface MyBrowseViewController () {
    NSMutableArray *historyArray;
}
@property (weak, nonatomic) IBOutlet UITableView *historyTable;

@end

@implementation MyBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"最近浏览";
    [self addNavBackBtn];
    
    historyArray = [[NSMutableArray alloc] init];
    _historyTable.tableFooterView = [[UIView alloc] init];
    
    [self loadDatas];
}

- (void)loadDatas {
    FMDatabase *db = [BaseFunction createDB];
    SingleProjectManager *manager = [[SingleProjectManager alloc] initWithDb:db];
    [db open];
    FMResultSet *set = [manager getBrowseCursor:[AppConfigure objectForKey:USERID]];
    
    NSMutableDictionary *dictionary = set.columnNameToIndexMap;
    while ([set next]) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        for(NSString *key in dictionary) {
            [item setObject:[NSString stringWithFormat:@"%@", [set stringForColumn:key]] forKey:key];
        }
        [historyArray addObject:item];
    }
    
    [set close];
    [db close];
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"historyArray = %@", historyArray]];
    if (historyArray == nil || historyArray.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"最近没有浏览过工程"];
    }
    
    [_historyTable reloadData];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [historyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = (int)indexPath.row;
    static NSString *CustomCellIdentifier = @"ProjectBrowseCell";
    static BOOL nibsRegistered = NO;
    ProjectCell *cell = (ProjectCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell == nil) {
        nibsRegistered = NO;
    }
    if (!nibsRegistered) {
        [LogUtils Log:TAG content:@"cell is nil"];
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([ProjectCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
        cell = (ProjectCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    [cell initViewForBrowseWithData:[historyArray objectAtIndex:row]];
    
    return cell;
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"selected section %ld, row %ld", indexPath.section, indexPath.row]];
    
    NSDictionary *selectedCellData;
    NSInteger row = indexPath.row;
    selectedCellData = [historyArray objectAtIndex:row];
    //    NSLog(@"selectedCellData = %@", selectedCellData);
    NSString *projectID = [selectedCellData objectForKey:@"_id"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"projectID = %@", projectID]];
    
    SectionManager *sectionManager = [[SectionManager alloc] initWithDb];
    [sectionManager openDB];
    // 判断工程是否有分段存在
    BOOL hasSection = [sectionManager getHasSelectionByProjectId:projectID userid:[AppConfigure objectForKey:USERID]];
    [sectionManager closeDB];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"hasSection = %@", hasSection ? @"YES" : @"NO"]];
    // 有，跳转到分段界面
    // type: 界面标识（用于判断是从工程列表进入（1），还是待办任务列表进入（2））
    if (hasSection) {
        SectionViewController *sectionViewController = [[SectionViewController alloc] initWithNibName:@"SectionViewController" bundle:nil];
        sectionViewController.projectID = projectID;
        sectionViewController.type = @"1";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sectionViewController];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    } else {// 没有，则跳转到关键控制点界面
        TableInfoViewController *tableInfoViewController = [[TableInfoViewController alloc] initWithNibName:@"TableInfoViewController" bundle:nil];
        tableInfoViewController.projectID = projectID;
        tableInfoViewController.type = @"1";
        tableInfoViewController.sectionID = @"null";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableInfoViewController];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProjectCell *cell = (ProjectCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    // 计算cell.projectName的文字大小
    CGSize labelSize = [cell.projectName.text sizeWithAttributes:@{NSFontAttributeName:cell.projectName.font}];
    
    [cell.projectName sizeToFit];
    // 计算cell.projectName的文字在当前手机屏幕的宽度减去左右间隔之后有几行
    float lines = labelSize.width / (UI_SCREEN_WIDTH - 16);
    // 转成整数，用来计算是否有非零的小数位
    int l = (int) lines;
    int lines_final = 0;
    // 如果有非零的小数位，说明超过l行，应该加1
    if (lines - l > 0) {
        lines_final = lines + 1;
    } else {
        lines_final = l;
    }
    
    float part1 = 13 + lines_final * labelSize.height + (lines - 1) * 3;
    float part2 = 4 + cell.projetNO.frame.size.height;
    float part3 = 4 + cell.projectTakePhotos.frame.size.height;
    float part4 = 10;
    float height = part1 + part2 + part3 + part4;
    
    return 1  + height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

@end
