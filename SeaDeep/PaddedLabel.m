//
//  PaddedLabel.m
//  SeaDeep
//
//  Created by Julio Vasquez on 3/6/15.
//  Copyright (c) 2015 Christopher Workman. All rights reserved.
//

#import "PaddedLabel.h"
@implementation PaddedLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 5, 0, 5};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
