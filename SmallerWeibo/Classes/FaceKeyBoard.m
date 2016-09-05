//
//  FaceKeyBoard.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import "FaceKeyBoardCollectionView.h"
#import "FaceKeyBoard.h"
#import <Masonry.h>
@interface FaceKeyBoard ()<UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *_scrollView;
    __weak IBOutlet UIView *_scrollContainView;
    __weak IBOutlet NSLayoutConstraint *_scrollViewWidth;
    __weak IBOutlet UIButton *_defultFaceBtn;
    __weak IBOutlet UIButton *_lxhFaceBtn;
    __weak IBOutlet UIButton *_delectBtn;
}
@end
@implementation FaceKeyBoard
+ (instancetype)shareFaceKeyBoard{
    static FaceKeyBoard *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[NSBundle mainBundle] loadNibNamed:@"FaceKeyBoard" owner:nil options:nil].firstObject;
    });
    return view;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _scrollViewWidth.constant = [UIScreen mainScreen].bounds.size.width*2;
    _scrollView.delegate = self;
    FaceKeyBoardCollectionView *defultFace = [FaceKeyBoardCollectionView faceKeyBoardWithPlistPath:[[NSBundle mainBundle] pathForResource:@"FacesKeyboard.plist" ofType:nil]];
    FaceKeyBoardCollectionView *lxhFace = [FaceKeyBoardCollectionView faceKeyBoardWithPlistPath:[[NSBundle mainBundle] pathForResource:@"FacesKeyboard-LXH.plist" ofType:nil]];
    [_scrollContainView addSubview:defultFace];
    [_scrollContainView addSubview:lxhFace];
    [defultFace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(_scrollContainView);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
    }];
    [lxhFace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.equalTo(_scrollContainView);
        make.leading.equalTo(defultFace.mas_trailing);
    }];
    _defultFaceBtn.selected = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    [self changeBtnStateWithIndex:index];
}

- (IBAction)faceBtnAction:(UIButton *)sender {
    [_scrollView setContentOffset:CGPointMake((sender.tag - 1) * [UIScreen mainScreen].bounds.size.width, 0) animated:YES];
    [self changeBtnStateWithIndex:sender.tag - 1];
}

- (void)changeBtnStateWithIndex:(NSInteger)index{
    _lxhFaceBtn.selected = NO;
    _defultFaceBtn.selected = NO;
    if (index == 0) {
        _defultFaceBtn.selected = YES;
    }else{
        _lxhFaceBtn.selected = YES;
    }
}
@end
