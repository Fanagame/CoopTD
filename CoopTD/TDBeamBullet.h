//
//  TDLaserBullet.h
//  CoopTD
//
//  Created by Remy Bardou on 11/8/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBullet.h"

@interface TDBeamBullet : TDBaseBullet

@property (nonatomic, strong) SKAction *soundAction;

- (void) updateWidth:(CGFloat)width;

@end
