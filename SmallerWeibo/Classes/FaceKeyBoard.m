//
//  FaceKeyBoard.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "FaceKeyBoard.h"
#import "FaceKeyBoardCollectionViewCell.h"
@interface FaceKeyBoard ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,copy)NSArray *data;
@end
@implementation FaceKeyBoard

+ (instancetype)shareFaceKeyBoard{
    static FaceKeyBoard *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.itemSize = CGSizeMake(40, 40);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        view = [[FaceKeyBoard alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        view.delegate = view;
        view.dataSource = view;
        [view registerNib:[UINib nibWithNibName:@"FaceKeyBoardCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FaceCell"];
        view.backgroundColor = [UIColor clearColor];
        view.showsHorizontalScrollIndicator = NO;
    });
    return view;
}

- (NSArray *)data{
    if (!_data) {
        NSDictionary *dictTemp = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face.plist" ofType:nil]];
        NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:dictTemp.count];
        for (NSString *key in dictTemp) {
            [arr addObject:@{key:dictTemp[key]}];
        }
        _data = [arr copy];
    }
    return _data;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FaceKeyBoardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceCell" forIndexPath:indexPath];
    NSDictionary *dicTemp = self.data[indexPath.row];
    cell.image = dicTemp[dicTemp.allKeys.lastObject];
    return cell;
}

@end
