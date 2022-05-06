//
//  SignalGenerator.h
//  HeartDetectorEngine
//
//  Created by Davide Morelli on 10/10/15.
//  Copyright © 2015 BioBeats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamAnalyzer.h"

@interface SignalGenerator : NSObject<StreamAnalyzer>

@property (retain, nonatomic) id<StreamAnalyzer> delegate;

- (instancetype) initWithFakeData: (float *) buffer
                  numberOfSamples: (NSUInteger) nSamples
                    andSampleRate: (float) sampleRate
                      andStreamID: (int) stream;

- (void) generateSignal;

- (BOOL) generateSample;

- (BOOL) generateSampleAtTime: (CMTime) t;

@end
