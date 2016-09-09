//
//  ShowImgCollectionView.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/6.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import "ShowImgCollectionView.h"
#import <TZImagePickerController.h>
#import <TZImageManager.h>
#import "UIView+extend.h"

@interface ImgShowCollectionViewCell ()
{
    __weak IBOutlet UIImageView *_image;
    __weak IBOutlet UILabel *_add;
    __weak IBOutlet UIButton *_delected;
}
@property (nonatomic,strong)NSIndexPath *index;
@property (nonatomic,copy)void (^cancelImg)(UIImage *);
@property (nonatomic,strong)UIImage *img;
@end
@implementation ImgShowCollectionViewCell

- (void)awakeFromNib{
    [super awakeFromNib];
    _add.textColor = ThemeColor;
    _delected.tintColor = ThemeColor;
}

- (void)setImg:(UIImage *)img{
    _img = img;
    _image.image = img;
}

- (IBAction)cancelImg:(id)sender {
    if (self.cancelImg) {
        self.cancelImg(self.img);
    }
}

@end
@interface ShowImgCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate>
@property (nonatomic,strong)TZImagePickerController *chooseImgVC;
@end
@implementation ShowImgCollectionView

- (TZImagePickerController *)chooseImgVC{
    if (!_chooseImgVC) {
        _chooseImgVC = [[TZImagePickerController alloc]initWithMaxImagesCount:9 delegate:self];
        _chooseImgVC.allowPickingVideo = NO;
    }
    return _chooseImgVC;
}

- (NSArray *)data{
    if (!_data) {
        _data = @[[[UIImage alloc]init]];
    }
    return _data;
}

+ (instancetype)showImgView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumInteritemSpacing = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    ShowImgCollectionView *view = [[ShowImgCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    [view registerNib:[UINib nibWithNibName:@"ImgShowCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ImgCell"];
    [view registerNib:[UINib nibWithNibName:@"ShowImgCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"AddCell"];
    view.delegate = view;
    view.backgroundColor = [UIColor whiteColor];
    view.dataSource = view;
    return view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *img = self.data[indexPath.row];
    if (img.size.height == 0 && img.size.width == 0) {
        ImgShowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddCell" forIndexPath:indexPath];
        return cell;
    }else{
        ImgShowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImgCell" forIndexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        cell.cancelImg = ^(UIImage *image){
            [weakSelf removeImg:image];
        };
        cell.index = indexPath;
        cell.img = weakSelf.data[indexPath.row];
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.data.count - 1 && self.data.count != 10) {
        [self addImg];
    }
}

- (void)addImg{
    [self.superViewController presentViewController:self.chooseImgVC animated:YES completion:nil];
}

- (void)removeImg:(UIImage *)img{
    NSMutableArray *arrTemp = [self.data mutableCopy];
    NSInteger index = [arrTemp indexOfObject:img];
    [arrTemp removeObject:img];
    self.data = arrTemp;
    [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    if (self.data.count == 8 ) {
        UIImage *imageTemp = self.data.lastObject;
        if (imageTemp.size.height != 0 && imageTemp.size.width != 0) {
            [arrTemp addObject:[[UIImage alloc]init]];
            self.data = arrTemp;
            [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:8 inSection:0]]];
        }
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    __weak typeof(self) weakSelf = self;
    NSMutableArray *arrTemp = [NSMutableArray arrayWithCapacity:photos.count];
    if (assets.count > 0) {
        if (isSelectOriginalPhoto) {
            for (NSInteger index = 0; index<assets.count; index++) {
                [[TZImageManager manager]getOriginalPhotoWithAsset:assets[index] completion:^(UIImage *photo, NSDictionary *info) {
                    [arrTemp addObject:photo];
                    if (arrTemp.count == photos.count && photos.count != 9 ) {
                        [arrTemp addObject:[[UIImage alloc]init]];
                    }
                    weakSelf.data = arrTemp;
                    [weakSelf reloadData];
                }];
            }
        }else{
            [arrTemp addObjectsFromArray:photos];
            if (arrTemp.count != 9) {
                [arrTemp addObject:[[UIImage alloc]init]];
            }
            self.data = arrTemp;
        };
        [self reloadData];
    }
}

@end

