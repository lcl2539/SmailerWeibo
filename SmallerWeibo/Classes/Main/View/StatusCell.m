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
#import "SingExp.h"
#import "MLLinkLabel.h"
#import "CommentsStatusModel.h"
#import "MLExpressionManager.h"
#define lineCount 3
#define imgSize(offset) ([UIScreen mainScreen].bounds.size.width - 32 - offset)/lineCount;
#define imgViewWidth ([UIScreen mainScreen].bounds.size.width - 16)
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
@property (nonatomic,strong)MLExpression *exp;
@end
@implementation StatusCell

+ (instancetype)statusCellWithTableView:(UITableView *)tableView{
    
    StatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"StatusCell" owner:nil options:nil]firstObject];
        cell.exp = [SingExp shareExp];
    }
    return cell;
}

- (MLExpression *)exp{
    if (_exp) {
        _exp = [SingExp shareExp];
    }
    return _exp;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _userImg.layer.cornerRadius = 25;
    _userImg.clipsToBounds = YES;
    _userImg.layer.borderWidth = 1;
    _userImg.layer.borderColor = [UIColor grayColor].CGColor;
    _status.delegate = self;
    _status.lineSpacing = 5;
    _status.font = [UIFont systemFontOfSize:17];
    _status.dataDetectorTypes = MLDataDetectorTypeHashtag | MLDataDetectorTypeURL | MLDataDetectorTypeUserHandle;
    _repeatStatus.lineSpacing = 3;
    _repeatStatus.textInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    _repeatStatus.font = [UIFont systemFontOfSize:15];
    _repeatStatus.dataDetectorTypes = MLDataDetectorTypeHashtag | MLDataDetectorTypeURL | MLDataDetectorTypeUserHandle;
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
        _status.attributedText = [MLExpressionManager expressionAttributedStringWithString:modelTemp.strText expression:self.exp];
        [_commentsBtn setTitle:[NSString stringWithFormat:@"评论(%ld)",modelTemp.commentsCount] forState:UIControlStateNormal];
        [_repateBtn setTitle:[NSString stringWithFormat:@"转发(%ld)",modelTemp.repostsCount] forState:UIControlStateNormal];
        if (modelTemp.arrPicUrls){
            [self setImageView:_imgView layoutHeight:_statusImgViewHeight viewOffset:0 ImgArr:modelTemp.arrPicUrls];
        }
        if (modelTemp.retweetedStatus) {
            _repeatStatus.attributedText = [MLExpressionManager expressionAttributedStringWithString:[NSString stringWithFormat:@"@%@：%@",modelTemp.retweetedStatus.user.strName,modelTemp.retweetedStatus.strText] expression:self.exp];
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
        _status.attributedText = [MLExpressionManager expressionAttributedStringWithString:modelTemp.commentText expression:self.exp];
        [_commentsBtn setTitle:[NSString stringWithFormat:@"评论(%ld)",modelTemp.status.commentsCount] forState:UIControlStateNormal];
        [_repateBtn setTitle:[NSString stringWithFormat:@"转发(%ld)",modelTemp.status.repostsCount] forState:UIControlStateNormal];
        _repeatStatus.attributedText = [MLExpressionManager expressionAttributedStringWithString:[NSString stringWithFormat:@"@%@：%@",modelTemp.status.user.strName,modelTemp.status.strText] expression:self.exp];
        if (modelTemp.status.arrPicUrls) {
            [self setImageView:_repeatImgView layoutHeight:_repeatImgViewHeight viewOffset:0 ImgArr:modelTemp.status.arrPicUrls];
        }
    }
    _imgView.layer.cornerRadius = 5;
    _repeatImgView.layer.cornerRadius = 5;
    _imgView.clipsToBounds = YES;
    _repeatImgView.clipsToBounds = YES;
}

- (void)setImageView:(UIView *)view layoutHeight:(NSLayoutConstraint *)height viewOffset:(NSInteger)offset ImgArr:(NSArray *)arr{
    switch (arr.count) {
        case 1:
            height.constant = [self haveOneImgWithArr:arr view:view];
            break;
        case 2:
            height.constant = [self haveTwoImgWithArr:arr view:view];
            break;
        case 3:
            height.constant = [self haveThreeImgWithArr:arr view:view];
            break;
        case 4:
            height.constant = [self haveFourImgWithArr:arr view:view];
            break;
        case 6:
            height.constant = [self haveSixImgWithArr:arr view:view];
            break;
        default:
            height.constant = [self haveOtherImgWithArr:arr view:view];
            break;
    }
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel{
    NSLog(@"%@\n%@\n%@",link,linkText,linkLabel);
}

- (void)imgDidTouch:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(showImgWithImgArr:frameArr:button:)]) {
        NSArray *arr;
        NSMutableArray *frameArr = [NSMutableArray array];
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
            [self.delegate showImgWithImgArr:arr frameArr:frameArr button:btn];
        }else{
            CommentsStatusModel *modelTemp = (CommentsStatusModel *)self.model;
            [self.delegate showImgWithImgArr:modelTemp.status.arrPicUrls frameArr:frameArr button:btn];
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

- (NSInteger)haveOneImgWithArr:(NSArray *)arr view:(UIView *)view{
    UIButton *image = [self creatImgBtnWith:arr[0][@"thumbnail_pic"] index:0];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(imgViewWidth, imgViewWidth/2);
    image.frame = frame;
    [view addSubview:image];
    return imgViewWidth/2;
}

- (NSInteger)haveTwoImgWithArr:(NSArray *)arr view:(UIView *)view{
    NSInteger width = imgViewWidth/2;
    for (NSInteger index = 0; index < arr.count; index++) {
        UIButton *image = [self creatImgBtnWith:arr[index][@"thumbnail_pic"] index:index];
        image.frame = CGRectMake(width*(index%2), 0, width, width);
        [view addSubview:image];
    }
    return width;
}

- (NSInteger)haveThreeImgWithArr:(NSArray *)arr view:(UIView *)view{
    NSInteger width = imgViewWidth/2;
    for (NSInteger index = 0; index < arr.count; index++) {
        UIButton *image = [self creatImgBtnWith:arr[index][@"thumbnail_pic"] index:index];
        if (index == 0) {
            image.frame = CGRectMake(0, 0, width, imgViewWidth);
        }else{
            image.frame = CGRectMake(width, width*((index-1)/2), width, width);
        }
        [view addSubview:image];
    }
    return imgViewWidth;
}

- (NSInteger)haveFourImgWithArr:(NSArray *)arr view:(UIView *)view{
    NSInteger width = imgViewWidth/2;
    for (NSInteger index = 0; index < arr.count; index++) {
        UIButton *image = [self creatImgBtnWith:arr[index][@"thumbnail_pic"] index:index];
        image.frame = CGRectMake(width*(index%2), width*(index/2), width, width);
        [view addSubview:image];
    }
    return imgViewWidth;
}

- (NSInteger)haveSixImgWithArr:(NSArray *)arr view:(UIView *)view{
    NSInteger width = imgViewWidth/3;
    for (NSInteger index = 0; index < arr.count; index++) {
        UIButton *image = [self creatImgBtnWith:arr[index][@"thumbnail_pic"] index:index];
        if (index == 0) {
            image.frame = CGRectMake(0, 0, width*2, width*2);
        }else if(index == 1 || index == 2){
            image.frame = CGRectMake(width*2, width*(index/2), width, width);
        }else{
            image.frame = CGRectMake(width*((index-3)%3), width*2, width, width);
        }
        [view addSubview:image];
    }
    return imgViewWidth;
}

- (NSInteger)haveOtherImgWithArr:(NSArray *)arr view:(UIView *)view{
    NSInteger width = imgViewWidth/3;
    for (NSInteger index = 0; index < arr.count; index++) {
        UIButton *image = [self creatImgBtnWith:arr[index][@"thumbnail_pic"] index:index];
        image.frame = CGRectMake(width*(index%3), width*(index/3), width, width);
        [view addSubview:image];
    }
    return imgViewWidth;
}


- (UIButton *)creatImgBtnWith:(NSString *)url index:(NSInteger)index{
    UIButton *image = [[UIButton alloc]init];
    [image addTarget:self action:@selector(imgDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [image sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
    image.contentMode = UIViewContentModeScaleToFill;
    image.tag = index;
    image.clipsToBounds = YES;
    return image;
}


@end
