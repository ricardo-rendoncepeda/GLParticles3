//
//  SGGEmitter.m
//  GLParticles3
//
//  Created by RRC on 5/2/13.
//
//

#import "SGGEmitter.h"
#import "EmitterShader.h"

#define NUM_PARTICLES 18

typedef struct Particles
{
    float       pID;
    GLKVector3  pColorOffset;
}
Particles;

typedef struct Emitter
{
    Particles   eParticles[NUM_PARTICLES];
    GLKVector2  ePosition;
    float       eRadius;
    float       eGrowth;
    float       eDecay;
    float       eSize;
    GLKVector3  eColor;
}
Emitter;

@interface SGGEmitter ()

@property (assign) Emitter emitter;
@property (strong) EmitterShader* shader;

@end

@implementation SGGEmitter
{
    // Instance variables
    GLuint      _particleBuffer;
    GLuint      _texture;
    GLKMatrix4  _projectionMatrix;
    GLKVector2  _position;
    float       _time;
    BOOL        _dead;
}

- (id)initWithFile:(NSString *)fileName projectionMatrix:(GLKMatrix4)projectionMatrix position:(GLKVector2)position
{
    if((self = [super init]))
    {
        _particleBuffer = 0;
        _texture = 0;
        _projectionMatrix = projectionMatrix;
        _position = position;
        _time = 0.0f;
        _dead = NO;
        
        [self loadShader];
        [self loadEmitter];
        [self loadTexture:fileName];
    }
    return self;
}

- (void)loadShader
{
    self.shader = [[EmitterShader alloc] init];
    [self.shader loadShader];
    glUseProgram(self.shader.program);
    glUseProgram(0);
}

- (float)randomFloatBetween:(float)min and:(float)max
{
    float range = max - min;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * range) + min;
}

- (void)loadEmitter
{
    Emitter newEmitter = {0.0f};
    
    // Offset bounds
    float oColor = 0.25f;   // 0.5 = 50% shade offset
    
    // Load Particles
    for(int i=0; i<NUM_PARTICLES; i++)
    {
        // Assign a unique ID to each particle, between 0 and 360 (in radians)
        newEmitter.eParticles[i].pID = GLKMathDegreesToRadians(((float)i/(float)NUM_PARTICLES)*360.0f);
        
        // Assign random offsets within bounds
        float r = [self randomFloatBetween:-oColor and:oColor];
        float g = [self randomFloatBetween:-oColor and:oColor];
        float b = [self randomFloatBetween:-oColor and:oColor];
        newEmitter.eParticles[i].pColorOffset = GLKVector3Make(r, g, b);
    }
    
    // Load Properties
    newEmitter.ePosition = _position;                       // Source position
    newEmitter.eRadius = 50.0f;                             // Blast radius
    newEmitter.eGrowth = 0.25f;                             // Growth time
    newEmitter.eDecay = 0.75f;                              // Decay time
    newEmitter.eSize = 32.00f;                              // Fragment size
    newEmitter.eColor = GLKVector3Make(0.5f, 0.0f, 0.0f);   // Fragment color
    
    // Set Emitter & VBO
    self.emitter = newEmitter;
    glGenBuffers(1, &_particleBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _particleBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(self.emitter.eParticles), self.emitter.eParticles, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)loadTexture:(NSString *)fileName
{
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],
                             GLKTextureLoaderOriginBottomLeft,
                             nil];
    
    NSError* error;
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if(texture == nil)
    {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    }
    
    _texture = texture.name;
    glBindTexture(GL_TEXTURE_2D, _texture);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)renderWithModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    [super renderWithModelViewMatrix:modelViewMatrix];
    
    // "Set"
    glUseProgram(self.shader.program);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glBindBuffer(GL_ARRAY_BUFFER, _particleBuffer);
    
    // Uniforms
    glUniform1i(self.shader.u_Texture, 0);
    glUniformMatrix4fv(self.shader.u_ProjectionMatrix, 1, 0, _projectionMatrix.m);
    glUniformMatrix4fv(self.shader.u_ModelViewMatrix, 1, 0, modelViewMatrix.m);
    glUniform1f(self.shader.u_Time, _time);
    glUniform2f(self.shader.u_ePosition, self.emitter.ePosition.x, self.emitter.ePosition.y);
    glUniform1f(self.shader.u_eRadius, self.emitter.eRadius);
    glUniform1f(self.shader.u_eGrowth, self.emitter.eGrowth);
    glUniform1f(self.shader.u_eDecay, self.emitter.eDecay);
    glUniform1f(self.shader.u_eSize, self.emitter.eSize);
    glUniform3f(self.shader.u_eColor, self.emitter.eColor.r, self.emitter.eColor.g, self.emitter.eColor.b);
    
    // Attributes
    glEnableVertexAttribArray(self.shader.a_pID);
    glEnableVertexAttribArray(self.shader.a_pColorOffset);
    glVertexAttribPointer(self.shader.a_pID, 1, GL_FLOAT, GL_FALSE, sizeof(Particles), (void*)(offsetof(Particles, pID)));
    glVertexAttribPointer(self.shader.a_pColorOffset, 3, GL_FLOAT, GL_FALSE, sizeof(Particles), (void*)(offsetof(Particles, pColorOffset)));
    
    // Draw particles
    glDrawArrays(GL_POINTS, 0, NUM_PARTICLES);
    glDisableVertexAttribArray(self.shader.a_pID);
    glDisableVertexAttribArray(self.shader.a_pColorOffset);
    
    // "Reset"
    glUseProgram(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)update:(float)dt
{
    const float life = self.emitter.eGrowth + self.emitter.eDecay;
    
    if(_time < life)
        _time += dt;
    else
        _dead = YES;
}

- (BOOL)isDead
{return _dead;}

@end
