#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare fragment shader inputs

layout(location = 0) in vec3 nor;
layout(location = 1) in float heightFrac;

layout(location = 0) out vec4 outColor;

void main() {
    // TODO: Compute fragment color
    const vec3 lightDir = normalize(vec3(camera.view[0][2], camera.view[1][2], camera.view[2][2])); 
    const float diffuse = max(dot(nor, lightDir), 0.f);

    // albedo, let grass be lighter at the tip
    const vec3 topColor = vec3(0.1f, 0.8f, 0.1f);
    const vec3 bottomColor = vec3(0.0, 0.5f, 0.0);
    const vec3 baseColor = mix(bottomColor, topColor, heightFrac);

    const float ambient = 0.1f;

    const vec3 col = baseColor * (diffuse + ambient);
    outColor = vec4(col, 1.0);
}
