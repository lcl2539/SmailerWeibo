//
//  ShowImgCollectionView.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/6.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowImgCollectionView : UICollectionView
@property (nonatomic,copy)NSArray *data;
+ (instancetype)showImgView;
@end

@interface ImgShowCollectionViewCell : UICollectionViewCell

@end
