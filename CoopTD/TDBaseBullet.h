//
//  TDBaseBullet.h
//  CoopTD
//
//  Created by Remy Bardou on 11/3/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TDBaseBullet : SKSpriteNode

@property (nonatomic, assign) CGFloat baseAttack;
@property (nonatomic, assign) CGFloat bonusAttack;

@property (nonatomic, readonly) CGFloat attack;

@end
