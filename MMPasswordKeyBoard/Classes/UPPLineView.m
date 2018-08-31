//
//  UPLineView.m
//  UPPayPluginEx
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import "UPPLineView.h"

@interface UPPLineView ()
{
    BOOL _dotted;
}

@end

@implementation UPPLineView

@synthesize lineColor;

#define dataEngine [CUPPLusEngine sharedInstance].noCardData

-(id)initWithFrame:(CGRect)frame color:(UIColor *) color{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.lineColor = color;;
	}
    return self;
}

-(id)initWithFrame:(CGRect)frame color:(UIColor *) color dotted:(BOOL)dotted
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineColor = color;
        _dotted = dotted;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    if (_dotted) {
        CGFloat lengths[] = {3,3};
        CGContextSetLineDash(context, 0, lengths, 2);
        CGContextSetLineCap(context, kCGLineCapRound);  //设置线条终点形状
    }
    
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, CGRectGetHeight(rect));
    if (!_dotted) {
        CGContextStrokeRectWithWidth(context, rect, CGRectGetWidth(rect));
    }
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextStrokePath(context);
}

- (void)dealloc
{
    self.lineColor = nil;
//    [super dealloc];
}

@end
