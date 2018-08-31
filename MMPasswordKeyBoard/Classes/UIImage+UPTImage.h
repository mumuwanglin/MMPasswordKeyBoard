//
//  UIImage+UPPImage.h
//  UPPayPlugin
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UPTImage)

+ (instancetype)upp_imageWitColor:(UIColor*)color;

- (CGSize)upp_realSize;

@end
