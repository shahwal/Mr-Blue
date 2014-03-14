//
//  paronoma.h
//  trail
//
//  Created by shahwal on 13/03/14.
//  Copyright (c) 2014 BSL. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface paronoma : SKNode

- (instancetype)initWithBackground:(NSString *)file size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed;
- (instancetype)initWithBackgrounds:(NSArray *)files size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed;
- (void)randomizeNodesPositions;
- (void)update:(NSTimeInterval)currentTime;

@end
