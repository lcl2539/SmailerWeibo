//
//  StatusText.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/9.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface StatusText : NSMutableAttributedString
+ (NSAttributedString *)changStrToStatusText:(NSString *)originalString fontSize:(CGFloat)size;

@end
