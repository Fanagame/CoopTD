//
//  TDSoundManager.m
//  CoopTD
//
//  Created by Remy Bardou on 12/15/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDSoundManager.h"

@interface TDSoundManager ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation TDSoundManager

static TDSoundManager *_sharedManager;

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[TDSoundManager alloc] init];
    });
    return _sharedManager;
}

- (id) init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (NSMutableDictionary *) cachedSounds {
    if (!_cachedSounds) {
        _cachedSounds = [[NSMutableDictionary alloc] init];
    }
    return _cachedSounds;
}

#pragma mark - Music

- (void) playBackgroundMusicNamed:(NSString *)musicName {
    return;
    [self stopBackgroundMusic];
    
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:musicName ofType:@"mp3"]];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"playBackgroundMusicNamed ERROR: %@", error);
    } else {
        self.audioPlayer.numberOfLoops = -1;
        [self.audioPlayer play];
    }
}

- (void) playBackgroundMusic {
    [self.audioPlayer play];
}

- (void) stopBackgroundMusic {
    [self.audioPlayer stop];
}

#pragma mark - Sounds

- (void) playSoundNamed:(NSString *)soundName withLoop:(BOOL)loop andKey:(NSString *)key {
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"]];
    
    AVAudioPlayer *audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"playSoundNamed ERROR: %@", error);
    } else if (audio) {
        audio.numberOfLoops = (loop ? -1 : 1);
        self.cachedSounds[key] = audio;
        [audio play];
    }
}

- (void) playSoundWithKey:(NSString *)key {
    AVAudioPlayer *audio = self.cachedSounds[key];
    [audio play];
}

- (void) stopSoundWithKey:(NSString *)key {
    AVAudioPlayer *audio = self.cachedSounds[key];
    [audio stop];
}

- (void) uncacheSoundWithKey:(NSString *)key {
    [self stopSoundWithKey:key];
    [self.cachedSounds removeObjectForKey:key];
}

- (void) stopAllSoundsWithName:(NSString *)soundName {
#warning TODO: implement stopAllSoundsWithName
}

- (void) stopAllSounds {
    for (AVAudioPlayer *audio in self.cachedSounds.allValues) {
        [audio stop];
    }
}

@end
