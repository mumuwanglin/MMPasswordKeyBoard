//
//  UPPKeyboard.h
//  UPPayPlugin
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UPTKeyboardDelegate

- (void)doneClick:(NSString *)resultStr;
- (void)textChanged:(NSString*)text keyboard:(id)keyboard;
- (void)deleteClickKeyboard:(id)keyboard;

@end

@interface UPTKeyboard : UIView

@property (nonatomic, weak)   id<UPTKeyboardDelegate> delegate;
@property (nonatomic, assign) BOOL security;
@property (nonatomic, readonly) BOOL needDoneButton;

- (void)cleanSecurity;
- (NSString *)getPayData;
- (instancetype)initWithDoneButton:(BOOL)needDoneButton;

@end
