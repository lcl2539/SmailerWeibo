//
//  StatusTextView.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusTextView : UIView
@property (nonatomic,copy)NSArray *imgArr;
@property (nonatomic,copy)NSString *status;
@property (nonatomic,copy)void (^sendStatus)();
- (void)beginEdit;
- (void)changeTypeToMini;
+ (instancetype)statusTextView;
@end
