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
#import "StatusText.h"
#import "MLLinkLabel.h"
#import "CommentsStatusModel.h"
#define lineCount 3
#define imgSize(offset) ([UIScreen mainScreen].bounds.size.width - 32 - offset)/lineCount;
#define constants(layout) layout.constant
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
    __weak IBOutlet UIButton *_likeBtn;
    __weak IBOutlet UIButton *_repateBtn;
    __weak IBOutlet UIButton *_commentsBtn;
    
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

- (void)awakeFromNib{
    [super awakeFromNib];
    _userImg.layer.cornerRadius = 25;
    _userImg.clipsToBounds = YES;
    _userImg.layer.borderWidth = 1;
    _userImg.layer.borderColor = [UIColor grayColor].CGColor;
    _status.delegate = self;
    _status.lineSpacing = 5;
    _repeatStatus.lineSpacing = 3;
    _repeatStatus.textInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    _repeatStatus.lineBreakMode = NSLineBreakByCharWrapping;
    _repeatStatus.delegate = self;
}

- (void)setModel:(id)model{
    _model = model;
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
        [_userImg sd_setImageWithURL:[NSURL URLWithString:modelTemp.user.strProfileImageUrl] forState:UIControlStateNormal];
        _creatTime.text = [NSString dateFromString:modelTemp.strCreatedAt];
        _nicknName.text = modelTemp.user.strName;
        _from.text = modelTemp.strSourceDes;
        _status.attributedText = [StatusText changStrToStatusText:modelTemp.strText fontSize:17];
        [_commentsBtn setTitle:[NSString stringWithFormat:@"评论(%ld)",modelTemp.commentsCount] forState:UIControlStateNormal];
        [_repateBtn setTitle:[NSString stringWithFormat:@"转发(%ld)",modelTemp.repostsCount] forState:UIControlStateNormal];
        if (modelTemp.arrPicUrls){
            [self setImageView:_imgView layoutHeight:_statusImgViewHeight viewOffset:0 ImgArr:modelTemp.arrPicUrls];
        }
        if (modelTemp.retweetedStatus) {
            _repeatStatus.attributedText = [StatusText changStrToStatusText:[NSString stringWithFormat:@"@%@:%@",modelTemp.retweetedStatus.user.strName,modelTemp.retweetedStatus.strText] fontSize:15];
            if (modelTemp.retweetedStatus.arrPicUrls){
                [self setImageView:_repeatImgView layoutHeight:_repeatImgViewHeight viewOffset:0 ImgArr:modelTemp.retweetedStatus.arrPicUrls];
            }
        }else{
            _repeatStatus.attributedText = nil;
            
        }
    }else{
        CommentsStatusModel *modelTemp = (CommentsStatusModel *)model;
        [_userImg sd_setImageWithURL:[NSURL URLWithString:modelTemp.user.strProfileImageUrl] forState:UIControlStateNormal];
        _creatTime.text = [NSString dateFromString:modelTemp.strCreatedAt];
        _nicknName.text = modelTemp.user.strScreenName;
        _from.text = modelTemp.strSource;
        _status.attributedText = [StatusText changStrToStatusText:modelTemp.commentText fontSize:17];
        [_commentsBtn setTitle:[NSString stringWithFormat:@"评论(%ld)",modelTemp.status.commentsCount] forState:UIControlStateNormal];
        [_repateBtn setTitle:[NSString stringWithFormat:@"转发(%ld)",modelTemp.status.repostsCount] forState:UIControlStateNormal];
        _repeatStatus.attributedText = [StatusText changStrToStatusText:[NSString stringWithFormat:@"@%@:%@",modelTemp.status.user.strScreenName,modelTemp.status.strText] fontSize:15];
        if (modelTemp.status.arrPicUrls) {
            [self setImageView:_repeatImgView layoutHeight:_repeatImgViewHeight viewOffset:0 ImgArr:modelTemp.status.arrPicUrls];
        }
    }
}

- (void)setImageView:(UIView *)view layoutHeight:(NSLayoutConstraint *)height viewOffset:(NSInteger)offset ImgArr:(NSArray *)arr{
    NSInteger count = arr.count;
    NSInteger width = imgSize(offset);
    for (NSInteger index = 0; index<count; index++) {
        UIButton *image = [[UIButton alloc]initWithFrame:CGRectMake(index % lineCount * (width+3), index / lineCount * (width+3), width, width)];
        NSMutableString *strImg = [[NSMutableString alloc]initWithString:arr[index][@"thumbnail_pic"]];
        [image sd_setBackgroundImageWithURL:[NSURL URLWithString:strImg] forState:UIControlStateNormal];
        [image addTarget:self action:@selector(imgDidTouch:) forControlEvents:UIControlEventTouchUpInside];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.tag = index;
        image.clipsToBounds = YES;
        [view addSubview:image];
    }
    height.constant = (count % lineCount == 0) ? (count / lineCount ) * (width+3) + 3 : ((count / lineCount ) + 1)* (width + 3) + 3;
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel{
    NSLog(@"%@\n%@\n%@",link,linkText,linkLabel);
}

- (void)imgDidTouch:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(showImgWithArr:button:)]) {
        NSArray *arr;
        if ([self.model isKindOfClass:[StatusModel class]]) {
            StatusModel *modelTemp = (StatusModel *)self.model;
            if (modelTemp.arrPicUrls) {
                arr = modelTemp.arrPicUrls;
            }else {
                arr = modelTemp.retweetedStatus.arrPicUrls;
            }
            [self.delegate showImgWithArr:arr button:btn];
        }else{
            CommentsStatusModel *modelTemp = (CommentsStatusModel *)self.model;
            [self.delegate showImgWithArr:modelTemp.status.arrPicUrls button:btn];
        }
    }
}

- (IBAction)btnAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cellBtnActionWithIndex:withStatusId:)]) {
        NSString *statusId;
        if ([self.model isKindOfClass:[StatusModel class]]) {
            statusId = ((StatusModel *)self.model).strIdstr;
        }else{
            statusId = ((CommentsStatusModel *)self.model).status.strIdstr;
        }
        [self.delegate cellBtnActionWithIndex:sender.tag withStatusId:[statusId integerValue]];
    }
}


@end
