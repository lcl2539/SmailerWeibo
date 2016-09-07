//
//  SendStatus.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SendStatus : NSObject
@property (nonatomic,strong)NSMutableArray *status;
+ (instancetype)shareSendStatus;
@end

@interface NewStatusModel : NSObject
@property (nonatomic,copy)NSString *status;
@property (nonatomic,copy)NSArray *imgArr;
+ (instancetype)newStatusMoldeWithStatus:(NSString *)status imgArr:(NSArray *)arr;
@end
