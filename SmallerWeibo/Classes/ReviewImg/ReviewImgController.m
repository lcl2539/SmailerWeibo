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
#import "UIView+Toast.h"
#import "ReViewImgAnimation.h"
#define  screenSize [UIScreen mainScreen].bounds.size
@interface ReviewImgController ()<UIScrollViewDelegate>
{
    __weak UIScrollView *_imageScroll;
}
@property (nonatomic,assign)BOOL isFinishLoad;
@end

@implementation ReviewImgController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self loadScrollView];
    _imageScroll.alpha = 0;
    [self.view addSubview:self.placeHoldimageView];
    [self.view bringSubviewToFront:_imageScroll];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changePlaceHoldViewFrame];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)loadSomeSetting{
    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)changePlaceHoldViewFrame{
    CGRect frame = self.placeHoldimageView.frame;
    frame.size = self.placeHoldimageView.image.size;
    if (frame.size.width < self.placeHoldimageView.frame.size.width) {
        CGFloat x = (self.placeHoldimageView.frame.size.width - frame.size.width) / 2 + self.placeHoldimageView.frame.origin.x;
        frame.origin.x = x;
    }
    if (frame.size.height < self.placeHoldimageView.frame.size.height) {
        CGFloat y = (self.placeHoldimageView.frame.size.height - frame.size.height) / 2 + self.placeHoldimageView.frame.origin.y;
        frame.origin.y = y;
    }
    self.lastFrame = frame;
    frame.origin.x = 0;
    frame.size.width = screenSize.width;
    frame.size.height = (CGFloat)screenSize.width / self.placeHoldimageView.image.size.width * frame.size.height;
    if (frame.size.height >= screenSize.height) {
        frame.origin.y = 0;
    }else{
        frame.origin.y = screenSize.height/2 - frame.size.height/2;
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        weakSelf.placeHoldimageView.frame = frame;
    } completion:^(BOOL finished) {
        _imageScroll.alpha = 1;
        if (self.isFinishLoad) {
            [weakSelf.placeHoldimageView removeFromSuperview];
        }else{
            self.isFinishLoad = YES;
        }
    }];
}

- (void)loadScrollView{
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scroll.contentSize = CGSizeMake(self.picArr.count * self.view.frame.size.width, 0);
    scroll.pagingEnabled = YES;
    scroll.backgroundColor = [UIColor clearColor];
    __weak typeof(self) weakSelf = self;
    for (NSInteger index = 0; index <self.picArr.count ; index++) {
        UIScrollView *ImgScroll = [self creatImgScroll:index];
        ImgScroll.tag = index;
        [ImgScroll setBackgroundColor:[UIColor clearColor]];
        NSMutableString *imgURL = [[NSMutableString alloc]initWithString:self.picArr[index][@"thumbnail_pic"]];
        [imgURL replaceOccurrencesOfString:@"thumbnail" withString:@"large" options:0 range:NSMakeRange(0, imgURL.length)];
        NSURL *bigImgURL = [NSURL URLWithString:imgURL];
        [scroll addSubview:ImgScroll];
        UIProgressView *progress = [self creatProgress];
        [ImgScroll addSubview:progress];
        [[SDWebImageManager sharedManager]downloadImageWithURL:bigImgURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            [progress setProgress:(CGFloat)receivedSize/expectedSize animated:YES];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (self.isFinishLoad && index == self.showWhichImg) {
                [weakSelf.placeHoldimageView removeFromSuperview];
            }
            if (index == self.showWhichImg) {
                self.isFinishLoad = YES;
            }
            [progress removeFromSuperview];
            [weakSelf creatImg:image scrollView:ImgScroll];
        }];
        [self creatGeature:ImgScroll];
    }
    _imageScroll = scroll;
    [scroll setContentOffset:CGPointMake(self.showWhichImg * self.view.frame.size.width, 0) animated:YES];
    [self.view addSubview:_imageScroll];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            return view;
        }
    }
    return nil;
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
    ImgScroll.backgroundColor = [UIColor clearColor];
    return ImgScroll;
}

- (void)creatImg:(UIImage *)image scrollView:(UIScrollView *)scrollView{
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
    scrollView.contentSize = frame.size;
    [scrollView addSubview:img];
}

- (void)creatGeature:(UIView *)view{
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage:)];
    lp.minimumPressDuration = 1;
    [view addGestureRecognizer:lp];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didDoubleTap:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 2;
    [view addGestureRecognizer:tap];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:tap];
}


- (void)saveImage:(UILongPressGestureRecognizer *)lp{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否保存图片到相册？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_queue_t queue = dispatch_queue_create("saveImg", NULL);
        dispatch_async(queue, ^{
            UIImage *img = ((UIImageView *)lp.view.subviews.firstObject).image;
            UIImageWriteToSavedPhotosAlbum(img, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(lp.view));
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

- (UIProgressView *)creatProgress{
    UIProgressView *progress = [[UIProgressView alloc]initWithFrame:CGRectMake(50, self.view.frame.size.height/2, self.view.frame.size.width-100, 0)];
    progress.trackTintColor = [UIColor darkGrayColor];
    return progress;
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIView *view = [_imageScroll viewWithTag:_imageScroll.contentOffset.x/screenSize.width].subviews.firstObject;
    [UIView animateWithDuration:0.3 animations:^{
        view.frame = self.lastFrame;
    }];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)image: (UIImage *)image didFinishSavingWithError: (NSError *) error contextInfo: (void *)contextInfo{
    [self.view toastWithString:@"保存完成"];
}
@end
