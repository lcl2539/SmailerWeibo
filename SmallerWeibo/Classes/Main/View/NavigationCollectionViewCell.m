//
//  NavigationCollectionViewCell.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "NavigationCollectionViewCell.h"
@interface NavigationCollectionViewCell ()
{
    __weak IBOutlet UILabel *_titleLab;
    
}
@end

@implementation NavigationCollectionViewCell

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [UIView animateWithDuration:0.25 animations:^{
        _titleLab.textColor = selected ? [UIColor whiteColor] : [UIColor colorWithWhite:1 alpha:0.5];
        _titleLab.transform = selected ? CGAffineTransformMakeScale(1.1, 1.1) : CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLab.text = title;
}

@end
