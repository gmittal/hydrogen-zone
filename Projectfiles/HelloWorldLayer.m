/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"

@interface HelloWorldLayer (PrivateMethods)
@end

@implementation HelloWorldLayer

-(id) init
{
	if ((self = [super init]))
	{
		glClearColor(0.047f, 0.094f, 0.169f, 1.0f);

        director = [CCDirector sharedDirector];
        
        screenSize = [director screenSize];
        

		player = [CCSprite spriteWithFile:@"hydrogen.png"];
        player.position = ccp(screenSize.width/2, screenSize.height/2);
        player.scale = 0.5f;
        [self addChild:player];
        
        
        topBorder = [CCSprite spriteWithFile:@"border.png"];
        topBorder.position = ccp(screenSize.width/2, screenSize.height - 23);
        [self addChild:topBorder z:10000];
        
        bottomBorder = [CCSprite spriteWithFile:@"border.png"];
        bottomBorder.position = ccp(screenSize.width/2, 23);
        [self addChild:bottomBorder z:10000];
        
        
        timeLeft = 0;
        timeString = [NSString stringWithFormat:@"1:0%i", timeLeft];
        timeLabel = [CCLabelTTF labelWithString:timeString fontName:@"HelveticaNeue-UltraLight" fontSize:30];
        timeLabel.position = ccp(screenSize.width/2, topBorder.position.y);
        timeLabel.color = ccc3(12, 24, 43);
        [self addChild:timeLabel z:10001];
        
        timeLeft = 60;
        
        [self startTimer];
        [self scheduleUpdate];
        
	}

	return self;
}




-(void) startTimer {
    [self schedule: @selector(tick:) interval:1.0];
    
}

-(void) tick: (ccTime) dt {
    if (timeLeft == 60) {
        timeString = @"1:00";
    } else if (timeLeft < 60 && timeLeft > 10) {
        timeString = [NSString stringWithFormat:@"0:%i", timeLeft];
    } else if (timeLeft < 10) {
        timeString = [NSString stringWithFormat:@"0:0%i", timeLeft];
    } else if (timeLeft == 0) {
        timeString = [NSString stringWithFormat:@"0:0%i", timeLeft];
    }
    
    [timeLabel setString:timeString];
    
    
    if (timeLeft <= 0) {
        timeLeft = 0;
    } else {
        timeLeft--;
    }
}





-(void) movePlayerPos: (CGPoint) rot_pos1 rot_pos2:(CGPoint) rot_pos2
{
    float touchangle;
    float rotation_theta = atan((rot_pos1.y-rot_pos2.y)/(rot_pos1.x-rot_pos2.x)) * 180 / M_PI;
    
    if(rot_pos1.y - rot_pos2.y > 0)
    {
        if(rot_pos1.x - rot_pos2.x < 0)
        {
            touchangle = (-90-rotation_theta);
        }
        else if(rot_pos1.x - rot_pos2.x > 0)
        {
            touchangle = (90-rotation_theta);
        }
    }
    else if(rot_pos1.y - rot_pos2.y < 0)
    {
        if(rot_pos1.x - rot_pos2.x < 0)
        {
            touchangle = (270-rotation_theta);
        }
        else if(rot_pos1.x - rot_pos2.x > 0)
        {
            touchangle = (90-rotation_theta);
        }
    }
    
    if (touchangle < 0)
    {
        touchangle+=360;
    }
    
    float speed = 5; // Move 50 pixels in 60 frames (1 second)
    
    float vx = cos(touchangle * M_PI / 180) * speed;
    float vy = sin(touchangle * M_PI / 180) * speed;
    
    CGPoint direction = ccp(vy,vx);
    
    player.position = ccpAdd(player.position, direction);
    player.rotation = touchangle;
    
}




-(void) playerTouchInput {
    KKInput *input = [KKInput sharedInput];
    
    if (input.touchesAvailable) {
        //[self stopAction:movePlayer];
        //[self movePlayerToCoord];
        CGPoint playerpos = player.position;
        
        CGPoint posTouchScreen = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        //        [self calculateAngleWith:playerpos andWith:posTouchScreen andSetVariable:touchangle];
        
        CGPoint rot_pos2 = [player position];
        CGPoint rot_pos1 = posTouchScreen;
        
        CGPoint newpos = posTouchScreen;
        CGPoint oldpos = [player position];
        
        if(newpos.x - oldpos.x > 5 || newpos.x - oldpos.x < -5 || newpos.y - oldpos.y > 5 || newpos.y - oldpos.y < -5)
        {
            [self movePlayerPos:rot_pos1 rot_pos2:rot_pos2];
            //NSLog(@"Ohai.");
            
        }
        
    }

}


-(void) update:(ccTime)delta
{
    [self playerTouchInput];
    
}

@end
