//
//  Constant.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/30/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#ifndef DanceStep_Constant_h
#define DanceStep_Constant_h
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

typedef enum DancerActionNotifications {
    DNAddDancer,
    DNVerticalAlignment,
    DNHorizontalAlignment,
    DNVerticallyEquidistant,
    DNHorizontallyEquidistant,
    DNCircle,
    DNRedo,
    DNUndo,
    DNSelectAll,
    DNDeSelectAll,
    DNAcculmulate,
    DNPickColor
} DancerActionNotifications;
#endif
