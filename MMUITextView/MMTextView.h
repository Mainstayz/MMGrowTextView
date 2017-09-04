//
//  MMTextView.h
//  MMUITextView
//
//  Created by Pillar on 2017/9/1.
//  Copyright © 2017年 unkown. All rights reserved.
//

#import "MMUITextView.h"

@class MMTextView;

@protocol MMUITextViewDelegate <NSObject>
- (void)textView:(MMTextView *)textView newHeightAfterTextChanged:(CGFloat)height;
@end


@interface MMTextView : MMUITextView
@property(nonatomic, assign, getter=isAnimating) BOOL animating;
@property(nonatomic, assign) BOOL shouldRejectSystemScroll; 
@end
