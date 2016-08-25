//
//  commentsModel.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserModel;
@interface commentsModel : NSObject
@property (nonatomic,copy)NSString *commentsText;
@property (nonatomic,strong)UserModel *user;
@property (nonatomic,copy)NSString *creatTime;
@end
