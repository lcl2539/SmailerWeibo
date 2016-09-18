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
#import "FriendsViewController.h"
#import "UIButton+WebCache.h"
#import "ViewController.h"
#import "UIView+extend.h"
#import "UserMangerViewController.h"
#import "PrefixHeader.pch"
#import "AboutViewController.h"
@interface MoreViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_tab;
    __weak UIButton *_userHeadImg;
    __weak UILabel *_userName;
    __weak UIImageView *_bgImg;
}
@property (nonatomic,strong)UserModel *model;
@property (nonatomic,copy)NSArray *titleArr;
@end

@implementation MoreViewController

- (NSArray *)titleArr{
    if (!_titleArr) {
        _titleArr = @[@"我的关注",@"我的粉丝",@"账号管理",@"主题风格",@"清除缓存",@"关于"];
    }
    return _titleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTab];
    __weak typeof(self) weakSelf = self;
    [HttpRequest userInfoWithToken:myToken userID:userId success:^(id object){
        [weakSelf loadData:object];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadData:(id)object{
    UserModel *user = [UserModel userModelWithDictionary:object];
    self.model = user;
    [_userHeadImg sd_setImageWithURL:[NSURL URLWithString:self.model.strAvatarHd] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"]];
    [_userName setText:user.strScreenName];
}

- (void)loadTab{
    UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:view];
    _tab = view;
    [_tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.rowHeight = 50;
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
    _bgImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"bg_%@",Theme] ofType:@"png"]];
    UIButton *img = [[UIButton alloc]init];
    img.layer.cornerRadius = 25;
    img.clipsToBounds = YES;
    [head addSubview:img];
    _userHeadImg = img;
    UILabel *name = [[UILabel alloc]init];
    name.textColor = [UIColor flatWhiteColor];
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
    [_userHeadImg addTarget:self action:@selector(showMe) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showMe{
    [self.view showUserShowVcWithUserModel:self.model button:_userHeadImg];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self back];
    switch (indexPath.row) {
        case 0:
        case 1:
        {
            [self.view showFriendsVcWithType:indexPath.row userModel:self.model];
        }
            break;
        case 2:
        {
            UserMangerViewController *vc = [[UserMangerViewController alloc]init];
            vc.currentUser = self.model.strScreenName;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            ViewController *vc = (ViewController *)self.parentViewController;
            [vc chooseColorTheme];
        }
            break;
        case 4:
        {
            [[SDImageCache sharedImageCache] cleanDisk];
            [self.view toastWithString:@"清除成功!" type:kLabPostionTypeBottom];
        }
            break;
        case 5:
        {
            AboutViewController *vc = [[AboutViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)back{
    ViewController *vc = (ViewController *)self.parentViewController;
    [vc moreBtndidClick];
}
@end
