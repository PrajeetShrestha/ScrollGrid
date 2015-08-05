//
//  Position.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/5/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Position : NSManagedObject

@property (nonatomic, retain) NSNumber * isOccupied;
@property (nonatomic, retain) NSNumber * positionX;
@property (nonatomic, retain) NSNumber * positionY;
@property (nonatomic, retain) NSString * dancerName;
@property (nonatomic, retain) NSNumber * frameIndex;
@property (nonatomic, retain) NSNumber * positionIndex;

@end
