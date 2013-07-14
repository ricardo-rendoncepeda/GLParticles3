// Vertex Shader

static const char* EmitterVS = STRINGIFY
(

// Attributes
attribute float     a_pID;
attribute vec3      a_pColorOffset;

// Uniforms
uniform mat4        u_ProjectionMatrix;
uniform mat4        u_ModelViewMatrix;
uniform float       u_Time;
uniform vec2        u_ePosition;
uniform float       u_eRadius;
uniform float       u_eGrowth;
uniform float       u_eDecay;
uniform float       u_eSize;
 
// Varying
varying vec3        v_pColorOffset;

void main(void)
{
    // Convert polar angle to cartesian coordinates and calculate radius
    float x = cos(a_pID);
    float y = sin(a_pID);
    float r = u_eRadius;
    
    // Size
    float s = u_eSize;
    
    // If blast is growing
    if(u_Time < u_eGrowth)
    {
        float t = u_Time / u_eGrowth;
        x = x * r * t;
        y = y * r * t;
    }
    
    // Else if blast is decaying
    else
    {
        float t = (u_Time - u_eGrowth) / u_eDecay;
        x = x * r;
        y = y * r;
        s = (1.0 - t) * u_eSize;
    }
    
    // Calculate position with respect to emitter source
    vec2 position = vec2(x,y) + u_ePosition;
    
    // Required OpenGL ES 2.0 outputs
    gl_Position = u_ProjectionMatrix * u_ModelViewMatrix * vec4(position, 0.0, 1.0);
    gl_PointSize = s;
    
    // Fragment Shader outputs
    v_pColorOffset = a_pColorOffset;
}

);