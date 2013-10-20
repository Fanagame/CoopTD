//
//  TDUnit.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDUnit.h"
#import "PathFinder.h"

CGFloat const kUnitMovingSpeed = 0.3f;

@interface TDUnit ()

@property (nonatomic, strong) NSArray *path;

@end

@implementation TDUnit

- (id) init {
    self = [super init];
    
    if (self) {
        self.displayName = @"Pikachu";
    }
    
    return self;
}

- (SKSpriteNode *)spriteNode {
    if (!_spriteNode) {
        _spriteNode = [[SKSpriteNode alloc] initWithImageNamed:@"pikachu-32"];
    }
    
    return _spriteNode;
}


/// @description Change the unit status. Going to standby cancels any of its ongoing actions.
- (void) setStatus:(TDUnitStatus)status {
    if (status == TDUnitStatus_Standy || status == TDUnitStatus_CalculatingPath) {
        self.path = nil;
        [self.spriteNode removeAllActions];
    }
    
    _status = status;
}


/// @description Makes a unit follow a path from point A to point B
- (void) followArrayPath:(NSArray *)path withCompletionHandler:(void (^)())onComplete {
    self.path = path;
    
    NSMutableArray *moveActions = [[NSMutableArray alloc] init];
    for (PathNode *node in path) {
        SKAction *action = [SKAction moveTo:node.position duration:kUnitMovingSpeed];
        [moveActions addObject:action];
    }
    
    [self.spriteNode runAction:[SKAction sequence:moveActions] completion:onComplete];
}

/// @description Makes a unit follow a path from point A to point B
- (void) followArrayPath:(NSArray *)path {
    [self followArrayPath:path withCompletionHandler:nil];
}

@end
