//
//  MMPassWordTextField.h
//  TestDemo
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMPassWordTextFieldDegegate <NSObject>
- (void)getKeyBoardData:(NSString *)keyBoardData;
- (void)doneClick:(NSString *)resultStr;
- (void)deleteClickKeyboard:(id)keyboard;
@end

@interface MMPassWordTextField : UITextField

@property (nonatomic, weak) id<MMPassWordTextFieldDegegate> ptfDelegate;
/**
 初始化方法

 @param frame 设置大小
 @param needDoneButton 是否需要完成键盘
 @param security 是否混乱键盘

 */
- (instancetype)initWithFrame:(CGRect)frame needDoneButton:(BOOL)needDoneButton isSecurity:(BOOL)security;
@end
