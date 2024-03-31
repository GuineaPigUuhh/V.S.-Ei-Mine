#pragma header

        uniform float iTime;

        uniform sampler2D distortTexture;

        void main(){
                vec2 p_m = openfl_TextureCoordv;
                vec2 p_d = p_m;

                p_d.t -= iTime * 0.05;
                p_d.t = mod(p_d.t, 1.0);

                vec4 dst_map_val = flixel_texture2D(distortTexture, p_d);

                vec2 dst_offset = dst_map_val.xy;
                dst_offset -= vec2(.5,.5);
                dst_offset *= 2.;
                dst_offset *= 0.009; //THIS CONTROLS THE INTENSITY [higher numbers = MORE WAVY]

                //reduce effect towards Y top
                dst_offset *= pow(p_m.t, 1.4); //THIS CONTROLS HOW HIGH UP THE SCREEN THE EFFECT GOES [higher numbers = less screen space]

                vec2 dist_tex_coord = p_m.st + dst_offset;
                gl_FragColor = flixel_texture2D(bitmap, dist_tex_coord); 
        }