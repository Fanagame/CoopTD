//
//  TDGameScene.h
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class TDMap;

@interface TDGameScene : SKScene<UIGestureRecognizerDelegate> {
    CGFloat _lastScale;
}

@property (nonatomic, strong) TDMap *currentMap;

@end
