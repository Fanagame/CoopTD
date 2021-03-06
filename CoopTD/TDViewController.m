//
//  TDViewController.m
//  CoopTD
//
//  Created by Rémy Bardou on 17/10/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDViewController.h"
#import "TDNewGameScene.h"

@implementation TDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
	__weak TDViewController *weakSelf = self;
    [TDNewGameScene loadSceneAssetsForMapName:self.mapName withCompletionHandler:^{
        [weakSelf hideInterface];
        
        TDNewGameScene * scene = [[TDNewGameScene alloc] initWithSize:skView.bounds.size andMapName:weakSelf.mapName];
        scene.scaleMode = SKSceneScaleModeAspectFill;
		scene.parentViewController = weakSelf;
        
        // Present the scene.
        [skView presentScene:scene];
    }];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBarHidden = YES;
}

- (void) hideInterface {
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:[SKScene class]]) {
            view.hidden = YES;
        }
    }
}

- (void) showInterface {
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:[SKScene class]]) {
            view.hidden = NO;
        }
    }
}

- (NSString *)mapName {
	return [self.mapFilename stringByDeletingPathExtension];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[TDNewGameScene releaseSceneAssetsForMapName:self.mapName];
}

@end
