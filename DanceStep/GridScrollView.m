//
//  PJScrollView.m
//  test1
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "GridScrollView.h"
@interface GridScrollView ()<UIScrollViewDelegate>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) NSMutableArray *gridViews;
@property (nonatomic) UILabel *indexLabel;
@property (nonatomic) Class viewClass;
@end

@implementation GridScrollView

#pragma mark - Nib Loading
- (void)awakeFromNib {
    _indexPage = 0;
    [self initializations];
}
#pragma mark - Private methods

- (void)initializations {
    _viewArray = [NSMutableArray new];
    _gridViews = [NSMutableArray new];
    [self setUpScrollViewProperties];
    [self registerNotifications];
}

- (void)setUpScrollViewProperties {
    self.bounces = NO;
    self.pagingEnabled = YES;
    self.delegate = self;
}

- (void)removeAllSubviewsFromScroller {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

#pragma mark - Notification Observers
-(void)registerNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dancerTouchBeganNotification:) name:kDancerTouchBeganNotification  object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dancerTouchMovedNotification:) name:kDancerTouchMoveNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dancerTouchEndNotification:) name:kDancerTouchEndNotification object:nil];
}

- (void)dancerTouchBeganNotification:(NSNotification *)notification {
    self.scrollEnabled = NO;
}

- (void)dancerTouchMovedNotification:(NSNotification *)notification {

}

- (void)dancerTouchEndNotification:(NSNotification *)notification {
    self.scrollEnabled = YES;
}

#pragma mark - Public Methods
//Call this loader in ViewDidAppear of Controller from which these are called.
- (void)loadScroller:(Class)viewClass {
    self.viewClass = viewClass;
    [self removeAllSubviewsFromScroller];
    CGRect  scrollerBound  = self.bounds;
    CGFloat scrollerMinY   = CGRectGetMinY(scrollerBound);
    CGFloat scrollerHeight = CGRectGetHeight(scrollerBound);
    CGFloat scrollerWidth  = CGRectGetWidth(scrollerBound);
    [_gridViews removeAllObjects];
    for (CGFloat i = 0; i <= _viewArray.count; i++) {
        //Content Width is always +1 Width greater than current contents because we want to always have a view to scroll at last.
        self.contentSize = CGSizeMake((unsigned long)(_viewArray.count + 1) *scrollerWidth, scrollerHeight);
        CGRect frame = CGRectMake(i * scrollerWidth, scrollerMinY, scrollerWidth, scrollerHeight);
        GridContainerView *view = [[viewClass alloc]initWithFrame:frame];

        view.backgroundColor = UIColorFromRGB(0x146622);
        if (i != _viewArray.count) {
            [_gridViews addObject:view];
            view.containerIndex = _gridViews.count - 1;
        }
        [self addSubview:view];
    }

}
// Method to display page number of scrollView.
- (void)loadIndexLabel {
    _indexLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.origin.x + 2, self.frame.origin.y + 2, 100, 100)];
    _indexLabel.textColor = [UIColor darkGrayColor];
    _indexLabel.text = [NSString stringWithFormat:@" Grid-%d ",(int)_indexPage];
    _indexLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_indexLabel sizeToFit];
    //_indexLabel.clipsToBounds = YES;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_indexLabel.bounds];
    _indexLabel.layer.masksToBounds = NO;
    _indexLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    _indexLabel.layer.shadowOffset = CGSizeMake(2.0f, 1.0f);
    _indexLabel.layer.shadowOpacity = 0.6f;
    _indexLabel.layer.shadowPath = shadowPath.CGPath;
    [self.superview addSubview:_indexLabel];
}

- (UIView *)getCurrentView {
    //NSLog(@"%@ Grid View",_gridViews[(int)_indexPage]);
    return _gridViews[(int)_indexPage];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Calculating which page is user in
    _indexPage = floor(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
    _indexLabel.text = [NSString stringWithFormat:@" Grid-%d ",(int)_indexPage];
    [_indexLabel sizeToFit];

    //Shows the direction that user is dragging the scrollview
    ScrollDirection scrollDirection;
    if (self.lastContentOffset > scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionRight;
    }
    else if (self.lastContentOffset < scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionLeft;
    }
    self.lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //If indexPage and View Array count is equal add another object to viewArray so that
    //Everytime we scroll left another view is added at the last.
    if (_indexPage == _viewArray.count) {
        [_viewArray addObject:@"t3.png"];
        //[self loadScroller:self.viewClass];
        [self appendNewViewInScroller];
    }
}

- (void)appendNewViewInScroller {

    CGRect  scrollerBound  = self.bounds;
    CGFloat scrollerMinY   = CGRectGetMinY(scrollerBound);
    CGFloat scrollerHeight = CGRectGetHeight(scrollerBound);
    CGFloat scrollerWidth  = CGRectGetWidth(scrollerBound);

    self.contentSize = CGSizeMake((unsigned long)(_viewArray.count + 1) *scrollerWidth, scrollerHeight);
    CGRect frame = CGRectMake((_viewArray.count -1) * scrollerWidth, scrollerMinY, scrollerWidth, scrollerHeight);
    GridContainerView *view = [[_viewClass alloc]initWithFrame:frame];
    view.backgroundColor = UIColorFromRGB(0x146622);
    [_gridViews addObject:view];
    [self addSubview:view];
    view.containerIndex = _gridViews.count - 1;
    [view replicateDancerAtPreviousPosition];

    //Extra view So that scroll view can scrollleft
    CGRect lastViewFrame = CGRectMake((_viewArray.count) * scrollerWidth, scrollerMinY, scrollerWidth, scrollerHeight);
    UIView *lastView = [[_viewClass alloc]initWithFrame:lastViewFrame];
    lastView.backgroundColor = UIColorFromRGB(0x146622);
    [self addSubview:lastView];
    
}
@end
