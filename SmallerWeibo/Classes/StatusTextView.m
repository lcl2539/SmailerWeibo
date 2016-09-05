//
//  StatusTextView.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "StatusTextView.h"
#import "FaceKeyBoard.h"
#import <YYTextView.h>
@interface StatusTextView ()<YYTextViewDelegate>
{
    __weak IBOutlet YYTextView *_text;
    __weak IBOutlet UILabel *_surplus;
    __weak IBOutlet UIView *_scroll;
    __weak IBOutlet UIButton *_imageBtn;
    __weak IBOutlet UIButton *_userBtn;
    __weak IBOutlet UIButton *_topicBtn;
    __weak IBOutlet NSLayoutConstraint *_scrollWidth;
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
    }
    return _faceKeyBoard;
}


- (void)loadSomeSetting{
    _text.delegate = self;
    _text.placeholderText = @"写点什么吧....";
}


- (void)textViewDidChange:(UITextView *)textView{
    _surplus.text = [NSString stringWithFormat:@"%ld/140",140-textView.attributedText.length];
}

- (IBAction)topicBtnAction:(id)sender {
}

- (IBAction)userBtnAction:(id)sender {
}

- (IBAction)imageBtnAction:(id)sender {
    _text.inputView = self.faceKeyBoard;
}

- (IBAction)sendStatus:(id)sender {
}

@end
