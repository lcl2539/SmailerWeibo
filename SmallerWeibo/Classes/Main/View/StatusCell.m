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
#define lineCount 3
#define imgSize(offset) ([UIScreen mainScreen].bounds.size.width - 30 - offset)/lineCount;
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
    _repeatStatus.lineBreakMode = NSLineBreakByCharWrapping;
    _repeatStatus.delegate = self;
}

- (void)setModel:(StatusModel *)model{
    _model = model;
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.user.strProfileImageUrl] forState:UIControlStateNormal];
    _creatTime.text = [NSString dateFromString:model.strCreatedAt];
    _nicknName.text = model.user.strName;
    _from.text = model.strSourceDes;
    _status.attributedText = [StatusText changStrToStatusText:model.strText fontSize:17];
    _statusImgViewHeight.constant = 0;
    _repeatImgViewHeight.constant = 0;
    for (UIView *view in _imgView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in _repeatImgView.subviews) {
        [view removeFromSuperview];
    }
    if (model.arrPicUrls){
        [self setImageView:_imgView layoutHeight:_statusImgViewHeight viewOffset:0 ImgArr:model.arrPicUrls];
    }
    if (model.retweetedStatus) {
        _repeatStatus.attributedText = [StatusText changStrToStatusText:[NSString stringWithFormat:@"@%@:%@",model.retweetedStatus.user.strName,model.retweetedStatus.strText] fontSize:14];
        if (model.retweetedStatus.arrPicUrls){
            [self setImageView:_repeatImgView layoutHeight:_repeatImgViewHeight viewOffset:3 ImgArr:model.retweetedStatus.arrPicUrls];
        }
    }else{
        _repeatStatus.attributedText = nil;
        
    }
}

- (void)setImageView:(UIView *)view layoutHeight:(NSLayoutConstraint *)height viewOffset:(NSInteger)offset ImgArr:(NSArray *)arr{
    NSInteger count = arr.count;
    NSInteger width = imgSize(offset);
    for (NSInteger index = 0; index<count; index++) {
        UIButton *image = [[UIButton alloc]initWithFrame:CGRectMake(3+index % lineCount * (width+3), 3 + index / lineCount * (width+3), width, width)];
        NSMutableString *strImg = [[NSMutableString alloc]initWithString:arr[index][@"thumbnail_pic"]];
        [image sd_setImageWithURL:[NSURL URLWithString:strImg] forState:UIControlStateNormal];
        [image addTarget:self action:@selector(imgDidTouch:) forControlEvents:UIControlEventTouchUpInside];
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
    if ([self.delegate respondsToSelector:@selector(showImgWithArr:index:)]) {
        NSArray *arr;
        if (self.model.arrPicUrls) {
            arr = self.model.arrPicUrls;
        }else {
            arr = self.model.retweetedStatus.arrPicUrls;
        }
        [self.delegate showImgWithArr:arr index:btn.tag];
    }
}

@end
