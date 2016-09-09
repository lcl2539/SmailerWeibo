//
//  CommentsTableViewCell.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import "MLLinkLabel.h"
#import "MLExpressionManager.h"
#import "SingExp.h"
#import "CommentsTableViewCell.h"
#import "UserModel.h"
#import "UIButton+WebCache.h"
#import "commentsModel.h"
#import "UIView+extend.h"
@interface CommentsTableViewCell ()<MLLinkLabelDelegate>
{
    __weak IBOutlet UIButton *_userImg;
    __weak IBOutlet UILabel *_userName;
    __weak IBOutlet UILabel *_creatTime;
    __weak IBOutlet MLLinkLabel *_comments;
    
}
@property (nonatomic,strong)MLExpression *exp;
@end
@implementation CommentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _userImg.layer.cornerRadius = 25;
    _comments.delegate = self;
    _userName.textColor = ThemeColor;
    _comments.linkTextAttributes = @{NSForegroundColorAttributeName:ThemeColor};
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (selected) {
        
    }
}
- (IBAction)userImgDidClick {
    [self showUserShowVcWithUserModel:self.model.user button:_userImg];
}

+ (instancetype)commentsCellWithTableview:(UITableView *)tabelview{
    CommentsTableViewCell *cell = [tabelview dequeueReusableCellWithIdentifier:@"commentsCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"CommentsTableViewCell" owner:nil options:nil].firstObject;
        cell.exp = [SingExp shareExp];
    }
    return cell;
}

- (void)setModel:(commentsModel *)model{
    _model = model;
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.user.strProfileImageUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"]];
    _userName.text = model.user.strScreenName;
    _creatTime.text = model.creatTime;
    _comments.attributedText = [MLExpressionManager expressionAttributedStringWithString:model.commentsText expression:self.exp];
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel{
    
}


@end
