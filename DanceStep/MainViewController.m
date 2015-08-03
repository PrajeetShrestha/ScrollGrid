//
//  MainViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/31/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "MainViewController.h"



@interface MainViewController()<UIScrollViewDelegate> {
    NSUInteger indexOfPage;
    UIScrollView *pageScroll;
}
@property (nonatomic, assign) CGFloat lastContentOffset;
@end
@implementation MainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridControllers = @[@1,@2,@3];
    indexOfPage = 0;
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Memory warning received");
}

- (void)viewDidLayoutSubviews {

}
- (void)setScrollViewDelegate {
    for (UIScrollView *view in self.pageViewController.view.subviews){
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.delegate = self;
            pageScroll = view;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self setUpPages];
    [self setScrollViewDelegate];
}
- (void)setUpPages {
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageViewController.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;

    GridViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // Change the size of page view controller
    self.pageViewController.view.frame = self.container.bounds;//CGRectMake(0, 0, self.container.bounds.size.width, self.container.bounds.size.height);
    [self addChildViewController:_pageViewController];
    [self.container addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GridViewController*) viewController).pageIndex;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GridViewController*) viewController).pageIndex;

    if (index == NSNotFound) {
        return nil;
    }

    index++;
    if (index == [self.gridControllers count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (GridViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.gridControllers count] == 0) || (index >= [self.gridControllers count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    GridViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GridViewController"];
    pageContentViewController.delegate = self;
    pageContentViewController.pageIndex = index;
    pageContentViewController.view.preservesSuperviewLayoutMargins = YES;
    NSLog(@"%@ Frame ",NSStringFromCGRect(pageContentViewController.view.frame));
    return pageContentViewController;
}

#pragma mark - Touch Gestures
- (void)touchesBegan {
    self.pageViewController.dataSource = nil;
    pageScroll.bounces = YES;
}

- (void)touchesEnd {
    self.pageViewController.dataSource = self;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    GridViewController *vc = [pendingViewControllers lastObject];
    vc.automaticallyAdjustsScrollViewInsets = NO;
    if(vc.view.frame.size.height == 568) {
            vc.view.frame = CGRectOffset(vc.view.frame, 0, 20);
    }

    NSLog(@"%@ FRAME ",NSStringFromCGRect(vc.view.frame));
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    GridViewController *vc = [pageViewController.viewControllers lastObject];
    indexOfPage = vc.pageIndex  ;
}
#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    ScrollDirection scrollDirection;
    if (self.lastContentOffset > scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionRight;
        if (indexOfPage == 0) {
            scrollView.bounces = NO;
        }
    }
    else if (self.lastContentOffset < scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionLeft;
    }
    self.lastContentOffset = scrollView.contentOffset.x;
}

#pragma mark - Actions
- (IBAction)addDancer:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNAddDancer] object:userInfo];
}

- (IBAction)verticalAlignment:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNVerticalAlignment] object:userInfo];
}
- (IBAction)horizontalAlignment:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNHorizontalAlignment] object:userInfo];
}

- (IBAction)verticallyEquidistant:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNVerticallyEquidistant] object:userInfo];
}

- (IBAction)horizontallyEquidistant:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNHorizontallyEquidistant] object:userInfo];
}

- (IBAction)circle:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNCircle] object:userInfo];
}

- (IBAction)undo:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNUndo] object:userInfo];
}

- (IBAction)redo:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNRedo] object:userInfo];
}

- (IBAction)selectAllDancer:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNSelectAll] object:userInfo];
}

- (IBAction)deselectAllDancer:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNDeSelectAll] object:userInfo];
}

- (IBAction)accumulate:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNAcculmulate] object:userInfo];
}

- (IBAction)pickColor:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:[self formatTypeToString:DNPickColor] object:userInfo];
}

//Convert ENUM to String
- (NSString*)formatTypeToString:(DancerActionNotifications)formatType {
    NSString *result = nil;
    NSLog(@"%u FORMAT TYPE ",formatType);
    switch(formatType) {
        case DNAddDancer:
            result = @"DNAddDancer";
            break;
        case DNVerticalAlignment:
            result = @"DNVerticalAlignment";
            break;
        case DNHorizontalAlignment:
            result = @"DNHorizontalAlignment";
            break;
        case DNVerticallyEquidistant:
            result = @"DNVerticallyEquidistant";
            break;
        case DNHorizontallyEquidistant:
            result = @"DNHorizontallyEquidistant";
            break;
        case DNCircle:
            result = @"DNCircle";
            break;
        case DNRedo:
            result = @"DNRedo";
            break;
        case DNUndo:
            result = @"DNUndo";
            break;
        case DNSelectAll:
            result = @"DNSelectAll";
            break;
        case DNDeSelectAll:
            result = @"DNDeSelectAll";
            break;
        case DNAcculmulate:
            result = @"DNAcculmulate";
            break;
        case DNPickColor:
            result = @"DNPickColor";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }

    return result;
}


//- (void)loadImageScrollerWithCardView:(NSString *)cardView
//{
//    for (UIView *view in _imageScroller.subviews ) {
//        [view removeFromSuperview ];
//    }
//    NSArray *imgArray = @[@"tc01.png",@"tc01.png",@"tc01.png"];
//
//    CGRect imageScrollerBound = _imageScroller.bounds;
//    CGFloat imageScrollerMinY = CGRectGetMinY(imageScrollerBound);
//    CGFloat imageScrollerHeight = CGRectGetHeight(imageScrollerBound);
//    CGFloat imageScrollerWidth = CGRectGetWidth(imageScrollerBound);
//
//    [_imageScroller.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//
//    _imageScroller.delegate = self;
//
//    if ([cardView isEqualToString:@"TimerView"]) {
//        _imageScroller.contentSize = CGSizeMake(1 *imageScrollerWidth, imageScrollerHeight);
//        CGRect frame = CGRectMake(0, imageScrollerMinY, imageScrollerWidth, imageScrollerHeight);
//        HazView *pagarView = [[HazView alloc]initWithView:cardView];
//        pagarView.frame = frame;
//        [pagarView setViewsForTimerView];
//        [pagarView startTimer];
//        [timers addObject:pagarView.myTimer];
//        [_imageScroller addSubview:pagarView];
//        pagarView.delegate = self;
//
//    } else {
//        for (int i = 0; i < imgArray.count; i++) {
//            _imageScroller.contentSize = CGSizeMake((unsigned long)imgArray.count *imageScrollerWidth, imageScrollerHeight);
//            CGRect frame = CGRectMake(i * imageScrollerWidth, imageScrollerMinY, imageScrollerWidth, imageScrollerHeight);
//            HazView *pagarView = [[HazView alloc]initWithView:cardView];
//            pagarView.frame = frame;
//
//            pagarView.delegate = self;
//            if ([cardView isEqualToString:@"HazView"]) {
//                pagarView.message.text = @"Haz click en la superficie de la tarjeta para activarla y permitir los pagos móviles";
//
//                //            } else if([cardView isEqualToString:@"TimerView"]) {
//                //                [pagarView setViewsForTimerView];
//                //                [pagarView startTimer];
//                //                [timers addObject:pagarView.myTimer];
//                //            }
//
//            }
//            [_imageScroller addSubview:pagarView];
//
//        }
//    }
//
//    CGRect imageScrollerFrame = _imageScroller.frame;
//    CGFloat minx = CGRectGetMinX(imageScrollerFrame);
//    CGFloat maxy = CGRectGetMaxY(imageScrollerFrame);
//    CGFloat width = CGRectGetWidth(imageScrollerFrame);
//    //Add page control
//    pageControl = [UIPageControl new];
//    pageControl.frame = CGRectMake(minx, maxy , width, 20);
//    pageControl.numberOfPages = 3;//imgArray.count;
//    pageControl.enabled = NO;
//    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
//    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
//    [self.view addSubview:pageControl];
//}


@end
