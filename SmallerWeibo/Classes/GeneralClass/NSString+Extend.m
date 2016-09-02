//
//  NSString+WriteUserInfo.m
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "NSString+Extend.h"
#import "MLExpressionManager.h"
#import "SingExp.h"
@implementation NSString (extend)
+ (void)writeUserInfoWithKey:(NSString *)key value:(id)value{
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)filePathWithfile:(NSString *)file{
    static NSString *str;
    static NSFileManager *manager;
    str = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    manager = [NSFileManager defaultManager];
    str = [str stringByAppendingPathComponent:file];
    if (![manager fileExistsAtPath:str]) {
        [manager createFileAtPath:str contents:nil attributes:nil];
    }
    return str;
};

- (CGSize)getStringSize:(UIFont*)font width:(CGFloat)width
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    NSDictionary *attrSyleDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  font, NSFontAttributeName,
                                  nil];
    [attributedString addAttributes:attrSyleDict
                              range:NSMakeRange(0, self.length)];
    CGRect stringRect = [attributedString boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       context:nil];
    
    return stringRect.size;
}

+ (NSString *)dateFromString:(NSString *)str{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"EEE MMM dd HH:mm:SS Z yyyy";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date = [formatter dateFromString:str];
    formatter.dateFormat = @"MM-dd HH:mm";
    NSString *time = [formatter stringFromDate:date];
    return time;
}

- (NSAttributedString *)attributedStr{
    return [MLExpressionManager expressionAttributedStringWithString:self expression:[SingExp shareExp]];
}

@end
