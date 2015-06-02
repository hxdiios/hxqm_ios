//
//  MajorProjectListView.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/27/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "MajorProjectListView.h"

@interface MajorProjectListView () {
    NSArray *_listDatas;
}

@end

@implementation MajorProjectListView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MajorProjectListView" owner:self options:nil];
        for(NSObject *obj in objects) {
            if([obj isKindOfClass:[MajorProjectListView class]]) {
                self = (MajorProjectListView *) obj;
                break;
            }
        }
        self.frame = frame;
        [self initView];
    }
    return self;
}

- (void)initView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 40;
    // 不显示没内容的Cell
    _tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setDatas:(NSArray *)data {
    _listDatas = data;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _listDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *projectList = [[_listDatas objectAtIndex:section] objectForKey:@"project_list"];
    NSDictionary *dic = [_listDatas objectAtIndex:section];
    BOOL isOpened = [[dic objectForKey:@"isOpened"] isEqualToString:@"YES"];
    
    return isOpened ? projectList.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"project_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSLog(@"cell is nil");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSArray *projectList = [[_listDatas objectAtIndex:indexPath.section] objectForKey:@"project_list"];
    NSDictionary *projectDict = [projectList objectAtIndex:indexPath.row];
    cell.textLabel.text = [projectDict objectForKey:@"keyname"];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ListHeadView *headView = [ListHeadView headViewWithTableView:tableView data:_listDatas[section]];
    headView.delegate = self;
    headView.datas = _listDatas[section];
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(projectSelectAtIndexPath:)]) {
        [_delegate projectSelectAtIndexPath:indexPath];
    }
}

- (void)clickHeadView {
    [self.tableView reloadData];
}

@end
