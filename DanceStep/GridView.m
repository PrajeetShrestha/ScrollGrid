//
//  GridView.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/29/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "GridView.h"

@implementation GridView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isColorSet = NO;
    }
    return self;
}

- (void)viewStateSelected {
    self.layer.borderColor = [UIColor blueColor].CGColor;
    self.layer.borderWidth = 2.0f;
}

- (void)viewStateDeselected {
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0.0f;
}

- (void)expand {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.5, 1.5);

        self.alpha = 1.0f;
    }];
}

- (void)shrink {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)setColorWhenTouchedForFirstTime {
    if(!self.isColorSet) {
        self.backgroundColor = [UIColor blackColor];
        self.isColorSet = YES;
    }
}
@end
