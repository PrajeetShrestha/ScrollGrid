//
//  ViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/23/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "ViewController.h"
#import "ColorPicker.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@interface ViewController ()<ColorPicker>
{
    NSMutableArray *gridPoints;
}
@property (nonatomic) NSMutableArray *movableViews;

@property (nonatomic) NSMutableArray *selectedViews;
@property (nonatomic) UIView *activeView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation ViewController
-(void)viewDidLoad {
    [super viewDidLoad];
    self.movableViews = [NSMutableArray new];
    self.selectedViews = [NSMutableArray new];

    [self createImaginaryGrid];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addLongPressGestures {
    for (UIView *aView in self.movableViews){

        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
        lpgr.minimumPressDuration = 0.3;
        [aView addGestureRecognizer:lpgr];

        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doubleTapped:)];
        doubleTap.numberOfTapsRequired = 2;
        [aView addGestureRecognizer:doubleTap];

    }
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Double Tapped");
}



- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIView *view = [sender view];
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

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches){
        if (self.activeView == nil) {
            self.activeView = [touch view];
            if ([self isViewMovable]) {

                [UIView animateWithDuration:0.2 animations:^{
                    self.activeView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                }];
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
            self.activeView = [touch view];
        } else {
            if ([self isViewMovable]) {
                [self dispatchTouchEvent:self.activeView toPosition:[touch locationInView:self.containerView]];
            }
        }
    }
}

- (BOOL)isViewMovable {
    if ([self.movableViews containsObject:self.activeView]) {
        return YES;
    } else {
        return NO;
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
        CGPoint nearestPoint;
        //BOOL isViewOverLappedInPoint = NO;
        for (NSDictionary *dictionary in gridPoints) {
            //CGFloat xPos = dictionary[@"x"]
            CGPoint point = CGPointMake([dictionary[@"x"] floatValue], [dictionary[@"y"] floatValue]);

            //Calculate near points
            CGFloat xDist = (self.activeView.center.x - point.x);
            CGFloat yDist = (self.activeView.center.y - point.y);
            CGFloat tempDistance = sqrt((xDist * xDist) + (yDist * yDist)) ;

            if (distance == 0) {
                distance = tempDistance;
                nearestPoint = CGPointMake([dictionary[@"x"] floatValue], [dictionary[@"y"] floatValue]);
            }
            if (tempDistance < distance) {
                nearestPoint = CGPointMake([dictionary[@"x"] floatValue], [dictionary[@"y"] floatValue]);
                distance = tempDistance;

                NSLog(@"Stored NearestPoint %@",NSStringFromCGPoint(nearestPoint));
            }
        }

        if (distance != 0) {

            [UIView animateWithDuration:0.3 animations:^{
                self.activeView.center = nearestPoint;
            }];
            NSLog(@"Distance = %f Point = %@",distance,NSStringFromCGPoint(nearestPoint));

        }
    }

    //Snap ENd test
    self.activeView = nil;

}

-(void)dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position
{
    // Check to see which view, or views,  the point is in and then move to that position.
    if (CGRectContainsPoint([self.activeView frame], position)) {
        self.activeView.center = position;
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

- (void)clearSelectedViews {

    for (UIView *view in self.selectedViews){
        view.layer.borderColor = [UIColor clearColor].CGColor;
        view.layer.borderWidth = 0.0f;

    }
    [self.selectedViews removeAllObjects];


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
    CGFloat distantBetweenViews = 40 + sampleView.frame.size.height/2;
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
    CGFloat distantBetweenViews = 40 + sampleView.frame.size.width/2;
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
    NSLog(@"%@ Rectangle Point %@",NSStringFromCGRect(self.containerView.frame),NSStringFromCGPoint(self.containerView.center));
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ColorPicker *viewController = (ColorPicker *)segue.destinationViewController;
    viewController.delegate = self;

}
- (IBAction)addDancer:(id)sender {
    UIView *newDancer = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 30, 30)];
    newDancer.backgroundColor = [UIColor blackColor];
    newDancer.tag = self.movableViews.count;
    newDancer.layer.cornerRadius = newDancer.frame.size.width/2;
    newDancer.clipsToBounds = YES;
    UILabel *viewTag = [[UILabel alloc]init];
    viewTag.text = [NSString stringWithFormat:@"%ld",(long)newDancer.tag];
    [viewTag sizeToFit];
    viewTag.textColor = [UIColor whiteColor];
    viewTag.center = CGPointMake(newDancer.bounds.size.width/2, newDancer.bounds.size.height/2);
    [newDancer addSubview:viewTag];
    [self.containerView addSubview:newDancer];

    [self.movableViews addObject:newDancer];
    [self addLongPressGestures];
}

- (void)createImaginaryGrid {
    gridPoints = [NSMutableArray new];
    UIGraphicsBeginImageContextWithOptions(self.containerView.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    int gridSize = 28;
    for (int i = gridSize; i < self.containerView.bounds.size.width; i += gridSize) {
        for (int j = gridSize; j < self.containerView.bounds.size.height; j += gridSize) {
            CGRect dotFrameHorizontal = CGRectMake(i, j, 3, 3);
            CGContextSetFillColorWithColor(ctx, [UIColor groupTableViewBackgroundColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectInset(dotFrameHorizontal, 0, 0));
            NSDictionary *point = @{@"x":[NSNumber numberWithFloat:i],
                                    @"y":[NSNumber numberWithFloat:j]
                                    };
            [gridPoints addObject:point];
        }
    }
    NSLog(@"Grid Points %@",gridPoints);
    
    self.containerView.layer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
    
    NSLog(@"Show movableViews %@",self.movableViews);
    
}


@end
