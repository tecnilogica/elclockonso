//
//  MainScreenViewController.h
//  SoftAlarm
//
//  Created by Juan Alonso on 09/02/14.
//  Copyright (c) 2014 Tecnilogica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MainScreenViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) MPMusicPlayerController *appPlayer;

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@property (strong, nonatomic) NSTimer *alarmTimer;

@property (weak, nonatomic) IBOutlet UILabel *alarmLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopAlarmButton;
@property (weak, nonatomic) IBOutlet UIView *longTapView;
@property (weak, nonatomic) IBOutlet UISwitch *alarmOnSwitch;

@property BOOL alarmIsPlaying;
@property BOOL alarmIsOn;

@end
