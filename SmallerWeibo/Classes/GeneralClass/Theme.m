//
//  Theme.m
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/9.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "Theme.h"
@interface Theme()
@property (nonatomic,copy)NSArray *colors;
@end
@implementation Theme

- (NSArray *)colors{
    if (!_colors) {
        _colors = @[[UIColor flatSkyBlueColor],
                    [UIColor flatPinkColor],
                    [UIColor flatWatermelonColor],
                    [UIColor flatOrangeColor],
                    [UIColor flatGreenColorDark],
                    [UIColor flatMintColorDark],
                    [UIColor flatTealColor],
                    [UIColor flatMagentaColor],
                    [UIColor flatBlackColor]];
    }
    return _colors;
}

- (UIColor *)color{
    if (!_color) {
        NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ColorTheme"] integerValue];
        _color = self.colors[index];
    }
    return _color;
}

+ (instancetype)shareColor{
    static Theme *theme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theme = [[Theme alloc]init];
        
    });
    return theme;
}

@end
