//
//  LPreviewImgVC.m
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/24.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "LPreviewImgVC.h"
#import "UIImageView+WebCache.h"
#import <Masonry.h>
@interface LPreviewImgVC ()
{
    __weak UIView *_progress;
}
@property (nonatomic,assign)CGSize frameSize;
@end

@implementation LPreviewImgVC

- (void)setUrl:(NSString *)url{
    _url = [url stringByReplacingOccurrencesOfString:@"thumb150" withString:@"large"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadImage];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.frameSize = self.view.frame.size;
}

- (void)loadSomeSetting{
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = ThemeColor;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self.view);
        make.height.equalTo(@5);
        make.width.equalTo(@0);
    }];
    _progress = view;
}

- (void)loadImage{
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.view addSubview:imageView];
    __weak typeof(self) weakSelf = self;
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.url] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        [_progress mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.equalTo(self.view);
            make.height.equalTo(@5);
            make.width.mas_equalTo(weakSelf.view.frame.size.width * (CGFloat)receivedSize/expectedSize);
        }];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [_progress mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.equalTo(self.view);
            make.height.equalTo(@5);
            make.width.mas_equalTo(weakSelf.view.frame.size.width);
        }];
        [imageView sizeToFit];
        imageView.frame = [weakSelf imageFrameWithImage:imageView.frame];
    }];
}

- (CGRect)imageFrameWithImage:(CGRect)imgFrame{
    [self.view setNeedsLayout];
    CGFloat width = self.frameSize.width>0 ? self.frameSize.width : [UIScreen mainScreen].bounds.size.width;
    CGFloat proportion = (CGFloat)width/imgFrame.size.width;
    imgFrame.size.width = imgFrame.size.width*proportion;
    imgFrame.size.height = imgFrame.size.height*proportion;
    if (imgFrame.size.height >= self.frameSize.height) {
        imgFrame.origin.y = 0;
    }else{
        imgFrame.origin.y = self.frameSize.height/2 - imgFrame.size.height/2;
    }
    return imgFrame;
}
@end
