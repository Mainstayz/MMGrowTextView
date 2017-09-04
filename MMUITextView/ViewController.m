//
//  ViewController.m
//  MMUITextView
//
//  Created by Pillar on 2017/9/1.
//  Copyright © 2017年 unkown. All rights reserved.
//

#import "ViewController.h"
#import "MMGrowTextView.h"



@interface ViewController ()
@property (nonatomic, strong) MMGrowTextView *textView;
@end

@implementation ViewController
 /*
 
 <MMTextView: 0x10a32f800; baseClass = UITextView; frame = (6 5; 200 34); text = ''; clipsToBounds = YES; gestureRecognizers = <NSArray: 0x113e91350>; layer = <CALayer: 0x10d33a2b0>; contentOffset: {0, 1}; contentSize: {200, 36}>
 Printing description of $5:
 <<_UITextContainerView: 0x114b8c690; frame = (0 0; 200 36); layer = <_UITextTiledLayer: 0x113e25300>> minSize = {0, 0}, maxSize = {1.7976931348623157e+308, 1.7976931348623157e+308}, textContainer = <NSTextContainer: 0x1199beee0 size = (200.000000,340282346638528859811704183484516925440.000000); widthTracksTextView = YES; heightTracksTextView = NO>; exclusionPaths = 0x17401b580; lineBreakMode = 0>
 Printing description of $6:
 <MMGrowTextView: 0x114bb3e20; frame = (37 3; 209 44); text = ''; layer = <CALayer: 0x114610b70>>
 2017-09-02 15:15:56.797619+0800 WeChat[1471:432112] text (null)
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView = [[MMGrowTextView alloc] initWithFrame:CGRectMake(40, 100, self.view.bounds.size.width - 80, 300)];
    self.textView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.textView];
}




@end
