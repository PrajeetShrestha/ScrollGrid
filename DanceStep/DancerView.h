//
//  GridView.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/29/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DancerView;

@protocol GridView <NSObject>
- (void)dancerTouchBegan;
- (void)dancerTouchEnd:(DancerView *)view;
- (void)dancerMoved;
@end

@interface DancerView : UIView
@property (nonatomic) CGPoint previousPosition;
@property (nonatomic) CGPoint latestPosition;
@property (nonatomic) BOOL isColorSet;
@property (nonatomic,weak) id <GridView> delegate;
@property (nonatomic) UILabel *tagTitle;
@property (nonatomic) NSString *tagString;

- (instancetype)initWithFrame:(CGRect)frame andDelegate:(id)delegate;
- (void)loadTagLabelWithString;
- (void)loadTagLabel:(NSString *)string;
- (void)viewStateSelected;
- (void)viewStateDeselected;
- (void)expand;
- (void)shrink;
- (void)setColorWhenTouchedForFirstTime;
@end
