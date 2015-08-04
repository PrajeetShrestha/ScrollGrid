//
//  ViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/23/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "GridViewController.h"
#import "ColorPicker.h"
#import "DancerView.h"


@interface GridViewController ()<ColorPicker,GridView>
{
    float gridSize;
    NSMutableArray *alphabetArray;
    NSMutableArray *viewStates;
    NSUndoManager *undoManager;
    CGPoint previousCenter;
    __weak IBOutlet UILabel *indicator;
    BOOL viewAppearedAlready;
}
@property (nonatomic) NSMutableArray *dancers;
@property (nonatomic) NSMutableArray *selectedViews;
@property (nonatomic) DancerView *activeView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation GridViewController

#pragma mark - View Life Cycle
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    indicator.text = [NSString stringWithFormat:@"%d",self.pageIndex];
}

- (void)setUp {
    self.activeView = [DancerView new];
    undoManager = [NSUndoManager new];
    self.dancers = [NSMutableArray new];
    self.selectedViews = [NSMutableArray new];
    self.grids = [NSMutableArray new];
    viewStates = [NSMutableArray new];
    [self alphabetArray];

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify) name:NSUndoManagerCheckpointNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDancerNotification:) name:[self formatTypeToString:DNAddDancer] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verticalAlignmentNotification:) name:[self formatTypeToString:DNVerticalAlignment] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(horizontalAlignmentNotification:) name:[self formatTypeToString:DNHorizontalAlignment] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verticallyEquidistantNotification:) name:[self formatTypeToString:DNVerticallyEquidistant] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(horizontallyEquidistantNotification:) name:[self formatTypeToString:DNHorizontallyEquidistant] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(circleNotification:) name:[self formatTypeToString:DNCircle] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redoNotification:) name:[self formatTypeToString:DNRedo] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoNotification:) name:[self formatTypeToString:DNUndo] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectAllNotification:) name:[self formatTypeToString:DNSelectAll] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deSelectAllNotification:) name:[self formatTypeToString:DNDeSelectAll] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accumulateNotification:) name:[self formatTypeToString:DNAcculmulate] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickColorNotification:) name:[self formatTypeToString:DNPickColor] object:nil];
}

#pragma mark - Notifications
- (void)addDancerNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
            [self addDancer:nil];
    }
}

- (void)verticalAlignmentNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self alignVertically:nil];
    }
}

- (void)horizontalAlignmentNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self alignHorizontally:nil];
    }
}

- (void)verticallyEquidistantNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self makeEquidistantVertically:nil];
    }
}

- (void)horizontallyEquidistantNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self makeEquidistantHorizontally:nil];
    }
}

- (void)circleNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self circle:nil];
    }
}

- (void)redoNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self redoMove:nil];
    }
}

- (void)undoNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self undoMove:nil];
    }
}
- (void)selectAllNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self selectAll:nil];
    }
}

- (void)deSelectAllNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self deselectAll:nil];
    }

}

- (void)accumulateNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self accumulate:nil];
    }
}


- (void)pickColorNotification:(NSNotification *)notification {
    NSUInteger notificationIndex = [notification.object[@"index"] integerValue];
    if (notificationIndex == self.pageIndex) {
        NSLog(@"Page Index %d",self.pageIndex);
        [self colorPicker:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {


}

- (void)viewDidLayoutSubviews {
    [self createImaginaryGrid];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)addDancer:(id)sender {
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
        [self.containerView addSubview:newDancer];
        [self.dancers addObject:newDancer];
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
    CGFloat differenceAngle = (360)/self.selectedViews.count;
    differenceAngle = DEGREES_TO_RADIANS(differenceAngle);
    CGFloat initialAngle = 0;
    for (UIView *view in self.selectedViews){
        [UIView animateWithDuration:0.3 animations:^{
            view.center = CGPointMake(center.x + cos (initialAngle) * 100 , center.y + sin(initialAngle) * 100);
        }];
        initialAngle = initialAngle + differenceAngle;
    }
}
- (IBAction)selectAll:(id)sender {
    [self.selectedViews removeAllObjects];
    for (DancerView *view in self.dancers){
        [view viewStateSelected];
        [self.selectedViews addObject:view];
    }
}

- (IBAction)deselectAll:(id)sender {
    for (DancerView *view in self.dancers){
        [view viewStateDeselected];
        [self.selectedViews removeObject:view];
    }
}

- (IBAction)accumulate:(id)sender {
    [self alignHorizontally:nil];
    [self alignVertically:nil];
}

- (IBAction)colorPicker:(id)sender {
    [self performSegueWithIdentifier:@"PickColor" sender:nil];
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
    
    [self upDateGridContents];
    
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
    DancerView *view = self.activeView  ;
    if ([self.selectedViews containsObject:view]) {
        [view viewStateDeselected];
        [self.selectedViews removeObject:view];
    } else {
        [view viewStateSelected];
        [self.selectedViews addObject:view];
    }

    [UIView animateWithDuration:0.2 animations:^{
        self.activeView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

#pragma mark - GridView Delegate
- (void)dancerTouchBegan {
    [self upDateGridContents];
    [self.delegate touchesBegan];
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
    [self.delegate touchesEnd];
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

#pragma mark - Private Methods

- (BOOL)isActiveViewMovable {
    if ([self.dancers containsObject:self.activeView]) {
        return YES;
    } else {
        return NO;
    }
}

// To make view draggable on move touch event

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
    if (self.dancers.count != 26) {
        isAllAlphabetOccupied = NO;
    } else {
        isAllAlphabetOccupied = YES;
    }
    return !isAllSlotsOccupied && !isAllAlphabetOccupied;
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
    gridSize = self.containerView.bounds.size.width/11;
    for (float i = gridSize; i < self.containerView.bounds.size.width; i += gridSize) {
        for (float j = gridSize; j < self.containerView.bounds.size.height; j += gridSize) {
            CGRect dotFrameHorizontal = CGRectMake(i, j, 2, 2);
            CGContextSetFillColorWithColor(ctx, [UIColor groupTableViewBackgroundColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectInset(dotFrameHorizontal, 0, 0));
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
    self.containerView.layer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ColorPicker *viewController = (ColorPicker *)segue.destinationViewController;
    viewController.delegate = self;

}

- (NSString*)formatTypeToString:(DancerActionNotifications)formatType {
    NSString *result = nil;
    NSLog(@"%u FORMAT TYPE ",formatType);
    switch(formatType) {
        case DNAddDancer:
            result = @"DNAddDancer";
            break;
        case DNVerticalAlignment:
            result = @"DNVerticalAlignment";
            break;
        case DNHorizontalAlignment:
            result = @"DNHorizontalAlignment";
            break;
        case DNVerticallyEquidistant:
            result = @"DNVerticallyEquidistant";
            break;
        case DNHorizontallyEquidistant:
            result = @"DNHorizontallyEquidistant";
            break;
        case DNCircle:
            result = @"DNCircle";
            break;
        case DNRedo:
            result = @"DNRedo";
            break;
        case DNUndo:
            result = @"DNUndo";
            break;
        case DNSelectAll:
            result = @"DNSelectAll";
            break;
        case DNDeSelectAll:
            result = @"DNDeSelectAll";
            break;
        case DNAcculmulate:
            result = @"DNAcculmulate";
            break;
        case DNPickColor:
            result = @"DNPickColor";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }

    return result;
}


@end
