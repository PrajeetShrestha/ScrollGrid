//
//  DanceStepEditorViewController.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//
@import AVFoundation;
typedef enum EditActions {
    AddDancer = 80,
    AlignHorizontally = 81,
    AlignVertically = 82,
    Equidistant = 83,
    Undo =85,
    Redo = 86,
    SelectAll = 90,
    DeselectAll = 91,
    Reset = 89
} EditActions;

#import <UIKit/UIKit.h>
#import "GridScrollView.h"
#import "AudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DanceStepEditorViewController : UIViewController<MPMediaPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet GridScrollView *gridScroller;

#pragma mark - EDIT Actions
- (IBAction)playGrids:(id)sender;
- (IBAction)pickColor:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)editActions:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *pickButton;

- (void)clearContainerView;


#pragma media
@property (nonatomic) AudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UISlider *currentTimeSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;

@property BOOL isPaused;
@property BOOL scrubbing;

@property NSTimer *timer;
@property NSTimer *updateTimer;


@end
