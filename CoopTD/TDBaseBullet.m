//
//  TDBaseBullet.m
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBaseBullet.h"

@implementation TDBaseBullet

- (CGFloat) attack {
    return self.baseAttack + self.bonusAttack;
}

@end
