//
//  BlackWorld.m
//  trail
//
//  Created by shahwal on 28/02/14.
//  Copyright (c) 2014 BSL. All rights reserved.
//

@import CoreFoundation;
@import CoreMotion;

#import "BlackWorld.h"
#import "paronoma.h"

@implementation BlackWorld {
    BOOL isStartGame;
    SKLabelNode* titile;
    
    paronoma *_parallaxNodeBackgrounds;
    paronoma *_parallaxSpaceDust;
    
    SKSpriteNode* _ironMan;
    
    NSMutableArray *_ironManLasers;
    CMMotionManager *_motionManager;
    int _nextShipLaser;

}

/**rd
 
 Called once when the scene is created, do your one-time setup here.
 
 A scene is infinitely large, but it has a viewport that is the frame through which you present the content of the scene.
 The passed in size defines the size of this viewport that you use to present the scene.
 To display different portions of your scene, move the contents relative to the viewport. One way to do that is to create a SKNode to function as a viewport transformation. That node should have all visible conents parented under it.
 
 @param size a size in points that signifies the viewport into the scene that defines your framing of the scene.
 */
-(id) initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {

        self.backgroundColor = [SKColor whiteColor];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

        NSArray* parallaxBackgroundNames = @[@"Empire_State_Building.png", @"frame_View01.png98ee6aec-ea8e-477d-9675-b50babd194c9Large.png", @"multi_level_building_3d_5815.png"];
        CGSize planetSizes = CGSizeMake(200.0, 200.0);
        
        _parallaxNodeBackgrounds = [[paronoma alloc] initWithBackgrounds:parallaxBackgroundNames size:planetSizes pointsPerSecondSpeed:10.0];
        _parallaxNodeBackgrounds.position = CGPointMake(size.width/2.0, size.height/2.0);
        [_parallaxNodeBackgrounds randomizeNodesPositions];
        [self addChild:_parallaxNodeBackgrounds];
        
        NSArray *parallaxBackground2Names = @[@"multi_level_building_3d_5815.png",@"multi_level_building_3d_5815.png"];
        _parallaxSpaceDust = [[paronoma alloc] initWithBackgrounds:parallaxBackground2Names
                                                                     size:size
                                                     pointsPerSecondSpeed:25.0];
        _parallaxSpaceDust.position = CGPointMake(0, 0);
        [self addChild:_parallaxSpaceDust];
        
        _ironMan = [SKSpriteNode spriteNodeWithImageNamed:@"ironMan2.png"];
        _ironMan.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
        _ironMan.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ironMan.frame.size];
        _ironMan.physicsBody.dynamic = YES;
        _ironMan.physicsBody.affectedByGravity = YES;
        //Give the ship an arbitrary mass so that its movement feels natural.
        _ironMan.physicsBody.mass = 0.02;
        [self addChild:_ironMan];
        
#pragma mark - Setup the lasers
        _ironManLasers = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i = 0; i < 5; ++i) {
            SKSpriteNode *shipLaser = [SKSpriteNode spriteNodeWithImageNamed:@"laserbeam_blue"];
            //SKSpriteNode *shipLaser = [SKSpriteNode spriteNodeWithTexture:laserTexture];
            shipLaser.hidden = YES;
            [_ironManLasers addObject:shipLaser];
            [self addChild:shipLaser];
        }
#pragma mark - Setup the Accelerometer to move the ship
        _motionManager = [[CMMotionManager alloc] init];



    }
    
    return self;
}

- (void)startTheGame
{
    for (SKSpriteNode *laser in _ironManLasers) {
        laser.hidden = YES;
    }
    _ironMan.hidden = NO;
    _ironMan.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
    
    //setup to handle accelerometer readings using CoreMotion Framework
    [self startMonitoringAcceleration];
}

- (void)startMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

- (void)updateShipPositionFromMotionManager
{
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        //NSLog(@"acceleration value = %f",data.acceleration.x);
        [_ironMan.physicsBody applyForce:CGVectorMake(0.0, 40.0 * data.acceleration.x)];
    }
    
}

#pragma mark - Handle touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    //check if they touched our Restart Label
//    for (UITouch *touch in touches) {
//        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
//        if (n != self && [n.name isEqual: @"restartLabel"]) {
//            //[self.theParentView restartScene];
//            [[self childNodeWithName:@"restartLabel"] removeFromParent];
//            [[self childNodeWithName:@"winLoseLabel"] removeFromParent];
//            [self startTheGame];
//            return;
//        }
//    }
    
    //do not process anymore touches since we are game over
//    if (_gameOver) {
//        return;
//    }
    
    SKSpriteNode *ironManLaser = [_ironManLasers objectAtIndex:_nextShipLaser];
    _nextShipLaser++;
    if (_nextShipLaser >= _ironManLasers.count) {
        _nextShipLaser = 0;
    }
    
    ironManLaser.position = CGPointMake(_ironMan.position.x+ironManLaser.size.width/2,_ironMan.position.y+0);
    ironManLaser.hidden = NO;
    [ironManLaser removeAllActions];
    
    
    CGPoint location = CGPointMake(self.frame.size.width, _ironMan.position.y);
    SKAction *laserFireSoundAction = [SKAction playSoundFileNamed:@"laser_ship.caf" waitForCompletion:NO];
    SKAction *laserMoveAction = [SKAction moveTo:location duration:0.5];
    SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        //NSLog(@"Animation Completed");
        ironManLaser.hidden = YES;
    }];
    
    SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserFireSoundAction, laserMoveAction,laserDoneAction]];
    
    [ironManLaser runAction:moveLaserActionWithDone withKey:@"laserFired"];
    
}
- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(void)update:(NSTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    //Update background (parallax) position
    [_parallaxSpaceDust update:currentTime];
    
    [_parallaxNodeBackgrounds update:currentTime];    //other additional game background
    
    [self updateShipPositionFromMotionManager];

    
}
//-(void)update:(CFTimeInterval)currentTime {
//    /* Called before each frame is rendered */
//    
//    if (isStartGame == YES) {
//        [self enumerateChildNodesWithName:@"background" usingBlock: ^(SKNode *node, BOOL *stop) {
//            SKSpriteNode *bg = (SKSpriteNode *) node;
//            bg.position = CGPointMake(bg.position.x - 5, bg.position.y);
//            
//            if (bg.position.x <= -bg.size.width) {
//                bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y);
//            }
//        }];
//    }
//   
//}

//handle touch events
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInNode:self];
//    SKNode *node = [self nodeAtPoint:location];
//    
//    //if fire button touched, bring the rain
//    if ([node.name isEqualToString:@"start"]) {
//        //do whatever...
//        isStartGame = YES;
//        titile.hidden = YES;
//    }
//}

@end

