//
//  DetectorsPipelineBuilder.h
//  BreatingEngine
//
//  Created by Davide Morelli on 8/16/13.
//  Copyright (c) 2013 BioBeats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HREventsDelegate.h"
#import "BREventsDelegate.h"
#import "StreamAnalyzer.h"
#import "SignalGenerator.h"
#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIView.h>

@interface HeartDetectorEngine : NSObject<StreamAnalyzer>

@property (strong, nonatomic) id<HREventsDelegate> HRDelegate;
@property (strong, nonatomic) id<BREventsDelegate> BRDelegate;

@property int samplerate;


// build and starts the pipeline
// the pipeline needs to know if it should use the accelerometer (belly breathing)
// if it should use the camera (both can be used at the same time)
// the pipeline needs to know the period (in seconds) of the control signal
- (void) startBreathEngineWithCMMotionManager:(CMMotionManager *) motionManager
                                  andCamera:(BOOL) cameraPresent
                     andControlSignalPeriod: (float) period
                        saveRawCameraSamples: (BOOL) saveRawPPG
                                  forDuration: (int) seconds;

- (void) startHeartEngine;

- (void) startHeartEngineWithPreviewView:(UIView*) previewView;

- (void) startHeartEngineSavingRawCameraSamples: (BOOL) saveRawPPG
                                    forDuration: (int) seconds;

- (void) startHeartEngineSavingRawCameraSamples: (BOOL) saveRawPPG
                                    forDuration: (int) seconds
                                    previewView: (UIView *) previewView;

- (void) testBreathEngineWithDummyCamera: (SignalGenerator *) fakeCamera
                          withSampleRate: (float) sampleRate
                 withControlSignalPeriod: (float) period
                  withDummyControlSignal: (SignalGenerator *) fakeControlSignal
                  withDummyAccelerometer: (SignalGenerator *) fakeAccelerometer
                                 andLogs: (BOOL) logs;

- (void) testHeartEngineWithDummyCamera: (SignalGenerator *) fakeCamera
                         withSampleRate: (float) sampleRate
                               withLogs: (BOOL) logs;

- (void) addControlSignalValue: (float) value
                       andTime: (CMTime) time;

- (void) stop;

// tells the engine what the user should be doing in this moment
// expected values are 0 to 1
// 0 means keep the air out
// going from 0 to 1 means inhaling
// 1 means holding the air in
// going from 1 to 0 means exhaling
// values will be interpolated, so you can send only 0s and 1s
// (when phases change)
- (void) addControlSignalValue:(float) v;

// get data to be saved in parse
- (NSArray *) getPPGsamples;
- (NSArray *) getHrPeriods;
- (NSArray *) getBreathingQuality;

- (void) resetPPGCollector;


// methods for external RR devices (e.g. the MS band)
- (void) startBreathEngineWithExternalHRDetectorandControlSignalPeriod: (float) period;
- (void) addRRintervalWithTimestamp: (NSDate *) date
                      andRRInterval: (float) interval;

+ (BOOL) hasDualCamera;
@end
