//
//  ViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/23/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "ViewController.h"
#import "ColorPicker.h"
#import "GridView.h"


@interface ViewController ()<ColorPicker>
{
    float gridSize;
    NSMutableArray *alphabetArray;
    NSMutableArray *viewStates;
    NSUndoManager *undoManager;
    CGPoint previousCenter;
}
@property (nonatomic) NSMutableArray *movableViews;
@property (nonatomic) NSMutableArray *selectedViews;
@property (nonatomic) GridView *activeView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation ViewController

#pragma mark - View Life Cycle
-(void)viewDidLoad {
    [super viewDidLoad];
    self.activeView = [GridView new];
    undoManager = [NSUndoManager new];
    self.movableViews = [NSMutableArray new];
    self.selectedViews = [NSMutableArray new];
    self.grids = [NSMutableArray new];
    viewStates = [NSMutableArray new];
    [self alphabetArray];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify) name:NSUndoManagerCheckpointNotification object:nil];
}

- (void)notify {
    //NSLog(@"Notification received");
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self createImaginaryGrid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)addDancer:(id)sender {
    if ([self canMoreViewBeAdded]) {
        GridView *newDancer = [[GridView alloc]initWithFrame:CGRectMake(10, 10, gridSize-1, gridSize-1)];
        newDancer.backgroundColor = [UIColor orangeColor];
        newDancer.tag = self.movableViews.count;
        newDancer.layer.cornerRadius = newDancer.frame.size.width/2;
        newDancer.clipsToBounds = YES;
        newDancer.alpha = 0.8f;

        UILabel *viewLabel = [[UILabel alloc]init];
        viewLabel.text = alphabetArray[newDancer.tag];//[NSString stringWithFormat:@"%ld",(long)newDancer.tag];
        [viewLabel sizeToFit];
        viewLabel.textColor = [UIColor whiteColor];
        viewLabel.center = CGPointMake(newDancer.bounds.size.width/2, newDancer.bounds.size.height/2);
        [newDancer addSubview:viewLabel];
        [self.containerView addSubview:newDancer];
        [self.movableViews addObject:newDancer];
        [self addLongPressGestures];
    } else {
        NSLog(@"Move view can not be added!");
    }
}

- (IBAction)alignVertically:(id)sender {
    __block CGFloat topmostYPosition = 0;
    for (UIView *view in self.selectedViews) {
        //Find the topmost view first
        if (topmostYPosition == 0) {
            topmostYPosition = view.center.y;
        }
        if (view.center.y < topmostYPosition) {
            topmostYPosition = view.center.y;
        }
    }

    for (UIView *view in self.selectedViews){
        if (view.center.y != topmostYPosition) {
            [UIView animateWithDuration:0.3 animations:^{
                view.center = CGPointMake(view.center.x, topmostYPosition);

            }];
        }
    }
    //[self clearSelectedViews];
}
- (IBAction)alignHorizontally:(id)sender {

    __block CGFloat leftMostXposition = 0;
    for (UIView *view in self.selectedViews) {
        //Find the topmost view first
        if (leftMostXposition == 0) {
            leftMostXposition = view.center.x;
        }
        if (view.center.x < leftMostXposition) {
            leftMostXposition = view.center.x;
        }
    }

    for (UIView *view in self.selectedViews){
        if (view.center.x != leftMostXposition) {
            [UIView animateWithDuration:0.3 animations:^{
                view.center = CGPointMake(leftMostXposition, view.center.y);
            }];
        }
    }
    //[self clearSelectedViews];
}


- (IBAction)makeEquidistantVertically:(id)sender {
    NSMutableArray *arrayOfYPosition = [NSMutableArray new];
    //Sort Views based on vertical distance from top
    for (UIView *view in self.selectedViews){
        [arrayOfYPosition addObject:[NSNumber numberWithDouble:view.center.y]];
    }

    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [arrayOfYPosition sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    NSMutableArray *sortedView = [NSMutableArray new];
    for (NSNumber *yPos in arrayOfYPosition){
        for (UIView *view in self.selectedViews){
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

- (IBAction)makeEquidistantHorizontally:(id)sender {
    NSMutableArray *arrayOfYPosition = [NSMutableArray new];
    //Sort Views based on vertical distance from top
    for (UIView *view in self.selectedViews){
        [arrayOfYPosition addObject:[NSNumber numberWithDouble:view.center.x]];
    }

    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [arrayOfYPosition sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    NSMutableArray *sortedView = [NSMutableArray new];
    for (NSNumber *xPos in arrayOfYPosition){
        for (UIView *view in self.selectedViews){

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
- (IBAction)circle:(id)sender {
    CGPoint center = CGPointMake(self.containerView.bounds.size.width/2, self.containerView.bounds.size.height/2);
    //NSLog(@"%@ Rectangle Point %@",NSStringFromCGRect(self.containerView.frame),NSStringFromCGPoint(self.containerView.center));
    CGFloat differenceAngle = (360)/self.selectedViews.count;
    differenceAngle = DEGREES_TO_RADIANS(differenceAngle);
    CGFloat initialAngle = 0;
    for (UIView *view in self.selectedViews){
        [UIView animateWithDuration:0.3 animations:^{
            view.center = CGPointMake(center.x + cos (initialAngle) * 50 , center.y + sin(initialAngle) * 50);
        }];
        initialAngle = initialAngle + differenceAngle;
    }
}
- (IBAction)selectAll:(id)sender {
    [self.selectedViews removeAllObjects];
    for (UIView *view in self.movableViews){
        view.layer.borderColor = [UIColor blueColor].CGColor;
        view.layer.borderWidth = 2.0f;
        [self.selectedViews addObject:view];
    }
}

- (IBAction)deselectAll:(id)sender {
    for (UIView *view in self.movableViews){
        view.layer.borderColor = [UIColor clearColor].CGColor;
        view.layer.borderWidth = 0.0f;
        [self.selectedViews removeObject:view];
    }
}

- (IBAction)accumulate:(id)sender {
    [self alignHorizontally:nil];
    [self alignVertically:nil];
}

- (IBAction)colorPicker:(id)sender {
}
- (void)pickedColor:(UIColor *)color {
    for (UIView *view in self.selectedViews){
        view.backgroundColor = color;
    }
}

- (IBAction)changePositions:(id)sender {

    NSArray *animationSequence = @[@{@"startGrid":self.grids[0],
                                     @"destinationGrid":self.grids[4]
                                     },
                                   @{@"startGrid":self.grids[4],
                                     @"destinationGrid":self.grids[10]
                                     },
                                   @{@"startGrid":self.grids[5],
                                     @"destinationGrid":self.grids[11]
                                     },
                                   @{@"startGrid":self.grids[2],
                                     @"destinationGrid":self.grids[3]
                                     },
                                   @{@"startGrid":self.grids[6],
                                     @"destinationGrid":self.grids[14]
                                     },
                                   @{@"startGrid":self.grids[7],
                                     @"destinationGrid":self.grids[8]
                                     }
                                   ];
    for (NSDictionary *dic in animationSequence){
        [self shiftGridContentOf:dic[@"startGrid"] toNewPosition:dic[@"destinationGrid"]];
    }
    
    [self upDateGridContents:self.grids];
    
}

#pragma mark - Gestures
- (void)addLongPressGestures {
    }

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Double Tapped");
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {

    }
}

- (void)selectView {
    UIView *view = self.activeView  ;
    if ([self.selectedViews containsObject:view]) {
        view.layer.borderColor = [UIColor clearColor].CGColor;
        view.layer.borderWidth = 0.0f;
        [self.selectedViews removeObject:view];
    } else {
        view.layer.borderColor = [UIColor blueColor].CGColor;
        view.layer.borderWidth = 2.0f;
        [self.selectedViews addObject:view];
    }

    [UIView animateWithDuration:0.2 animations:^{
        self.activeView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

#pragma mark - Touch Delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches){
        if (self.activeView == nil) {
            self.activeView = (GridView *)[touch view];
            if ([self isViewMovable]) {
                self.activeView.previousPosition = self.activeView.center;
                [UIView animateWithDuration:0.2 animations:^{
                    self.activeView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                    if(!self.activeView.isColorSet) {
                        self.activeView.backgroundColor = [UIColor blackColor];
                        self.activeView.isColorSet = YES;
                    }
                    self.activeView.alpha = 1.0f;
                }];
//                [self upDateGridContents:self.grids];
                for (Grid *grid in self.grids){
                    if ([grid.content isEqual:self.activeView]) {
                        grid.isOccupied = NO;
                    }
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Enumerates through all touch objects
    for (UITouch *touch in touches) {

        if (self.activeView == nil) {
            self.activeView = (GridView *)[touch view];
        } else {
            if ([self isViewMovable]) {
                [self dispatchTouchEvent:self.activeView toPosition:[touch locationInView:self.containerView]];
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.2 animations:^{
        self.activeView.transform = CGAffineTransformMakeScale(1, 1);
    }];

    //Snap to Grid
    if ([self isViewMovable]) {
        CGFloat distance = 0;
        Grid *nearestUnoccupiedGrid = [Grid new];
        for (Grid *grid in self.grids) {
            if (!grid.isOccupied) {
                CGFloat xDist = (self.activeView.center.x - grid.position.x);
                CGFloat yDist = (self.activeView.center.y - grid.position.y);
                CGFloat tempDistance = sqrt((xDist * xDist) + (yDist * yDist)) ;
                if (distance == 0) {
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

        [UIView animateWithDuration:0.2 animations:^{
            if (nearestUnoccupiedGrid != nil) {
                [self setCenter:nearestUnoccupiedGrid.position forView:self.activeView];
                //self.activeView.center = nearestUnoccupiedGrid.position;
                nearestUnoccupiedGrid.viewTag = self.activeView.tag;
                nearestUnoccupiedGrid.isOccupied = YES;
                nearestUnoccupiedGrid.content = self.activeView;
                // NSLog(@"Transcendenting to %@ %d %d",NSStringFromCGPoint(nearestUnoccupiedGrid.position),nearestUnoccupiedGrid.isOccupied,self.activeView.tag);
            }
        }];
        [self upDateGridContents:self.grids];
    }
    //Snap End
    self.activeView = nil;

}

#pragma mark - Undomanager Methods


- (void)setCenter:(CGPoint)newCenter forView:(GridView *)view {

    CGPoint currentCenter = view.previousPosition;
    if (!(view.center.x == newCenter.x && view.center.y == newCenter.y) ) {
        [[undoManager prepareWithInvocationTarget:self] setCenter:currentCenter forView:view];
        [UIView animateWithDuration:0.2 animations:^{
            view.previousPosition = newCenter;
            view.center = newCenter;
        } completion:^(BOOL finished) {
            [self upDateGridContents:self.grids];
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

#pragma mark - Private Methods

- (BOOL)isViewMovable {
    if ([self.movableViews containsObject:self.activeView]) {
        return YES;
    } else {
        return NO;
    }
}

// To make view draggable on move touch event
-(void)dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position
{
    // Check to see which view, or views,  the point is in and then move to that position.
    if (CGRectContainsPoint([self.activeView frame], position)) {
        self.activeView.center = position;
    }
}
- (void)clearSelectedViews {
    for (UIView *view in self.selectedViews){
        view.layer.borderColor = [UIColor clearColor].CGColor;
        view.layer.borderWidth = 0.0f;
    }
    [self.selectedViews removeAllObjects];
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
    if (self.movableViews.count != 26) {
        isAllAlphabetOccupied = NO;
    } else {
        isAllAlphabetOccupied = YES;
    }
    return !isAllSlotsOccupied && !isAllAlphabetOccupied;
}



-(BOOL)isPointAlreadyStoredInGrid:(CGPoint)point {
    for (Grid *grd in self.grids){
        if(grd.position.x == point.x && grd.position.y == point.y) {
            return YES;
        }
    }
    return NO;
}

- (void)shiftGridContentOf:(Grid *)initGrid toNewPosition:(Grid *)destGrid {
    if (initGrid.content != nil) {
        UIView *viewReference = (UIView *)initGrid.content;
        [UIView animateWithDuration:0.3 animations:^{
            if (destGrid.isOccupied) {
                NSLog(@"Destination grid has already content can't move");
            } else {
                viewReference.center = destGrid.position;
            }
        }];
    }
}

- (void)upDateGridContents:(NSMutableArray *)gridColleciton {
           NSLog(@"New start");
    for (Grid *grid in self.grids){
        BOOL isThereAnyViewInGridPosition = NO;
        for (GridView *view in self.movableViews) {
            if (view.center.x == grid.position.x && view.center.y == grid.position.y) {
                grid.content = view;
                grid.isOccupied = YES;
                grid.viewTag = view.tag;
                isThereAnyViewInGridPosition = YES;
            }
        }
        if (!isThereAnyViewInGridPosition) {
            grid.isOccupied = NO;
            grid.content = nil;
            grid.viewTag = -1;
        }

        NSLog(@"Grid %hhd ",grid.isOccupied);
    }
}

- (void)alphabetArray {
    alphabetArray = [NSMutableArray new];
    for (char a = 'A'; a <= 'Z'; a++)
    {
        [alphabetArray addObject:[NSString stringWithFormat:@"%c", a]];
    }
}
//Plot the grid as a image in containerViewLayer's content
- (void)createImaginaryGrid {
    UIGraphicsBeginImageContextWithOptions(self.containerView.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    gridSize = self.containerView.bounds.size.width/4;
    for (float i = gridSize; i < self.containerView.bounds.size.width; i += gridSize) {
        for (float j = gridSize; j < self.containerView.bounds.size.height; j += gridSize) {
            CGRect dotFrameHorizontal = CGRectMake(i, j, 2, 2);
            CGContextSetFillColorWithColor(ctx, [UIColor groupTableViewBackgroundColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectInset(dotFrameHorizontal, 0, 0));
            CGPoint point = CGPointMake(i, j);
            //
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
    self.containerView.layer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
}




#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ColorPicker *viewController = (ColorPicker *)segue.destinationViewController;
    viewController.delegate = self;
    
}
@end
