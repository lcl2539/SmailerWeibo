//
//  ReviewImgController.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/16.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "ReviewImgController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import <Masonry.h>
@interface ReviewImgController ()<UIScrollViewDelegate>
{
    __weak UIScrollView *_imageScroll;
}
@end

@implementation ReviewImgController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self loadScrollView];
    [self loadBackBtn];
}

- (void)loadSomeSetting{
    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
}

- (void)loadScrollView{
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scroll.contentSize = CGSizeMake(self.picArr.count * self.view.frame.size.width, 0);
    scroll.pagingEnabled = YES;
    for (NSInteger index = 0; index <self.picArr.count ; index++) {
        UIScrollView *ImgScroll = [self creatImgScroll:index];
        NSMutableString *imgURL = [[NSMutableString alloc]initWithString:self.picArr[index][@"thumbnail_pic"]];
        UIImageView *img = [[UIImageView alloc]initWithFrame:ImgScroll.bounds];
        [imgURL replaceOccurrencesOfString:@"thumbnail" withString:@"large" options:0 range:NSMakeRange(0, imgURL.length)];
        NSURL *bigImgURL = [NSURL URLWithString:imgURL];
        [scroll addSubview:ImgScroll];
        [ImgScroll addSubview:img];
        [[SDWebImageManager sharedManager]downloadImageWithURL:bigImgURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [img setImage:image];
        }];
        UITapGestureRecognizer *tap = [self creatGeature];
        [ImgScroll addGestureRecognizer:tap];
        img.contentMode = UIViewContentModeScaleAspectFit;
    }
    _imageScroll = scroll;
    [scroll setContentOffset:CGPointMake(self.showWhichImg * self.view.frame.size.width, 0) animated:YES];
    [self.view addSubview:_imageScroll];
}

- (void)loadBackBtn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.tintColor = [UIColor darkGrayColor];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(10);
        make.bottom.equalTo(self.view).offset(-10);
        make.width.height.mas_equalTo(40);
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [scrollView.subviews firstObject];
}

- (UIScrollView *)creatImgScroll:(NSInteger)index{
    UIScrollView *ImgScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(index * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    ImgScroll.bouncesZoom = YES;
    ImgScroll.maximumZoomScale = 2;
    ImgScroll.minimumZoomScale = 1;
    ImgScroll.delegate = self;
    ImgScroll.zoomScale = 2;
    return ImgScroll;
}

- (UITapGestureRecognizer *)creatGeature{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didDoubleTap:)];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 1;
    return tap;
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap{
    UIScrollView *scroll = (UIScrollView *)tap.view;
    if(scroll.zoomScale>1){
        [scroll setZoomScale:1 animated:YES];
    }else{
        
    }
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end