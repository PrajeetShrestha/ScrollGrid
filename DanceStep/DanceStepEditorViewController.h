//
//  DanceStepEditorViewController.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//
@import AVFoundation;

#import <UIKit/UIKit.h>
#import "GridScrollView.h"
#import "AudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DanceStepEditorViewController : UIViewController<MPMediaPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet GridScrollView *gridScroller;

#pragma mark - EDIT Actions
- (IBAction)addDancer:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)alignHorizontally:(id)sender;
- (IBAction)alignVertically:(id)sender;
- (IBAction)equiDistant:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)pickColor:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)selectAll:(id)sender;


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
