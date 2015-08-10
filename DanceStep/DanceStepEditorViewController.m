//
//  DanceStepEditorViewController.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "DanceStepEditorViewController.h"
#import "GridScrollView.h"
#import "Position.h"

@interface DanceStepEditorViewController()
@property (weak, nonatomic) IBOutlet UIView *controlBackground;
@end
@implementation DanceStepEditorViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self clearData];

    [self performSelector:@selector(initiate) withObject:nil afterDelay:0.5f];
}

- (void)initiate {
    [self.gridScroller.viewArray addObject:@"t1.jpg"];
    [self.gridScroller loadScroller:[GridContainerView class]];
    [self.gridScroller loadIndexLabel];
    self.controlBackground.backgroundColor = UIColorFromRGB(0x6180B9);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Edit Action

- (IBAction)pickColor:(id)sender {
}
//
- (IBAction)deselectAll:(id)sender {
    [self editActions:sender];
}

- (IBAction)selectAll:(id)sender {
    [self editActions:sender];
}

- (IBAction)editActions:(id)sender {
    if (self.audioPlayer.audioPlayer.url != nil) {
        UIButton *btn = (UIButton *)sender;
        GridContainerView *containerView =(GridContainerView *) [self.gridScroller getCurrentView];
        switch (btn.tag) {
            case AddDancer:
                [containerView addDancer];
                break;
            case AlignHorizontally:
                [containerView alignHorizontally];
                break;
            case AlignVertically:
                [containerView alignVertically];
                break;
            case Equidistant:
                [containerView equiDistant];
                break;
            case Undo:
                [containerView undoMove];
                break;
            case Redo:
                [containerView redoMove];
                break;
            case SelectAll:
                [containerView selectAll];
                break;
            case DeselectAll:
                [containerView deselectAll];
                break;
            case Reset:
                [self reset];
                break;
            default:
                break;
        }
    } else {
        [self showErrorAlert];
    }
}

- (void)reset {
    UIView *view =    [self.view viewWithTag:1000];
    [view removeFromSuperview];
}
- (void)clearContainerView {

    for (GridContainerView *view in self.view.subviews) {

        if ([view isKindOfClass:[GridContainerView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (IBAction)playGrids:(id)sender {
    [self clearContainerView];
    GridContainerView *containerView = [[GridContainerView alloc]initWithFrame:self.gridScroller.frame];
    containerView.tag = 1000;
    [self.view addSubview:containerView];
    containerView.userInteractionEnabled = NO;

    NSArray *positions = [self fetchPositions];
    NSNumber *maxFrame = [positions valueForKeyPath:@"@max.frameIndex"];
    NSMutableArray *positionsByFrame = [NSMutableArray new];
    for (int i = 0 ; i <= maxFrame.integerValue; i ++ ) {
        NSMutableArray *positionsRow = [NSMutableArray new];
        for (Position *position in positions) {
            if (position.frameIndex.integerValue == i && position.dancerName != nil) {
                [positionsRow addObject:position];
            }
        }
        [positionsByFrame addObject:positionsRow];

    }
    
    int counter = 0;
    for (NSArray *currentPosition in positionsByFrame){
        NSDictionary *userInfo;

        if (counter == 0) {
            userInfo = @{@"positions":currentPosition,
                         @"containerView":containerView
                         };
        }   else {
            userInfo = @{@"positions":currentPosition,
                         @"containerView":containerView,
                         @"previousPositions":positionsByFrame[counter-1]
                         };
        }

        [self startTimerWithInfo:userInfo andTime:counter * 2];
        counter ++;
    }

}



- (void) startTimerWithInfo:(NSDictionary *)userInfo andTime:(NSUInteger)timeInterval {
    [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:userInfo
                                    repeats:NO];
}

- (void) tick:(NSTimer *) timer {
    GridContainerView *containerView = timer.userInfo[@"containerView"];
    NSArray *positions = timer.userInfo[@"positions"];
    NSArray *previousPositions = timer.userInfo[@"previousPositions"];
    [containerView addDancerInPositions:positions previousPosition:previousPositions ];
}

- (void)clearData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {

    }
    for (Position *position in fetchedObjects) {
        [kAppDelegate.managedObjectContext deleteObject:position];
    }
}


- (NSArray *)fetchPositions {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];


    NSError *error = nil;
    NSArray *fetchedObjects = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    return fetchedObjects;
}

#pragma mark - Media Player Delegate
- (void)displayMediaPicker {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems:NO];
    picker.prompt = @"Pick a song to process";
    [self presentViewController:picker animated:YES completion:nil];
    picker = nil;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)collection {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSURL *url = nil;
    MPMediaItem *item = [collection.items objectAtIndex:0];
    if (item) url = [item valueForProperty:@"assetURL"];
    //If url is selected then setupAudioPlayerWithURL
    if (url) {
        [self setupAudioPlayerWithURL:url];
    } else [self displayMediaPicker];
}

- (IBAction)drawMediaPicker:(id)sender {
    [self displayMediaPicker];
}

#pragma mark AudioPlayer Setup
- (void)setupAudioPlayerWithURL:(NSURL *)audioFileLocation {

    self.audioPlayer = [[AudioPlayer alloc] init];

    self.timeElapsed.text = @"0:00";
    self.duration.text = [NSString stringWithFormat:@"-%@",
                          [self.audioPlayer timeFormat:[self.audioPlayer getAudioDuration]]];

    //init the Player to get file properties to set the time labels
    [self.audioPlayer initPlayerWithURL:audioFileLocation];
    self.currentTimeSlider.maximumValue = [self.audioPlayer getAudioDuration];

    //init the current timedisplay and the labels. if a current time was stored
    //for this player then take it and update the time display
    self.timeElapsed.text = @"0:00";

    self.duration.text = [NSString stringWithFormat:@"-%@",
                          [self.audioPlayer timeFormat:[self.audioPlayer getAudioDuration]]];
}

- (IBAction)playAudioPressed:(id)playButton
{
    if (self.audioPlayer.audioPlayer.url == nil) {
        [self showErrorAlert];
    } else {
        [self.timer invalidate];
        [self.updateTimer invalidate];
        //play audio for the first time or if pause was pressed
        if (!self.isPaused) {
            //        [self.playButton setBackgroundImage:[UIImage imageNamed:@"audioplayer_pause.png"]
            //                                   forState:UIControlStateNormal];

            //start a timer to update the time label display
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateTime:)
                                                        userInfo:nil
                                                         repeats:YES];

            [self.audioPlayer playAudio];
            self.isPaused = TRUE;

        } else {
            //player is paused and Button is pressed again
            //        [self.playButton setBackgroundImage:[UIImage imageNamed:@"audioplayer_play.png"]
            //                                   forState:UIControlStateNormal];
            
            [self.audioPlayer pauseAudio];
            self.isPaused = FALSE;
        }

    }
}

- (void)showErrorAlert {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No media!" message:@"Please pick the media to play" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    alert.tag = 100;
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:0.0]];
    [animation setDuration:0.2f];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setAutoreverses:YES];
    [animation setRepeatCount:2];
    [[self.pickButton layer] addAnimation:animation forKey:@"alpha"];
}

#pragma mark -
- (void)updateTime:(NSTimer *)timer {
    //to don't update every second. When scrubber is mouseDown the the slider will not set
    if (!self.scrubbing) {
        self.currentTimeSlider.value = [self.audioPlayer getCurrentAudioTime];
    }
    self.timeElapsed.text = [NSString stringWithFormat:@"%@",
                             [self.audioPlayer timeFormat:[self.audioPlayer getCurrentAudioTime]]];

    self.duration.text = [NSString stringWithFormat:@"-%@",
                          [self.audioPlayer timeFormat:[self.audioPlayer getAudioDuration] - [self.audioPlayer getCurrentAudioTime]]];
}

/*
 * Sets the current value of the slider/scrubber
 * to the audio file when slider/scrubber is used
 */
- (IBAction)setCurrentTime:(id)scrubber {
    //if scrubbing update the timestate, call updateTime faster not to wait a second and dont repeat it
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];

    [self.audioPlayer setCurrentAudioTime:self.currentTimeSlider.value];
    self.scrubbing = FALSE;
}

/*
 * Sets if the user is scrubbing right now
 * to avoid slider update while dragging the slider
 */
- (IBAction)userIsScrubbing:(id)sender {
    self.scrubbing = TRUE;
}

//- (IBAction)getGridDetails:(id)sender {
//    ClearConsole
//    GridContainerView *containerView = (GridContainerView *)[self.gridScroller getCurrentView];
//    for (Grid *grid in containerView.grids){
//        [grid logContent];
//    }
//}


@end