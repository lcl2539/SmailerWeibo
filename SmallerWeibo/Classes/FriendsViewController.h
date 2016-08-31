//
//  FansViewController.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    kFriendsVcFans,
    kFriendsVcFollows
} kFriendsType;
@interface FriendsViewController : UIViewController
@property (nonatomic,assign)kFriendsType type;
@end
