//
//  TDFreezeBeamBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/12/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDFreezeBeamBullet.h"
#import "TDConstants.h"
#import "TDBaseBuff.h"
#import "TDSoundManager.h"

@implementation TDFreezeBeamBullet

- (id) init {
    self = [super init];
    
    if (self) {
        self.color = [UIColor blueColor];
//        [TDBaseBuff addBuff:[[TDBaseBuff alloc] initFreezeBuff] toBuffList:self.buffs withImmunities:nil];
//        [TDBaseBuff addBuff:[[TDBaseBuff alloc] initFireBuffWithDuration:2 andStrength:1] toBuffList:self.buffs withImmunities:nil];
        [TDBaseBuff addBuff:[[TDBaseBuff alloc] initPoisonBuffWithDuration:5 andDamagesPerSecond:60] toBuffList:self.buffs withImmunities:nil];
    }
    
    return self;
}

- (CGFloat) heightForBeam {
    return 8;
}

- (void) startAnimation {
    [[TDSoundManager sharedManager] playSoundNamed:@"bullets_laser_pulse" withLoop:YES andKey:self.key];
}

- (void) stopAnimation {
    [[TDSoundManager sharedManager] uncacheSoundWithKey:self.key];
}

@end
