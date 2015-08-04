//
//  GridContainerView.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "GridContainerView.h"
@interface GridContainerView ()<GridView> {
    CGFloat gridSize;
    NSUndoManager *undoManager;
    NSMutableArray *alphabetArray;
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
        [self setAlphabetArray];
        [self initializeGrids];
    }
    return self;
}

- (void)setAlphabetArray {
    alphabetArray = [NSMutableArray new];
    for (char a = 'A'; a <= 'Z'; a++)
    {
        [alphabetArray addObject:[NSString stringWithFormat:@"%c", a]];
    }
}

//Create Grid Points in container view
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    gridSize = self.bounds.size.width/11;
    for (float i = gridSize; i < self.bounds.size.width; i += gridSize) {
        for (float j = gridSize; j < self.bounds.size.height; j += gridSize) {
            CGRect dotFrameHorizontal = CGRectMake(i, j, 2, 2);
            CGContextSetFillColorWithColor(ctx, [UIColor groupTableViewBackgroundColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectInset(dotFrameHorizontal, 0, 0));
        }
    }
}

//Create imaginary gridpoints
- (void)initializeGrids {

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
                [self.grids addObject:grid];
            }
        }
    }
    //[self logGridPoints];
}

-(BOOL)isPointAlreadyStoredInGrid:(CGPoint)point {
    for (Grid *grd in self.grids){
        if(grd.position.x == point.x && grd.position.y == point.y) {
            if (grd.isOccupied ) {
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (void)logGridPoints {
    for (Grid *grid in self.grids) {
        NSLog(@"%@ Grid Position",NSStringFromCGPoint(grid.position));
    }
}



#pragma mark - Getters
- (Grid *)getGridAtIndex:(NSUInteger)index {
    return self.grids[index];
}

#pragma mark - Setters
- (void)setGridAtIndex:(Grid *)grid atIndex:(NSUInteger)index{
    [self.grids replaceObjectAtIndex:index withObject:grid];
}

#pragma mark - DancerView Delegates
- (void)dancerTouchBegan {
    [self upDateGridContents];
    //[self.delegate touchesBegan];
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
                grid.dancerTag = view.dancerTag;
            }
        }
        if (!isThereAnyViewInGridPosition) {
            grid.isOccupied = NO;
            grid.content = nil;
            grid.viewTag = -1;
            grid.dancerTag = nil;
        }
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
        DancerView *newDancer = [[DancerView alloc]initWithFrame:CGRectMake(10, 10, gridSize-1, gridSize-1)];
        newDancer.backgroundColor = [UIColor orangeColor];
        newDancer.tag = self.dancers.count;
        newDancer.layer.cornerRadius = newDancer.frame.size.width/2;
        newDancer.clipsToBounds = YES;
        newDancer.alpha = 0.8f;
        newDancer.delegate = self;

        UILabel *viewLabel = [[UILabel alloc]init];
        viewLabel.text = alphabetArray[newDancer.tag];
        newDancer.dancerTag = viewLabel.text;
        [viewLabel sizeToFit];
        viewLabel.textColor = [UIColor whiteColor];
        viewLabel.center = CGPointMake(newDancer.bounds.size.width/2, newDancer.bounds.size.height/2);
        [newDancer addSubview:viewLabel];
        newDancer.tagTitle = viewLabel;
        [self addSubview:newDancer];
        [self.dancers addObject:newDancer];
        //[self addLongPressGestures];
    } else {
        NSLog(@"Move view can not be added!");
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
