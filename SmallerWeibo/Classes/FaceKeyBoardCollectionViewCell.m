//
//  FaceKeyBoardCollectionViewCell.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "FaceKeyBoardCollectionViewCell.h"
@interface FaceKeyBoardCollectionViewCell ()
{
    __weak IBOutlet UIImageView *_img;
    
}
@end
@implementation FaceKeyBoardCollectionViewCell


- (void)setImage:(NSString *)image{
    _image = image;
    static NSBundle *bundle;
    bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Image.bundle" ofType:nil]];
    [_img setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:image ofType:@"png"]]];
}

@end
