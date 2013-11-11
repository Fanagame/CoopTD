//
//  TDHudButton.m
//  CoopTD
//
//  Created by Remy Bardou on 11/10/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDHudButton.h"

#define BUTTON_SIZE 48

@interface TDHudButton ()

@property (nonatomic, assign) TDHudButtonColor color;
@property (nonatomic, assign) TDHudButtonShape shape;

@end

@implementation TDHudButton

- (id)initWithTitle:(NSString *)title {
    return [self initWithTitle:title shape:TDHudButtonShape_Circle];
}

- (id)initWithTitle:(NSString *)title color:(TDHudButtonColor)buttonColor {
    return [self initWithTitle:title shape:TDHudButtonShape_Circle color:buttonColor];
}

- (id)initWithTitle:(NSString *)title shape:(TDHudButtonShape)buttonShape {
    return [self initWithTitle:title shape:buttonShape color:TDHudButtonColor_Red];
}

- (id)initWithTitle:(NSString *)title shape:(TDHudButtonShape)buttonShape color:(TDHudButtonColor)color {
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE);
        self.contentEdgeInsets = UIEdgeInsetsMake(-3, 20, 0, 20);
        self.shape = buttonShape;
        self.color = color;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
        UIImage *bgImage = [UIImage imageNamed:[self buttonImageName]];
        [self setBackgroundImage:[bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5 topCapHeight:bgImage.size.height * 0.5] forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateNormal];
        [self sizeToFit];
    }
    
    return self;
}

- (NSString *) buttonImageName {
    NSMutableString *imgName = [[NSMutableString alloc] initWithString:@"btn_"];
    
    switch (self.shape) {
        case TDHudButtonShape_Circle:
            [imgName appendString:@"circle_"];
            break;
        default:
            [imgName appendString:@"rect_"];
            break;
    }
    
    switch (self.color) {
        case TDHudButtonColor_Blue:
            [imgName appendString:@"blue"];
            break;
        case TDHudButtonColor_Yellow:
            [imgName appendString:@"yellow"];
            break;
        case TDHudButtonColor_Green:
            [imgName appendString:@"green"];
            break;
        case TDHudButtonColor_Orange:
            [imgName appendString:@"orange"];
            break;
        default:
            [imgName appendString:@"red"];
            break;
    }
    
    return imgName;
}

- (CGPoint) position {
    return self.frame.origin;
}

- (void) setPosition:(CGPoint)position {
    self.frame = CGRectMake(position.x, position.y, self.frame.size.width, self.frame.size.height);
}

@end
