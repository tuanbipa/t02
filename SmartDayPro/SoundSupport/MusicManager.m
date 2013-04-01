//
//  MusicManager.m
//  SmartPlan
//
//  Created by Trung Nguyen on 6/22/10.
//  Copyright 2010 LCL. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>

#import "MusicManager.h"

#import "Common.h"
#import "Settings.h"

MusicManager *_musicManagerSingleton = nil;

@implementation MusicManager

@synthesize backgroundMusicPlayer;

-(BOOL) checkIfOtherAudioIsPlaying
{
	BOOL gOtherAudioIsPlaying = NO;
	
	UInt32	 propertySize, audioIsAlreadyPlaying;
	
	// do not open the track if the audio hardware is already in use (could be the iPod app playing music)
	propertySize = sizeof(UInt32);
	
	AudioSessionInitialize(NULL,NULL,NULL,NULL);	
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &audioIsAlreadyPlaying);
	if (audioIsAlreadyPlaying != 0)
	{
		gOtherAudioIsPlaying = YES;
	}
	else
	{
		gOtherAudioIsPlaying = NO;
	}
	
	return gOtherAudioIsPlaying;
}

- (id) init
{
	if (self = [super init])
	{
		musicLibrary = [[NSMutableDictionary alloc] init];
		otherAudioIsPlaying = [self checkIfOtherAudioIsPlaying];
	}
	
	return self;
}

- (void) loadBackgroundMusicWithKey:(NSString*)theMusicKey fileName:(NSString*)theFileName fileExt:(NSString*)theFileExt {
	
	NSString *path = [[NSBundle mainBundle] pathForResource:theFileName ofType:theFileExt];
	[musicLibrary setObject:path forKey:theMusicKey];
}

- (void) setMusicPath:(NSString *)path forKey:(NSString *)forKey
{
    [musicLibrary setObject:path forKey:forKey];
}

- (void) playMusicWithKey:(NSString*)theMusicKey timesToRepeat:(NSUInteger)theTimesToRepeat {
	
	NSError *error;
	
	NSString *path = [musicLibrary objectForKey:theMusicKey];
	
	if(!path) {
		//////NSLog(@"ERROR SoundEngine: The music key '%@' could not be found", theMusicKey);
		return;
	}
	
	if (self.backgroundMusicPlayer != nil)
	{
		[self.backgroundMusicPlayer stop];
	}
	
	// Initialize the AVAudioPlayer
	//self.backgroundMusicPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error] autorelease];
	self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	[self.backgroundMusicPlayer release];
    
    [self.backgroundMusicPlayer prepareToPlay];
	
	// If the backgroundMusicPlayer object is nil then there was an error
	if(!self.backgroundMusicPlayer) {
		//////NSLog(@"ERROR SoundManager: Could not play music for key '%d'", error);
		return;
	}		
	
	// Set the number of times this music should repeat.  -1 means never stop until its asked to stop
	[self.backgroundMusicPlayer setNumberOfLoops:theTimesToRepeat];
	
	float backgroundMusicVolume = 1.0f;
	// Set the volume of the music
	[self.backgroundMusicPlayer setVolume:backgroundMusicVolume];
	
	// Play the music
	[self.backgroundMusicPlayer play];
}

- (void) playSound:(SoundType) sound
{
	if (![[Settings getInstance] soundEnable])
	{
		return;
	}
	
	if (otherAudioIsPlaying)
	{
		return;
	}
	
	switch (sound)
	{
		case SOUND_TIMER_ON:
			[self playMusicWithKey:@"open" timesToRepeat:0];
			break;
		case SOUND_TIMER_OFF:
			[self playMusicWithKey:@"close" timesToRepeat:0];
			break;
		case SOUND_START:
			[self playMusicWithKey:@"Start" timesToRepeat:0];
			break;
		case SOUND_PAUSE:
			[self playMusicWithKey:@"Pause" timesToRepeat:0];
			break;
		case SOUND_STOP:
			[self playMusicWithKey:@"Stop" timesToRepeat:0];
			break;
		case SOUND_REPORT:
			[self playMusicWithKey:@"Harp" timesToRepeat:0];
			break;
		case SOUND_ALARM:
			//[self playMusicWithKey:@"AlarmDrum" timesToRepeat:0];
            [self playMusicWithKey:@"Alarm" timesToRepeat:0];
			break;
			
	}
}

- (void) stopSound
{
	if (self.backgroundMusicPlayer != nil)
	{
		[self.backgroundMusicPlayer stop];
	}
    
    self.backgroundMusicPlayer = nil;
}

- (void)dealloc 
{	
	[musicLibrary release];
	self.backgroundMusicPlayer = nil;
	[super dealloc];
}

+(id)getInstance
{
	if (_musicManagerSingleton == nil)
	{
		_musicManagerSingleton = [[MusicManager alloc] init];
	}
	
	return _musicManagerSingleton;
}

+(void)free
{
	if (_musicManagerSingleton != nil)
	{
		[_musicManagerSingleton release];
		
		_musicManagerSingleton = nil;
	}
}

+ (void) startup
{
	MusicManager *mm = [MusicManager getInstance];

    [mm loadBackgroundMusicWithKey:@"open" fileName:@"open" fileExt:@"wav"];
	[mm loadBackgroundMusicWithKey:@"close" fileName:@"close" fileExt:@"wav"];
	[mm loadBackgroundMusicWithKey:@"Harp" fileName:@"Harp" fileExt:@"wav"];
    [mm loadBackgroundMusicWithKey:@"Start" fileName:@"Start" fileExt:@"wav"];
	[mm loadBackgroundMusicWithKey:@"Pause" fileName:@"Pause" fileExt:@"wav"];
	[mm loadBackgroundMusicWithKey:@"Stop" fileName:@"Stop" fileExt:@"wav"];
    [mm loadBackgroundMusicWithKey:@"AlarmDrum" fileName:@"AlarmDrum" fileExt:@"wav"];
    [mm loadBackgroundMusicWithKey:@"Alarm" fileName:@"Alarm" fileExt:@"wav"];
	
}


@end
