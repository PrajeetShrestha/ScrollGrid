//
//  ViewController.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/23/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Grid.h"

@protocol GridViewController <NSObject>

- (void)touchesBegan;
- (void)touchesEnd;

@end

@interface GridViewController : UIViewController
@property (nonatomic) NSMutableArray *grids;
@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic,weak) id <GridViewController> delegate;
@end


