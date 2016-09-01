//
//  commentsModel.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "commentsModel.h"
#import "UserModel.h"
#import "NSString+Extend.h"
@implementation commentsModel
+ (instancetype)commentsModleWithDict:(NSDictionary *)dict{
    commentsModel *model = [[commentsModel alloc]init];
    model.user = [UserModel userModelWithDictionary:dict[@"user"]];
    model.commentsText = dict[@"text"];
    model.creatTime = [NSString dateFromString:dict[@"created_at"]];
    return model;
}
@end
