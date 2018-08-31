//
//  MMViewController.m
//  MMPasswordKeyBoard
//
//  Created by 873621881@qq.com on 08/31/2018.
//  Copyright (c) 2018 873621881@qq.com. All rights reserved.
//

#import "MMViewController.h"
#import <MMPasswordKeyBoard/MMPassWordTextField.h>

@interface MMViewController ()<MMPassWordTextFieldDegegate>

@end

@implementation MMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     初始化方法
     
     @param frame 设置大小
     @param needDoneButton 是否需要完成键盘
     @param security 是否混乱键盘
     
     */
    MMPassWordTextField *pwdTF = [[MMPassWordTextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 132, self.view.frame.size.height / 2 - 60, 264, 44) needDoneButton:YES isSecurity:YES];
    pwdTF.ptfDelegate = self;
    [self.view addSubview:pwdTF];
}
#pragma mark- MMPassWordTextFieldDegegate
- (void)getKeyBoardData:(NSString *)keyBoardData{
    NSLog(@"%@",keyBoardData);
}
- (void)doneClick:(NSString *)resultStr{
    NSLog(@"%@",resultStr);
}
- (void)deleteClickKeyboard:(id)keyboard{
    NSLog(@"%@",keyboard);
}
@end
