//
//  TDHealthBar.m
//  CoopTD
//
//  Created by Remy Bardou on 11/4/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDHealthBar.h"

@interface TDHealthBar ()

@property (nonatomic, strong) SKSpriteNode *healthBar;

@end

@implementation TDHealthBar

- (id) initWithTotalHP:(CGFloat)totalHP aboveSprite:(SKSpriteNode *)spriteNode {
    self = [super initWithColor:[UIColor blackColor] size:CGSizeMake(64, 8)];
    
    if (self) {
        self.position = CGPointMake(0, spriteNode.size.height * 0.5);
        self.healthBar = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(0, self.size.height)];
        self.healthBar.anchorPoint = CGPointMake(0.5, self.anchorPoint.y);
        [self addChild:self.healthBar];
        
        self.totalHP = totalHP;
        self.currentHP = totalHP;
    }
    
    return self;
}

- (void) setTotalHP:(NSUInteger)totalHP {
    _totalHP = totalHP;
    [self updateHealthBar];
}

- (void) setCurrentHP:(NSUInteger)currentHP {
    _currentHP = currentHP;
    [self updateHealthBar];
}

- (void) updateHealthBar {
    // recalculates how much the health bar is filled
    CGFloat fraction = (CGFloat)self.currentHP / (CGFloat)self.totalHP;
    CGFloat width = self.size.width * fraction;

    self.healthBar.position = CGPointMake(- (self.size.width - width) * 0.5, self.healthBar.position.y);
    self.healthBar.size = CGSizeMake(width, self.size.height);
}

@end
