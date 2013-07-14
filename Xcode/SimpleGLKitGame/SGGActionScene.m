//
//  SGGActionScene.m
//  SimpleGLKitGame
//
//  Created by Ray Wenderlich on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGGActionScene.h"
#import "SGGSprite.h"
#import "SimpleAudioEngine.h"
#import "SGGGameOverScene.h"
#import "SGGAppDelegate.h"
#import "SGGViewController.h"

// GLP3
// ----
#import "SGGEmitter.h"
// ----
// GLP3

@interface SGGActionScene ()
@property (strong) GLKBaseEffect * effect;
@property (strong) SGGSprite * player;
@property (assign) float timeSinceLastSpawn;
@property (strong) NSMutableArray *projectiles;
@property (strong) NSMutableArray *targets;
@property (assign) int targetsDestroyed;
// GLP3
// ----
@property (strong) NSMutableArray* emitters;
// ----
// GLP3
@end

@implementation SGGActionScene
@synthesize effect = _effect;
@synthesize player = _player;
@synthesize timeSinceLastSpawn = _timeSinceLastSpawn;
@synthesize projectiles = _projectiles;
@synthesize targets = _targets;
@synthesize targetsDestroyed = _targetsDestroyed;

- (id)initWithEffect:(GLKBaseEffect *)effect
{
    if ((self = [super init]))
    {
        self.effect = effect;
        
        self.player = [[SGGSprite alloc] initWithFile:@"Player.png" effect:self.effect];    
        self.player.position = GLKVector2Make(self.player.contentSize.width/2, 160);
        
        self.children = [NSMutableArray array];
        [self.children addObject:self.player];    
                       
        self.projectiles = [NSMutableArray array];
        self.targets = [NSMutableArray array];
        
        // GLP3
        // ----
        self.emitters = [NSMutableArray array];
        // ----
        // GLP3
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pew-pew.wav"];
        
        // GLP3
        // ----
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"blast.caf"];
        // ----
        // GLP3
    }
    return self;
}

- (void)handleTap:(CGPoint)touchLocation
{
    GLKVector2 target = GLKVector2Make(touchLocation.x, touchLocation.y);
    GLKVector2 offset = GLKVector2Subtract(target, self.player.position);
    GLKVector2 normalizedOffset = GLKVector2Normalize(offset);
    
    static float POINTS_PER_SECOND = 480;  
    GLKVector2 moveVelocity = GLKVector2MultiplyScalar(normalizedOffset, POINTS_PER_SECOND);
    
    SGGSprite * sprite = [[SGGSprite alloc] initWithFile:@"Projectile.png" effect:self.effect];
    sprite.position = self.player.position;
    sprite.moveVelocity = moveVelocity;
    [self.children addObject:sprite];
    
    [self.projectiles addObject:sprite];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew.wav"];
}

- (void)addTarget
{
    SGGSprite * target = [[SGGSprite alloc] initWithFile:@"Target.png" effect:self.effect];
    [self.children addObject:target];
    
    int minY = target.contentSize.height/2;
    int maxY = 320 - target.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    target.position = GLKVector2Make(480 + (target.contentSize.width/2), actualY);    
    
    int minVelocity = 480.0/4.0;
    int maxVelocity = 480.0/2.0;
    int rangeVelocity = maxVelocity - minVelocity;
    int actualVelocity = (arc4random() % rangeVelocity) + minVelocity;
    
    target.moveVelocity = GLKVector2Make(-actualVelocity, 0);
    
    [self.targets addObject:target];
}

// GLP3
// ----
- (void)addEmitter:(GLKVector2)position
{
    SGGEmitter* emitter = [[SGGEmitter alloc] initWithFile:@"particle_32.png" projectionMatrix:self.effect.transform.projectionMatrix position:position];
    [self.children addObject:emitter];
    [self.emitters addObject:emitter];
    [[SimpleAudioEngine sharedEngine] playEffect:@"blast.caf"];
}
// ----
// GLP3

- (void)gameOver:(BOOL)win
{
    SGGGameOverScene * gameOver = [[SGGGameOverScene alloc] initWithEffect:self.effect win:win];

    SGGAppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    UIWindow * mainWindow = [delegate window];
    SGGViewController * viewController = (SGGViewController *) mainWindow.rootViewController;
    viewController.scene = gameOver;
}

- (void)update:(float)dt
{
    [super update:dt];
    
    NSMutableArray * projectilesToDelete = [NSMutableArray array];
    for (SGGSprite * projectile in self.projectiles)
    {
        
        NSMutableArray * targetsToDelete = [NSMutableArray array];
        for (SGGSprite * target in self.targets)
        {
            if (CGRectIntersectsRect(projectile.boundingBox, target.boundingBox))
            {
                [targetsToDelete addObject:target];
            }            
        }
        
        for (SGGSprite * target in targetsToDelete)
        {
            // GLP3
            // ----
            [self addEmitter:target.position];
            // ----
            // GLP3
            
            [self.targets removeObject:target];
            [self.children removeObject:target];
            _targetsDestroyed++;
        }
        
        if (targetsToDelete.count > 0)
        {
            [projectilesToDelete addObject:projectile];
        }
    }
    
    for (SGGSprite * projectile in projectilesToDelete)
    {
        [self.projectiles removeObject:projectile];
        [self.children removeObject:projectile];
    }
    
    // GLP3
    // ----
    if([self.emitters count] != 0)
    {
        NSMutableArray * emittersToDelete = [NSMutableArray array];
        
        for(SGGEmitter* emitter in self.emitters)
        {
            if([emitter isDead])
                [emittersToDelete addObject:emitter];
        }
        
        for(SGGEmitter* emitter in emittersToDelete)
        {
            [self.emitters removeObject:emitter];
            [self.children removeObject:emitter];
        }
    }
    // ----
    // GLP3
    
    self.timeSinceLastSpawn += dt;
    if (self.timeSinceLastSpawn > 1.0)
    {
        self.timeSinceLastSpawn = 0;
        [self addTarget];
    }
    
    if (_targetsDestroyed > 5)
    {
        [self gameOver:YES];
        return;        
    }

    BOOL lose = NO;    
    for (int i = self.children.count - 1; i >= 0; i--)
    {
        SGGSprite * sprite = [self.children objectAtIndex:i];
        
        if (sprite.position.x <= -sprite.contentSize.width/2 ||
            sprite.position.x > 480 + sprite.contentSize.width/2 ||
            sprite.position.y <= -sprite.contentSize.height/2 ||
            sprite.position.y >= 320 + sprite.contentSize.height/2)
        {
            if ([self.targets containsObject:sprite])
            {
                [self.targets removeObject:sprite];
                [self.children removeObjectAtIndex:i];
                lose = YES;
            }
            else if ([self.projectiles containsObject:sprite])
            {
                [self.projectiles removeObject:sprite];
                [self.children removeObjectAtIndex:i];
            }
        } 
    }
    
    if (lose)
    {
        [self gameOver:NO];
    }
}

@end
