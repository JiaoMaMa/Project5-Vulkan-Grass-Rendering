#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(quads, equal_spacing, ccw) in;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare tessellation evaluation shader inputs and outputs
layout(location = 0) in vec4 v0_es[];
layout(location = 1) in vec4 v1_es[];
layout(location = 2) in vec4 v2_es[];
layout(location = 3) in vec4 up_es[];

layout(location = 0) out vec3 nor;
layout(location = 1) out float heightFrac;

void main() {
    float u = gl_TessCoord.x;
    float v = gl_TessCoord.y;

	// TODO: Use u and v to parameterize along the grass blade and output positions for each vertex of the grass blade
    const vec3 v0 = v0_es[0].xyz;
    const vec3 v1 = v1_es[0].xyz;
    const vec3 v2 = v2_es[0].xyz;
    const float orientation = v0_es[0].w;
    const float height = v1_es[0].w;
    const float width = v2_es[0].w;
    
    // normal
    const vec3 t1 = vec3(cos(orientation), 0, sin(orientation));
    const vec3 a = v0 + v * (v1 - v0);
    const vec3 b = v1 + v * (v2 - v1);
    const vec3 c = a + v * (b - a);
    const vec3 c0 = c - width * t1;
    const vec3 c1 = c + width * t1;
    const vec3 t0 = normalize(b - a);
    nor = normalize(cross(t0, t1));

    // position
    const float t = u + 0.5f * v - u * v; //triangle
    const vec3 pos = mix(c0, c1, t);
    gl_Position = camera.proj * camera.view * vec4(pos, 1.f);

    // height fraction
    heightFrac = pos.y / height;
}
