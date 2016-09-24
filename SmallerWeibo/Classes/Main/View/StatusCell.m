//
//  StatusCell.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "StatusCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "StatusModel.h"
#import "UserModel.h"
#import "NSString+Extend.h"
#import "MLLinkLabel.h"
#import "CommentsStatusModel.h"
#import "ReviewImgController.h"
#import "UserShowViewController.h"
#import "UIView+extend.h"
#import "HttpRequest.h"
#import "WebViewController.h"
#define imgViewWidth(line) ([UIScreen mainScreen].bounds.size.width - 16 - 40 - 8 - 2*line)
#define constants(layout) layout.constant

@implementation StatusBtn

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.tintColor = ThemeColor;
    }else{
        self.tintColor = [UIColor grayColor];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGPoint center = self.titleLabel.center;
    center.y = 10;
    center.x += 3;
    self.titleLabel.center = center;
}

@end

@interface StatusCell ()<MLLinkLabelDelegate>
{
    __weak IBOutlet UIButton *_userImg;
    __weak IBOutlet UILabel *_nicknName;
    __weak IBOutlet UILabel *_creatTime;
    __weak IBOutlet UILabel *_from;
    __weak IBOutlet MLLinkLabel *_status;
    __weak IBOutlet UIView *_imgView;
    __weak IBOutlet NSLayoutConstraint *_statusImgViewHeight;
    __weak IBOutlet MLLinkLabel *_repeatStatus;
    __weak IBOutlet UIView *_repeatImgView;
    __weak IBOutlet NSLayoutConstraint *_repeatImgViewHeight;
    __weak IBOutlet StatusBtn *_likeBtn;
    __weak IBOutlet StatusBtn *_repateBtn;
    __weak IBOutlet StatusBtn *_commentsBtn;
    __weak IBOutlet StatusBtn *_supportBtn;
    
}
@end
@implementation StatusCell

+ (instancetype)statusCellWithTableView:(UITableView *)tableView{
    
    StatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"StatusCell" owner:nil options:nil]firstObject];
    }
    return cell;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (selected && self.model) {
        StatusModel *model;
        if ([self.model isKindOfClass:[StatusModel class]]) {
            model = self.model;
        }else{
            model = ((CommentsStatusModel *)self.model).status;
        }
        [self showDetailStatusVcWithModel:model];
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _nicknName.textColor = ThemeColor;
    _userImg.layer.cornerRadius = 20;
    _userImg.clipsToBounds = YES;
    _status.delegate = self;
    _status.lineSpacing = 5;
    [_likeBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
    [_repateBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
    [_supportBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
    [_commentsBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
    _status.font = [UIFont systemFontOfSize:15];
    _status.dataDetectorTypes = MLDataDetectorTypeHashtag | MLDataDetectorTypeURL | MLDataDetectorTypeUserHandle;
    _repeatStatus.lineSpacing = 2;
    _repeatStatus.textInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    _repeatStatus.font = [UIFont systemFontOfSize:13];
    _repeatStatus.dataDetectorTypes = MLDataDetectorTypeHashtag | MLDataDetectorTypeURL | MLDataDetectorTypeUserHandle;
    _repeatStatus.lineBreakMode = NSLineBreakByCharWrapping;
    _repeatStatus.delegate = self;
    _status.linkTextAttributes = @{NSForegroundColorAttributeName:ThemeColor};
    _repeatStatus.linkTextAttributes = @{NSForegroundColorAttributeName:ThemeColor};
}

- (void)setModel:(id)model{
    _model = model;
    _likeBtn.selected = NO;
    _repateBtn.selected = NO;
    _commentsBtn.selected = NO;
    _supportBtn.selected = NO;
    _statusImgViewHeight.constant = 0;
    _repeatImgViewHeight.constant = 0;
    for (UIView *view in _imgView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in _repeatImgView.subviews) {
        [view removeFromSuperview];
    }
    if ([model isKindOfClass:[StatusModel class]]) {
        StatusModel *modelTemp = (StatusModel *)model;
        [self updataWithStatusModle:modelTemp];
    }else{
        CommentsStatusModel *modelTemp = (CommentsStatusModel *)model;
        [self updataWithCommentsModle:modelTemp];
    }
}

- (void)changeBtnStatuWithType:(BtnType)type{
    switch (type) {
        case kBtnLikeType:
            _likeBtn.selected = YES;
            break;
        case kBtnRepeatType:
            _repateBtn.selected = YES;
            break;
        case kBtnCommentType:
            _commentsBtn.selected = YES;
            break;
        case kBtnSupportType:
            _supportBtn.selected = YES;
            break;
        default:
            break;
    }
}

- (void)updataWithStatusModle:(StatusModel *)model{
    if (model.favorited) {
        _likeBtn.selected = YES;
    }
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.user.strAvatarLarge] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"]];
    _creatTime.text = [NSString dateFromString:model.strCreatedAt];
    _nicknName.text = model.user.strName;
    _from.text = model.strSourceDes;
    _status.attributedText = model.attributedStr;
    [_commentsBtn setTitle:[NSString stringWithFormat:@"%ld",(long)model.commentsCount] forState:UIControlStateNormal];
    [_repateBtn setTitle:[NSString stringWithFormat:@"%ld",(long)model.repostsCount] forState:UIControlStateNormal];
    [_supportBtn setTitle:[NSString stringWithFormat:@"%ld",(long)model.attitudesCount] forState:UIControlStateNormal];
    if (model.arrPicUrls){
        [self setImageView:_imgView layoutHeight:_statusImgViewHeight viewOffset:0 ImgArr:model.arrPicUrls];
    }
    if (model.retweetedStatus) {
        NSMutableAttributedString *strTemp = [model.retweetedStatus.attributedStr mutableCopy];
        [strTemp insertAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"@%@:",model.retweetedStatus.user.strScreenName]] atIndex:0];
        _repeatStatus.attributedText = strTemp;
        if (model.retweetedStatus.arrPicUrls){
            [self setImageView:_repeatImgView layoutHeight:_repeatImgViewHeight viewOffset:0 ImgArr:model.retweetedStatus.arrPicUrls];
        }
    }else{
        _repeatStatus.attributedText = nil;
        
    }
}

- (void)updataWithCommentsModle:(CommentsStatusModel *)model{
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.user.strAvatarLarge] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"UserHeadPlaceHold"]];
    _creatTime.text = [NSString dateFromString:model.strCreatedAt];
    _nicknName.text = model.user.strScreenName;
    _from.text = model.strSource;
    _status.attributedText = model.attributedStr;
    [_commentsBtn setTitle:[NSString stringWithFormat:@"%ld",(long)model.status.commentsCount] forState:UIControlStateNormal];
    [_repateBtn setTitle:[NSString stringWithFormat:@"%ld",(long)model.status.repostsCount] forState:UIControlStateNormal];
    [_supportBtn setTitle:[NSString stringWithFormat:@"%ld",(long)model.status.attitudesCount] forState:UIControlStateNormal];
    NSMutableAttributedString *strTemp = [model.status.attributedStr mutableCopy];
    [strTemp insertAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"@%@:",model.status.user.strScreenName]] atIndex:0];
    _repeatStatus.attributedText = strTemp;
    if (model.status.arrPicUrls) {
        [self setImageView:_repeatImgView layoutHeight:_repeatImgViewHeight viewOffset:0 ImgArr:model.status.arrPicUrls];
    }
}

- (void)setImageView:(UIView *)view layoutHeight:(NSLayoutConstraint *)height viewOffset:(NSInteger)offset ImgArr:(NSArray *)arr{
    NSInteger count = arr.count;
    if (count%3 == 0 || count < 3) {
        height.constant = [self haveThreeImgWithArr:arr view:view];
    }else{
        height.constant = [self haveFourImgWithArr:arr view:view];
    }
}

- (NSInteger)haveThreeImgWithArr:(NSArray *)arr view:(UIView *)view{
    NSInteger width = imgViewWidth(3)/3;
    for (NSInteger index = 0; index < arr.count; index++) {
        UIButton *image = [self creatImgBtnWith:arr[index] index:index];
        image.frame = CGRectMake((width + 2) *(index%3), 3+(width + 2)*(index/3), width, width);
        [view addSubview:image];
    }
    NSInteger height = (arr.count%3 > 0) ? (width * ((arr.count/3)+1)) : width*(arr.count/3) + 6;
    return height;
}

- (NSInteger)haveFourImgWithArr:(NSArray *)arr view:(UIView *)view{
    NSInteger width = imgViewWidth(4)/4;
    for (NSInteger index = 0; index < arr.count; index++) {
        UIButton *image = [self creatImgBtnWith:arr[index] index:index];
        image.frame = CGRectMake((width + 2) *(index%4), 3+(width + 2)*(index/4), width, width);
        [view addSubview:image];
    }
    NSInteger height = (arr.count%4 > 0) ? (width * ((arr.count/4)+1)) : width*(arr.count/4) + 6;
    return height;
}

- (UIButton *)creatImgBtnWith:(NSString *)url index:(NSInteger)index{
    UIButton *imageBtn = [[UIButton alloc]init];
    [imageBtn addTarget:self action:@selector(imgDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeHold"]];
    imageBtn.tintColor = [UIColor grayColor];
    imageBtn.contentMode = UIViewContentModeScaleAspectFill;
    imageBtn.tag = index;
    imageBtn.clipsToBounds = YES;
    return imageBtn;
}

- (IBAction)userImgClickAction:(UIButton *)sender {
    UserModel *model;
    if ([self.model isKindOfClass:[StatusModel class]]) {
        model = ((StatusModel *)self.model).user;
    }else{
        model = ((CommentsStatusModel *)self.model).user;
    }
    [self showUserShowVcWithUserModel:model button:sender];
}

- (void)imgDidTouch:(UIButton *)btn{
    NSArray *arr;
    NSMutableArray *frameArr = [NSMutableArray array];
    NSMutableArray *placeHoldImages = [NSMutableArray array];
    for (UIButton *btnTemp in btn.superview.subviews) {
        [placeHoldImages addObject:btnTemp.currentBackgroundImage];
    }
    for (UIView *view in btn.superview.subviews) {
        [frameArr addObject:[NSValue valueWithCGRect:[self.window convertRect:view.frame fromView:view.superview]]];
    }
    if ([self.model isKindOfClass:[StatusModel class]]) {
        StatusModel *modelTemp = (StatusModel *)self.model;
        if (modelTemp.arrPicUrls) {
            arr = modelTemp.arrPicUrls;
        }else {
            arr = modelTemp.retweetedStatus.arrPicUrls;
        }
    }else{
        CommentsStatusModel *modelTemp = (CommentsStatusModel *)self.model;
        arr = modelTemp.status.arrPicUrls;
    }
    [self showReViewImgVCWithImageArr:arr frameArr:frameArr placeHoldImages:placeHoldImages button:btn];
}

- (IBAction)repateAndCommentBtnClick:(UIButton *)sender {
    if (sender.selected)return;
    [self changeBtnStatu:sender.tag+1];
    sender.selected = !sender.isSelected;
    [self showNewStatusVcWithType:sender.tag + 1 StatusId:[self.model isKindOfClass:[StatusModel class]] ? ((StatusModel *)self.model).strIdstr : ((CommentsStatusModel *)self.model).status.strIdstr];
}

- (IBAction)likeAndSupportBtnClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self changeBtnStatu:(sender.tag == 0 ? 0 : 3)];
    __weak typeof(self) weakSelf = self;
    NSString *statusId = [self.model isKindOfClass:[StatusModel class]] ? ((StatusModel *)self.model).strIdstr : ((CommentsStatusModel *)self.model).status.strIdstr;
    [HttpRequest likeStatusHttpRequestWithStatusId:statusId type:sender.tag success:^(id object) {
        [weakSelf toastWithString:sender.tag == 0 ? @"已收藏！" : @"已赞！" type:kLabPostionTypeBottom];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel{
    if ([linkText hasPrefix:@"#"] && [linkText hasSuffix:@"#"]) {
        NSString *topic = [linkText substringWithRange:NSMakeRange(1, linkText.length-2)];
        [self showTopicVcWithTopic:topic];
    }else if([linkText hasPrefix:@"@"]){
        [self showUserShowVcWithUserName:[linkText substringWithRange:NSMakeRange(1, linkText.length-1)]];
    }else{
        [self showWebVcWithUrl:linkText];
    }
}

- (void)changeBtnStatu:(NSInteger)index{
    if (self.btnDidClick) {
        self.btnDidClick(self,index);
    }
}

- (void)imageWithLocotion:(CGPoint)point result:(void (^)(CGRect frame,NSString *url))result{
    if (_repeatImgView.subviews.count == 0 && _imgView.subviews == 0) {
        result(CGRectZero,nil);
        return;
    }else{
        if (_imgView.subviews.count>0) {
            if (!CGRectContainsPoint(_imgView.frame, point)) {
                result(CGRectZero,nil);
                return;
            }
        }else{
            if (!CGRectContainsPoint(_repeatImgView.frame, point)) {
                result(CGRectZero,nil);
                return;
            }
        }
    }
    
    CGRect frame = CGRectZero;
    NSString *url = [[NSString alloc]init];
    if (_imgView.subviews.count > 0) {
        for (UIButton *btn in _imgView.subviews) {
            if (CGRectContainsPoint(btn.frame, [_imgView convertPoint:point fromView:self])) {
                frame = [self.window convertRect:btn.frame fromView:btn.superview];
                url = [self urlWithIndex:btn.tag];
                break;
            }
        }
    }else{
        for (UIButton *btn in _repeatImgView.subviews) {
            if (CGRectContainsPoint(btn.frame,  [_repeatImgView convertPoint:point fromView:self])) {
                frame = [self.window convertRect:btn.frame fromView:btn.superview];
                url = [self urlWithIndex:btn.tag];
                break;
            }
        }
    }
    if (url.length == 0) {
        result(CGRectZero,nil);
        return;
    }
    result(frame,url);
}

- (NSString *)urlWithIndex:(NSInteger)index{
    if ([self.model isKindOfClass:[StatusModel class]]) {
        StatusModel *model = (StatusModel *)self.model;
        if (model.arrPicUrls) {
            return model.arrPicUrls[index];
        }else{
            return model.retweetedStatus.arrPicUrls[index];
        }
    }else{
        CommentsStatusModel *model = (CommentsStatusModel *)self.model;
        return model.status.arrPicUrls[index];
    }
    return nil;
}


@end
