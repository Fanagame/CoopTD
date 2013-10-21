//
//  TDViewController.m
//  CoopTD
//
//  Created by Rémy Bardou on 17/10/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDViewController.h"
#import "TDMainMenuScene.h"
#import "TDGameScene.h"
#import "TDNewGameScene.h"

@implementation TDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    [TDNewGameScene loadSceneAssetsWithCompletionHandler:^{
        [self hideInterface];
        
        SKScene * scene = [TDNewGameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }];
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

@end
