//
//  PJScrollView.h
//  test1
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridContainerView.h"
@protocol GridScrollView <NSObject>

@end
@interface GridScrollView : UIScrollView
@property (nonatomic) NSMutableArray *viewArray;
@property (nonatomic) CGFloat indexPage;
@property (nonatomic) UIView *firstView;

- (void)loadScroller:(Class)viewClass ;
- (void)loadIndexLabel;
- (UIView *)getCurrentView;
@end
