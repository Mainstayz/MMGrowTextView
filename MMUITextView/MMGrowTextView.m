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
    NSInteger _maxLine;
    NSMutableDictionary *_attributes;
    MMTextView *_textView;
    CGFloat _lineHeight;
    CGFloat _textViewMinHeight;
    CGFloat _originY;
    CGFloat _preCursorTop;
    BOOL _isMaxHeight;
    
}
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
    _maxLine = 5;
    _attributes = [NSMutableDictionary dictionary];
    
    CGRect rect = CGRectInset(self.bounds, 5, 5);
    rect.origin.x += 1;
    _textView = [[MMTextView alloc] initWithFrame:CGRectMake(6, 4, 230, 34)];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.delegate = self;
    
    _textView.textContainerInset = Regular_EdgeInset;
    _textView.textContainer.lineFragmentPadding = 0;
    _textView.contentInset = UIEdgeInsetsZero;
    
    _attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentNatural;
    paragraph.lineSpacing = 0;
    _attributes[NSParagraphStyleAttributeName] = paragraph;
    _attributes[NSForegroundColorAttributeName] = [UIColor blackColor];
    _textView.typingAttributes = _attributes;
    
    [self addSubview:_textView];
    _textViewMinHeight = _textView.bounds.size.height;
    
    UITextRange *startTextRange = [_textView characterRangeAtPoint:CGPointZero];
    CGRect caretRect = [_textView caretRectForPosition:startTextRange.end];
    _originY = caretRect.origin.y;
    
    _lineHeight = _textView.font.lineHeight;
    

    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChanged:) name:UITextViewTextDidChangeNotification object:_textView];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)handleTextChanged:(id)sender {
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
    
        CGRect cursorFrame = [textView caretRectForPosition:textView.selectedTextRange.end];
        CGPoint contentOffset = textView.contentOffset;
        
        // 光标会时不时突出0.5个点
        BOOL inLastLine = ABS(CGRectGetMaxY(cursorFrame) - textView.contentSize.height) < 1;
        CGRect textViewframe = _textView.frame;
        
        CGFloat targetOffsetY = contentOffset.y;
        
        
        if (inLastLine && textView.contentSize.height < 2 * _lineHeight) {
            textView.textContainerInset = Regular_EdgeInset;
            targetOffsetY = 0;
            textViewframe.size.height = _textViewMinHeight;
            _isMaxHeight = NO;
        }else{
            if (_isMaxHeight && _textView.shouldRejectSystemScroll == YES) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setTextViewDonotRejectSystemScroll) object:nil];
            }
            _textView.shouldRejectSystemScroll = YES;
            // 分3种情况
            if (!UIEdgeInsetsEqualToEdgeInsets(textView.textContainerInset, UIEdgeInsetsZero)) {
                textView.textContainerInset = UIEdgeInsetsZero;
                cursorFrame = [textView caretRectForPosition:textView.selectedTextRange.end];
            }

            if (CGRectGetMinY(cursorFrame) +1 < textView.contentOffset.y) { // 光标偶尔突破0.5个点
                // 光标在 可见区域 上面
                // 出现这种情况只有 大于 5 行，发生了滚动才会存在
                targetOffsetY = CGRectGetMinY(cursorFrame);
                _isMaxHeight = YES;
                
            } else if (CGRectGetMaxY(cursorFrame) -1 > textView.contentOffset.y + textViewframe.size.height) {
                // 光标在可视区域下方，往上滚动

                if(CGRectGetMaxY(cursorFrame) > _maxLine * cursorFrame.size.height){
                    targetOffsetY = CGRectGetMaxY(cursorFrame) - textViewframe.size.height;
                    _isMaxHeight = YES;
                    
                }else{
                    targetOffsetY = 0;
                    textViewframe.size.height = textView.contentSize.height;
                    _isMaxHeight = NO;
                }
                
            } else {
                
                if (textView.contentSize.height > _maxLine * cursorFrame.size.height) {
                    CGFloat distance = textView.contentSize.height - textView.contentOffset.y;
                    if (distance < textViewframe.size.height) {
                        targetOffsetY = textView.contentSize.height - textViewframe.size.height;
                    }else{
                        
                    }
                    _isMaxHeight = YES;
                }else{
                    
                    targetOffsetY = 0;
                    textViewframe.size.height = textView.contentSize.height;
                    _isMaxHeight = NO;
                }
                
            }
            
        }
        _textView.shouldRejectSystemScroll = NO;
        _textView.animating = YES;
        CGPoint offset = _textView.contentOffset;
        offset.y = targetOffsetY;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut |
         UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _textView.contentOffset = offset;
                             _textView.frame = textViewframe;
                         }
                         completion:^(BOOL finished) {
                             _textView.shouldRejectSystemScroll = YES;
                             _textView.animating = NO;
                             [self performSelector:@selector(setTextViewDonotRejectSystemScroll) withObject:nil afterDelay:0.8];
                         }
         ];
    }
}
// 还原textView系统控制
- (void)setTextViewDonotRejectSystemScroll{
    if (_isMaxHeight) {
        _textView.shouldRejectSystemScroll = NO;
    }
}
- (BOOL)textView:(MMTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        //在这里做你响应return键的代码
        if (textView.isAnimating) {
            return NO;
        }
    }
    return YES;
}

@end
