#version 320 es
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    pixColor.rgb *= vec3(1.0, 0.963636, 0.909091);
    fragColor = pixColor;
}
