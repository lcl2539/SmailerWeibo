//
//  StatusText.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/9.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "StatusText.h"
#define rangeLength (range.length+range.location)
#define imageConditions @"\\[[^\\[\\]]*\\]"
#define UserConditions @"\\@\\w+"
#define topicConditions @"#[^#]*#"
@implementation StatusText

+ (NSAttributedString *)changStrToStatusText:(NSString *)originalString fontSize:(CGFloat)size{
    NSArray *arrTemp = [self getImgRange:originalString];
    UIFont *font = [UIFont systemFontOfSize:size];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:@"" attributes:@{NSFontAttributeName:font}];
    for (NSValue *value in arrTemp) {
        NSRange range = [value rangeValue];
        NSString *subStr = [originalString substringWithRange:range];
        if ([subStr containsString:@"["] && [subStr containsString:@"]"]) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:[[NSBundle mainBundle] pathForResource:subStr ofType:nil]];
            attachment.bounds = CGRectMake(0, -5, font.lineHeight, font.lineHeight);
            [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }else{
            [string appendAttributedString:[[NSAttributedString alloc]initWithString:subStr attributes:@{NSFontAttributeName:font}]];
        }
    }
    string = [self changeStrToLink:string];
    return string;
}

+ (NSMutableAttributedString *)changeStrToLink:(NSMutableAttributedString *)string{
    NSArray *patternArr = @[UserConditions,topicConditions];
    for (NSString *pattern in patternArr) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSArray *arr = [regex matchesInString:string.string options:NSMatchingReportProgress range:NSMakeRange(0, string.string.length)];
        for (NSTextCheckingResult *result in arr) {
            [string addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@"http://www.baidu.com"] range:result.range];
        }
    }
    return string;
}

+ (NSArray *)getImgRange:(NSString *)originalString{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:imageConditions options:0 error:nil];
    NSArray *arr = [regex matchesInString:originalString options:NSMatchingReportProgress range:NSMakeRange(0, originalString.length)];
    NSMutableArray *allRangeArr = [[NSMutableArray alloc]init];
    NSInteger allLoc = 0;
    if (arr.count) {
        for (NSTextCheckingResult *result in arr) {
            NSInteger loc = result.range.location;
            NSInteger length = result.range.length;
            if (loc > allLoc) {
                [allRangeArr addObject:[NSValue valueWithRange:NSMakeRange(allLoc, loc-allLoc)]];
            }
            [allRangeArr addObject:[NSValue valueWithRange:result.range]];
            allLoc = loc + length;
            if ([result isEqual: arr.lastObject] && (originalString.length > (loc + length))) {
                [allRangeArr addObject:[NSValue valueWithRange:NSMakeRange(loc + length, originalString.length-loc-length)]];
            }
        }
    }else{
        [allRangeArr addObject:[NSValue valueWithRange:NSMakeRange(0, originalString.length)]];
    }
    return allRangeArr;
}

@end
