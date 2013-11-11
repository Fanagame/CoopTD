//
//  TDHudNode.m
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDHudNode.h"
#import "TDHudButton.h"
#import "TDNewGameScene.h"
#import "TDPlayer.h"

@interface TDHudNode ()

@property (nonatomic, strong) TDHudButton *exitButton;
@property (nonatomic, strong) TDHudButton *debugButton;

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

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.exitButton = [[TDHudButton alloc] initWithTitle:@"Exit"];
    self.exitButton.position = CGPointMake(10, 50);
    [self.exitButton addTarget:self action:@selector(didTapExit) forControlEvents:UIControlEventTouchUpInside];
    [self.gameScene.view addSubview:self.exitButton];
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
