//
//  GridView.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/29/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridView : UIView
@property (nonatomic) CGPoint previousPosition;
@property (nonatomic) CGPoint latestPosition;
@property (nonatomic) BOOL isColorSet;
@end
