//
//  SGGEmitter.h
//  GLParticles3
//
//  Created by RRC on 5/2/13.
//
//

#import <GLKit/GLKit.h>
#import "SGGNode.h"

@interface SGGEmitter : SGGNode

- (id)initWithFile:(NSString *)fileName projectionMatrix:(GLKMatrix4)projectionMatrix position:(GLKVector2)position;
- (BOOL)isDead;

@end
