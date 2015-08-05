//
//  GridContainerView.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "GridContainerView.h"
#import "Position.h"
@interface GridContainerView () <GridView> {
    CGFloat gridSize;
    NSUndoManager *undoManager;
}
@property (nonatomic) NSMutableArray *dancers;
@property (nonatomic) DancerView *activeView;
@end

@implementation GridContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.grids = [NSMutableArray new];
        self.activeView = [DancerView new];
        undoManager = [NSUndoManager new];
        self.dancers = [NSMutableArray new];
        self.grids = [NSMutableArray new];
        gridSize = self.frame.size.width/11;
        [self initializeGrids];
    }
    return self;
}

//Create Grid Points in container view
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    gridSize = self.bounds.size.width/11;
    for (float i = gridSize; i < self.bounds.size.width; i += gridSize) {
        for (float j = gridSize; j < self.bounds.size.height; j += gridSize) {
            CGRect dotFrameHorizontal = CGRectMake(i, j, 2, 2);
            CGContextSetFillColorWithColor(ctx, [UIColor yellowColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectInset(dotFrameHorizontal, 0, 0));
        }
    }
}

//Create imaginary gridpoints
- (void)initializeGrids {
    int index = 0;
    for (float i = gridSize; i < self.bounds.size.width; i += gridSize) {
        for (float j = gridSize; j < self.bounds.size.height; j += gridSize) {
            CGPoint point = CGPointMake(i, j);
            if (![self isPointAlreadyStoredInGrid:point]) {
                //Default initialization of Grid
                Grid *grid = [Grid new];
                grid.position = CGPointMake(i, j);
                grid.isOccupied = NO;
                grid.content = nil;
                grid.viewTag = -1;
                grid.positionIndex = index;
                [self.grids addObject:grid];
                index ++;
            }
        }
    }
    //[self logGridPoints];
}

-(BOOL)isPointAlreadyStoredInGrid:(CGPoint)point {
    for (Grid *grd in self.grids){
        if(grd.position.x == point.x && grd.position.y == point.y) {
            return grd.isOccupied?NO:YES;
        }
    }
    return NO;
}

//For Logging purpose
- (void)logGridPoints {
    for (Grid *grid in self.grids) {
        NSLog(@"%@ Grid Position",NSStringFromCGPoint(grid.position));
    }
}

#pragma mark - Getters
- (Grid *)getGridAtIndex:(NSInteger)index {
    return self.grids[index];
}

#pragma mark - Setters
- (void)setGridAtIndex:(Grid *)grid atIndex:(NSUInteger)index{
    [self.grids replaceObjectAtIndex:index withObject:grid];
}

#pragma mark - DancerView Delegates
- (void)dancerTouchBegan {
    [self upDateGridContents];
}

- (void)dancerTouchEnd:(DancerView *)view {
    Grid *nearestUnoccupiedGrid = [self findNearestUnoccupiedGridForView:view];
    [UIView animateWithDuration:0.2 animations:^{
        if (nearestUnoccupiedGrid != nil) {
            //Undomanager setup
            [self setCenter:nearestUnoccupiedGrid.position forView:view];
            nearestUnoccupiedGrid.viewTag = view.tag;
            nearestUnoccupiedGrid.isOccupied = YES;
            nearestUnoccupiedGrid.content = view;
        }
    }];
    [self upDateGridContents];
    [self saveGridState];
    self.activeView = nil;
    //[self.delegate touchesEnd];
}

- (void)dancerMoved {
    [self upDateGridContents];
}

- (Grid *)findNearestUnoccupiedGridForView:(DancerView *)view {
    Grid *nearestUnoccupiedGrid = [Grid new];
    CGFloat distance = -1;
    for (Grid *grid in self.grids) {
        //Check if grid is occupied. If occupied ignore the grid and if unoccupied calculate the distance of all the unoccupied grid and find the minimum among it and assign to nearestUnOccupied Grid.
        if (!grid.isOccupied) {
            CGFloat xDist = (view.center.x - grid.position.x);
            CGFloat yDist = (view.center.y - grid.position.y);
            CGFloat tempDistance = sqrt((xDist * xDist) + (yDist * yDist)) ;
            if (distance == -1) {
                distance = tempDistance;
                nearestUnoccupiedGrid = grid;
            } else {
                if (tempDistance < distance) {
                    distance = tempDistance;
                    nearestUnoccupiedGrid = grid;
                }
            }
        }
    }
    return nearestUnoccupiedGrid;
}

- (void)upDateGridContents{
    for (Grid *grid in self.grids){
        BOOL isThereAnyViewInGridPosition = NO;

        for (DancerView *view in self.dancers) {
            if (view.center.x == grid.position.x && view.center.y == grid.position.y) {
                grid.content = view;
                grid.isOccupied = YES;
                grid.viewTag = view.tag;
                isThereAnyViewInGridPosition = YES;
                grid.dancerName = view.tagTitle.text;
            }
        }
        if (!isThereAnyViewInGridPosition) {
            grid.isOccupied = NO;
            grid.content = nil;
            grid.viewTag = -1;
            grid.dancerName = nil;
        }
    }
}

- (void)saveGridState {
    for (Grid *grid in self.grids){
        NSInteger index = [self.grids indexOfObject:grid];
        Position *pos;
        pos = [self fetchPositionAtIndex:index];
        if (pos == nil) {
            pos = [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
        }
        pos.positionIndex = [NSNumber numberWithInteger:index];
        pos.isOccupied = [NSNumber numberWithBool:grid.isOccupied];
        pos.positionX = [NSNumber numberWithFloat:grid.position.x];
        pos.positionY = [NSNumber numberWithFloat:grid.position.y];
        pos.dancerName = grid.dancerName;
        pos.frameIndex = [NSNumber numberWithInteger:self.containerIndex];
        [kAppDelegate saveContext];
    }

    for (Grid *grid in self.grids){
        NSInteger index = [self.grids indexOfObject:grid];
             //NSLog(@"%d INDEX ",index);
        Position *pos;
        pos = [self fetchPositionAtIndex:index];
    }
}

- (Position *)fetchPositionAtIndex:(NSInteger)index {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionIndex == %@ AND frameIndex == %@", [NSNumber numberWithInteger:index], [NSNumber numberWithInteger:self.containerIndex] ];
    [fetchRequest setPredicate:predicate];


    NSError *error = nil;
    NSArray *fetchedObjects = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {

    }
    if (fetchedObjects.count != 0) {
        return fetchedObjects[0];
    } else {
        return nil;
    }
}

#pragma mark - Undomanager Methods

- (void)setCenter:(CGPoint)newCenter forView:(DancerView *)view {

    CGPoint previousPosition = view.previousPosition;
    if (!(view.center.x == newCenter.x && view.center.y == newCenter.y) ) {
        [[undoManager prepareWithInvocationTarget:self] setCenter:previousPosition forView:view];
        [UIView animateWithDuration:0.2 animations:^{
            view.previousPosition = newCenter;
            view.center = newCenter;
        } completion:^(BOOL finished) {
            [self upDateGridContents];
        }];
    } else {
        NSLog(@"Equal");
    }
}

- (IBAction)undoMove:(id)sender {
    [undoManager undo];
}
- (IBAction)redoMove:(id)sender {
    [undoManager redo];
}

- (void)addDancer {
    if ([self canMoreViewBeAdded]) {
        CGRect dancerFrame = CGRectMake(10, 10, gridSize - 1, gridSize - 1);
        DancerView *newDancer = [[DancerView alloc]initWithFrame:dancerFrame];
        newDancer.tag = self.dancers.count;
        newDancer.delegate = self;
        [newDancer loadTagLabelWithString];
        [self addSubview:newDancer];
        [self.dancers addObject:newDancer];
        //[self addLongPressGestures];
    } else {
        NSLog(@"Move view can not be added!");
    }
}
- (void)addDancerInPositions:(NSArray *)positions previousPosition:(NSArray *)previousPositions{
    for (UIView *view in self.subviews){
        [view removeFromSuperview];
    }

    //This is for the first view
    if (previousPositions == nil) {
        for (Position *position in positions) {
            [self.dancers removeAllObjects];
            if (position.dancerName != nil) {
                CGRect dancerFrame = CGRectMake(10, 10, gridSize - 1, gridSize - 1);
                DancerView *newDancer = [[DancerView alloc]initWithFrame:dancerFrame];
                [newDancer loadTagLabel:position.dancerName];
                newDancer.delegate = self;
                //[newDancer loadTagLabelWithString];
                [newDancer setColorWhenTouchedForFirstTime];
                [self addSubview:newDancer];
                [self.dancers addObject:newDancer];
                newDancer.center = CGPointMake(position.positionX.floatValue,position.positionY.floatValue);
            }
        }
    } else {
        //For subsequent views
        [self.dancers removeAllObjects];
        for (Position *position in previousPositions) {
            if (position.dancerName != nil) {
                CGRect dancerFrame = CGRectMake(10, 10, gridSize - 1, gridSize - 1);
                DancerView *newDancer = [[DancerView alloc]initWithFrame:dancerFrame];
                [newDancer loadTagLabel:position.dancerName];
                newDancer.tagString = position.dancerName;
                newDancer.delegate = self;
                //[newDancer loadTagLabelWithString];
                [newDancer setColorWhenTouchedForFirstTime];
                [self addSubview:newDancer];
                [self.dancers addObject:newDancer];
                newDancer.center = CGPointMake(position.positionX.floatValue,position.positionY.floatValue);
            }
        }
        for (Position *position in positions) {
            for (DancerView *dancer in self.dancers) {
                if (position.dancerName != nil && [dancer.tagString isEqualToString:position.dancerName]) {
                    [UIView animateWithDuration:0.2 animations:^{
                        dancer.center = CGPointMake(position.positionX.floatValue, position.positionY.floatValue);
                    }];
                }
            }
        }
    }
}

- (void)replicateDancerAtPreviousPosition {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"frameIndex == %@",[NSNumber numberWithInteger:self.containerIndex - 1] ];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    for (Position *position in fetchedObjects) {

        if (position.isOccupied.boolValue) {
            CGRect dancerFrame = CGRectMake(10, 10, gridSize - 1, gridSize - 1);
            DancerView *newDancer = [[DancerView alloc]initWithFrame:dancerFrame];
            newDancer.tag = self.dancers.count;
            newDancer.delegate = self;
            [newDancer loadTagLabel:position.dancerName];
            [newDancer setColorWhenTouchedForFirstTime];
            [self addSubview:newDancer];
            [self.dancers addObject:newDancer];
            newDancer.center = CGPointMake(position.positionX.floatValue,position.positionY.floatValue);
        }
    }
}

- (BOOL)canMoreViewBeAdded {
    BOOL isAllSlotsOccupied = NO;
    int count = 0;
    for (Grid *grid in self.grids) {
        if (grid.isOccupied) {
            count ++;
        }
    }
    if (count == self.grids.count) {
        isAllSlotsOccupied = YES;
    }
    BOOL isAllAlphabetOccupied = NO;
    if (self.dancers.count != 26) {
        isAllAlphabetOccupied = NO;
    } else {
        isAllAlphabetOccupied = YES;
    }
    return !isAllSlotsOccupied && !isAllAlphabetOccupied;
}



@end
