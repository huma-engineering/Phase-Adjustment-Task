//
//  BREventsDeletage.h
//  BreatingEngine
//
//  Created by Davide Morelli on 8/16/13.
//  Copyright (c) 2013 BioBeats. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BREventsDelegate <NSObject>


- (void) breathingCycleDetectedWithInstantRate: (float) InstantBreathsPerMinute
                                      averageRate: (float) AverageBreathsPerMinute
                                       andQuality: (float) quality;

// phases:
// 0=inhale
// 1=hold in
// 2=exhale
// 3=hold out
// probably only inhale and exhale will be actually detected
- (void) breathingPhaseDetected: (float) phase
                 withConfidence:(float) confidence;

// changes if the user is breathing slowly or normally
- (void) slowBreathingDetectedChanged: (BOOL) breathingSlowly;

// changes if the user is moving too much, or still enough for he session to be valid
// so the UI can inform the user that she should stay still
- (void) eccessiveMovementDetected: (BOOL) movement;

// the quality of the current exercise
// quality is how well the user is performing (correlation with the control signal):
// 0 means poor performance, 1 means perfect performance
// timing tells how well the user is respecting the timing of the exercise (time difference with the control signal):
// 0 means he has no time difference
// negative values mean the user is anticipating the exercise
// positive values mean the user is late
// range is -0.5 to 0.5
- (void) performanceQuality: (float) quality
                   withTiming:(float) timing;

- (void) movementQuality: (float) quality;

@end
