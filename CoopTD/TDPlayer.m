//
//  TDPlayer.m
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDPlayer.h"

NSString * const kLocalPlayerCurrencyUpdatedNotificationName = @"kCurrencyUpdatedNotificationName";
NSString * const kLocalPlayerLivesUpdatedNotificationName = @"kLivesUpdatedNotificationName";
NSString * const kLocalPlayerLivesReachedZeroNotificationName = @"kLocalPlayerLivesReachedZeroNotificationName";

@interface TDPlayer ()

@property (nonatomic, assign) NSInteger playerId;

@property (nonatomic, strong) NSString *gameCenterDisplayName;
@property (nonatomic, assign) NSInteger gameCenterId;

@property (nonatomic, assign) BOOL isLocal;

@property (nonatomic, assign) NSInteger hardCurrency;
@property (nonatomic, assign) NSInteger fightCurrency;

@end

@implementation TDPlayer

static TDPlayer *_localPlayer;
+ (instancetype) localPlayer {
    if (!_localPlayer) {
        @synchronized(self) {
            if (!_localPlayer) {
                _localPlayer = [[TDPlayer alloc] init];
                _localPlayer.isLocal = YES;
            }
        }
    }
    
    return _localPlayer;
}


#pragma mark - Currencies management

- (void) addSoftCurrency:(NSInteger)amount {
    self.softCurrency += amount;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerCurrencyUpdatedNotificationName object:self];
}

- (void) addHardCurrency:(NSInteger)amount {
    self.hardCurrency += amount;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerCurrencyUpdatedNotificationName object:self];
}

- (void) addFightCurrency:(NSInteger)amount {
    self.fightCurrency += amount;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerCurrencyUpdatedNotificationName object:self];
}

- (void) subtractSoftCurrency:(NSInteger)amount {
    self.softCurrency -= amount;
    if (self.softCurrency < 0) { self.softCurrency = 0; }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerCurrencyUpdatedNotificationName object:self];
}

- (void) subtractHardCurrency:(NSInteger)amount {
    self.hardCurrency -= amount;
    if (self.hardCurrency < 0) { self.hardCurrency = 0; }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerCurrencyUpdatedNotificationName object:self];
}

- (void) subtractFightCurrency:(NSInteger)amount {
    self.fightCurrency -= amount;
    if (self.fightCurrency < 0) { self.fightCurrency = 0; }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerCurrencyUpdatedNotificationName object:self];
}


// should only be called when starting a new game
- (void) setSoftCurrency:(NSInteger)softCurrency {
    _softCurrency = softCurrency;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerCurrencyUpdatedNotificationName object:self];
}

#pragma mark - Lives management

- (void) setRemainingLives:(NSInteger)remainingLives {
    
    if (remainingLives >= 0) {
        _remainingLives = remainingLives;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerLivesUpdatedNotificationName object:self];
        
        // might trigger game over popup or something else!
        if (remainingLives == 0)
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocalPlayerLivesReachedZeroNotificationName object:self];
    }
}

@end
