//
//  CommentsStatusModel.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/22.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "CommentsStatusModel.h"
#import "StatusModel.h"
#import "UserModel.h"
#import "NSString+Extend.h"
@implementation CommentsStatusModel

+ (instancetype)commentsModelWithDictionary:(NSDictionary *)dicData{
    CommentsStatusModel *model = [[self alloc]init];
    model.strCreatedAt = [NSString dateFromString:dicData[@"created_at"]];
    model.commentID = [dicData[@""] integerValue];
    model.commentText = dicData[@"text"];
    model.status = [StatusModel statusModelWithDictionary:dicData[@"ststus"]];
    model.user = [UserModel userModelWithDictionary:dicData[@"user"]];
    model.strCreatedAt = dicData[@"source"];
    return model;
}

- (void)setStrSource:(NSString *)strSource {
    _strSource = strSource;
    if ([strSource isEqualToString:@""]) {
        _strSource = @"";
        return;
    }
    NSRange rangeLeft = [_strSource rangeOfString:@">"];
    NSRange rangeRight = [_strSource rangeOfString:@"</"];
    NSRange rangeResult = NSMakeRange(rangeLeft.location + 1, rangeRight.location - rangeLeft.location - 1);
    _strSource = [_strSource substringWithRange:rangeResult];
}

@end
