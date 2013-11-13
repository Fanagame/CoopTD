//
//  TDFreezeBeamBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/12/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDFreezeBeamBullet.h"
#import "TDConstants.h"

@implementation TDFreezeBeamBullet

- (id) init {
    self = [super init];
    
    if (self) {
        self.color = [UIColor blueColor];
        self.attackEffect = kTDBulletEffect_Freeze | kTDBulletEffect_Fire;
    }
    
    return self;
}

- (CGFloat) heightForBeam {
    return 8;
}

@end
