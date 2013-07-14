//
//  EmitterShader.h
//  GLParticles3
//
//  Created by RRC on 5/2/13.
//
//

#import <GLKit/GLKit.h>

@interface EmitterShader : NSObject

// Program Handle
@property (readwrite) GLuint    program;

// Attribute Handles
@property (readwrite) GLint     a_pID;
@property (readwrite) GLint     a_pColorOffset;

// Uniform Handles
@property (readwrite) GLint     u_ProjectionMatrix;
@property (readwrite) GLint     u_ModelViewMatrix;
@property (readwrite) GLint     u_Texture;
@property (readwrite) GLint     u_Time;
@property (readwrite) GLint     u_ePosition;
@property (readwrite) GLint     u_eRadius;
@property (readwrite) GLint     u_eGrowth;
@property (readwrite) GLint     u_eDecay;
@property (readwrite) GLint     u_eSize;
@property (readwrite) GLint     u_eColor;

// Methods
- (void)loadShader;

@end
