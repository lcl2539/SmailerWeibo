//
//  Theme.h
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/9.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Theme : NSObject
@property (nonatomic,strong)UIColor *color;
+ (instancetype)shareColor;
@end
