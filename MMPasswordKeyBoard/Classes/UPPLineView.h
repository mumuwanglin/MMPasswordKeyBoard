//
//  UPLineView.h
//  UPPayPluginEx
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPPLineView : UIView
{
    NSInteger lineWidth;
    UIColor * lineColor;
}

@property (nonatomic, retain) UIColor * lineColor;

-(id)initWithFrame:(CGRect)frame color:(UIColor *) color;

-(id)initWithFrame:(CGRect)frame color:(UIColor *) color dotted:(BOOL)dotted;

@end
