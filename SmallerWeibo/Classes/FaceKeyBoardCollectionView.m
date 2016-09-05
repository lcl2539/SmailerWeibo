//
//  FaceKeyBoard.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "FaceKeyBoardCollectionView.h"
#import "FaceKeyBoardCollectionViewCell.h"
@interface FaceKeyBoardCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,copy)NSArray *data;
@end
@implementation FaceKeyBoardCollectionView

+ (instancetype)faceKeyBoardWithPlistPath:(NSString *)path{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    layout.itemSize = CGSizeMake(30, 30);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    FaceKeyBoardCollectionView *view = [[FaceKeyBoardCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    view = [[FaceKeyBoardCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    view.delegate = view;
    view.dataSource = view;
    view.contentInset = UIEdgeInsetsMake(10, 20, 0, 20);
    view.data = [NSArray arrayWithContentsOfFile:path];
    [view registerNib:[UINib nibWithNibName:@"FaceKeyBoardCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FaceCell"];
    view.backgroundColor = [UIColor clearColor];
    view.showsHorizontalScrollIndicator = NO;
    return view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.data[indexPath.row];
    if (self.faceDidClick) {
        self.faceDidClick(dict.allKeys.lastObject,dict.allValues.lastObject);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FaceKeyBoardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceCell" forIndexPath:indexPath];
    NSDictionary *dicTemp = self.data[indexPath.row];
    cell.name = dicTemp.allKeys.lastObject;
    cell.image = dicTemp[dicTemp.allKeys.lastObject];
    return cell;
}

@end
