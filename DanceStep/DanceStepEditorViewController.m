//
//  DanceStepEditorViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "DanceStepEditorViewController.h"
#import "GridScrollView.h"

@interface DanceStepEditorViewController() {
}
@end
@implementation DanceStepEditorViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.gridScroller.viewArray addObject:@"t1.jpg"];
    [self.gridScroller loadScroller:[GridContainerView class]];
    [self.gridScroller loadIndexLabel];

}

- (IBAction)addDancer:(id)sender {
    GridContainerView *containerView =(GridContainerView *) [self.gridScroller getCurrentView];
    [containerView addDancer];
}

- (IBAction)getGridDetails:(id)sender {
    NSLog(@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    GridContainerView *containerView = (GridContainerView *)[self.gridScroller getCurrentView];
    for (Grid *grid in containerView.grids){
        [grid logContent];
    }
}


@end
