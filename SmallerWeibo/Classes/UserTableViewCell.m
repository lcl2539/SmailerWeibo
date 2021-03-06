//
//  UserTableViewCell.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "UserTableViewCell.h"
#import "UserModel.h"
#import "UIView+extend.h"
#import "UIButton+WebCache.h"
@interface UserTableViewCell()
{
    __weak IBOutlet UIButton *_userImg;
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
    _userName.textColor = ThemeColor;
    _userInfo.textColor = ThemeColor;
    _userInfo.alpha = 0.8;
    [_cancelFansBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
    [_userImg addTarget:self action:@selector(showUser) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setModel:(UserModel *)model{
    _model = model;
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.strAvatarLarge] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"]];
    _userName.text = model.strScreenName;
    _userInfo.text = model.strUserDescription;
    self.followType = (model.following) ? kUserFriendsFollowing : kUserFriendsFollowMe;
    if(model.followMe && model.following)self.followType = kUserFriendsAll;
}

- (void)setFollowType:(UserFriendsType)followType{
    _followType = followType;
    NSString *title;
    if (followType == kUserFriendsAll) {
        title = @"互相关注";
    }else{
        title = (followType == kUserFriendsFollowMe) ? @"关注" : @"取消关注";
    }
    [_cancelFansBtn setTitle:title forState:UIControlStateNormal];
}
- (IBAction)changeUserFollowState {
    __weak typeof(self) weakSelf = self;
    [self followUser:self.model.strIdstr isFollowed:self.model.following success:^{
        weakSelf.model.following = !weakSelf.model.following;
        weakSelf.followType = (weakSelf.model.following) ? kUserFriendsFollowing : kUserFriendsFollowMe;
        if(weakSelf.model.followMe && weakSelf.model.following)weakSelf.followType = kUserFriendsAll;
    }];
}

- (void)showUser{
    [self showUserShowVcWithUserModel:self.model button:_userImg];
}

@end
