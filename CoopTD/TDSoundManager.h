//
//  TDSoundManager.h
//  CoopTD
//
//  Created by Remy Bardou on 12/15/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TDSoundManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *cachedSounds;

+ (instancetype) sharedManager;

- (void) playBackgroundMusicNamed:(NSString *)musicName;
- (void) playBackgroundMusic;
- (void) stopBackgroundMusic;

- (void) playSoundNamed:(NSString *)soundName withLoop:(BOOL)loop andKey:(NSString *)key;
- (void) playSoundWithKey:(NSString *)key;
- (void) stopSoundWithKey:(NSString *)key;
- (void) uncacheSoundWithKey:(NSString *)key;
- (void) stopAllSoundsWithName:(NSString *)soundName;
- (void) stopAllSounds;

@end
