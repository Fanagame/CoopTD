//
//  TDHealthBar.h
//  CoopTD
//
//  Created by Remy Bardou on 11/4/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TDHealthBar : SKSpriteNode

@property (nonatomic, assign) NSUInteger totalHP;
@property (nonatomic, assign) NSUInteger currentHP;

- (id) initWithTotalHP:(CGFloat)totalHP aboveSprite:(SKSpriteNode *)spriteNode;

@end
