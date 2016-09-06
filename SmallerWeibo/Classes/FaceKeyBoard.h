//
//  FaceKeyBoard.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceKeyBoard : UIView
@property (nonatomic,copy)void (^faceDidTouch)(NSString *);
@property (nonatomic,copy)void (^delectBtnDidClick)();
+ (instancetype)shareFaceKeyBoard;
@end

@interface FaceKeyBoardCollectionView : UICollectionView
@property (nonatomic,copy)void (^faceDidClick)(NSString *);
+ (instancetype)faceKeyBoardWithPlistPath:(NSString *)path;
@end

@interface FaceKeyBoardCollectionViewCell : UICollectionViewCell
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *image;
@end
