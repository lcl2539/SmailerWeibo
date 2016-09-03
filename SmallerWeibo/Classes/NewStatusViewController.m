//
//  NewStatusViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "NewStatusViewController.h"
#import <Masonry.h>
#import "FaceKeyBoard.h"
@interface NewStatusViewController ()

@end

@implementation NewStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    FaceKeyBoard *view = [FaceKeyBoard shareFaceKeyBoard];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.equalTo(@200);
    }];
    
}

- (void)show{
    [self.fromVc.navigationController pushViewController:self animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
