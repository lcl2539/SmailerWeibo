//
//  FaceKeyBoard.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import "FaceKeyBoard.h"
#import <Masonry.h>
@interface FaceKeyBoardCollectionViewCell ()
{
    __weak IBOutlet UIImageView *_img;
}
@end
@implementation FaceKeyBoardCollectionViewCell


- (void)setImage:(NSString *)image{
    _image = image;
    static NSBundle *bundle;
    bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Image.bundle" ofType:nil]];
    [_img setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:image ofType:nil]]];
}
@end

@interface FaceKeyBoardCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,copy)NSArray *data;
@end
@implementation FaceKeyBoardCollectionView

+ (instancetype)faceKeyBoardWithPlistPath:(NSString *)path{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    layout.itemSize = CGSizeMake(30, 30);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    FaceKeyBoardCollectionView *view = [[FaceKeyBoardCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    view = [[FaceKeyBoardCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    view.delegate = view;
    view.dataSource = view;
    view.contentInset = UIEdgeInsetsMake(10, 20, 0, 20);
    view.data = [NSArray arrayWithContentsOfFile:path];
    [view registerNib:[UINib nibWithNibName:@"FaceKeyBoardCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FaceCell"];
    view.backgroundColor = [UIColor clearColor];
    view.showsHorizontalScrollIndicator = NO;
    return view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.data[indexPath.row];
    if (self.faceDidClick) {
        self.faceDidClick(dict.allKeys.lastObject);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FaceKeyBoardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceCell" forIndexPath:indexPath];
    NSDictionary *dicTemp = self.data[indexPath.row];
    cell.name = dicTemp.allKeys.lastObject;
    cell.image = dicTemp[dicTemp.allKeys.lastObject];
    return cell;
}
@end

@interface FaceKeyBoard ()<UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *_scrollView;
    __weak IBOutlet UIView *_scrollContainView;
    __weak IBOutlet NSLayoutConstraint *_scrollViewWidth;
    __weak IBOutlet UIButton *_defultFaceBtn;
    __weak IBOutlet UIButton *_lxhFaceBtn;
    __weak IBOutlet UIButton *_delectBtn;
    __weak FaceKeyBoardCollectionView *_defultFace;
    __weak FaceKeyBoardCollectionView *_lxhFace;
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

- (void)setFaceDidTouch:(void (^)(NSString *))faceDidTouch{
    _faceDidTouch = faceDidTouch;
    _defultFace.faceDidClick = self.faceDidTouch;
    _lxhFace.faceDidClick = self.faceDidTouch;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [_defultFaceBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
    [_lxhFaceBtn setTitleColor:ThemeColor forState:UIControlStateSelected];
    _delectBtn.tintColor = ThemeColor;
    _scrollViewWidth.constant = [UIScreen mainScreen].bounds.size.width*2;
    _scrollView.delegate = self;
    FaceKeyBoardCollectionView *defultFace = [FaceKeyBoardCollectionView faceKeyBoardWithPlistPath:[[NSBundle mainBundle] pathForResource:@"FacesKeyboard.plist" ofType:nil]];
    FaceKeyBoardCollectionView *lxhFace = [FaceKeyBoardCollectionView faceKeyBoardWithPlistPath:[[NSBundle mainBundle] pathForResource:@"FacesKeyboard-LXH.plist" ofType:nil]];
    _defultFace = defultFace;
    _lxhFace = lxhFace;
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
- (IBAction)delectBtnDidClick:(id)sender {
    if (self.delectBtnDidClick) {
        self.delectBtnDidClick();
    }
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
