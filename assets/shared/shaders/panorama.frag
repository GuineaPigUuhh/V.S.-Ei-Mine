float str = 2.;
float ok = 1.5;
const float PI = 3.14159265359;

void main()
{
    vec2 uv = warp(fragCoord/iResolution.xy);
    vec2 cntr = vec2(0);
    
    uv.x -= iTime/100.;
    fragColor = col(uv);
}

vec2 warp(vec2 inp)
{
    inp.y -= (inp.y - .5)* str * pow(abs(inp.x - .5), ok);
    return inp;
}