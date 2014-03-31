/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"

@interface HelloWorldLayer : CCLayer
{
    CCDirector *director;
    CGSize screenSize;
    CCSprite *player;
    
    NSMutableArray *oxygen;
    NSMutableArray *halogens;
    
    NSString *scoreString;
    CCLabelTTF *scoreLabel;
    
    CCSprite *topBorder;
    
}

@end
