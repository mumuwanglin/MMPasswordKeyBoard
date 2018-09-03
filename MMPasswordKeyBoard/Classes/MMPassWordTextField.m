//
//  MMPassWordTextField.m
//  TestDemo
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import "MMPassWordTextField.h"
#import "UPTKeyboard.h"

#define kDotCount 6                                 //设置密码长度，默认是6位
#define kDotSize CGSizeMake (10, 10)                //密码点的大小
#define K_Field_Height self.frame.size.height       //密码框高度

@interface MMPassWordTextField()<UITextFieldDelegate,UPTKeyboardDelegate>
@property (nonatomic, strong) NSMutableArray *dotArray;     //小黑点
@property (nonatomic, strong) NSMutableArray *fakePWDArray;
@property (nonatomic, strong) UPTKeyboard *keyboard;
@end

@implementation MMPassWordTextField
- (instancetype)initWithFrame:(CGRect)frame needDoneButton:(BOOL)needDoneButton isSecurity:(BOOL)security {
    if ((self = [super initWithFrame:frame])) {             
        [self setupUINeedDoneButton:needDoneButton isSecurity:security];
    }
    return self;
}

- (void)setupUINeedDoneButton:(BOOL)needDoneButton isSecurity:(BOOL)security {
    //设置键盘
    self.keyboard = [[UPTKeyboard alloc] initWithDoneButton:needDoneButton];
    self.keyboard.security = security;
    self.keyboard.delegate = self;
    [self setInputView:self.keyboard];
    
    self.borderStyle = UITextBorderStyleLine;   //设置边框样式
    self.tintColor = [UIColor clearColor];      //看不到光标
    self.textColor = [UIColor clearColor];      //看不到输入内容
    self.delegate = self;                       //设置代理
    
    //每个密码输入框的宽度
    CGFloat width = self.frame.size.width / kDotCount;
    //生成分割线
    for (int i = 0; i < kDotCount - 1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((i + 1) * width, 0, 1.5, K_Field_Height)];
        lineView.backgroundColor = [UIColor grayColor];
        [self addSubview:lineView];
    }
    
    //生成中间的点
    for (int i = 0; i < kDotCount; i++) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake((width - kDotCount) / 2 + i * width, (K_Field_Height - kDotSize.height) / 2, kDotSize.width, kDotSize.height)];
        dotView.backgroundColor = [UIColor blackColor];
        dotView.layer.cornerRadius = kDotSize.width / 2.0f;
        dotView.clipsToBounds = YES;
        dotView.hidden = YES; //先隐藏
        [self addSubview:dotView];
        //把创建的黑色点加入到数组中
        [self.dotArray addObject:dotView];
    }
}
//设置小黑点
- (void)setDotView {
    for (UIView *dotView in self.dotArray) {
        dotView.hidden = YES;
    }
    for (int i = 0; i < self.fakePWDArray.count; i++) {
        ((UIView *)[self.dotArray objectAtIndex:i]).hidden = NO;
    }
}

#pragma mark- UITextFieldDelegate
//禁止复制粘贴
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}
#pragma mark- UPTKeyboardDelegate
- (void)doneClick:(NSString *)resultStr {
    NSLog(@"%@",resultStr);
    [self.ptfDelegate doneClick:resultStr];
}
- (void)textChanged:(NSString*)text keyboard:(id)keyboard {
    [self.fakePWDArray addObject:text];
    [self setDotView];
    if (self.fakePWDArray.count == kDotCount) {
        NSLog(@"输入完毕");
        [self.ptfDelegate getKeyBoardData:[self.keyboard getPayData]];
    }
    //拼接密码
    NSString *curStr = @"";
    for (NSString *tpStr in _fakePWDArray) {
        curStr = [curStr stringByAppendingString:tpStr];
    }
    [self.ptfDelegate textChanged:curStr keyboard:keyboard];
}
- (void)deleteClickKeyboard:(id)keyboard {
    [self.fakePWDArray removeLastObject];
    [self setDotView];
    [self.ptfDelegate deleteClickKeyboard:keyboard];
    //拼接密码
    NSString *curStr = @"";
    for (NSString *tpStr in _fakePWDArray) {
        curStr = [curStr stringByAppendingString:tpStr];
    }
    [self.ptfDelegate textChanged:curStr keyboard:keyboard];
}
//MARK: --------------------------- 懒加载 --------------------------
- (NSMutableArray *)dotArray{
    if (!_dotArray) {
        _dotArray = [NSMutableArray array];
    }
    return _dotArray;
}
- (NSMutableArray *)fakePWDArray{
    if (!_fakePWDArray) {
        _fakePWDArray = [NSMutableArray array];
    }
    return _fakePWDArray;
}
@end
