//
//  ButtonImage.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/16.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "ButtonImage.h"

@implementation ButtonImage
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(imgDidTouch:)]) {
        [self.delegate imgDidTouch:self.index];
    }
}
@end
