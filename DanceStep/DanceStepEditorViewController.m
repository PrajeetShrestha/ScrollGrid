//
//  DanceStepEditorViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "DanceStepEditorViewController.h"
#import "GridScrollView.h"
#import "Position.h"

@interface DanceStepEditorViewController() {
}
@end
@implementation DanceStepEditorViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self clearData];
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

- (IBAction)play:(id)sender {

    GridContainerView *containerView = [[GridContainerView alloc]initWithFrame:self.gridScroller.frame];
    [self.view addSubview:containerView];
    containerView.userInteractionEnabled = NO;

    NSArray *positions = [self fetchPositions];
    NSNumber *maxFrame = [positions valueForKeyPath:@"@max.frameIndex"];
    NSMutableArray *positionsByFrame = [NSMutableArray new];
    for (int i = 0 ; i <= maxFrame.integerValue; i ++ ) {
        NSMutableArray *positionsRow = [NSMutableArray new];
        for (Position *position in positions) {
            if (position.frameIndex.integerValue == i && position.dancerName != nil) {
                [positionsRow addObject:position];
            }
        }
        [positionsByFrame addObject:positionsRow];

    }
    int counter = 0;
    for (NSArray *currentPosition in positionsByFrame){
        NSDictionary *userInfo;

        if (counter == 0) {
            userInfo = @{@"positions":currentPosition,
                         @"containerView":containerView
                         };
        }   else {
            userInfo = @{@"positions":currentPosition,
                         @"containerView":containerView,
                         @"previousPositions":positionsByFrame[counter-1]
                         };
        }

        [self startTimerWithInfo:userInfo andTime:counter * 2];
        counter ++;
    }

}

- (void) startTimerWithInfo:(NSDictionary *)userInfo andTime:(NSUInteger)timeInterval {
    [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:userInfo
                                    repeats:NO];
}

- (void) tick:(NSTimer *) timer {
    GridContainerView *containerView = timer.userInfo[@"containerView"];
    NSArray *positions = timer.userInfo[@"positions"];
    NSArray *previousPositions = timer.userInfo[@"previousPositions"];
    [containerView addDancerInPositions:positions previousPosition:previousPositions ];
}

- (void)clearData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];


    NSError *error = nil;
    NSArray *fetchedObjects = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {

    }
    for (Position *position in fetchedObjects) {
        [kAppDelegate.managedObjectContext deleteObject:position];
    }
}


- (NSArray *)fetchPositions {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];


    NSError *error = nil;
    NSArray *fetchedObjects = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    return fetchedObjects;
    
}

@end
