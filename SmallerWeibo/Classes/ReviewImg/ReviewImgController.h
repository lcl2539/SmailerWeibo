//
//  ReviewImgController.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/16.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewImgController : UIViewController<UINavigationControllerDelegate>
@property (nonatomic,copy)NSArray *picArr;
@property (nonatomic,assign)NSInteger showWhichImg;
@property (nonatomic,strong)UIImageView *placeHoldimageView;
@property (nonatomic,assign)CGRect lastFrame;
@property (nonatomic,copy)NSArray *frameArr;
@property (nonatomic,strong)UIViewController *fromVc;
@property (nonatomic,strong)NSArray *placeHoldImages;
- (void)show;
@end
