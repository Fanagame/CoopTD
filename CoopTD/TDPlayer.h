//
//  TDPlayer.h
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kLocalPlayerCurrencyUpdatedNotificationName;
extern NSString * const kLocalPlayerLivesUpdatedNotificationName;
extern NSString * const kLocalPlayerLivesReachedZeroNotificationName;

@interface TDPlayer : NSObject

@property (nonatomic, assign, readonly) NSInteger playerId;
@property (nonatomic, strong, readwrite) NSString *displayName;

@property (nonatomic, strong, readonly) NSString *gameCenterDisplayName;
@property (nonatomic, assign, readonly) NSInteger gameCenterId;

@property (nonatomic, assign, readonly) BOOL isLocal;

@property (nonatomic, assign) NSInteger remainingLives;

@property (nonatomic, assign, readwrite) NSInteger softCurrency; // current game currency - to buys towers and stuff during a game
@property (nonatomic, assign, readonly) NSInteger hardCurrency; // currency bought with real money - buys you cool enhancements
@property (nonatomic, assign, readonly) NSInteger fightCurrency; // currency obtained through playing the game as pro - buys you cool enhancements too!

+ (instancetype) localPlayer;

- (void) addSoftCurrency:(NSInteger)amount;
- (void) addHardCurrency:(NSInteger)amount;
- (void) addFightCurrency:(NSInteger)amount;
- (void) subtractSoftCurrency:(NSInteger)amount;
- (void) subtractHardCurrency:(NSInteger)amount;
- (void) subtractFightCurrency:(NSInteger)amount;

@end
