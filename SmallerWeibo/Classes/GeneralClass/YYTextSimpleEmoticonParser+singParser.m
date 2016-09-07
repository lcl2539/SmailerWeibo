//
//  YYTextSimpleEmoticonParser+singParser.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/2.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "YYTextSimpleEmoticonParser+singParser.h"

@implementation YYTextSimpleEmoticonParser (singParser)
+ (instancetype)myParser{
    static YYTextSimpleEmoticonParser *parser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[YYTextSimpleEmoticonParser alloc]init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        NSDictionary *dictTemp = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"face.plist" ofType:nil]];
        NSBundle *face = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Image" ofType:@"bundle"]];
        for (NSString *key in dictTemp) {
            [dict setObject:[UIImage imageNamed:dictTemp[key] inBundle:face compatibleWithTraitCollection:nil] forKey:key];
        }
        parser.emoticonMapper = dict;
    });
    return parser;
}

@end
