//
//  HRVHelper.h
//  BioBeatsBreathe
//
//  Created by Davide Morelli on 29/09/15.
//  Copyright © 2015 BioBeats. All rights reserved.
//

#import <Foundation/Foundation.h>

// the names of the HRV features
// the names are used in the JSON serialization
// and in the .pInfo files
#define FIELD_NAME_PERIODS @"periods"
#define FIELD_NAME_AVERAGE_NN @"averageNN"
#define FIELD_NAME_AVERAGE_HR @"averageHR"
#define FIELD_NAME_pNN50 @"pNN50"
#define FIELD_NAME_SDNN @"SDNN"
#define FIELD_NAME_RMSSD @"RMSSD"
#define FIELD_NAME_SDSD @"SDSD"
#define FIELD_NAME_SD1 @"SD1"
#define FIELD_NAME_SD2 @"SD2"
#define FIELD_NAME_SVI @"SVI"
#define FIELD_NAME_VLF @"VLF"
#define FIELD_NAME_LF @"LF"
#define FIELD_NAME_HF @"HF"
#define FIELD_NAME_ENTROPY @"ApEn" // TODO
#define FIELD_NAME_RANGE @"range"
#define FIELD_NAME_PPG_SAMPLES @"PPGSamples"
#define FIELD_NAME_PPG_SAMPLERATE @"samplerate"

@interface HRVFeatureExtractor : NSObject

@property (strong, nonatomic) NSArray *periods;
@property (strong, nonatomic) NSArray *PPGSamples;
@property (strong, nonatomic) NSNumber *averageNN;
@property (strong, nonatomic) NSNumber *averageHR;
@property (strong, nonatomic) NSNumber *SDNN;
@property (strong, nonatomic) NSNumber *pNN50;
@property (strong, nonatomic) NSNumber *SVI;
@property (strong, nonatomic) NSNumber *RMSSD;
@property (strong, nonatomic) NSNumber *SDSD;
// frequency domain
@property (strong, nonatomic) NSNumber *VLF;
@property (strong, nonatomic) NSNumber *LF;
@property (strong, nonatomic) NSNumber *HF;
@property (strong, nonatomic) NSArray  *spectrumFrequencyFrom;
@property (strong, nonatomic) NSArray  *spectrumFrequencyTo;
@property (strong, nonatomic) NSArray  *spectrumPower;
// pointcaré plot
@property (strong, nonatomic) NSNumber *SD1;
@property (strong, nonatomic) NSNumber *SD2;
// non linear features
@property (strong, nonatomic) NSNumber *ApEn;
@property (strong, nonatomic) NSNumber *range;
@property (strong, nonatomic) NSNumber *samplerate;

@property BOOL includePPG;

@property BOOL extractedTimeDomainFeatures;
@property BOOL extractedFrequencyDomainFeatures;


- (id) initWithNNPeriods: (NSArray *) periods andPPGSamples: (NSArray *) samples atSampleRate:(NSNumber *) samplerate;
- (id) initWithJSONRepresentation: (NSString *) json;

// returns YES if all the features could be extracted
// returns NO if at least some feature could not be extracted
- (BOOL) extractFeatures;

- (NSString *) createJSONRepresentation;

- (float) breathingQualityAtBreathingFrequency: (float) BreathingHz;

@end
