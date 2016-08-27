//
//  ViewController.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#define navFrame self.navigationController.navigationBar.bounds
#define tableViewFrame(index) CGRectMake(index * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
#define dictKey(index) [NSString stringWithFormat:@"%ld",index]
#import "ViewController.h"
#import "NavigationScroll.h"
#import "StatusTableViewController.h"
#import "HttpRequest.h"
#import "StatusModel.h"
#import "PrefixHeader.pch"
#import <WeiboSDK.h>
#import <Masonry.h>
#import <AFNetworking.h>
#import "CommentsStatusModel.h"
#import "MoreViewController.h"
@interface ViewController ()<NavigationScrollDeleagte,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    __weak NavigationScroll *_navigationScroll;
    __weak UIScrollView *_mainScroll;
    __weak UIView *_contentView;
    __weak UIView *_placeHoldView;
    __weak UIView *_shadeView;
}
@property (nonatomic,strong)NSMutableSet *visibleTabViewControllers;
@property (nonatomic,strong)NSMutableSet *reusedTableViewControllers;
@property (nonatomic,strong)NSMutableDictionary *allData;
@property (nonatomic,assign)NSInteger top;
@property (nonatomic,strong)MoreViewController *slideVc;
@property (nonatomic,assign)CGRect slideViewFrame;
@end

@implementation ViewController

- (NSMutableSet *)visibleTabViewControllers{
    if (!_visibleTabViewControllers) {
        _visibleTabViewControllers = [[NSMutableSet alloc]init];
    }
    return _visibleTabViewControllers;
}

- (NSMutableSet *)reusedTableViewControllers{
    if (!_reusedTableViewControllers) {
        _reusedTableViewControllers = [[NSMutableSet alloc]init];
    }
    return _reusedTableViewControllers;
}

- (NSMutableDictionary *)allData{
    if (!_allData) {
        _allData = [[NSMutableDictionary alloc]init];
    }
    return _allData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self loadPlaceHoldView];
    [self judgeLogin];
    [self loadSlideGesTure];
}

- (void)judgeLogin{
    NSString *access_token = myToken;
    if (!access_token) {
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = redirect_Url;
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }else{
        [self loadNavgationBarSetting];
        [self loadMianScrollView];
        [_navigationScroll changeNavgationScrollValue:0];
        [self.view bringSubviewToFront:_placeHoldView];
        [self loadShadeView];
        [self loadSlideVc];
        
    }
}

- (void)loadSomeSetting{
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBarHidden = YES;
}

- (void)loadPlaceHoldView{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height);
    }];
    _placeHoldView = view;
}

- (void)loadShadeView{
    UIView *view = [[UIView alloc]initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.view addSubview:view];
    view.alpha = 0;
    _shadeView = view;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(moreBtndidClick)];
    [_shadeView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(screenEdgesSlide:)];
    [_shadeView addGestureRecognizer:pan];
}

- (void)loadSlideVc{
    self.slideVc = [[MoreViewController alloc]init];
    [self addChildViewController:self.slideVc];
    [self.view addSubview:self.slideVc.view];
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.x = - [UIScreen mainScreen].bounds.size.width * 2/3;
    frame.size.width = -frame.origin.x;
    self.slideViewFrame = frame;
    self.slideVc.view.frame = frame;
    [self.slideVc addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(_mainScroll)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    CGFloat X = [change[@"new"] CGRectValue].origin.x;
    CGFloat width = [change[@"new"] CGRectValue].size.width;
    _shadeView.alpha = 1 - (CGFloat)(- X) / width;
}

- (void)loadSlideGesTure{
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenEdgesSlide:)];
    pan.edges = UIRectEdgeLeft;
    pan.delegate = self;
    [_mainScroll addGestureRecognizer:pan];
}

- (void)screenEdgesSlide:(UIPanGestureRecognizer *)slide{
    CGPoint original = CGPointZero;
    if (slide.state == UIGestureRecognizerStateBegan) {
        original = [slide locationInView:self.view];
    }else if (slide.state == UIGestureRecognizerStateChanged) {
        if (self.slideVc.view.frame.origin.x <= 0) {
            CGPoint point = [slide locationInView:self.view];
            CGRect frame = CGRectOffset(self.slideViewFrame, point.x - original.x, 0);
            if (frame.origin.x > 0) {
                frame.origin.x = 0;
            }
            self.slideVc.view.frame = frame;
        }
    }else if (slide.state == UIGestureRecognizerStateEnded){
        if (self.slideVc.view.frame.origin.x < 0) {
            CGRect frame = self.slideViewFrame;
            if (self.slideVc.view.frame.origin.x > -self.slideVc.view.frame.size.width/2) {
                frame.origin.x = 0;
            }
            [UIView animateWithDuration:0.25 animations:^{
                self.slideVc.view.frame = frame;
            }];
        }
    }
}

- (void)loadNavgationBarSetting{
    NavigationScroll *scroll = [[NavigationScroll alloc]init];
    [self.view addSubview:scroll];
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_placeHoldView.mas_bottom);
        make.leading.trailing.equalTo(_placeHoldView);
        make.height.mas_equalTo(navFrame.size.height + 30);
    }];
    _navigationScroll = scroll;
    _navigationScroll.delegate = self;
}

- (void)loadMianScrollView{
    UIScrollView *mainScrollView = [[UIScrollView alloc]init];
    [self.view addSubview:mainScrollView];
    [mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_navigationScroll.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.delegate = self;
    mainScrollView.bounces = NO;
    _mainScroll = mainScrollView;
    UIView *contentView = [[UIView alloc]init];
    [_mainScroll addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(_mainScroll);
        make.centerY.equalTo(_mainScroll.mas_centerY);
        make.width.mas_equalTo(self.view.frame.size.width*7);
    }];
    _contentView = contentView;
    [self showSatusViewAtIndex:0];
    [self loadVisibleTableViewData:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self judgeStatusScrollIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_navigationScroll changeNavgationScrollValue:(_mainScroll.bounds.origin.x/_mainScroll.bounds.size.width)];
    
}

- (void)loadVisibleTableViewData:(NSInteger)index{
    for (StatusTableViewController *vc in self.visibleTabViewControllers) {
        if (vc.index == index) {
            NSArray *arr = [self.allData valueForKey:dictKey(index)];
            if (arr) {
                vc.dataArr = arr;
            }else{
                [self tableViewLoadData:vc isReLoad:NO];
            }
        }
    }
}

- (void)tableViewLoadData:(StatusTableViewController *)vc isReLoad:(BOOL)isReLoad{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 0;
    NSArray *arrTemp = self.allData[[NSString stringWithFormat:@"%ld",vc.index]];
    page = arrTemp.count/20 + 1;
    if (arrTemp.count>0 && page == 1) {
        page += 1;
    }
    if (isReLoad && page >= 1) {
        page = 1;
        [self.allData setObject:[NSArray array] forKey:dictKey(vc.index)];
    }
    [HttpRequest statusHttpRequestWithType:vc.index page:page success:^(id Object) {
        NSArray *arr;
        switch (vc.index) {
            case 0:
            case 1:
            case 2:
            case 6:
                arr = Object[@"statuses"];
                break;
            case 3:
                arr = Object[@"favorites"];
                break;
            case 4:
            case 5:
                arr = Object[@"comments"];
                break;
            default:
                break;
        }
        [weakSelf loadDataWithArr:arr tableView:vc];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr tableView:(StatusTableViewController *)vc {
    NSArray *arrOrigin = self.allData[dictKey(vc.index)];
    NSMutableArray *arrTemp = [arrOrigin mutableCopy];
    if (!arrTemp || arrTemp.count == 0) {
        arrTemp = [[NSMutableArray alloc]init];
    }
    for (NSDictionary *dict in arr) {
        NSObject *model;
        switch (vc.index) {
            case 0:
            case 1:
            case 2:
            case 6:
                model = [StatusModel statusModelWithDictionary:dict];
                break;
            case 3:
                model = [StatusModel statusModelWithDictionary:dict[@"status"]];
                break;
            case 4:
            case 5:
                model = [CommentsStatusModel commentsModelWithDictionary:dict];
                break;
            default:
                break;
        }
        [arrTemp addObject:model];
    }
    [self.allData setObject:arrTemp forKey:dictKey(vc.index)];
    vc.dataArr = [arrTemp copy];
}

- (void)judgeStatusScrollIndex{
    CGRect visiblesBounds = _mainScroll.bounds;
    CGFloat minX = CGRectGetMinX(visiblesBounds);
    CGFloat maxX = CGRectGetMaxX(visiblesBounds);
    CGFloat width = CGRectGetWidth(visiblesBounds);
    NSInteger firstIndex = (NSInteger)floorf(minX/width);
    NSInteger lastIndex = (NSInteger)floorf(maxX/width);
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (lastIndex >= 7) {
        lastIndex = 6;
    }
    for (StatusTableViewController *vc in self.visibleTabViewControllers) {
        if (vc.index < firstIndex || vc.index > lastIndex) {
            [self.reusedTableViewControllers addObject:vc];
            [vc removeFromParentViewController];
            [vc.tableView removeFromSuperview];
        }
    }
    [self.visibleTabViewControllers minusSet:self.reusedTableViewControllers];
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        for (StatusTableViewController *vc in self.visibleTabViewControllers) {
            if (vc.index == index) {
                isShow = YES;
            }
        }
        if (!isShow) {
            [self showSatusViewAtIndex:index];
        }
    }
}

- (void)showSatusViewAtIndex:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    StatusTableViewController *vc = [self.reusedTableViewControllers anyObject];
    if (vc) {
        [self.reusedTableViewControllers removeObject:vc];
    }else{
        StatusTableViewController *childVc = [[StatusTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
        vc = childVc;
        vc.reloadDate = ^(StatusTableViewController *vc,BOOL isReLoad){
            [weakSelf tableViewLoadData:vc isReLoad:isReLoad];
        };
        vc.changeTop = ^(NSInteger value,NSInteger vcIndex){
            if ((NSInteger)floorf(_mainScroll.contentOffset.x/self.view.frame.size.width) != vcIndex) return ;
            if (value >= 38 || value <= -38) return;
            if(value == 0) return;
            if (self.top+value >= 0) {
                self.top = 0;
            }else if(self.top+value <= -38){
                self.top = -38;
            }else{
                self.top += value;
            }
            [_navigationScroll mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_placeHoldView.mas_bottom).offset(self.top);
                make.leading.trailing.equalTo(self.view);
                make.height.mas_equalTo(navFrame.size.height + 30);
            }];
        };
    }
    vc.index = index;
    [self addChildViewController:vc];
    vc.dataArr = nil;
    [_contentView addSubview:vc.tableView];
    [vc.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_contentView);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.leading.mas_equalTo(index * self.view.frame.size.width);
    }];
    [self.visibleTabViewControllers addObject:vc];
    [self loadVisibleTableViewData:index];
}

- (void)navigationScrollValueDidChange:(NSInteger)value{
    [_mainScroll setContentOffset:CGPointMake(value * self.view.frame.size.width, 0) animated:YES];
}

- (void)moreBtndidClick{
    CGRect frame = self.slideVc.view.frame;
    frame.origin.x = (frame.origin.x < 0) ? 0 : -self.view.frame.size.width;
    [UIView animateWithDuration:0.25 animations:^{
        self.slideVc.view.frame = frame;
    }];
}

- (void)dealloc{
    [self.slideVc removeObserver:self.slideVc forKeyPath:@"view.frame"];
}

@end
