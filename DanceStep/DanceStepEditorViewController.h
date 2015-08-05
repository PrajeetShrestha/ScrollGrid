//
//  DanceStepEditorViewController.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridScrollView.h"

@interface DanceStepEditorViewController : UIViewController
@property (weak, nonatomic) IBOutlet GridScrollView *gridScroller;

- (IBAction)addDancer:(id)sender;
- (IBAction)getGridDetails:(id)sender;
- (IBAction)play:(id)sender;

@end
