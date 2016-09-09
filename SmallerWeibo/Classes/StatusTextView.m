//
//  StatusTextView.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#define spaceX 10
#import "StatusTextView.h"
#import "FaceKeyBoard.h"
#import "ShowImgCollectionView.h"
#import <YYTextView.h>
#import "UIView+extend.h"
#import <Masonry.h>
@interface StatusTextView ()<YYTextViewDelegate>
{
    __weak IBOutlet YYTextView *_text;
    __weak IBOutlet UILabel *_surplus;
    __weak IBOutlet UIButton *_imageBtn;
    __weak IBOutlet UIView *_imgView;
    __weak ShowImgCollectionView *_imgShowView;
}
@property (nonatomic,strong)FaceKeyBoard *faceKeyBoard;

@end
@implementation StatusTextView

+ (instancetype)statusTextView{
    StatusTextView *view = [[NSBundle mainBundle] loadNibNamed:@"StatusTextView" owner:nil options:nil].firstObject;
    [view loadSomeSetting];
    return view;
}

- (FaceKeyBoard *)faceKeyBoard{
    if (!_faceKeyBoard) {
        _faceKeyBoard = [FaceKeyBoard shareFaceKeyBoard];
        _faceKeyBoard.frame = CGRectMake(0, 0, 0, 200);
        __weak typeof(self) weakSelf = self;
        _faceKeyBoard.faceDidTouch = ^(NSString *face){
            [weakSelf addFaceWithFace:face];
        };
        _faceKeyBoard.delectBtnDidClick = ^(){
            [weakSelf delectBtnDidClick];
        };
    }
    return _faceKeyBoard;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self loadText];
    [self loadImgShow];
}

- (void)beginEdit{
    [_text becomeFirstResponder];
}

- (void)loadSomeSetting{
    _text.delegate = self;
    _text.placeholderText = @"写点什么吧....";
}

- (void)loadText{
    YYTextSimpleEmoticonParser *parser = [[YYTextSimpleEmoticonParser alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face.plist" ofType:nil]];
    NSMutableDictionary *dictTemp = [NSMutableDictionary dictionaryWithCapacity:dict.count];
    for (NSString *key in dict) {
        static NSBundle *img;
        img = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Image" ofType:@"bundle"]];
        [dictTemp setObject:[UIImage imageWithContentsOfFile: [img pathForResource:dict[key] ofType:@"png"]] forKey:key];
    }
    parser.emoticonMapper = dictTemp;
    _text.textParser = parser;
    _imageBtn.tintColor = [UIColor darkGrayColor];
}

- (void)loadImgShow{
    ShowImgCollectionView *view = [ShowImgCollectionView showImgView];
    [_imgView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(_imgView);
    }];
    _imgShowView = view;
}

- (void)textViewDidChange:(UITextView *)textView{
    _surplus.text = [NSString stringWithFormat:@"%lu/140",140-textView.text.length];
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (_text.text.length + text.length >140) {
        [self toastWithString:@"太长啦，受不了啦" type:kLabPostionTypeCenter];
        return NO;
    }
    return YES;
}

- (void)addFaceWithFace:(NSString *)face{
    NSRange range =_text.selectedRange;
    NSMutableAttributedString *strTemp = [_text.attributedText mutableCopy];
    [strTemp insertAttributedString:[[NSAttributedString alloc] initWithString:face] atIndex:range.location];
    [strTemp addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, strTemp.length)];
    _text.attributedText = strTemp;
    _text.selectedRange = NSMakeRange(range.location + 1, 0);
}

- (void)delectBtnDidClick{
    if (_text.attributedText.length == 0)return;
    NSRange range = _text.selectedRange;
    if ((NSInteger)(range.location - 1) < 0)return;
    NSMutableAttributedString *strTemp = [_text.attributedText mutableCopy];
    NSMutableAttributedString *strHead = [[strTemp attributedSubstringFromRange:NSMakeRange(0, range.location - 1)] mutableCopy];
    NSMutableAttributedString *strFinal = [[strTemp attributedSubstringFromRange:NSMakeRange(range.location, strTemp.length - range.location )] mutableCopy];
    [strHead appendAttributedString:strFinal];
    _text.attributedText = strHead;
    _text.selectedRange = NSMakeRange(range.location - 1, 0);
}

- (IBAction)imageBtnAction:(id)sender {
    _text.inputView = (_text.inputView == self.faceKeyBoard) ? nil : self.faceKeyBoard;
    [_text resignFirstResponder];
    [_text becomeFirstResponder];
    _imageBtn.tintColor = (_imageBtn.tintColor == [UIColor darkGrayColor]) ? [UIColor orangeColor] : [UIColor darkGrayColor];
}

- (IBAction)sendStatus:(id)sender {
    if (_text.text.length > 0) {
        if (self.sendStatus) {
            if (_imgShowView.data.count > 1) {
                NSMutableArray *arrTemp = [_imgShowView.data mutableCopy];
                UIImage *imgTemp = _imgShowView.data.lastObject;
                if (imgTemp.size.height == 0 && imgTemp.size.width == 0) {
                    [arrTemp removeObject:arrTemp.lastObject];
                }
                self.imgArr = arrTemp;
            }
            self.status = _text.text;
            self.sendStatus();
        } 
    }else{
        [self toastWithString:@"再写点东西吧~~" type:kLabPostionTypeCenter];
    }
}

@end
