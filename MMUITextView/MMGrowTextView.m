//
//  MMGrowTextView.m
//  MMUITextView
//
//  Created by Pillar on 2017/9/1.
//  Copyright © 2017年 unkown. All rights reserved.
//

#import "MMGrowTextView.h"
#import "MMTextView.h"
#define BECOME_FIRST_RESPONDER [self performSelector:@selector(textViewBecomeFirstResponder) withObject:nil afterDelay:0.1]
#define RESIGN_FIRST_RESPONDER [self performSelector:@selector(textViewResignFirstResponder) withObject:nil afterDelay:0.1]

#define Regular_EdgeInset UIEdgeInsetsMake(8, 0, 0, 0)

@interface MMGrowTextView ()<UITextViewDelegate>{
    NSInteger m_maxLine;
    NSMutableDictionary *m_attributes;
    MMTextView *m_textView;
    CGFloat m_cursorHeight;
    CGFloat m_textViewMinHeight;
    CGFloat m_originY;
    
}
@property (nonatomic, strong) NSMutableOrderedSet *orderedSet;
@end

@implementation MMGrowTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    m_maxLine = 5;
    m_attributes = [NSMutableDictionary dictionary];
    self.orderedSet = [NSMutableOrderedSet orderedSet];
    
    CGRect rect = CGRectInset(self.bounds, 5, 5);
    rect.origin.x += 1;
    m_textView = [[MMTextView alloc] initWithFrame:rect];
    m_textView.backgroundColor = [UIColor grayColor];
    
    m_textView.textContainerInset = Regular_EdgeInset;
    m_textView.textContainer.lineFragmentPadding = 0;
    m_textView.returnKeyType = UIReturnKeySend;
    m_textView.delegate = self;
    m_attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentNatural;
    paragraph.lineSpacing = 0;
    m_attributes[NSParagraphStyleAttributeName] = paragraph;
    m_attributes[NSForegroundColorAttributeName] = [UIColor blackColor];
    m_textView.typingAttributes = m_attributes;
    
    [self addSubview:m_textView];
    
    
    m_textViewMinHeight = m_textView.bounds.size.height;
    
    UITextRange *startTextRange = [m_textView characterRangeAtPoint:CGPointZero];
    CGRect caretRect = [m_textView caretRectForPosition:startTextRange.end];
    
    m_originY = caretRect.origin.y;
    m_cursorHeight = caretRect.size.height;
    

    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChanged:) name:UITextViewTextDidChangeNotification object:m_textView];
    [self.orderedSet addObject:@(m_originY)];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)handleTextChanged:(id)sender {
    // 输入字符的时候，placeholder隐藏
    
    MMTextView *textView = nil;
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if ([object isKindOfClass:[MMTextView class]]) {
            textView = (MMTextView *)object;
        }
    } else if ([sender isKindOfClass:[MMTextView class]]) {
        textView = (MMTextView *)sender;
    }
    
    if (textView) {
        
        // 上一次光标位置
        static CGFloat preCursorY = 0;
        
        // 获取光标位置
        CGRect cursorFrame = [m_textView caretRectForPosition:m_textView.selectedTextRange.end];
        
        // 获取光标Y坐标
        CGFloat currentCursorY = CGRectGetMinY(cursorFrame);
        
        if (currentCursorY == m_originY) {
            
            if (currentCursorY == preCursorY) {
                return;
            }
            
            // 还原 inset
            m_textView.textContainerInset = Regular_EdgeInset;
            m_textView.shouldRejectSystemScroll = NO;
            [m_textView setContentOffset:CGPointZero animated:YES];
            m_textView.shouldRejectSystemScroll = YES;   // 不允许滚动
            
            
            CGRect frame = m_textView.frame;
            frame.size.height = m_textViewMinHeight;
            m_textView.animating = YES;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut |
             UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 m_textView.frame = frame;
                             }
                             completion:^(BOOL finished) {
                                 m_textView.animating = NO;
                             }
             ];
            
        }else{
            
            
            // 不允许滚动
            m_textView.shouldRejectSystemScroll = YES;
            
            // 第2，3，4，5，。。。。行
            // 保存光标
            
            
            [self.orderedSet addObject:@(currentCursorY)];
            
            
            if (currentCursorY == preCursorY) {
                return;
            }
            
            
            static CGFloat textViewOffsetY = 0;
            static CGFloat textViewCursorCenterY = 0;
            
            
            
            
            CGFloat textViewContentHeight = m_textView.contentSize.height;
            
            textViewCursorCenterY = CGRectGetMidY(cursorFrame);
            
            
            if (textViewCursorCenterY < m_maxLine *  m_cursorHeight + m_originY) {
                
                // 设置OffsetY为原始光标的Y值
                textViewOffsetY = m_originY;
                
                // 更改当前offset
                CGPoint offset = m_textView.contentOffset;
                offset.y = textViewOffsetY;
                CGRect frame = m_textView.frame;
                
//                if (offset.y + frame.size.height < m_textView.contentSize.height) {
//                    
//                }else{
//                    
//                }
//                
                
                frame.size.height = textViewContentHeight - textViewOffsetY;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 允许滚动
                    m_textView.shouldRejectSystemScroll = NO;
                    m_textView.animating = YES;
                    [UIView animateWithDuration:0.25
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut |
                     UIViewAnimationOptionBeginFromCurrentState
                                     animations:^{
                                         m_textView.contentOffset = offset;
                                         m_textView.frame = frame;
                                     }completion:^(BOOL finished) {
                                         m_textView.animating = NO;
                                         //不允许滚动
                                         m_textView.shouldRejectSystemScroll = YES;
                                         if (textViewCursorCenterY > (m_maxLine - 1) *  m_cursorHeight + m_originY) {
                                             [self setTextViewDonotRejectSystemScroll];
                                         }
                                         
                                     } ];
                });
                
            }else{
                

                m_textView.shouldRejectSystemScroll = YES;
                // fix m_textViewMaxHeight
                CGFloat newOffset = CGRectGetMaxY(cursorFrame) - m_textView.frame.size.height;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 允许滚动
                    m_textView.shouldRejectSystemScroll = NO;
                    m_textView.animating = YES;
                    CGPoint offset = m_textView.contentOffset;
                    offset.y = newOffset;
                    [UIView animateWithDuration:0.25
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut |
                     UIViewAnimationOptionBeginFromCurrentState
                                     animations:^{
                                         m_textView.contentOffset = offset;
                                     }completion:^(BOOL finished) {
                                         m_textView.animating = NO;
                                         //不允许滚动
                                         m_textView.shouldRejectSystemScroll = YES;
                                         
                                     } ];
                });
                
                
                
            }
        }
        
        preCursorY = currentCursorY;
        
    }
}


// 还原textView系统控制
- (void)setTextViewDonotRejectSystemScroll{
    m_textView.shouldRejectSystemScroll = NO;
}

- (BOOL)textView:(MMTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        //        [m_textView resignFirstResponder];
        if (textView.isAnimating) {
            return NO;
        }
        //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

- (void)scrollCaretVisibleAnimated:(BOOL)animated {
    if (CGRectIsEmpty(m_textView.bounds)) {
        return;
    }
    
    CGRect caretRect = [m_textView caretRectForPosition:m_textView.selectedTextRange.end];
    CGFloat contentOffsetY = m_textView.contentOffset.y;
    
    if (CGRectGetMinY(caretRect) == m_textView.contentOffset.y + m_textView.textContainerInset.top) {
        // 命中这个条件说明已经不用调整了，直接 return，避免继续走下面的判断，会重复调整，导致光标跳动
        return;
    }
    
    if (CGRectGetMinY(caretRect) < m_textView.contentOffset.y + m_textView.textContainerInset.top) {
        // 光标在可视区域上方，往下滚动
        contentOffsetY = CGRectGetMinY(caretRect) - m_textView.textContainerInset.top - m_textView.contentInset.top;
        
    } else if (CGRectGetMaxY(caretRect) > m_textView.contentOffset.y + CGRectGetHeight(self.bounds) - m_textView.textContainerInset.bottom - m_textView.contentInset.bottom) {
        // 光标在可视区域下方，往上滚动
        contentOffsetY = CGRectGetMaxY(caretRect) - CGRectGetHeight(self.bounds) + m_textView.textContainerInset.bottom + m_textView.contentInset.bottom;
    } else {
        // 光标在可视区域内，不用调整
        return;
    }
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [m_textView setContentOffset:CGPointMake(m_textView.contentOffset.x, contentOffsetY) animated:NO];
                     }completion:^(BOOL finished) {
                         m_textView.animating = NO;
                         //不允许滚动
                         m_textView.shouldRejectSystemScroll = YES;

                     } ];

    
    
}


- (CGFloat)nextTextViewOffsetY:(CGFloat)contentOffsetY{
    
    
    //    NSUInteger index =  [self.orderedSet indexOfObject:@(contentOffsetY) inSortedRange:NSMakeRange(0, self.orderedSet.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    //        return [obj1 compare:obj2];
    //    }];
    
    NSUInteger index = [self.orderedSet indexOfObject:@(contentOffsetY)];
    CGFloat newOffsetY = [[self.orderedSet objectAtIndex:index - (m_maxLine - 1)] floatValue];
    return newOffsetY;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"cursorY"]) {
        NSLog(@"加入：%@",change[NSKeyValueChangeNewKey]);
        [self.orderedSet addObject:change[NSKeyValueChangeNewKey]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
