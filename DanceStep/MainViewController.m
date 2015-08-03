//
//  MainViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/31/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "MainViewController.h"

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface MainViewController()<UIScrollViewDelegate> {
    NSUInteger indexOfPage;
}
@property (nonatomic, assign) CGFloat lastContentOffset;
@end
@implementation MainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridControllers = @[@1,@2,@3];
    [self registerForNotification];
    indexOfPage = 0;
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Memory warning received");
}
- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pageIndexNotification:) name:@"IndexOfContent" object:nil];
}
- (void)viewDidLayoutSubviews {
    [self setUpPages];
    [self setScrollViewDelegate];
}
- (void)setScrollViewDelegate {
    for (UIScrollView *view in self.pageViewController.view.subviews){
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.delegate = self;
        }
    }
}
- (void)pageIndexNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"IndexOfContent"]) {
        NSDictionary *userInfo = notification.userInfo;
        indexOfPage = [userInfo[@"index"] integerValue];
        NSLog(@"%d Index Of page",indexOfPage);
    }
}

- (void)setUpPages {
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

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
    return pageContentViewController;
}

#pragma mark - Touch Gestures
- (void)touchesBegan {
    self.pageViewController.dataSource = nil;
}

- (void)touchesEnd {
    self.pageViewController.dataSource = self;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    GridViewController *vc = [pageViewController.viewControllers lastObject];
    indexOfPage = vc.pageIndex  ;
}


- (IBAction)addDancer:(id)sender {
    NSDictionary *userInfo = @{
                               @"index":[NSNumber numberWithInteger:indexOfPage]
                               };
    [[NSNotificationCenter defaultCenter]postNotificationName:@"AddDancer" object:userInfo];
}

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
        NSLog(@"Scrolled Left");}
    self.lastContentOffset = scrollView.contentOffset.x;
}

@end
