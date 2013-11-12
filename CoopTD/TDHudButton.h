//
//  TDHudButton.h
//  CoopTD
//
//  Created by Remy Bardou on 11/10/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDEnums.h"

@interface TDHudButton : UIButton

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign, readonly) TDHudButtonShape shape;
@property (nonatomic, assign, readonly) TDHudButtonColor color;

- (id) initWithTitle:(NSString *)title;
- (id) initWithTitle:(NSString *)title shape:(TDHudButtonShape)buttonShape;
- (id) initWithTitle:(NSString *)title color:(TDHudButtonColor)buttonColor;
- (id) initWithTitle:(NSString *)title shape:(TDHudButtonShape)buttonShape color:(TDHudButtonColor)color;

@end
