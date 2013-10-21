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
        
        [self loadHUD];
        [self loadDebug];
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

- (void) didSimulatePhysics {
    SKNode *camera = [self childNodeWithName:@"//camera"];
    
    [self centerOnNode:camera];
}

- (void) centerOnNode: (SKNode *) node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y);
}

#pragma mark - Main init functions 

- (void) loadHUD {
    self.hudNode = [SKNode node];
    
    SKButton *backButton = [[SKButton alloc] initWithImageNamedNormal:@"redButton" selected:@"redButtonActivated"];
    backButton.position = CGPointMake(75, self.size.height - 30);
    backButton.size = CGSizeMake(150, 30);
    [backButton.title setText:@"Reset game"];
    [backButton.title setFontSize:20.0];
    [backButton setTouchUpInsideTarget:self action:@selector(didTapReset)];
    [self addChild:backButton];
    
    backButton = [[SKButton alloc] initWithImageNamedNormal:@"redButton" selected:@"redButtonActivated"];
    backButton.position = CGPointMake(75, 100);
    backButton.size = CGSizeMake(150, 30);
    [backButton.title setText:@"Zoom on unit"];
    [backButton.title setFontSize:20.0];
    [backButton setTouchUpInsideTarget:self action:@selector(didTapZoom)];
    [self addChild:backButton];
}

- (void) loadDebug {
    self.debugNode = [SKNode node];
}

- (void) didTapReset {
    [self.world resetUnits];
}

- (void) didTapZoom {
    [self.world pointCameraToUnit:self.world.units[0]];
}

- (void) loadMapNamed:(NSString *)mapName {
    // remove previous map from screen
    [self.world.tileMap removeFromParent];
    
    // load the new one
    self.world = [[TDMap alloc] initMapNamed:mapName];
    
    if (self.world.tileMap) {
        [self addChild:self.world.tileMap];
        
//        [self.world pointCameraToDefaultElement];
//        [self.world setCameraToDefaultZoomLevel];
        
        // new camera
        SKNode *camera = [SKNode node];
        camera.name = @"camera";
        [self.world.tileMap addChild:camera];
    }
}

- (void) loadUnits {
    TDUnit *unit = [[TDUnit alloc] init];
    [self.world addUnit:unit];
}

#pragma mark - Game Logic

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self.world update:currentTime];
}

#pragma mark - UIGestureRecognizer

- (void) handlePan:(UIPanGestureRecognizer *)pan {
    // get the camera
    SKNode *camera = [self childNodeWithName:@"//camera"];
    
    // get the translation info
    CGPoint trans = [pan translationInView:pan.view];
    
    // calculate the new map position
    CGPoint pos = camera.position;
    CGPoint newPos = CGPointMake(pos.x - trans.x, pos.y + trans.y);
//    [self.world pointCameraToPoint:newPos];
    camera.position = newPos;
    
    // "reset" the translation
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void) handlePinch:(UIPinchGestureRecognizer *)pinch {
    SKNode *camera = [self childNodeWithName:@"//camera"];
    
    static CGFloat startScale = 1;
    if (pinch.state == UIGestureRecognizerStateBegan)
    {
//        startScale = self.world.cameraZoomLevel;
        startScale = camera.xScale;
    }
    CGFloat newScale = startScale * pinch.scale;
//    self.world.cameraZoomLevel = newScale;
    camera.xScale = newScale;
    camera.yScale = newScale;
}

@end
