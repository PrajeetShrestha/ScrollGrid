//
//  ColorPicker.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/23/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
@protocol ColorPicker <NSObject>
- (void)pickedColor:(UIColor *)color;
@end
@interface ColorPicker : UIViewController

@property (nonatomic) NSArray *colorArray;
@property (nonatomic,weak) id<ColorPicker> delegate;
@end
