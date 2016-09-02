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
#import "UIView+extend.h"
#import "ReViewImgAnimation.h"
#import "NSString+Extend.h"
#define  screenSize [UIScreen mainScreen].bounds.size
#define lineCount 3
@interface ReviewImgController ()<UIScrollViewDelegate>
{
    __weak UIScrollView *_imageScroll;
    __weak UILabel *_numLab;
    __weak UIButton *_saveBtn;
}
@property (nonatomic,assign)BOOL isFinishLoad;
@end

@implementation ReviewImgController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self loadScrollView];
    [self loadNumLab];
    _numLab.alpha = 0;
    _imageScroll.alpha = 0;
    [self.view addSubview:self.placeHoldimageView];
    [self.view sendSubviewToBack:self.placeHoldimageView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changePlaceHoldViewFrame];
}

- (void)loadSomeSetting{
    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)loadNumLab{
    UILabel *lab = [[UILabel alloc]init];
    lab.text = [NSString stringWithFormat:@"%ld/%ld",self.showWhichImg + 1,self.picArr.count];
    [self.view addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-10);
        make.centerX.equalTo(self.view);
    }];
    _numLab = lab;
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
    frame.origin.x = 0;
    frame.size.width = screenSize.width;
    frame.size.height = (CGFloat)screenSize.width / self.placeHoldimageView.image.size.width * frame.size.height;
    if (frame.size.height >= screenSize.height) {
        frame.origin.y = 0;
    }else{
        frame.origin.y = screenSize.height/2 - frame.size.height/2;
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionTransitionNone animations:^{
        weakSelf.placeHoldimageView.frame = frame;
        _numLab.alpha = 1;
    } completion:^(BOOL finished) {
        _imageScroll.alpha = 1;
        if (self.isFinishLoad) {
            [weakSelf.placeHoldimageView removeFromSuperview];
            weakSelf.placeHoldimageView = nil;
        }else{
            self.isFinishLoad = YES;
        }
        NSString *toast = [[NSUserDefaults standardUserDefaults]objectForKey:@"toastImg"];
        if ([toast integerValue] < 6 || !toast) {
            [self.view toastWithString:@"长按可以保存图片哦~"];
            NSInteger num = (toast) ? [toast integerValue] : 0;
            num += 1;
            [NSString writeUserInfoWithKey:@"toastImg" value:[NSNumber numberWithInteger:num]];
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
        ImgScroll.tag = 100 + index;
        [ImgScroll setBackgroundColor:[UIColor clearColor]];
        NSMutableString *imgURL = [[NSMutableString alloc]initWithString:self.picArr[index]];
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
                weakSelf.placeHoldimageView = nil;
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
    _imageScroll.delegate = self;
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
    if (!image)return;
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
    if (!((UIImageView *)lp.view.subviews.firstObject).image)return;
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView != _imageScroll)return;
    NSInteger showIndex = _imageScroll.contentOffset.x / screenSize.width;
    _numLab.text = [NSString stringWithFormat:@"%ld/%ld",showIndex + 1,self.picArr.count];
    self.lastFrame = [self.frameArr[showIndex] CGRectValue];
}

- (UIProgressView *)creatProgress{
    UIProgressView *progress = [[UIProgressView alloc]initWithFrame:CGRectMake(50, self.view.frame.size.height/2, self.view.frame.size.width-100, 0)];
    progress.trackTintColor = [UIColor darkGrayColor];
    return progress;
}

- (void)show{
    [self.fromVc.navigationController pushViewController:self animated:YES];
}

- (void)back{
    UIScrollView *view = [_imageScroll viewWithTag:(_imageScroll.contentOffset.x/screenSize.width) + 100];
    UIView *img = view.subviews.firstObject;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:UIViewAnimationOptionTransitionNone animations:^{
        if (self.placeHoldimageView) {
            self.placeHoldimageView.frame = self.lastFrame;
            view.alpha = 0;
        }else{
            view.contentOffset  =CGPointZero;
            img.frame = self.lastFrame;
        }
    } completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError: (NSError *) error contextInfo: (void *)contextInfo{
    [self.view toastWithString:@"保存完成"];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    ReViewImgAnimation *animation = [[ReViewImgAnimation alloc]init];
    animation.type = (fromVC == self) ? kPopAnimationType : kPushAnimationType;
    return animation;
}

@end
