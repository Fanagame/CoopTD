//
//  TDGameScene.m
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDGameScene.h"
#import "TDMap.h"
#import "TDUnit.h"
#import "SKButton.h"
#import "JSTileMap.h"

@implementation TDGameScene

- (id) initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        [self loadMapNamed:@"Demo.tmx"];
        [self loadUnits];
        
        // do it last to be on top
        [self loadHUD];
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

#pragma mark - Main init functions 

- (void) loadHUD {
    SKButton *backButton = [[SKButton alloc] initWithImageNamedNormal:@"redButton" selected:@"redButtonActivated"];
    backButton.position = CGPointMake(75, self.size.height - 30);
    backButton.size = CGSizeMake(150, 30);
    [backButton.title setText:@"Reset game"];
    [backButton.title setFontSize:20.0];
    [backButton setTouchUpInsideTarget:self action:@selector(didTapReset)];
    [self addChild:backButton];
}

- (void) didTapReset {
    [self.currentMap resetUnits];
}

- (void) loadMapNamed:(NSString *)mapName {
    // remove previous map from screen
    [self.currentMap.tileMap removeFromParent];
    
    // load the new one
    self.currentMap = [[TDMap alloc] initMapNamed:mapName];
    
    if (self.currentMap.tileMap) {
        [self addChild:self.currentMap.tileMap];
    }
}

- (void) loadUnits {
    TDUnit *unit = [[TDUnit alloc] init];
    [self.currentMap addUnit:unit];
}

#pragma mark - Game Logic

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self.currentMap update:currentTime];
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

//TODO: figure out a clean way to limit the zoom by the map limits and also make the zoom centered on fixed position
- (void) handlePinch:(UIPinchGestureRecognizer *)pinch {
    static CGFloat startScale = 1;
    if (pinch.state == UIGestureRecognizerStateBegan)
    {
        startScale = self.currentMap.tileMap.xScale;
    }
    CGFloat newScale = startScale * pinch.scale;
    self.currentMap.tileMap.xScale = MIN(2.0, MAX(newScale, .05));
    self.currentMap.tileMap.yScale = self.currentMap.tileMap.xScale;
}

@end
