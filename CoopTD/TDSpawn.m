//
//  TDSpawn.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDSpawn.h"

@implementation TDSpawn

- (SKSpriteNode *)spriteNode {
    if (!_spriteNode) {
        _spriteNode = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:self.frame.size];
        _spriteNode.position = CGPointMake(self.frame.origin.x + self.frame.size.width * 0.5, self.frame.origin.y + self.frame.size.height * 0.5);
    }
    return _spriteNode;
}

@end
