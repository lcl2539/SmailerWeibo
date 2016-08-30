//
//  UserInfoHeadView.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "UserInfoHeadView.h"
#import "UserModel.h"
#import "UIImageView+WebCache.h"
@interface UserInfoHeadView ()
{
    __weak IBOutlet UIImageView *_userImg;
    __weak IBOutlet UILabel *_userName;
    __weak IBOutlet UILabel *_userText;
    __weak IBOutlet UILabel *_statusNum;
    __weak IBOutlet UILabel *_fansNum;
    __weak IBOutlet UILabel *_friendsNum;
}
@end
@implementation UserInfoHeadView

+ (instancetype)headView{
    UserInfoHeadView *view = [[NSBundle mainBundle]loadNibNamed:@"UserInfoHeadView" owner:nil options:nil].firstObject;
    return view;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _userImg.layer.cornerRadius = 35;
    _userImg.clipsToBounds = YES;
    _userImg.alpha = 0;
}

- (void)setModel:(UserModel *)model{
    _model = model;
    __weak typeof(self) weakSelf = self;
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.strAvatarHd] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (weakSelf.downloadFinish) {
            weakSelf.downloadFinish();
        }
    }];
    _userName.text = model.strScreenName;
    _userText.text = model.strUserDescription;
    _statusNum.text = [NSString stringWithFormat:@"%ld",model.statusesCount];
    _fansNum.text = [NSString stringWithFormat:@"%ld",model.followersCount];
    _friendsNum.text = [NSString stringWithFormat:@"%ld",model.friendsCount];
    _userImgFrame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-35, 20, 70, 70);
}
- (IBAction)backBtnAction {
    [self.delegate back];
}

- (void)userImgShow{
    _userImg.alpha = (_userImg.alpha == 1) ? 0 : 1;;
}
@end
