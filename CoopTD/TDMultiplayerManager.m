//
//  TDMultiplayerManager.m
//  CoopTD
//
//  Created by Rémy Bardou on 20/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMultiplayerManager.h"

NSString * const kGameServiceType = @"cooptd";

@interface TDMultiplayerManager ()

@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCPeerID *myPeerId;

@property (nonatomic, strong) MCBrowserViewController *browserVC;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

@property (nonatomic, assign) BOOL isHost;

@property (nonatomic, copy) MultiplayerSuccessBlock onSuccess;
@property (nonatomic, copy) MultiplayerFailureBlock onFailure;

@end

@implementation TDMultiplayerManager

static TDMultiplayerManager *_sharedManager;
+ (instancetype) sharedManager {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[TDMultiplayerManager alloc] init];
	});
	return _sharedManager;
}

- (void) startLookingForPlayersWithSuccessBlock:(MultiplayerSuccessBlock)onSuccess andFailureBlock:(MultiplayerFailureBlock)onFailure {
	if (self.presentingViewController) {
		self.onSuccess = onSuccess;
		self.onFailure = onFailure;
		
		[self.advertiser start];
		[self.presentingViewController presentViewController:self.browserVC animated:YES completion:nil];
	}
}

- (void) stopLookingForPlayers {
	if (self.presentingViewController) {
		[self.advertiser stop];
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - Browser delegate

- (void) browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
	[self stopLookingForPlayers];
	
	if (self.onFailure) {
		self.onFailure();
		self.onFailure = nil;
	}
}

- (void) browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
	[self stopLookingForPlayers];
	
	if (self.onSuccess) {
		self.onSuccess();
		self.onSuccess = nil;
	}
}

#pragma mark - Getters

- (MCPeerID *) myPeerId {
	if (!_myPeerId) {
		_myPeerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
	}
	return _myPeerId;
}

- (MCSession *) mySession {
	if (!_mySession) {
		_mySession = [[MCSession alloc] initWithPeer:self.myPeerId];
	}
	return _mySession;
}

- (MCBrowserViewController *) browserVC {
	if (!_browserVC) {
		_browserVC = [[MCBrowserViewController alloc] initWithServiceType:kGameServiceType session:self.mySession];
		_browserVC.delegate = self;
	}
	return _browserVC;
}

- (MCAdvertiserAssistant *) advertiser {
	if (_advertiser) {
		_advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:kGameServiceType discoveryInfo:nil session:self.mySession];
	}
	return _advertiser;
}

@end
