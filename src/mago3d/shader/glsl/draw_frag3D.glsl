precision highp float;

uniform sampler2D u_wind;
uniform vec2 u_wind_min;
uniform vec2 u_wind_max;
uniform bool u_flipTexCoordY_windMap;
uniform bool u_colorScale;
uniform float u_tailAlpha;
uniform float u_externAlpha;
uniform bool bUseLogarithmicDepth;

varying vec2 v_particle_pos;
varying float flogz;
varying float Fcoef_half;

vec3 getRainbowColor_byHeight(float height)
{
	float minHeight_rainbow = 0.0;
	float maxHeight_rainbow = 1.0;
	float gray = (height - minHeight_rainbow)/(maxHeight_rainbow - minHeight_rainbow);
	if (gray > 1.0){ gray = 1.0; }
	else if (gray<0.0){ gray = 0.0; }
	
	float r, g, b;
	
	if(gray < 0.16666)
	{
		b = 0.0;
		g = gray*6.0;
		r = 1.0;
	}
	else if(gray >= 0.16666 && gray < 0.33333)
	{
		b = 0.0;
		g = 1.0;
		r = 2.0 - gray*6.0;
	}
	else if(gray >= 0.33333 && gray < 0.5)
	{
		b = -2.0 + gray*6.0;
		g = 1.0;
		r = 0.0;
	}
	else if(gray >= 0.5 && gray < 0.66666)
	{
		b = 1.0;
		g = 4.0 - gray*6.0;
		r = 0.0;
	}
	else if(gray >= 0.66666 && gray < 0.83333)
	{
		b = 1.0;
		g = 0.0;
		r = -4.0 + gray*6.0;
	}
	else if(gray >= 0.83333)
	{
		b = 6.0 - gray*6.0;
		g = 0.0;
		r = 1.0;
	}
	
	float aux = r;
	r = b;
	b = aux;
	
	//b = -gray + 1.0;
	//if (gray > 0.5)
	//{
	//	g = -gray*2.0 + 2.0; 
	//}
	//else 
	//{
	//	g = gray*2.0;
	//}
	//r = gray;
	vec3 resultColor = vec3(r, g, b);
    return resultColor;
} 

vec3 getWhiteToBlueColor_byHeight(float height, float minHeight, float maxHeight)
{
    // White to Blue in 32 steps.
    float gray = (height - minHeight)/(maxHeight - minHeight);
    gray = 1.0 - gray; // invert gray value (white to blue).
    // calculate r, g, b values by gray.

    float r, g, b;

    // Red.
    if(gray >= 0.0 && gray < 0.15625) // [1, 5] from 32 divisions.
    {
        float minGray = 0.0;
        float maxGray = 0.15625;
        //float maxR = 0.859375; // 220/256.
        float maxR = 1.0;
        float minR = 0.3515625; // 90/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        r = maxR - relativeGray*(maxR - minR);
    }
    else if(gray >= 0.15625 && gray < 0.40625) // [6, 13] from 32 divisions.
    {
        float minGray = 0.15625;
        float maxGray = 0.40625;
        float maxR = 0.3515625; // 90/256.
        float minR = 0.0; // 0/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        r = maxR - relativeGray*(maxR - minR);
    }
    else  // [14, 32] from 32 divisions.
    {
        r = 0.0;
    }

    // Green.
    if(gray >= 0.0 && gray < 0.15625) // [1, 5] from 32 divisions.
    {
        g = 1.0; // 256.
    }
    else if(gray >= 0.15625 && gray < 0.5625) // [6, 18] from 32 divisions.
    {
        float minGray = 0.15625;
        float maxGray = 0.5625;
        float maxG = 1.0; // 256/256.
        float minG = 0.0; // 0/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        g = maxG - relativeGray*(maxG - minG);
    }
    else  // [18, 32] from 32 divisions.
    {
        g = 0.0;
    }

    // Blue.
    if(gray < 0.5625)
    {
        b = 1.0;
    }
    else // gray >= 0.5625 && gray <= 1.0
    {
        float minGray = 0.5625;
        float maxGray = 1.0;
        float maxB = 1.0; // 256/256.
        float minB = 0.0; // 0/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        b = maxB - relativeGray*(maxB - minB);
    }

    return vec3(r, g, b);
}

void main() {
	vec2 windMapTexCoord = v_particle_pos;
	if(u_flipTexCoordY_windMap)
	{
		windMapTexCoord.y = 1.0 - windMapTexCoord.y;
	}
    vec2 velocity = mix(u_wind_min, u_wind_max, texture2D(u_wind, windMapTexCoord).rg);
    float speed_t = length(velocity) / length(u_wind_max);

	
	if(u_colorScale)
	{
		speed_t *= 1.5;
		if(speed_t > 1.0)speed_t = 1.0;
		float b = 1.0 - speed_t;
		float g;
		if(speed_t > 0.5)
		{
			g = 2.0-2.0*speed_t;
		}
		else{
			g = 2.0*speed_t;
		}
		//vec3 col3 = getRainbowColor_byHeight(speed_t);
		vec3 col3 = getWhiteToBlueColor_byHeight(speed_t, 0.0, 1.0);
		float r = speed_t;
		gl_FragColor = vec4(col3.x, col3.y, col3.z ,u_tailAlpha*u_externAlpha);
	}
	else{
		float intensity = speed_t*3.0;
		if(intensity > 1.0)
			intensity = 1.0;
		gl_FragColor = vec4(intensity,intensity,intensity,u_tailAlpha*u_externAlpha);
	}

	#ifdef USE_LOGARITHMIC_DEPTH
	if(bUseLogarithmicDepth)
	{
		gl_FragDepthEXT = log2(flogz) * Fcoef_half;
	}
	#endif
}