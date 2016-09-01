//
//  SingExp.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/27.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "SingExp.h"

@implementation SingExp

+ (MLExpression *)shareExp{
    static MLExpression *exp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!exp) {
            exp = [MLExpression expressionWithRegex:@"\\[[^\\[\\]]*\\]" plistName:@"face.plist" bundleName:@"Image"];
        }
    });
    return exp;
}

@end
