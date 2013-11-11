//
//  TDHudNode.h
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class TDHudButton;

@interface TDHudNode : SKNode

@property (nonatomic, strong, readonly) TDHudButton *exitButton;
@property (nonatomic, strong, readonly) TDHudButton *debugButton;

@property (nonatomic, strong, readonly) SKLabelNode *playerNameLabel;
@property (nonatomic, strong, readonly) SKLabelNode *playerSoftCurrencyLabel;
@property (nonatomic, strong, readonly) SKLabelNode *playerLivesLabel;

@property (nonatomic, readonly) CGFloat topOverlayHeight;

- (void) didMoveToScene;

@end
