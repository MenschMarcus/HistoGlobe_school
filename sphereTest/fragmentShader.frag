precision mediump float;

varying vec2 texCoord;
varying vec4 vertPos;
varying vec4 vertNorm;

uniform sampler2D texture;

void main(void) {
    vec4 lightPos = vec4(0.0, 1.0, 0.0, 1.0);
    vec4 vertToLight = vec4(lightPos - vertPos);
    float diff = dot(vertToLight, normalize(vertNorm));
    vec4 color = texture2D(texture, vec2(texCoord.s, texCoord.t));
    gl_FragColor = vec4(color.rgb * diff, color.a);
}