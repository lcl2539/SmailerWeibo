//
//  SingExp.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/27.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "MLExpressionManager.h"

@interface SingExp : MLExpression

+ (MLExpression *)shareExp;
+ (NSRegularExpression *)shareRex;
@end
