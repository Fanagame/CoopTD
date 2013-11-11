//
//  TDHealthBar.h
//  CoopTD
//
//  Created by Remy Bardou on 11/4/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TDProgressBar : SKSpriteNode

@property (nonatomic, assign) NSUInteger totalTicks;
@property (nonatomic, assign) NSUInteger currentTick;

@property (nonatomic, assign) BOOL hideWhenFull;

- (id) initWithTotalTicks:(CGFloat)totalTicks aboveSprite:(SKSpriteNode *)spriteNode;
- (id) initWithTotalTicks:(CGFloat)totalTicks fillColor:(UIColor *)fillColor aboveSprite:(SKSpriteNode *)spriteNode;

@end
