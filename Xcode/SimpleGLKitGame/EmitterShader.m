//
//  EmitterShader.m
//  GLParticles3
//
//  Created by RRC on 5/2/13.
//
//

#import "EmitterShader.h"
#import "ShaderProcessor.h"

// Shaders
#define STRINGIFY(A) #A
#include "Emitter.vsh"
#include "Emitter.fsh"

@implementation EmitterShader

- (void)loadShader
{
    // Program
    ShaderProcessor* shaderProcessor = [[ShaderProcessor alloc] init];
    self.program = [shaderProcessor BuildProgram:EmitterVS with:EmitterFS];
    
    // Attributes
    self.a_pID = glGetAttribLocation(self.program, "a_pID");
    self.a_pColorOffset = glGetAttribLocation(self.program, "a_pColorOffset");
    
    // Uniforms
    self.u_ProjectionMatrix = glGetUniformLocation(self.program, "u_ProjectionMatrix");
    self.u_ModelViewMatrix = glGetUniformLocation(self.program, "u_ModelViewMatrix");
    self.u_Texture = glGetUniformLocation(self.program, "u_Texture");
    self.u_Time = glGetUniformLocation(self.program, "u_Time");
    self.u_ePosition = glGetUniformLocation(self.program, "u_ePosition");
    self.u_eRadius = glGetUniformLocation(self.program, "u_eRadius");
    self.u_eGrowth = glGetUniformLocation(self.program, "u_eGrowth");
    self.u_eDecay = glGetUniformLocation(self.program, "u_eDecay");
    self.u_eSize = glGetUniformLocation(self.program, "u_eSize");
    self.u_eColor = glGetUniformLocation(self.program, "u_eColor");
}

@end
