//
//  SendStatus.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "SendStatus.h"
#import "HttpRequest.h"
#import "UIView+extend.h"
@implementation NewStatusModel

+ (instancetype)newStatusMoldeWithStatus:(NSString *)status imgArr:(NSArray *)arr{
    NewStatusModel *model = [[NewStatusModel alloc]init];
    model.status = status;
    model.imgArr = arr;
    return model;
}

@end
@interface SendStatus ()
@property (nonatomic,strong)NSMutableDictionary *task;
@end
@implementation SendStatus

+ (instancetype)shareSendStatus{
    static SendStatus *send;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        send = [[SendStatus alloc]init];
        [send loadKVO];
    });
    return send;
}

- (NSMutableArray *)status{
    if (!_status) {
        _status = [[NSMutableArray alloc]init];
    }
    return _status;
}

- (NSMutableDictionary *)task{
    if (_task) {
        _task = [[NSMutableDictionary alloc]init];
    }
    return _task;
}

- (void)loadKVO{
    static void *context = &context;
    [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:context];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NewStatusModel *model = change[@"new"][0];
    [self judgeStatusType:model];
}

- (void)judgeStatusType:(NewStatusModel *)model{
    if (model.imgArr.count > 0) {
        [self sendImgStatus:model];
    }else{
        [self sendTextStatus:model];
    }
}

- (void)sendTextStatus:(NewStatusModel *)model{
    [HttpRequest newStatusWithStatusText:model.status success:^(id object) {
        [[UIApplication sharedApplication].keyWindow toastWithString:@"发送成功！" type:kLabPostionTypeBottom];
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication].keyWindow toastWithString:@"发送失败！请检查网络" type:kLabPostionTypeBottom];
    }];
}
- (void)sendImgStatus:(NewStatusModel *)model{
    NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
    __weak typeof(self) weakSelf = self;
    for (UIImage *img in model.imgArr) {
        [HttpRequest uploadImgWithData:UIImageJPEGRepresentation(img, 1.0) success:^(id object) {
            [arrTemp addObject:object[@"pic_id"]];
            if (arrTemp.count == model.imgArr.count) {
                [HttpRequest sendStatusWithStatus:model.status picID:arrTemp success:^(id object) {
                    [[UIApplication sharedApplication].keyWindow toastWithString:@"发送成功！" type:kLabPostionTypeBottom];
                    [weakSelf.status removeObject:model];
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            }
        } failurl:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end

