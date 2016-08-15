//
//  StatusTableViewBaseView.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#define tableViewFrame(index) CGRectMake(index * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)
#import "MainScrollView.h"
#import "StatusTableView.h"
#import "HttpRequest.h"
#import "StatusModel.h"
@interface MainScrollView ()<UIScrollViewDelegate>
@property (nonatomic,strong)NSMutableSet *visibleTabViewControllers;
@property (nonatomic,strong)NSMutableSet *reusedTableViewControllers;
@property (nonatomic,strong)NSMutableArray *allData;
@end

@implementation MainScrollView

- (NSMutableSet *)visibleTabViews{
    if (!_visibleTabViewControllers) {
        _visibleTabViewControllers = [[NSMutableSet alloc]init];
    }
    return _visibleTabViewControllers;
}

- (NSMutableSet *)reusedTableViews{
    if (!_reusedTableViewControllers) {
        _reusedTableViewControllers = [[NSMutableSet alloc]init];
    }
    return _reusedTableViewControllers;
}

- (NSMutableArray *)allData{
    if (!_allData) {
        NSMutableArray *arrTemp = [[NSMutableArray alloc]initWithCapacity:6];
        for (NSInteger index = 0; index < 7; index++) {
            NSArray *arr = [[NSArray alloc]init];
            [arrTemp addObject:arr];
        }
        _allData = arrTemp;
    }
    return _allData;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame: frame]) {
        [self loadSomeSetting];
    }
    return self;
}

- (void)loadSomeSetting{
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.contentSize = CGSizeMake(self.frame.size.width * 7, 0);
    self.delegate = self;
    self.bounces = NO;
    [self showStatusTableViewAtIndex:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self judgeStatusScrollIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.mainScrollValueDidChange) {
        self.mainScrollValueDidChange(self.bounds.origin.x/self.bounds.size.width);
    }
}

- (void)judgeStatusScrollIndex{
    CGRect visibleBounds = self.bounds;
    CGFloat minX = CGRectGetMinX(visibleBounds);
    CGFloat maxX = CGRectGetMaxX(visibleBounds);
    CGFloat Width = CGRectGetWidth(visibleBounds);
    NSInteger firstIndex = (NSInteger)floorf(minX / Width);
    NSInteger lastIndex = (NSInteger)floorf(maxX / Width);
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (lastIndex >= 7) {
        lastIndex = 6;
    }
    for (StatusTableView *view in self.visibleTabViews) {
        if (view.tag < firstIndex || view.tag > lastIndex) {
            [self.reusedTableViews addObject:view];
            NSLog(@"________%ld",view.tag);
            [view removeFromSuperview];
        }
    }
    [self.visibleTabViews minusSet:self.reusedTableViews];
    for(NSInteger index = firstIndex; index <= lastIndex; index ++){
        BOOL isShow = NO;
        for (StatusTableView *view in self.visibleTabViews) {
            if (index == view.tag) {
                isShow = YES;
            }
        }
        if (!isShow) {
            [self showStatusTableViewAtIndex:index];
        }
    }
}

- (void)showStatusTableViewAtIndex:(NSInteger)index{
    StatusTableView *view = [self.reusedTableViews anyObject];
    if(view){
        [self.reusedTableViews removeObject:view];
        view.dataArr = self.allData[index];
    }else{
        StatusTableView *childView  = [[StatusTableView alloc]init];
        view = childView;
        view.dataArr = nil;
    }
    view.tag = index;
    view.frame = tableViewFrame(index);
    [self addSubview:view];
    [view reloadData];
    [self.visibleTabViews addObject:view];
}

- (void)loadDataWithTableView:(StatusTableView *)view index:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    [HttpRequest statusHttpRequestWithType:index success:^(id Object) {
        [weakSelf loadDataWithArr:Object[@"statuses"] tableView:view];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr tableView:(StatusTableView *)view {
    NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in arr) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    [self.allData replaceObjectAtIndex:view.tag withObject:arrTemp];
    view.dataArr = arrTemp;
    [view reloadData];
}
@end
