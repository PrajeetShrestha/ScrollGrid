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
@property (nonatomic) CGRect dancerFrame;
@property (nonatomic) NSMutableArray *selectedDancers;
@end

@implementation GridContainerView

#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self allocateMemoryForProperties];
        gridSize = self.frame.size.width/11;
        [self initializeGrids];
    }
    return self;
}

- (void)allocateMemoryForProperties {
    self.grids = [NSMutableArray new];
    self.activeView = [DancerView new];
    self.dancers = [NSMutableArray new];
    self.grids = [NSMutableArray new];
    self.selectedDancers = [NSMutableArray new];
    undoManager = [NSUndoManager new];
}

//Create Grid Points in container view
- (void)drawRect:(CGRect)rect {
    self.dancerFrame = CGRectMake(10, 10, gridSize - 1, gridSize - 1);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //Dividing width by 11 will create 10 columns in a grid
    gridSize = self.bounds.size.width/11;

    //This is to create grid dots
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
                Grid *grid = [[Grid alloc]initGridWithPosition:CGPointMake(i,j)
                                              andPositionIndex:index];
                [self.grids addObject:grid];
                index ++;
            }
        }
    }
    //[self logGridPoints];
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
    [self animateView:view toGrid:nearestUnoccupiedGrid];
    [self upDateGridContents];
    [self saveGridState];
    self.activeView = nil;
}

- (void)dancerMoved {
    [self upDateGridContents];
}

#pragma mark - Undomanager

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

- (void)undoMove {
    [undoManager undo];
}
- (void)redoMove {
    [undoManager redo];
}
#pragma mark - Public
- (void)addDancer {
    if ([self canMoreViewBeAdded]) {
        DancerView *newDancer = [[DancerView alloc]initWithFrame:self.dancerFrame
                                                     andDelegate:self];
        newDancer.tag = self.dancers.count;
        [newDancer loadTagLabelWithString];
        [self addSubview:newDancer];
        [self.dancers addObject:newDancer];
    } else {
        NSLog(@"Move view can not be added!");
    }
}

- (void)addDancerInPositions:(NSArray *)positions previousPosition:(NSArray *)previousPositions{
    [self removeAllSubViewsAndClearDancerArray];
    //If previousPosition is empty means it's the first grid of editor view.
    if (previousPositions == nil) {
        //LoaddancersForFirstGrid.
        [self loadDancerInPositions:positions];
    } else {
        //LoadDancersForSubsequentGrid
        [self loadDancerInPositions:previousPositions];
        [self animateDancerPositionToNewPosition:positions];
    }
}

- (void)replicateDancerAtPreviousPosition {
    NSArray *positions = [self fetchPreviousFramePositions];
    [self loadDancerInPositions:positions];
}

- (void)alignVertically {
    __block CGFloat topmostYPosition = 0;
    for (UIView *view in self.selectedDancers) {
        //Find the topmost view first
        if (topmostYPosition == 0) {
            topmostYPosition = view.center.y;
        }
        if (view.center.y < topmostYPosition) {
            topmostYPosition = view.center.y;
        }
    }

    for (UIView *view in self.selectedDancers){
        if (view.center.y != topmostYPosition) {
            [UIView animateWithDuration:0.3 animations:^{
                view.center = CGPointMake(view.center.x, topmostYPosition);

            }];
        }
    }
    //[self clearSelectedViews];
}
- (void)alignHorizontally{

    __block CGFloat leftMostXposition = 0;
    for (UIView *view in self.selectedDancers) {
        //Find the topmost view first
        if (leftMostXposition == 0) {
            leftMostXposition = view.center.x;
        }
        if (view.center.x < leftMostXposition) {
            leftMostXposition = view.center.x;
        }
    }

    for (UIView *view in self.selectedDancers){
        if (view.center.x != leftMostXposition) {
            [UIView animateWithDuration:0.3 animations:^{
                view.center = CGPointMake(leftMostXposition, view.center.y);
            }];
        }
    }
    //[self clearSelectedViews];
}

- (void)selectAll {
    [self.selectedDancers removeAllObjects];
    for (DancerView *view in self.dancers){
        [view viewStateSelected];
        [self.selectedDancers addObject:view];
    }
}

- (void)deselectAll {
    for (DancerView *view in self.dancers){
        [view viewStateDeselected];
        [self.selectedDancers removeObject:view];
    }
}

- (void)equiDistant {

    [self makeEquidistantHorizontally];
    [self makeEquidistantVertically];
    
}

- (void)makeEquidistantVertically {
    NSMutableArray *arrayOfYPosition = [NSMutableArray new];
    //Sort Views based on vertical distance from top
    for (UIView *view in self.selectedDancers){
        [arrayOfYPosition addObject:[NSNumber numberWithDouble:view.center.y]];
    }

    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [arrayOfYPosition sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    NSMutableArray *sortedView = [NSMutableArray new];
    for (NSNumber *yPos in arrayOfYPosition){
        for (UIView *view in self.selectedDancers){
            if (view.center.y == yPos.doubleValue && ![sortedView containsObject:view]) {

                [sortedView addObject:view];
                break;
            }
        }
    }
    UIView *sampleView = [sortedView firstObject];
    CGFloat distantBetweenViews = gridSize;
    CGFloat positionOfFirstView = sampleView.center.y;
    int count = 0 ;
    for (UIView *view in sortedView){
        //if (![view isEqual:[sortedView firstObject]]) {
        [UIView animateWithDuration:0.3 animations:^{
            view.center = CGPointMake(view.center.x, positionOfFirstView + (distantBetweenViews * count));
        }];
        //}
        count ++;
    }
}

- (void)makeEquidistantHorizontally {
    NSMutableArray *arrayOfYPosition = [NSMutableArray new];
    //Sort Views based on vertical distance from top
    for (UIView *view in self.selectedDancers){
        [arrayOfYPosition addObject:[NSNumber numberWithDouble:view.center.x]];
    }

    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [arrayOfYPosition sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    NSMutableArray *sortedView = [NSMutableArray new];
    for (NSNumber *xPos in arrayOfYPosition){
        for (UIView *view in self.selectedDancers){

            if (![sortedView containsObject:view] && view.center.x == xPos.doubleValue) {
                [sortedView addObject:view];
                break;
            }
        }
    }
    UIView *sampleView = [sortedView firstObject];
    CGFloat distantBetweenViews = gridSize;
    CGFloat positionOfFirstView = sampleView.center.x;
    int count = 0 ;
    for (UIView *view in sortedView){
        //if (![view isEqual:[sortedView firstObject]]) {
        [UIView animateWithDuration:0.3 animations:^{
            view.center = CGPointMake(positionOfFirstView + (distantBetweenViews * count),view.center.y );
        }];
        //}
        count ++;
    }
}

#pragma mark - Private
- (void)loadDancerInPositions:(NSArray *)positions {
      self.dancerFrame = CGRectMake(10, 10, gridSize - 1, gridSize - 1);
    for (Position *position in positions) {
        if (position.dancerName != nil) {
            DancerView *newDancer = [[DancerView alloc]initWithFrame:self.dancerFrame
                                                         andDelegate:self];
            [newDancer loadTagLabel:position.dancerName];
             newDancer.tagString = position.dancerName;
            [newDancer setColorWhenTouchedForFirstTime];
            newDancer.center = CGPointMake(position.positionX.floatValue,position.positionY.floatValue);
            [self addSubview:newDancer];
            [self.dancers addObject:newDancer];
        }
    }
}

- (void)animateDancerPositionToNewPosition:(NSArray *)positions {
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

- (NSArray *)fetchPreviousFramePositions {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"frameIndex == %@",[NSNumber numberWithInteger:self.containerIndex - 1] ];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

//Method to check if more dancers could be added in the container.
//More dancers couldn't be added if all slots in the container are
//occupied or the dancer upto tagName 'Z' are added in the screen.
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

- (void)removeAllSubViewsAndClearDancerArray {
    for (UIView *view in self.subviews){
        [view removeFromSuperview];
        
    }
    [self.dancers removeAllObjects];
}

-(BOOL)isPointAlreadyStoredInGrid:(CGPoint)point {
    for (Grid *grd in self.grids){
        if(grd.position.x == point.x && grd.position.y == point.y) {
            return grd.isOccupied?NO:YES;
        }
    }
    return NO;
}

//???:
- (void)logGridPoints {
    for (Grid *grid in self.grids) {
        NSLog(@"%@ Grid Position",NSStringFromCGPoint(grid.position));
    }
}

- (void)animateView:(DancerView *)view toGrid:(Grid *)nearestUnoccupiedGrid {
    [UIView animateWithDuration:0.2 animations:^{
        if (nearestUnoccupiedGrid != nil) {
            //Undomanager setup
            [self setCenter:nearestUnoccupiedGrid.position forView:view];
            nearestUnoccupiedGrid.viewTag = view.tag;
            nearestUnoccupiedGrid.isOccupied = YES;
            nearestUnoccupiedGrid.content = view;
        }
    }];
}

- (Grid *)findNearestUnoccupiedGridForView:(DancerView *)view {
    Grid *nearestUnoccupiedGrid = [Grid new];
    CGFloat distance = -1;
    for (Grid *grid in self.grids) {
        //Check if grid is occupied. If occupied ignore the grid and if unoccupied calculate
        //the distance of all the unoccupied grid and find the minimum among it and assign to nearestUnOccupied Grid.
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
                grid.content    = view;
                grid.isOccupied = YES;
                grid.viewTag    = view.tag;
                grid.dancerName = view.tagTitle.text;

                isThereAnyViewInGridPosition = YES;
            }
        }

        if (!isThereAnyViewInGridPosition) {
            [grid resetGridProperties];
        }
    }
}

- (void)saveGridState {
    //Loop through all thre grids and check if it's stored in coreData if it's not store it if it's already stored update the content.
    for (Grid *grid in self.grids){
        NSInteger index = [self.grids indexOfObject:grid];
        Position *pos;
        pos = [self fetchPositionAtIndex:index];
        if (pos == nil) {
            pos = [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
        }
        pos.positionIndex = [NSNumber numberWithInteger:index];
        pos.isOccupied    = [NSNumber numberWithBool:grid.isOccupied];
        pos.positionX     = [NSNumber numberWithFloat:grid.position.x];
        pos.positionY     = [NSNumber numberWithFloat:grid.position.y];
        pos.dancerName    = grid.dancerName;
        pos.frameIndex    = [NSNumber numberWithInteger:self.containerIndex];
        [kAppDelegate saveContext];
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
    if (fetchedObjects.count != 0 && fetchedObjects != nil) {
        return fetchedObjects[0];
    } else {
        return nil;
    }
}

- (void)selectView {
    DancerView *view = self.activeView  ;
    if ([self.selectedDancers containsObject:view]) {
        [view viewStateDeselected];
        [self.selectedDancers removeObject:view];
    } else {
        [view viewStateSelected];
        [self.selectedDancers addObject:view];
    }

    [UIView animateWithDuration:0.2 animations:^{
        self.activeView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}
- (void)clearSelectedDancers {
    for (UIView *view in self.selectedDancers){
        view.layer.borderColor = [UIColor clearColor].CGColor;
        view.layer.borderWidth = 0.0f;
    }
    [self.selectedDancers removeAllObjects];
}


@end
