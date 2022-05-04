varying vec2 position;
varying vec4 color;
varying vec2 texcoord;

uniform vec2 lightPosition;
uniform float lightDirection;
uniform float lightStrength;
uniform float lightSize;
uniform float lightFov;

#define PI	3.1415926538

void main(){
	// First, determine the distance of the fragment on the screen from the light's source position. Then,
	// determine the strength of the light source's effect on that fragment based on that distance relative to
	// the radius of the light.
	vec2 dist = position - lightPosition;
	float strength = 1.0 / (sqrt(dist.x * dist.x + dist.y * dist.y + lightSize * lightSize) - lightSize + 1.0 - lightStrength);
	
	// Convert the light's direction from angles (0 to 360) to radians (0 yo 2 * PI). Then, calculate the half
	// FOV since the total fov value has the light's direction in the middle; splitting in half allows the
	// calculations below to actually achieve that effect.
	float direction = radians(lightDirection);
	float hfov = radians(lightFov) * 0.5;
	
	// If half of the FOV is less then PI (AKA below 180 degrees), the light is considered directional and
	// must be treated as such. So, any pixels outside of that FOV range will have their strength set to 0.
	if (hfov < PI){
		float rad = atan(-dist.y, dist.x); // Ranges from -PI to +PI
		float angleDist = abs(mod(rad + 2.0 * PI, 2.0 * PI) - direction);
		angleDist = min(angleDist, 2.0 * PI - angleDist); // Converts to the correct angle needed for the light source
		strength *= clamp((1.0 - angleDist / hfov) * 2.5, 0.0, 1.0); // Softens the edges of the directional light
	}
	
	// Finally, pass off the strength value to the fragment color value to render that pixel of the light.
	vec4 texColor = texture2D(gm_BaseTexture, texcoord);
    gl_FragColor = color * vec4(vec3(strength), 1.0) * texColor;
}
