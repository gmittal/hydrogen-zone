/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"
#define ARC4RANDOM_MAX      0x100000000


@interface HelloWorldLayer : CCLayer
{
    CCDirector *director;
    CGSize screenSize;
    CCSprite *player;
    
    CGPoint screenCenter;
    
    NSMutableArray *atoms;
    
    NSString *timeString;
    CCLabelTTF *timeLabel;
    
    CCSprite *topBorder;
    CCSprite *bottomBorder;
    
    int timeLeft;
    
    float playerScale;
    
    CCMenu *pauseMenu;
    CCMenuItemImage *pause;
    
}

-(void) pause;

@end
