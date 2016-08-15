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
        [self loadCollectionView];
        [self loadSomeSetting];
    }
    return self;
}

- (void)loadSomeSetting{
    self.backgroundColor = [UIColor darkGrayColor];
}

- (void)loadCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *scroll = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    scroll.delegate = self;
    scroll.dataSource = self;
    [scroll registerNib:[UINib nibWithNibName:@"NavigationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"NavigationCell"];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.showsHorizontalScrollIndicator = NO;
    _collectionView = scroll;
    [self addSubview:scroll];
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

@end
