//
//  UIImage+UPPImage.m
//  UPPayPlugin
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import "UIImage+UPTImage.h"

@implementation UIImage (UPTImage)


+ (instancetype)upp_imageWitColor:(UIColor*)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (CGSize)upp_realSize
{
    return CGSizeMake(self.size.width/1, self.size.height/1);
}


@end
