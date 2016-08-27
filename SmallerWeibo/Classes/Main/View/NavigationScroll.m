//
//  NavigationScroll.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "NavigationScroll.h"
#import "NavigationCollectionViewCell.h"
#import "NSString+Extend.h"
#import <Masonry.h>
@interface NavigationScroll ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    __weak UICollectionView *_collectionView;
}
@property (nonatomic,copy)NSArray *titleArr;
@end

@implementation NavigationScroll

- (NSArray *)titleArr{
    if (!_titleArr) {
        _titleArr = @[@"主页",@"我的微博",@"广场",@"收藏",@"评论",@"提及的微博",@"提及的评论"];
    }
    return _titleArr;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self loadTopView];
        [self loadCollectionView];
        [self loadSomeSetting];
    }
    return self;
}

- (void)loadSomeSetting{
    self.backgroundColor = [UIColor darkGrayColor];
}

- (void)loadTopView{
    UIButton *user =[UIButton buttonWithType:UIButtonTypeSystem];
    [user addTarget:self action:@selector(userBtn) forControlEvents:UIControlEventTouchUpInside];
    [user setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    [self addSubview:user];
    [user setTintColor:[UIColor whiteColor]];
    [user mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self).offset(8);
        make.width.height.equalTo(@30);
    }];
    /*UIButton *search = [UIButton buttonWithType:UIButtonTypeSystem];
    [search setTintColor:[UIColor whiteColor]];
    [search setImage:[UIImage imageNamed:@"Search"] forState:UIControlStateNormal];
    [search addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:search];
    [search mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(user.mas_top).offset(1);
        make.trailing.equalTo(self.mas_trailing).offset(-8);
        make.width.height.equalTo(@28);
    }];*/
}

- (void)loadCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *scroll = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    scroll.delegate = self;
    scroll.dataSource = self;
    [scroll registerNib:[UINib nibWithNibName:@"NavigationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"NavigationCell"];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.showsHorizontalScrollIndicator = NO;
    _collectionView = scroll;
    [self addSubview:scroll];
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(30);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titleArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NavigationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NavigationCell" forIndexPath:indexPath];
    cell.title = self.titleArr[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(navigationScrollValueDidChange:)]) {
        [self.delegate navigationScrollValueDidChange:indexPath.row];
    }
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize itemSize = [self.titleArr[indexPath.row] getStringSize:[UIFont systemFontOfSize:15] width:self.bounds.size.width];
    return CGSizeMake(itemSize.width + 20, itemSize.height);
}

- (void)changeNavgationScrollValue:(NSInteger)value{
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:value inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)userBtn{
    if ([self.delegate respondsToSelector:@selector(moreBtndidClick)]) {
        [self.delegate moreBtndidClick];
    }
}


@end
