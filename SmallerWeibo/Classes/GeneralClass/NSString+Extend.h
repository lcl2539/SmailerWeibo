//
//  NSString+WriteUserInfo.h
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (extend)
+ (void)writeUserInfoWithKey:(NSString *)key value:(id)value;
+ (NSString *)filePathWithfile:(NSString *)file;
- (CGSize)getStringSize:(UIFont*)font width:(CGFloat)width;
+ (NSString *)dateFromString:(NSString *)str;
- (NSAttributedString *)attributedStr;
@end
