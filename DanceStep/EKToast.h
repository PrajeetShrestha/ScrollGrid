//
//  EKToast.h
//  EKToast
//
//  Created by Prajeet Shrestha on 8/11/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum EKToastPosition {
    ToastPositionTop,
    ToastPositionCenter,
    ToastPositionBottom
} EKToastPosition;

@interface EKToast : UIView
//Message to be displayed in EKToast
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;

//BackgroundView behind the text
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

//Leading and trailing space of a EKToastView with respect to superview.
@property (nonatomic) NSInteger horizontalOffset;

//Sets the position of the tost to top, mid or bottom
@property (nonatomic) EKToastPosition position;

//Duration of toast
@property (nonatomic) float duration;

//Delay
@property (nonatomic) float delay;

//Determines if toast should autoDestruct after set duration default is YES. If autoDestruct is not set the toast will be removed on touch gesture.
@property (nonatomic) BOOL shouldAutoDestruct;

//Method to initialize EKToast
- (instancetype)initWithMessage:(NSString *)message;

//Method to display EKToast with a completion block
- (void)show:(void (^)(void))completion;
@end
