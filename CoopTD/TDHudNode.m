//
//  TDHudNode.m
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDHudNode.h"
#import "TDNewGameScene.h"
#import "SKButton.h"
#import "TDPlayer.h"

#define BUTTON_SIZE 32

@interface TDHudNode ()

@property (nonatomic, strong) SKButton *exitButton;
@property (nonatomic, strong) SKButton *debugButton;

@property (nonatomic, strong) SKLabelNode *playerNameLabel;
@property (nonatomic, strong) SKLabelNode *playerSoftCurrencyLabel;
@property (nonatomic, strong) SKLabelNode *playerLivesLabel;

@property (nonatomic, readonly) TDNewGameScene *gameScene;
@property (nonatomic, strong) SKShapeNode *topOverlayNode;

@end

@implementation TDHudNode

#pragma mark - Readonly props

- (TDNewGameScene *) gameScene {
    return (TDNewGameScene *)self.scene;
}

- (CGFloat) topOverlayHeight {
    return 30;
}

#pragma mark - Init

- (id) init {
    self = [super init];
    
    if (self) {
        self.name = @"hud";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSoftCurrency) name:kLocalPlayerCurrencyUpdatedNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLives) name:kLocalPlayerLivesUpdatedNotificationName object:nil];
    }
    
    return self;
}

- (void) didMoveToScene {
    TDNewGameScene *scene = self.gameScene;
    
    CGPoint origin = CGPointMake(- scene.size.width / 2, - scene.size.height / 2);
    
    // add top overlay for scores
    self.topOverlayNode = [[SKShapeNode alloc] init];
    self.topOverlayNode.fillColor = [UIColor blackColor];
    self.topOverlayNode.strokeColor = [UIColor clearColor];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(origin.x, origin.y + scene.size.height - self.topOverlayHeight, scene.size.width, self.topOverlayHeight), NULL);
    self.topOverlayNode.path = path;
    CGPathRelease(path);
    [self addChild:self.topOverlayNode];
    
    // local player name in top left
    self.playerNameLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica Neue Ultralight"];
    self.playerNameLabel.text = [TDPlayer localPlayer].displayName;
    self.playerNameLabel.color = [UIColor whiteColor];
    self.playerNameLabel.fontSize = 16.0;
    self.playerNameLabel.position = CGPointMake(origin.x + 30, -origin.y - 25);
    [self.topOverlayNode addChild:self.playerNameLabel];
    
    // Total gold in top right
    self.playerSoftCurrencyLabel = [self.playerNameLabel copy];
    [self updateSoftCurrency];
    self.playerSoftCurrencyLabel.position = CGPointMake(origin.x + scene.size.width - 100, self.playerNameLabel.position.y);
    [self.topOverlayNode addChild:self.playerSoftCurrencyLabel];
    
    
    // Total lives on top
    self.playerLivesLabel = [self.playerNameLabel copy];
    [self updateLives];
    self.playerLivesLabel.position = CGPointMake(0, self.playerNameLabel.position.y);
    [self.topOverlayNode addChild:self.playerLivesLabel];
    
    // add buttons
    self.exitButton = [[SKButton alloc] initWithImageNamedNormal:@"Circle_Red" selected:@"Circle_Red"];
    self.exitButton.size = CGSizeMake(BUTTON_SIZE, BUTTON_SIZE);
    self.exitButton.anchorPoint = CGPointMake(1, 1);
    self.exitButton.position = CGPointMake(origin.x + scene.size.width - 50, origin.y + scene.size.height - 50);
    [self.exitButton addTarget:self action:@selector(didTapExit) forControlEvents:UIControlEventTouchUpInside];
    [self addChild:self.exitButton];
    
    self.debugButton = [[SKButton alloc] initWithImageNamedNormal:@"Circle_Green" selected:@"Circle_Green"];
    self.debugButton.size = CGSizeMake(BUTTON_SIZE, BUTTON_SIZE);
    self.debugButton.position = CGPointMake(origin.x, origin.y + 100);
    [self.debugButton addTarget:self action:@selector(didTapDebug) forControlEvents:UIControlEventTouchUpInside];
    [self addChild:self.debugButton];
}

- (void) updateSoftCurrency {
    self.playerSoftCurrencyLabel.text = [NSString stringWithFormat:@"Gold: %d", [TDPlayer localPlayer].softCurrency];
}

- (void) updateLives {
    self.playerLivesLabel.text = [NSString stringWithFormat:@"Lives: %d", [TDPlayer localPlayer].remainingLives];
}

#pragma mark - Buttons actions

- (void) didTapExit {
	[self.gameScene.parentViewController.navigationController popViewControllerAnimated:YES];
}

- (void) didTapDebug {
    if (self.gameScene.currentMode == TDWorldModePlaceBuilding) {
        self.gameScene.currentMode = TDWorldModeDefault;
    } else {
        self.gameScene.currentMode = TDWorldModePlaceBuilding;
    }
}

@end
