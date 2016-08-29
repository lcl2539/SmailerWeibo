//
//  MoreViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/26.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "MoreViewController.h"
#import <Masonry.h>
#import "HttpRequest.h"
#import "UserModel.h"
#import "UIImageView+WebCache.h"
@interface MoreViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_tab;
    __weak UIImageView *_userHeadImg;
    __weak UILabel *_userName;
    __weak UIImageView *_bgImg;
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
    __weak typeof(self) weakSelf = self;
    [HttpRequest userInfoHttpRequestWithSuccess:^(id object) {
        [weakSelf loadData:object];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    [HttpRequest fansHttpRequestWithSuccess:^(id object) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)loadData:(id)object{
    UserModel *user = [UserModel CreatMyModle:object];
    [_userHeadImg sd_setImageWithURL:[NSURL URLWithString:user.strAvatarLarge]];
    [_userName setText:user.strScreenName];
}

- (void)loadTab{
    UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:view];
    _tab = view;
    [_tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
    _tab.separatorStyle = UIAccessibilityTraitNone;
    _tab.delegate = self;
    _tab.dataSource = self;
    [self loadHeadView];
}

- (void)loadHeadView{
    UIView *head = [[UIView alloc]init];
    CGFloat height = self.view.bounds.size.height * 0.2;
    head.frame = CGRectMake(0, 0, 0, height);
    _tab.tableHeaderView = head;
    UIImageView *bgImg = [[UIImageView alloc]init];
    [head addSubview:bgImg];
    _bgImg = bgImg;
    UIImageView *img = [[UIImageView alloc]init];
    img.layer.cornerRadius = 25;
    img.clipsToBounds = YES;
    [head addSubview:img];
    _userHeadImg = img;
    UILabel *name = [[UILabel alloc]init];
    name.textAlignment = NSTextAlignmentCenter;
    [head addSubview:name];
    _userName = name;
    [_bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(head);
    }];
    [_userHeadImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.leading.equalTo(head).offset(15);
        make.bottom.equalTo(head).offset(-40);
    }];
    [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_userHeadImg.mas_leading);
        make.bottom.equalTo(head).offset(-5);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGRect frame = self.view.frame;
    frame.origin.x = (frame.origin.x != 0) ? 0 : -self.view.frame.size.width;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = frame;
    }];
}
@end
