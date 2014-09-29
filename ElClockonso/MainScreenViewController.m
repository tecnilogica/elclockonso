//
//  MainScreenViewController.m
//  SoftAlarm
//
//  Created by Juan Alonso on 09/02/14.
//  Copyright (c) 2014 Tecnilogica. All rights reserved.
//

#import "MainScreenViewController.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController



#pragma mark Interface functions

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _alarmIsPlaying = false;
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _appPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    _stopAlarmButton.layer.cornerRadius = 4;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    lpgr.delegate = self;
    [_longTapView addGestureRecognizer:lpgr];

    _alarmLabel.layer.shadowOffset = CGSizeZero;
    _alarmLabel.layer.shadowRadius = 2.0;
    _alarmLabel.layer.shadowOpacity = 0.75;
    _alarmLabel.layer.masksToBounds = NO;
    
}


- (void)viewWillAppear:(BOOL)animated {

    _alarmLabel.text = [_userDefaults stringForKey:@"alarmTime"];
    
    _alarmIsOn = [_userDefaults boolForKey:@"alarmOn"];
    [_alarmOnSwitch setOn:_alarmIsOn];

    [self repaintAlarmLabel];
    [self repaintSwitchButton];
    
    [self setTimer];
    
}


- (void)repaintAlarmLabel{
    
    if (_alarmIsOn) {
        [_alarmLabel setTextColor:[UIColor colorWithRed:233.0/255.0 green:242.0/255.0 blue:249.0/255.0 alpha:1]];
    } else {
        [_alarmLabel setTextColor:[UIColor colorWithRed:48.0/255.0 green:110.0/255.0 blue:169.0/255.0 alpha:1]];
    }
    _alarmLabel.layer.shadowColor = [_alarmLabel.textColor CGColor];
    
}


- (void)repaintSwitchButton{
    _alarmOnSwitch.hidden = _alarmIsPlaying;
    _stopAlarmButton.hidden = !_alarmIsPlaying;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark Alarm related functions

- (void)setTimer {
    
    if (_alarmIsPlaying) {
        if ([_alarmTimer isValid]) {
            [_alarmTimer invalidate];
        }
    } else {

        if (_alarmIsOn) {

            if (![_alarmTimer isValid]) {
                _alarmTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(tick:) userInfo:nil repeats:true];
                _alarmTimer.tolerance = 1;
            }
            
        } else {
            
            if ([_alarmTimer isValid]) {
                [_alarmTimer invalidate];
            }
            
        }

    }
    
}


- (void)tick:(NSTimer *) timer {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]]);
    if ([[_userDefaults stringForKey:@"alarmTime"] isEqualToString:[dateFormatter stringFromDate:[NSDate date]]]){
        [self startAlarm];
    }
}


- (void)startAlarm {

    _alarmIsPlaying = true;

    [_appPlayer setVolume:0];
    [_appPlayer setShuffleMode:MPMusicShuffleModeSongs];
    [_appPlayer setQueueWithQuery: [MPMediaQuery songsQuery]];
    [_appPlayer play];
    
    [self doVolumeFade];
    
    [self repaintSwitchButton];
    [self setTimer];
    
}


- (void)doVolumeFade
{
    if (_appPlayer.volume <= 0.70 && _alarmIsPlaying) {
        _appPlayer.volume = _appPlayer.volume + 0.01;;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:1];
    }
}




#pragma mark User actions

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if (!_alarmIsPlaying) {
        CGPoint p = [gestureRecognizer locationInView:self.longTapView];
        if (p.y>=0 && p.y<_longTapView.frame.size.height) {
            int minutes = 13*60 + 30 +  (int)(60 * p.y / _longTapView.frame.size.height);
            //int minutes = 15 *  (int)(96 * p.y / _longTapView.frame.size.height);
            NSString *alarmTime = [NSString stringWithFormat:@"%02d:%02d", (minutes/60)%60, minutes%60];
            _alarmLabel.text = alarmTime;
            [_userDefaults setObject:alarmTime forKey:@"alarmTime"];
            [_userDefaults synchronize];
        }
    }
    
}


- (IBAction)stopAlarmTapped:(id)sender {
    
    [_appPlayer stop];
    [_appPlayer setVolume:0.5];

    _alarmIsPlaying = false;
    
    [self repaintSwitchButton];
    [self setTimer];

    
}


- (IBAction)switchTapped:(id)sender {
    
    _alarmIsOn = [sender isOn];
    
    [_userDefaults setBool:_alarmIsOn forKey:@"alarmOn"];
    [_userDefaults synchronize];
    
    [UIView transitionWithView:_alarmLabel
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self repaintAlarmLabel];
                    }
                    completion:nil];
    
    [self setTimer];
    
}

@end
