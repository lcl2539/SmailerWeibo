//
//  FaceKeyBoard.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceKeyBoardCollectionView : UICollectionView
@property (nonatomic,copy)void (^faceDidClick)(NSString *,NSString *);
+ (instancetype)faceKeyBoardWithPlistPath:(NSString *)path;
@end
