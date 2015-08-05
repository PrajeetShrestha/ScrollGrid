//
//  Grid.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/28/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Grid : NSObject
@property (nonatomic) BOOL isOccupied;
@property (nonatomic) CGPoint position;
@property (nonatomic) NSInteger positionIndex;
@property (nonatomic) id content;
@property (nonatomic) NSInteger viewTag;
@property (nonatomic) NSString *dancerName;

- (BOOL)isEquivalentTo:(Grid *)grid;
- (void) logContent;
@end
