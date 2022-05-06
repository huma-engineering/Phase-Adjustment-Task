//
//  StreamAnalyzer.h
//  PulseDetector
//
//  Created by Davide Morelli on 9/6/13.
//  Copyright (c) 2013 BioBeats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol StreamAnalyzer <NSObject>

// stream IDs:

// Base streams:
#define STREAM_FINGER_PRESENT 999
#define STREAM_PPG 1
#define STREAM_ACCELEROMETER 2

// Breath detector:
#define STREAM_PPG_QUALITY 100
#define STREAM_PPG_PHASE 101
#define STREAM_ACCELEROMETER_QUALITY 102
#define STREAM_ACCELEROMETER_PHASE 103
#define STREAM_TACHOGRAM_QUALITY 104
#define STREAM_TACHOGRAM_PHASE 105
#define STREAM_CONTROL_SIGNAL 0
#define STREAM_DETECTED_QUALITY 106
#define STREAM_DETECTED_PHASE 107

// HR detector
#define STREAM_TACHOGRAM 200



- (void) addSampleWithTime: (CMTime) t
                  value: (float) v
               andStreamID: (int) ID;

@end
