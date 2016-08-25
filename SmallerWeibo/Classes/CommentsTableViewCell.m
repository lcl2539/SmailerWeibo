//
//  CommentsTableViewCell.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import "MLLinkLabel.h"
#import "CommentsTableViewCell.h"
#import "UserModel.h"
#import "StatusText.h"
#import "UIButton+WebCache.h"
@interface CommentsTableViewCell ()<MLLinkLabelDelegate>
{
    __weak IBOutlet UIButton *_userImg;
    __weak IBOutlet UILabel *_userName;
    __weak IBOutlet UILabel *_creatTime;
    __weak IBOutlet MLLinkLabel *_comments;
    
}
@end
@implementation CommentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _userImg.layer.cornerRadius = 25;
    _comments.delegate = self;
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel{
    
}

@end
