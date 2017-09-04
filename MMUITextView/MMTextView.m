//
//  MMTextView.m
//  MMUITextView
//
//  Created by Pillar on 2017/9/1.
//  Copyright © 2017年 unkown. All rights reserved.
//

#import "MMTextView.h"

@interface MMTextView ()

@property (nonatomic) CGPoint point;

@end

@implementation MMTextView

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (!_shouldRejectSystemScroll ) {
        _point = contentOffset;
        [super setContentOffset:contentOffset animated:animated];
    }else {
        NSLog(@"屏蔽系统滚动：%@",NSStringFromCGPoint(contentOffset));
        [super setContentOffset:_point animated:animated];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    if (!_shouldRejectSystemScroll ) {
        _point = contentOffset;
        [super setContentOffset:contentOffset];
    }else {
        NSLog(@"屏蔽系统滚动：%@",NSStringFromCGPoint(contentOffset));
        [super setContentOffset:_point];
    }
}

@end
