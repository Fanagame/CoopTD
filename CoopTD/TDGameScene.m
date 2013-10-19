//
//  TDGameScene.m
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDGameScene.h"
#import "TDMap.h"
#import "JSTileMap.h"

@implementation TDGameScene

- (id) initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        [self loadMapNamed:@"Demo.tmx"];
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];
}

- (void) loadMapNamed:(NSString *)mapName {
    // reset current view
    self.currentMap.tileMap.position = CGPointZero;
    [self.currentMap.tileMap setScale:0.5];
    
    // remove previous map from screen
    [self.currentMap.tileMap removeFromParent];
    
    // load the new one
    self.currentMap = [[TDMap alloc] initMapNamed:mapName];
    
    if (self.currentMap.tileMap) {
        [self.currentMap.tileMap setScale:0.5];
        
        CGRect mapBounds = [self.currentMap.tileMap calculateAccumulatedFrame];
        self.currentMap.tileMap.position = [self boundedLayerPosition:CGPointMake(-mapBounds.size.width/2.0, -mapBounds.size.height/2.0)];
        
        [self addChild:self.currentMap.tileMap];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

#pragma mark - Helper methods

- (CGPoint) boundedLayerPosition:(CGPoint)newPos {
    CGSize winSize = self.size;
    CGSize mapSize = self.currentMap.tileMap.calculateAccumulatedFrame.size;
    
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -mapSize.width + winSize.width);
    retval.y = MIN(retval.y, 0);
    retval.y = MAX(retval.y, -mapSize.height + winSize.height);
    
    return retval;
}

#pragma mark - UIGestureRecognizer

- (void) handlePan:(UIPanGestureRecognizer *)pan {
    // get the translation info
    CGPoint trans = [pan translationInView:pan.view];
    
    // calculate the new map position
    CGPoint pos = self.currentMap.tileMap.position;
    CGPoint newPos = CGPointMake(pos.x + trans.x, pos.y - trans.y);
    self.currentMap.tileMap.position = [self boundedLayerPosition:newPos];
    
    // "reset" the translation
    [pan setTranslation:CGPointZero inView:pan.view];
}

//TODO: fix this, it's not working atm
- (void) handlePinch:(UIPinchGestureRecognizer *)pinch {
//    if([pinch state] == UIGestureRecognizerStateBegan) {
//        // Reset the last scale, necessary if there are multiple objects with different scales
//        _lastScale = [pinch scale];
//    }
//    
//    if ([pinch state] == UIGestureRecognizerStateBegan ||
//        [pinch state] == UIGestureRecognizerStateChanged) {
//        
//        CGFloat currentScale = self.currentMap.tileMap.xScale;
//        
//        // Constants to adjust the max/min values of zoom
////        const CGFloat kMaxScale = 2.0;
////        const CGFloat kMinScale = 0.5;
//        const CGFloat kSpeed = 0.75;
//
//        CGFloat newScale = 1 -  (_lastScale - [pinch scale]) * (kSpeed);
////        newScale = MIN(newScale, kMaxScale / currentScale);
////        newScale = MAX(newScale, kMinScale / currentScale);
//        
//        [self.currentMap.tileMap setScale:newScale];
//        
//        _lastScale = [pinch scale];  // Store the previous scale factor for the next pinch gesture call
//    }
}

@end
