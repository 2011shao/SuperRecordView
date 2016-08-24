//
//  ProgressView.m
//  CusTomVideo
//
//  Created by ios-少帅 on 16/8/23.
//  Copyright © 2016年 ios-shaoshuai. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor redColor] set];
    UIRectFill(CGRectMake(0, 0, self.progress * rect.size.width, rect.size.height));
}


@end
