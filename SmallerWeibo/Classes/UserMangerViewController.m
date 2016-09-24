//
//  UserMangerViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "UserMangerViewController.h"
#import "TitleView.h"
#import <Masonry.h>
#import "UIImageView+WebCache.h"
#import "UserModel.h"
#import "HttpRequest.h"
#import "UserModel.h"
#import "LoginViewController.h"
#import "NSString+Extend.h"
#import "UIView+extend.h"
#import "AppDelegate.h"
@interface UserMangerCell ()
{
    __weak IBOutlet UIImageView *_userImg;
    __weak IBOutlet UILabel *_userName;
    __weak IBOutlet UIButton *_delectBtn;
}
@property (nonatomic,strong)UserModel *userInfo;
@property (nonatomic,assign)BOOL isCurrent;
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,copy)void (^delect)(NSInteger);
@end
@implementation UserMangerCell

- (void)setUserInfo:(UserModel *)userInfo{
    _userInfo  =userInfo;
    [_userImg sd_setImageWithURL:[NSURL URLWithString:userInfo.strAvatarLarge] placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"]];
    _userName.text = userInfo.strScreenName;
}

- (void)setIsCurrent:(BOOL)isCurrent{
    _isCurrent = isCurrent;
    if (_isCurrent) {
        [_delectBtn setTitle:@"当前用户" forState:UIControlStateNormal];
        _delectBtn.enabled = NO;
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _userImg.layer.cornerRadius = 25;
    _userImg.clipsToBounds  = YES;
    _userName.textColor = ThemeColor;
    [_delectBtn setTitleColor:ThemeColor forState:UIControlStateDisabled];
}

- (IBAction)delect:(id)sender {
    if (self.delect) {
        self.delect(self.index);
    }
}

@end

@interface UserMangerViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak TitleView *_titleView;
    __weak UITableView *_userList;
}
@property(nonatomic,strong)NSMutableArray *originalData;
@property(nonatomic,strong)NSMutableDictionary *data;
@end

@implementation UserMangerViewController

- (NSMutableArray *)originalData{
    if (!_originalData) {
        _originalData = [[[NSUserDefaults standardUserDefaults]objectForKey:@"AllUser"] mutableCopy];
    }
    return _originalData;
}

- (NSMutableDictionary *)data{
    if (!_data) {
        _data = [[NSMutableDictionary alloc]init];
    }
    return _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self loadTitleView];
    [self loadUserList];
    [self loadAddUserBtn];
    [self loadData];
}

- (void)loadTitleView{
    TitleView *view = [TitleView titleViewWithTitle:@"账号管理"];
    [self.view addSubview:view];
    _titleView = view;
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo([[UIApplication sharedApplication]statusBarFrame].size.height+50);
    }];
}

- (void)loadUserList{
    UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:view];
    view.delegate = self;
    view.dataSource = self;
    view.rowHeight = 70;
    view.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _userList = view;
    [_userList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
}

- (void)loadAddUserBtn{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, 50)];
    [btn setTitle:@"添加用户" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    _userList.tableFooterView = btn;
}

- (void)loadData{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:self.originalData.count];
    __weak typeof(self) weakSelf = self;
    for (NSDictionary *dict in self.originalData) {
        [HttpRequest userInfoWithToken:dict[@"access_token"] userID:dict[@"uid"] success:^(id object) {
            UserModel *model = [UserModel userModelWithDictionary:object];
            [data setObject:model forKey:model.strIdstr];
            if (data.count == weakSelf.originalData.count) {
                weakSelf.data = data;
                [_userList reloadData];
            }
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.originalData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserMangerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserMangerCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"UserMangerCell" owner:nil options:nil].firstObject;
        __weak typeof(self) weakSelf = self;
        cell.delect = ^(NSInteger index){
            [weakSelf delectUser:index];
        };
    }
    cell.userInfo = self.data[self.originalData[indexPath.row][@"uid"]];
    if ([cell.userInfo.strScreenName isEqualToString:self.currentUser]) {
        cell.isCurrent = YES;
    }
    cell.index = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserMangerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.isCurrent)return;
    [self changeUserWithTitle:@"是否切换到此用户？" user:self.originalData[indexPath.row]];
}

- (void)addUser{
    LoginViewController *vc = [[LoginViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    vc.addUserFinish = ^(NSDictionary *user){
        [weakSelf addUserFinish:user];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addUserFinish:(NSDictionary *)user{
    if (!user){
        [self.view toastWithString:@"此用户已登录，无需再次登录" type:kLabPostionTypeBottom];
        return;
    }
    [self changeUserWithTitle:@"添加用户成功" user:user];
    [self reloadData];
}

- (void)delectUser:(NSInteger)index{
    [self.originalData removeObjectAtIndex:index];
    UserMangerCell *cell = [_userList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self.data removeObjectForKey:cell.userInfo.strIdstr];
    [_userList deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    [NSString writeUserInfoWithKey:@"AllUser" value:self.originalData];
    
}

- (void)reloadData{
    self.originalData = nil;
    self.data = nil;
    [self loadData];
}

- (void)changeUserWithTitle:(NSString *)title user:(NSDictionary *)user{
    //__weak typeof(self) weakSelf = self;
    if (user) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"是否切换到当前用户？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [NSString writeUserInfoWithKey:@"CurrentUser" value:user];
            NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUser"]);
           __weak AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate loadMainViewController];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeUser" object:nil];
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
