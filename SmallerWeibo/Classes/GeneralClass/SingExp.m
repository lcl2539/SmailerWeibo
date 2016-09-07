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

+ (NSRegularExpression *)shareRex{
    static NSRegularExpression *rex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rex = [NSRegularExpression regularExpressionWithPattern:@"http://t.cn/\\w{7}" options:0 error:nil];
    });
    return rex;
}

@end
