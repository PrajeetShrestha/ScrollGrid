//
//  MainViewController.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/31/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridViewController.h"

@interface MainViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate,GridViewController>
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSArray *gridControllers;

@end
