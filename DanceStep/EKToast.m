//
//  EKToast.m
//  EKToast
//
//  Created by Prajeet Shrestha on 8/11/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "EKToast.h"

@implementation EKToast

- (instancetype)initWithSize:(CGSize)size andMessage:(NSString *)message
{
    self = [super init];
    if (self) {
        NSArray *views = [[NSBundle mainBundle]loadNibNamed:@"EKToast" owner:nil options:nil];
        self = (EKToast *)views[0];
        self.title = message;
        self.size = size;
        //[self setUpBackgroundView];
        self.toastPosition = ToastPositionCenter;
    }
    return self;
}

- (void)show:(void (^)(void))completion {
    self.lblMessage.text = self.title;
    UIWindow *window = [[UIApplication sharedApplication]windows][0];
    //This won't let multiple toast to be loaded in window.
    for (id view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[EKToast class]]) {
            return;
        }
    }
    [window.rootViewController.view addSubview:self];
    [self addConstraintWithRespectToSuperView:self];
    [UIView animateWithDuration:0.5f delay:1.6f options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        completion();
    }];
}

- (void)setUpBackgroundView {
    self.backgroundView.layer.cornerRadius = 6.0f;
    self.clipsToBounds = YES;
}

- (void)addConstraintWithRespectToSuperView:(UIView *)view {

    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *viewsDictionary = @{@"View":view};
    NSString *widthFormat;
    if (self.size.width == 0) {
        widthFormat = [NSString stringWithFormat:@"H:|-%d-[View]-%d-|",0,0];
    } else {
        widthFormat = [NSString stringWithFormat:@"H:[View(==%d)]",(int)self.size.width];
    }

    NSArray *widthConstraint = [NSLayoutConstraint constraintsWithVisualFormat:widthFormat
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];

    CGFloat toTop = view.superview.frame.size.height/2;
    NSLayoutConstraint *centerVerticallyToSuperView = [NSLayoutConstraint constraintWithItem:view
                                                                                   attribute:NSLayoutAttributeCenterY
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:view.superview
                                                                                   attribute:NSLayoutAttributeCenterY
                                                                                  multiplier:1
                                                                                    constant:0
                                                       ];

    NSLayoutConstraint *centerHorizontallyToSuperView = [NSLayoutConstraint constraintWithItem:view
                                                                                     attribute:NSLayoutAttributeCenterX
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:view.superview
                                                                                     attribute:NSLayoutAttributeCenterX
                                                                                    multiplier:1
                                                                                      constant:0
                                                         ];
    [view.superview addConstraint:centerVerticallyToSuperView];

    [view.superview addConstraint:centerHorizontallyToSuperView];

    [view.superview addConstraints:widthConstraint];
    [view.superview layoutIfNeeded];
    if (self.toastPosition == ToastPositionBottom) {
        centerVerticallyToSuperView.constant = +toTop - view.bounds.size.height/2;

    } else if(self.toastPosition == ToastPositionTop) {
        centerVerticallyToSuperView.constant = -toTop + view.bounds.size.height/2;

    }
}
@end
