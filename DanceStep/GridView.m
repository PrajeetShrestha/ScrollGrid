//
//  GridView.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/29/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "GridView.h"
@interface GridView()
{
    CGPoint startLocation;
}
@end
@implementation GridView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isColorSet = NO;
    }
    return self;
}

- (void)viewStateSelected {
    self.layer.borderColor = [UIColor yellowColor].CGColor;
    self.layer.borderWidth = 2.0f;
}

- (void)viewStateDeselected {
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0.0f;
}

- (void)expand {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.5, 1.5);

        self.alpha = 1.0f;
    }];
}

- (void)shrink {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)setColorWhenTouchedForFirstTime {
    if(!self.isColorSet) {
        self.backgroundColor = [UIColor whiteColor];
        self.isColorSet = YES;
        self.tagTitle.textColor = UIColorFromRGB(0x486D42);
    }
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Calculate and store offset, and pop view into front if needed
    // When touch began if activeView is nil then make the touched view active.
    // Check if active view is movable. (Movable views are view's representing dancers)
    //Set last previous position of a view before moving to next grid for undomanager to track view positions
    startLocation = [[touches anyObject] locationInView:self];
    [self.superview bringSubviewToFront:self];
    self.previousPosition = self.center;
    [self setColorWhenTouchedForFirstTime];
    [self expand];
    [self.delegate dancerTouchBegan];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Calculate offset
    CGPoint pt = [[touches anyObject] locationInView:self];
    float dx = pt.x - startLocation.x;
    float dy = pt.y - startLocation.y;
    CGPoint newcenter = CGPointMake(
                                    self.center.x + dx,
                                    self.center.y + dy);
    // Set new location
    // Restrict movement into parent bounds
    float halfx = CGRectGetMidX(self.bounds);
    newcenter.x = MAX(2 * halfx, newcenter.x);
    newcenter.x = MIN(self.superview.bounds.size.width - 2 * halfx,
                      newcenter.x);

    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(2 * halfy, newcenter.y);
    newcenter.y = MIN(self.superview.bounds.size.height - 2 * halfy,
                      newcenter.y);

    // Set new location
    self.center = newcenter;
    [self.delegate dancerMoved];
    [NSNumber numberWithBool:YES];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self shrink];
    [self.delegate dancerTouchEnd:self];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}
@end

