//
//  TDMultiplayerManager.h
//  CoopTD
//
//  Created by Rémy Bardou on 20/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

/*
 * http://www.raywenderlich.com/12735
 * http://www1.in.tum.de/lehrstuhl_1/people/98-teaching/tutorials/508-sgd-ws13-tutorial-multiplayer-games
 * https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MCBrowserViewController_class/Reference/Reference.html
 */
#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

typedef void(^MultiplayerSuccessBlock)();
typedef void(^MultiplayerFailureBlock)();

@interface TDMultiplayerManager : NSObject<MCBrowserViewControllerDelegate>

@property (nonatomic, strong, readonly) MCPeerID *myPeerId;
@property (nonatomic, strong, readonly) MCSession *mySession;
@property (nonatomic, readonly) BOOL isHost;

@property (nonatomic, weak) UIViewController *presentingViewController;

+ (instancetype) sharedManager;

- (void) startLookingForPlayersWithSuccessBlock:(MultiplayerSuccessBlock)onSuccess andFailureBlock:(MultiplayerFailureBlock)onFailure;
- (void) stopLookingForPlayers;

@end
