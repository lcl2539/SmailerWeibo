//
//  ButtonImage.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/16.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ButtonImgDelegate <NSObject>
- (void)imgDidTouch:(NSInteger)index;
@end
@interface ButtonImage : UIImageView
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,weak)id <ButtonImgDelegate> delegate;
@end
