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
#import <Chameleon.h>
#import "UIView+extend.h"
@interface UserInfoHeadView ()
{
    __weak IBOutlet UIImageView *_userImg;
    __weak IBOutlet UILabel *_userName;
    __weak IBOutlet UILabel *_userText;
    __weak IBOutlet UILabel *_statusNum;
    __weak IBOutlet UILabel *_fansNum;
    __weak IBOutlet UILabel *_friendsNum;
    __weak IBOutlet UIButton *_statusBtn;
    __weak IBOutlet UIButton *_fansBtn;
    __weak IBOutlet UIButton *_frendsBtn;
    __weak IBOutlet UIButton *_backBtn;
    __weak IBOutlet UIButton *_likeBtn;
    __weak IBOutlet NSLayoutConstraint *_userImgHeight;
    __weak IBOutlet NSLayoutConstraint *_userImgWeight;
}
@property (nonatomic,strong)UIColor *textColor;
@end
@implementation UserInfoHeadView

- (void)setUserImage:(UIImage *)userImage{
    _userImage = userImage;
    self.backgroundColor = GradientColor(UIGradientStyleRadial, self.frame, [NSArray arrayOfColorsFromImage:userImage withFlatScheme:NO]);
    self.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.backgroundColor isFlat:YES];
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    _userName.textColor = textColor;
    _userText.textColor = textColor;
    _fansNum.textColor = textColor;
    _friendsNum.textColor = textColor;
    _statusNum.textColor = textColor;
    [_fansBtn setTitleColor:textColor forState:UIControlStateNormal];
    [_frendsBtn setTitleColor:textColor forState:UIControlStateNormal];
    [_statusBtn setTitleColor:textColor forState:UIControlStateNormal];
    [_likeBtn setTitleColor:textColor forState:UIControlStateNormal];
    [_backBtn setTitleColor:textColor forState:UIControlStateNormal];
}

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
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.strAvatarLarge] placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (weakSelf.downloadFinish) {
            weakSelf.downloadFinish();
        }
        self.backgroundColor = GradientColor(UIGradientStyleRadial, self.frame, [NSArray arrayOfColorsFromImage:image withFlatScheme:NO]);
        self.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.backgroundColor isFlat:YES];
    }];
    _userName.text = model.strScreenName;
    _userText.text = model.strUserDescription;
    _statusNum.text = [NSString stringWithFormat:@"%ld",(long)model.statusesCount];
    _fansNum.text = [NSString stringWithFormat:@"%ld",(long)model.followersCount];
    _friendsNum.text = [NSString stringWithFormat:@"%ld",(long)model.friendsCount];
    _userImgFrame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-35, 20, 70, 70);
}

- (IBAction)backBtnAction {
    [self.delegate back];
}

- (void)changeAlpha:(CGFloat)alpha{
    _userName.alpha = alpha;
    _userText.alpha = alpha;
    _statusNum.alpha = alpha;
    _fansNum.alpha = alpha;
    _friendsNum.alpha = alpha;
    _statusBtn.alpha = alpha;
    _fansBtn.alpha = alpha;
    _frendsBtn.alpha = alpha;
    _userImgWeight.constant = 70 - 20 *(1-alpha);
    _userImgHeight.constant = 70 - 20 *(1-alpha);
    _userImg.layer.cornerRadius = _userImgHeight.constant/2;
}
- (IBAction)peopleBtnDidClick:(UIButton *)sender {
    [self showFriendsVcWithType:sender.tag userModel:self.model];
}

- (void)userImgShow{
    _userImg.alpha = (_userImg.alpha == 1) ? 0 : 1;;
}
@end
