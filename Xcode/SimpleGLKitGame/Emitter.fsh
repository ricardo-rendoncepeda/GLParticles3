// Fragment Shader

static const char* EmitterFS = STRINGIFY
(

// Varying
varying highp vec3      v_pColorOffset;
 
// Uniforms
uniform sampler2D       u_Texture;
uniform highp float     u_Time;
uniform highp float     u_eGrowth;
uniform highp float     u_eDecay;
uniform highp vec3      u_eColor;

void main(void)
{
    highp vec4 texture = texture2D(u_Texture, gl_PointCoord);
    highp vec4 color = vec4(1.0);
    
    // Calculate color with offset
    color.rgb = u_eColor + v_pColorOffset;
    color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));
    
    // If blast is growing
    if(u_Time < u_eGrowth)
    {
        color.a = 1.0;
    }
    
    // Else if blast is decaying
    else
    {
        highp float t = (u_Time - u_eGrowth) / u_eDecay;
        color.a = 1.0 - t;
    }
    
    // Required OpenGL ES 2.0 outputs
    gl_FragColor = texture * color;
}

);