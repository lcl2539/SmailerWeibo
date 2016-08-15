//
//  NavigationScroll.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NavigationScrollDeleagte <NSObject>

- (void)navigationScrollValueDidChange:(NSInteger)value;

@end
@interface NavigationScroll : UIView

@property (nonatomic,weak)id<NavigationScrollDeleagte> delegate;
- (void)changeNavgationScrollValue:(NSInteger)value;

@end
