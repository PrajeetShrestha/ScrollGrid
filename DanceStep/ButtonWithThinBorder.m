//
//  ButtonWithThinBorder.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/3/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "ButtonWithThinBorder.h"

@implementation ButtonWithThinBorder
- (void)awakeFromNib {
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 2.0f;
    self.clipsToBounds = YES;
}
@end
