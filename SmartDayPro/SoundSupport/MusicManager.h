//
//  MusicManager.h
//  SmartPlan
//
//  Created by Trung Nguyen on 6/22/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "Common.h"

@interface MusicManager : NSObject {
	NSMutableDictionary *musicLibrary;
	
	// AVAudioPlayer responsible for playing background music
	AVAudioPlayer *backgroundMusicPlayer;
	BOOL otherAudioIsPlaying;
}

@property (nonatomic, retain) AVAudioPlayer *backgroundMusicPlayer;

+(id)getInstance;
+(void)free;
+ (void) startup;

- (void) playSound:(SoundType) sound;

@end
