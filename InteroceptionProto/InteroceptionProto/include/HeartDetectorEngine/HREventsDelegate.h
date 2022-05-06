//
//  HREventsDelegate.h
//  BreatingEngine
//
//  Created by Davide Morelli on 8/16/13.
//  Copyright (c) 2013 BioBeats. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HREventsDelegate <NSObject>

- (void) beatDetectedWithHR: (float) HR
       andTotalMeasuredTime: (float) seconds;

- (void) beatDetectedWithInstantBPM: (float) instantBPM
                      andAverageBPM: (float) averageBPM;

// changes if the user has removed the finger from the camera
// so that the UI can instruct the user
- (void) fingerPresentChanged: (BOOL) isPresent;

- (void) newPPGSampleReady: (float) sample;

- (void) reportHRVActivation: (float) activation
               withMaxPeriod: (float) max
                andMinPeriod: (float) min;

@end
