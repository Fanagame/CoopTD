//
//  TDHudButton.h
//  CoopTD
//
//  Created by Remy Bardou on 11/10/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TDHudButtonShape : uint32_t {
    TDHudButtonShape_Circle,
    TDHudButtonShape_Rectangle
} TDHudButtonShape;

typedef enum TDHudButtonColor : uint32_t {
    TDHudButtonColor_Red,
    TDHudButtonColor_Orange,
    TDHudButtonColor_Green,
    TDHudButtonColor_Yellow,
    TDHudButtonColor_Blue
} TDHudButtonColor;

@interface TDHudButton : UIButton

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign, readonly) TDHudButtonShape shape;
@property (nonatomic, assign, readonly) TDHudButtonColor color;

- (id) initWithTitle:(NSString *)title;
- (id) initWithTitle:(NSString *)title shape:(TDHudButtonShape)buttonShape;
- (id) initWithTitle:(NSString *)title color:(TDHudButtonColor)buttonColor;
- (id) initWithTitle:(NSString *)title shape:(TDHudButtonShape)buttonShape color:(TDHudButtonColor)color;

@end
