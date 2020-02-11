precision highp float;
varying vec2 v_texcoord;
uniform bool textureFlipYAxis;
uniform sampler2D u_texture;
uniform highp int colorType; // 0= oneColor, 1= attribColor, 2= texture.
uniform vec4 oneColor4;

void main()
{
    vec4 textureColor;
	if(colorType == 2)
	{
		if(textureFlipYAxis)
		{
			textureColor = texture2D(u_texture, vec2(v_texcoord.s, 1.0 - v_texcoord.t));
		}
		else
		{
			textureColor = texture2D(u_texture, v_texcoord);
		}
		if(textureColor.w < 0.05)
		{
			discard;
		}
	}
	else if( colorType == 0)
	{
		textureColor = oneColor4;
	}

    gl_FragColor = textureColor;
}