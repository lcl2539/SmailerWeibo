//
//  UserTableViewCell.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "UserTableViewCell.h"
#import "UserModel.h"
#import "UIImageView+WebCache.h"
@interface UserTableViewCell()
{
    __weak IBOutlet UIImageView *_userImg;
    __weak IBOutlet UILabel *_userName;
    
    __weak IBOutlet UILabel *_userInfo;
    __weak IBOutlet UIButton *_cancelFansBtn;
}
@end
@implementation UserTableViewCell

+ (instancetype)userCellWithTableView:(UITableView *)tableview{
    UserTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"userCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"UserTableViewCell" owner:nil options:nil].firstObject;
    }
    return cell;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _userImg.clipsToBounds = YES;
    _userImg.layer.cornerRadius = 25;
}

- (void)setModel:(UserModel *)model{
    _model = model;
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.strAvatarLarge]];
    _userName.text = model.strScreenName;
    _userInfo.text = model.strUserDescription;
}

- (void)setType:(UserTableViewCellType)type{
    _type = type;
    if (type == kUserTableViewCellNone) {
        _cancelFansBtn.hidden = YES;
    }
}

@end
