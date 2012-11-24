attribute vec3 vertexPosition;
attribute vec3 vertexNormal;
attribute vec2 textureCoord;

uniform mat4 modelViewMat;
uniform mat4 projectionMat;
uniform mat4 normalMat;

varying vec4 vertPos;
varying vec4 vertNorm;
varying vec2 texCoord;

void main(void) {
    vertPos = modelViewMat * vec4(vertexPosition, 1.0);
    vertNorm = normalMat * vec4(vertexNormal, 1.0);
    gl_Position = projectionMat * vertPos;
    vTextureCoord = aTextureCoord;
}