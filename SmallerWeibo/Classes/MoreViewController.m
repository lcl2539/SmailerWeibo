//
//  MoreViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/26.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "MoreViewController.h"
#import <Masonry.h>
@interface MoreViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_tab;
}
@property (nonatomic,copy)NSArray *titleArr;
@end

@implementation MoreViewController

- (NSArray *)titleArr{
    if (!_titleArr) {
        _titleArr = @[@"我的关注",@"我的粉丝",@"账号管理",@"主题风格",@"夜间模式",@"关于"];
    }
    return _titleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTab];
    [self loadSomeSetting];

}

- (void)loadSomeSetting{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
}

- (void)loadTab{
    UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:view];
    _tab = view;
    [_tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
    _tab.delegate = self;
    _tab.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    return cell;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGRect frame = self.view.frame;
    frame.origin.x = (frame.origin.x != 0) ? 0 : -self.view.frame.size.width;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = frame;
    }];
}
@end
