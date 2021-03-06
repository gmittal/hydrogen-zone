/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

// Hydrozone by Gautam Mitta

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
        screenCenter = [director screenCenter];
        
        playerScale = 0.5f; // important, very very important

		player = [CCSprite spriteWithFile:@"hydrogen.png"];
        player.position = ccp(screenSize.width/2, screenSize.height/2);
        player.scale = playerScale;
        [self addChild:player];
        
        
        topBorder = [CCSprite spriteWithFile:@"border.png"];
        topBorder.position = ccp(screenSize.width/2, screenSize.height - 23);
        [self addChild:topBorder z:10000];
        
        bottomBorder = [CCSprite spriteWithFile:@"border.png"];
        bottomBorder.position = ccp(screenSize.width/2, 23);
        [self addChild:bottomBorder z:10000];
        
        pause = [CCMenuItemImage itemWithNormalImage:@"pause.png" selectedImage:@"pauseSel.png" target:self selector:@selector(pause)];
        pause.scale = 0.4f;
        pauseMenu = [CCMenu menuWithItems:pause, nil];
        pauseMenu.position = ccp(screenSize.width - 23, screenSize.height - 23);
        [self addChild:pauseMenu z:10001];
        
        
        timeLeft = 0;
        timeString = [NSString stringWithFormat:@"0:0%i", timeLeft];
        timeLabel = [CCLabelTTF labelWithString:timeString fontName:@"HelveticaNeue-UltraLight" fontSize:30];
        timeLabel.position = ccp(screenSize.width/2, topBorder.position.y);
        timeLabel.color = ccc3(12, 24, 43);
        [self addChild:timeLabel z:10001];
        
        timeLeft = 90;
        
        
        score = [self calculateScore:player.scale];
        scoreString = [NSString stringWithFormat:@"%iK", score];
        scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"HelveticaNeue-UltraLight" fontSize:30];
        scoreLabel.position = ccp(screenSize.width/2, bottomBorder.position.y);
        scoreLabel.color = ccc3(12, 24, 43);
        [self addChild:scoreLabel z:10001];
        
        
        // initialize various arrays
        atoms = [[NSMutableArray alloc] init];
        
        atomRateTarget = 20;
        
        [self initAtoms:atomRateTarget]; // specify how many atoms to start with, and they'll automatically regenerate themselves!
        
        
        [self startTimer];
        [self scheduleUpdate];
        
	}

	return self;
}


#pragma mark Functions That Generate Some Value
-(int) generateRandNumberFrom:(int) fromNumber to:(int)toNumber {
    return (arc4random()%(toNumber-fromNumber+1))+fromNumber;
}

-(CGPoint) generatePointByAngle:(float) angle distance:(float) someDistance startPoint:(CGPoint) point
{
    //    NSLog(@"%f", angle);
    angle = CC_DEGREES_TO_RADIANS(angle);
    double addedX = sin(angle) * someDistance;
    double addedY = cos(angle) * someDistance;
    //    NSLog(@"ADDED X: %f", addedX);
    //    NSLog(@"ADDED Y: %f", addedY);
    //    NSLog(NSStringFromCGPoint(point));
    CGPoint endPoint = ccp(point.x + addedX, point.y + addedY);
    //     NSLog(NSStringFromCGPoint(endPoint));
    //    NSLog(NSStringFromCGPoint(endPoint));
    return endPoint;
}


-(int) calculateScore:(float) scale {
    return scale * 1000;
}



-(void) initAtoms:(int) numAtoms {
    
    // simply generates
    for (int i = 0; i < numAtoms; i++) {
        double type = ((double)arc4random() / ARC4RANDOM_MAX);
        int atomType = 0;
        if (type < 0.85f) {
            atomType = 0; // OXYGEN! YAY!
        } else if (type > 0.85f) {
            atomType = 1; // HALOGEN! OH NO!
        }
        
        CCSprite *tmp;
        
        if (atomType == 0) {
            tmp = [CCSprite spriteWithFile:@"oxygen.png"];
            tmp.tag = atomType;
            
        } else if (atomType == 1) {
            tmp = [CCSprite spriteWithFile:@"halogen.png"];
            tmp.tag = atomType;
            
        }
        
        double scale = ((double)arc4random() / ARC4RANDOM_MAX);

        if (scale > 0.95f) {
            scale -= 0.5f;
        }
        
        if (scale < 0.1) {
            scale += 0.1;
        }
        
        tmp.scale = scale;
        
        int generatedPointAngle = [self generateRandNumberFrom:0 to:360];
        
        int xRand = [self generateRandNumberFrom:0 to:320];
        int yRand = [self generateRandNumberFrom:0 to:480];
        
        CGPoint generationAxis = ccp(xRand, yRand);
        
        CGPoint spriteStart = [self generatePointByAngle:generatedPointAngle distance:500 startPoint:generationAxis];
//        NSLog([NSString stringWithFormat:@"%@", spriteStart]);
        tmp.position = spriteStart;
        
        
        [atoms addObject:tmp];
        [self addChild:tmp];
        
        CGPoint endPoint = [self generatePointByAngle:generatedPointAngle+180 distance:500 startPoint:generationAxis];
        
//        [self moveObject:tmp toP1:[tmp position] P2:screenCenter];
        float moveTime = 13.0f;
        [tmp runAction:[CCMoveTo actionWithDuration:moveTime position:endPoint]];
        [self performSelector:@selector(removeSprite:) withObject:tmp afterDelay:moveTime];
        
    }
}

-(void) removeSprite:(CCSprite*) tmpSprite
{
    [self removeChild:tmpSprite cleanup:YES];
    [atoms removeObject:tmpSprite];
    if ([atoms count] < atomRateTarget) {
        [self initAtoms:1];
    }
}







-(void) circleCollisionWith:(NSMutableArray *) circle2
{
    //    [self updateCollisionCounter];
    
    for(NSUInteger i = 0; i < [circle2 count]; i++)
    {
        double playerWidth = [player boundingBox].size.width;
        CCSprite* tempSprite = [circle2 objectAtIndex:i];
        float c1radius = (playerWidth/2) - 3;
       
        float c2radius = [tempSprite boundingBox].size.width/2; // circle 2 radius
     
        float radii = c1radius + c2radius;
        float distX = player.position.x - tempSprite.position.x;
        float distY = player.position.y - tempSprite.position.y;
        float distance = sqrtf((distX * distX) + (distY * distY));
        
        
        if (distance <= radii) { // did the two circles collide at all??
            
            float ratio = distY/distance; // ratio of distance in terms of Y to distance from player
            float shipAngleRadians = asin(ratio); // arcsin of ratio
            float antiShipAngle = CC_RADIANS_TO_DEGREES(shipAngleRadians) * (-1); // convert to degrees from radians

            if (tempSprite.tag == 0) {
                // it's oxygen, yay
                if (tempSprite.scale < player.scale) {
                    player.scale += 0.01;
                } else if (tempSprite.scale > player.scale) {
                    NSLog(@"YOU DIE");
                }
            }
            
            if (tempSprite.tag == 1) {
                NSLog(@"YOU DIE");
            }
            
            id dock = [CCScaleTo actionWithDuration:0.1f scale:0];
            id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(removeArraySprite:)];
            [tempSprite runAction:[CCSequence actions:dock, removeSprite, nil]];
            
            
            
            
        }
        
    }
}




-(void) removeArraySprite:(id)sender
{
    [self removeChild:sender cleanup:YES];
    [atoms removeObject:sender];
    [self initAtoms:1];
    
    
}






#pragma mark Timer Functions
-(void) startTimer {
    [self schedule: @selector(tick:) interval:1.0];
    
}

-(void) tick: (ccTime) dt {
//    if (timeLeft == 60) {
//        timeString = @"1:00";
//    } else if (timeLeft < 60 && timeLeft > 10) {
//        timeString = [NSString stringWithFormat:@"0:%i", timeLeft];
//    } else if (timeLeft < 10) {
//        timeString = [NSString stringWithFormat:@"0:0%i", timeLeft];
//    } else if (timeLeft == 0) {
//        timeString = [NSString stringWithFormat:@"0:0%i", timeLeft];
//    }
    
    int minutes = timeLeft / 60;
    int seconds = timeLeft % 60;
    
    if (seconds >= 10) {
        timeString = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
    } else {
        timeString = [NSString stringWithFormat:@"%i:0%i", minutes, seconds];
    }
    [timeLabel setString:timeString];
    
    
    if (timeLeft <= 0) {
        timeLeft = 0;
        UIAlertView *alert;
        alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Time's Up!"];
        [alert setMessage:@"Katamari Damaci"];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        
        // STOP EVERYTHING
        [self unschedule:@selector(tick:)];
        [self unscheduleUpdate];
        [self stopAtomActions];
        
    
    } else {
        timeLeft--;
    }
}

-(void) stopAtomActions {
    for (int i = 0; i < [atoms count]; i++) {
        CCSprite *tmp = [atoms objectAtIndex:i];
        [tmp stopAllActions];
        [self removeChild:tmp cleanup:YES];
        [atoms removeObjectAtIndex:i];
        
        
    }
}


#pragma mark UPDATE FUNCTIONS

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
    
    float speed = 10; // Move 50 pixels in 60 frames (1 second)
    
    float vx = cos(touchangle * M_PI / 180) * speed;
    float vy = sin(touchangle * M_PI / 180) * speed;
    
    CGPoint direction = ccp(vy,vx);
    
    player.position = ccpAdd(player.position, direction);
    player.rotation = touchangle;
    
}


-(void) moveObject:(CCSprite*)object toP1:(CGPoint) rot_pos1 P2:(CGPoint) rot_pos2
{
    while (!CGPointEqualToPoint(object.position, rot_pos2)) {
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
        
        float speed = 1; // Move 50 pixels in 60 frames (1 second)
        
        float vx = cos(touchangle * M_PI / 180) * speed;
        float vy = sin(touchangle * M_PI / 180) * speed;
        
        CGPoint direction = ccp(vy,vx);
        
        object.position = ccpAdd(player.position, direction);
        object.rotation = touchangle;
    }

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
        
        
        if (player.scale <= 0) {
            player.scale = 0;
        } else if (!CGPointEqualToPoint([player position], posTouchScreen)) {
            player.scale -= player.scale/500;
        }
        
        if(newpos.x - oldpos.x > 5 || newpos.x - oldpos.x < -5 || newpos.y - oldpos.y > 5 || newpos.y - oldpos.y < -5)
        {
            [self movePlayerPos:rot_pos1 rot_pos2:rot_pos2];
            
        }
        
    }

}


-(void) pause {
    
}



-(void) update:(ccTime)delta
{
    [self playerTouchInput];
    [self circleCollisionWith:atoms];
    NSLog(@"Atoms: %i", [atoms count]);
    
}

@end
