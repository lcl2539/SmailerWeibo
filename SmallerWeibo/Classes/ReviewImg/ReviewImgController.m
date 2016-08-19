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
#define  screenSize [UIScreen mainScreen].bounds.size
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
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)loadScrollView{
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scroll.contentSize = CGSizeMake(self.picArr.count * self.view.frame.size.width, 0);
    scroll.pagingEnabled = YES;
    __weak typeof(self) weakSelf = self;
    for (NSInteger index = 0; index <self.picArr.count ; index++) {
        UIScrollView *ImgScroll = [self creatImgScroll:index];
        NSMutableString *imgURL = [[NSMutableString alloc]initWithString:self.picArr[index][@"thumbnail_pic"]];
        [imgURL replaceOccurrencesOfString:@"thumbnail" withString:@"large" options:0 range:NSMakeRange(0, imgURL.length)];
        NSURL *bigImgURL = [NSURL URLWithString:imgURL];
        [scroll addSubview:ImgScroll];
        [[SDWebImageManager sharedManager]downloadImageWithURL:bigImgURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [ImgScroll addSubview:[weakSelf creatImg:image scrollView:ImgScroll]];
        }];
        UITapGestureRecognizer *tap = [self creatGeature];
        UILongPressGestureRecognizer *lp = [self creatLongPressGeature];
        [ImgScroll addGestureRecognizer:lp];
        [ImgScroll addGestureRecognizer:tap];
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
    ImgScroll.minimumZoomScale = 1;
    ImgScroll.maximumZoomScale = 2;
    ImgScroll.delegate = self;
    ImgScroll.zoomScale = 2;
    ImgScroll.showsVerticalScrollIndicator = NO;
    ImgScroll.showsHorizontalScrollIndicator = NO;
    return ImgScroll;
}

- (UIImageView *)creatImg:(UIImage *)image scrollView:(UIScrollView *)scrollView{
    UIImageView * img = [[UIImageView alloc]initWithImage:image];
    CGRect frame = img.frame;
    CGFloat proportion = (CGFloat)screenSize.width/frame.size.width;
    frame.size.width = frame.size.width*proportion;
    frame.size.height = frame.size.height*proportion;
    if (frame.size.height >= screenSize.height) {
        frame.origin.y = 0;
    }else{
        frame.origin.y = screenSize.height/2 - frame.size.height/2;
    }
    img.frame = frame;
    scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height);
    return img;
}

- (UITapGestureRecognizer *)creatGeature{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didDoubleTap:)];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 1;
    return tap;
}

- (UILongPressGestureRecognizer *)creatLongPressGeature{
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage:)];
    lp.minimumPressDuration = 1;
    return lp;
}

- (void)saveImage:(UILongPressGestureRecognizer *)lp{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否保存图片到相册？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_queue_t queue = dispatch_queue_create("saveImg", NULL);
        dispatch_async(queue, ^{
            UIImage *img = ((UIImageView *)lp.view.subviews.firstObject).image;
            UIImageWriteToSavedPhotosAlbum(img, self, nil, nil);
        });
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap{
    UIScrollView *scroll = (UIScrollView *)tap.view;
    if(scroll.zoomScale>1){
        [scroll setZoomScale:1 animated:YES];
    }else{
        [scroll setZoomScale:2 animated:YES];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX=0.0;
    CGFloat offsetY=0.0;
    UIView *view = scrollView.subviews.firstObject;
    if (scrollView.bounds.size.width> scrollView.contentSize.width){
        offsetX = (scrollView.bounds.size.width- scrollView.contentSize.width)/2;
    }
    if (scrollView.bounds.size.height> scrollView.contentSize.height){
        offsetY = (scrollView.bounds.size.height- scrollView.contentSize.height)/2;
    }
    view.center=CGPointMake(scrollView.contentSize.width/2+offsetX,scrollView.contentSize.height/2+offsetY);
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
