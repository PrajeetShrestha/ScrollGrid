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
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic) NSString *title;
@property (nonatomic) CGSize size;
@property (nonatomic) EKToastPosition toastPosition;
- (instancetype)initWithSize:(CGSize)size andMessage:(NSString *)message;
- (void)show:(void (^)(void))completion;
@end
