//
//  SearchViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "SearchViewController.h"
#import <Masonry.h>
#import "UserModel.h"
#import "HttpRequest.h"
#import "UIButton+WebCache.h"
#import <MJRefresh.h>
#import "StatusModel.h"
#import "UIView+extend.h"
#import "UserTableViewCell.h"
#import "TitleView.h"
#import "LStatusTableVC.h"
@interface SearchUserCell ()
{
    __weak IBOutlet UIButton *_userImg;
    __weak IBOutlet UILabel *_userName;
    __weak IBOutlet UIButton *_all;
}
@property (nonatomic,strong)UserModel *model;
@property (nonatomic,copy)void (^allUser)();
@end
@implementation SearchUserCell

- (void)awakeFromNib{
    [super awakeFromNib];
    _userImg.layer.cornerRadius = 25;
    _userImg.clipsToBounds = YES;
    _userName.textColor = ThemeColor;;
    _all.tintColor = ThemeColor;
}

- (void)setModel:(UserModel *)model{
    _model = model;
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.strAvatarLarge] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"]];
    _userName.text = model.strScreenName;
}

- (IBAction)userBtnClickAction:(UIButton *)sender {
    [self showUserShowVcWithUserModel:self.model button:sender];
}

- (IBAction)gotoAllUser:(id)sender {
    if (self.allUser) {
        self.allUser();
    }
}


@end

@interface SearchAllUserVc ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_userList;
    __weak TitleView *_title;
}
@property (nonatomic,copy)NSArray *data;
@property (nonatomic,copy)NSString *text;
@end
@implementation SearchAllUserVc

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadTitleView];
    [self loadUserList];
}

- (void)loadTitleView{
    TitleView *view = [TitleView titleViewWithTitle:@"全部"];
    [self.view addSubview:view];
    _title = view;
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height + 40);
    }];
}

- (void)loadUserList{
    UITableView *tab = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    _userList = tab;
    _userList.delegate = self;
    _userList.dataSource = self;
    [_userList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_title.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    _userList.estimatedRowHeight = 50;
    _userList.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _userList.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _userList.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(httpRequest)];
}

- (void)httpRequest{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 1;
    page = self.data.count/20 + 1;
    page = (self.data.count%20 > 0) ? page + 1 : page;
    [HttpRequest searchForUserWithText:self.text page:page success:^(id object) {
        [weakSelf loadUserWithArr:object[@"users"]];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadUserWithArr:(NSArray *)arr{
    NSMutableArray *arrTemp = [self.data mutableCopy];
    for (NSDictionary *dict in arr) {
        UserModel *model = [UserModel userModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    self.data = arrTemp;
    [_userList reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserTableViewCell *cell = [UserTableViewCell userCellWithTableView:tableView];
    cell.model = self.data[indexPath.row];
    return cell;
}
@end




@interface SearchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>
{
    __weak UICollectionView *_userList;
    __weak LStatusTableVC *_statusList;
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UIView *_bgView;
    __weak IBOutlet UIButton *_searchBtn;
    __weak IBOutlet UIButton *_backBtn;
}
@property (nonatomic,copy)NSArray *userData;
@property (nonatomic,copy)NSString *text;
@end

@implementation SearchViewController

- (NSArray *)userData{
    if (!_userData) {
        _userData = [[NSArray alloc]init];
    }
    return _userData;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _searchBar.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
}

- (void)loadSomeSetting{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _bgView.backgroundColor = ThemeColor;
}

- (void)loadStatusList{
    LStatusTableVC *tab = [[LStatusTableVC alloc]initWithStyle:UITableViewStyleGrouped];
    [self addChildViewController:tab];
    [self.view addSubview:tab.view];
    _statusList = tab;
    [_statusList.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bgView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    _statusList.haveReload = NO;
    __weak typeof(self) weakSelf = self;
    tab.reloadDate = ^(LStatusTableVC *vc,BOOL isReload){
        [weakSelf httpRequest];
    };
    tab.didScroll = ^{
        if (_searchBar.isFirstResponder) {
            [_searchBar resignFirstResponder];
        }
    };
    [self loadUserList];
}

- (void)loadUserList{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(66, 89);
    layout.minimumInteritemSpacing = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *view = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 100) collectionViewLayout:layout];
    [view registerNib:[UINib nibWithNibName:@"SearchUserCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"UserCell"];
    [view registerNib:[UINib nibWithNibName:@"AllUserCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"AllUserCell"];
    view.delegate = self;
    view.backgroundColor = [UIColor whiteColor];
    view.dataSource = self;
    _statusList.tableView.tableHeaderView = view;
    _userList = view;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _searchBtn.userInteractionEnabled = (_searchBar.text.length > 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (self.userData.count > 0) ? self.userData.count + 1 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.userData.count) {
        __weak typeof(self) weakSelf = self;
        SearchUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AllUserCell" forIndexPath:indexPath];
        cell.allUser = ^(){
            [weakSelf searchUser];
        };
        return cell;
    }else{
        SearchUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
        cell.model = self.userData[indexPath.row];
        return cell;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_searchBar.isFirstResponder) {
        [_searchBar resignFirstResponder];
    }
}

- (void)searchUser{
    SearchAllUserVc *vc = [[SearchAllUserVc alloc]init];
    vc.data = self.userData;
    vc.text = self.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)search:(id)sender {
    _statusList.dataArr = nil;
    self.userData = nil;
    self.text = _searchBar.text;
    __weak typeof(self) weakSelf = self;
    [HttpRequest searchForUserWithText:_searchBar.text page:1 success:^(id object) {
        [weakSelf loadUserWithArr:object[@"users"]];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    [self httpRequest];
    [self loadStatusList];
}

- (void)httpRequest{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 1;
    page = _statusList.dataArr.count/20 + 1;
    page = (_statusList.dataArr.count%20 > 0) ? page + 1 : page;
    [HttpRequest topicStatusWithTopic:_searchBar.text page:page success:^(id object) {
        [weakSelf loadStatusWithArr:object[@"statuses"]];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadUserWithArr:(NSArray *)arr{
    NSMutableArray *arrTemp = [self.userData mutableCopy];
    for (NSDictionary *dict in arr) {
        UserModel *model = [UserModel userModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    self.userData = arrTemp;
    [_userList reloadData];
}

- (void)loadStatusWithArr:(NSArray *)arr{
    NSMutableArray *arrTemp = [_statusList.dataArr mutableCopy];
    for (NSDictionary *dict in arr) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
//    if (arrTemp.count == self.statusData.count) {
//        [_statusList.mj_footer endRefreshingWithNoMoreData];
//    }else{
//        [_statusList.mj_footer endRefreshing];
//    }
    //[_statusList.mj_header endRefreshing];
    _statusList.dataArr = arrTemp;
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
