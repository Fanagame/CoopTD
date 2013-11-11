//
//  TDHealthBar.m
//  CoopTD
//
//  Created by Remy Bardou on 11/4/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDProgressBar.h"

@interface TDProgressBar ()

@property (nonatomic, strong) SKSpriteNode *insideBar;

@end

@implementation TDProgressBar

- (id) initWithTotalTicks:(CGFloat)totalTicks aboveSprite:(SKSpriteNode *)spriteNode {
    return [self initWithTotalTicks:totalTicks fillColor:[UIColor redColor] aboveSprite:spriteNode];
}

- (id) initWithTotalTicks:(CGFloat)totalTicks fillColor:(UIColor *)fillColor aboveSprite:(SKSpriteNode *)spriteNode {
    self = [super initWithColor:[UIColor blackColor] size:CGSizeMake(64, 8)];
    
    if (self) {
        self.position = CGPointMake(0, spriteNode.size.height * 0.5);
        self.insideBar = [[SKSpriteNode alloc] initWithColor:fillColor size:CGSizeMake(0, self.size.height)];
        self.insideBar.anchorPoint = CGPointMake(0.5, self.anchorPoint.y);
        [self addChild:self.insideBar];
        
        self.totalTicks = totalTicks;
        self.currentTick = totalTicks;
    }
    
    return self;
}

- (void) setTotalTicks:(NSUInteger)totalTicks {
    _totalTicks = totalTicks;
    [self updateHealthBar];
}

- (void) setCurrentTick:(NSUInteger)currentTick {
    _currentTick = currentTick;
    [self updateHealthBar];
}

- (void) setHideWhenFull:(BOOL)hideWhenFull {
    if (_hideWhenFull != hideWhenFull) {
        _hideWhenFull = hideWhenFull;
        [self updateHealthBar];
    }
}

- (void) updateHealthBar {
    if (!self.hideWhenFull || self.currentTick != self.totalTicks) {
        if (!self.hideWhenFull) {
            self.insideBar.hidden = NO;
            self.hidden = NO;
        }

        // recalculates how much the health bar is filled
        CGFloat fraction = (CGFloat)self.currentTick / (CGFloat)self.totalTicks;
        CGFloat width = self.size.width * fraction;
        
        self.insideBar.position = CGPointMake(- (self.size.width - width) * 0.5, self.insideBar.position.y);
        self.insideBar.size = CGSizeMake(width, self.size.height);
    } else if (self.hideWhenFull) {
        self.insideBar.hidden = YES;
        self.hidden = YES;
    }
}

@end
