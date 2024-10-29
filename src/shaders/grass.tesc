#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(vertices = 1) out;

#define TESSELATION_LEVEL_MIN 1.0
#define TESSELATION_LEVEL_MAX 10.0
#define TESSELATION_DIST 20.0

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare tessellation control shader inputs and outputs
layout(location = 0) in vec4 v0_cs[];
layout(location = 1) in vec4 v1_cs[];
layout(location = 2) in vec4 v2_cs[];
layout(location = 3) in vec4 up_cs[];

layout(location = 0) out vec4 v0_es[];
layout(location = 1) out vec4 v1_es[];
layout(location = 2) out vec4 v2_es[];
layout(location = 3) out vec4 up_es[];


int getTessLevel(float distance)
{
    return int(mix(TESSELATION_LEVEL_MIN, TESSELATION_LEVEL_MAX, max(0.f, (TESSELATION_DIST - distance)) / TESSELATION_DIST));
}

void main() {
	// Don't move the origin location of the patch
    gl_out[gl_InvocationID].gl_Position = v0_cs[gl_InvocationID];

	// TODO: Write any shader outputs
    v0_es[gl_InvocationID] = v0_cs[gl_InvocationID];
    v1_es[gl_InvocationID] = v1_cs[gl_InvocationID];
    v2_es[gl_InvocationID] = v2_cs[gl_InvocationID];
    up_es[gl_InvocationID] = up_cs[gl_InvocationID];

	// TODO: Set level of tesselation
    const vec3 cameraPos = inverse(camera.view)[3].xyz;
    const int TESSELATION_LEVEL = getTessLevel(distance(v0_cs[gl_InvocationID].xyz, cameraPos));
    gl_TessLevelInner[0] = TESSELATION_LEVEL;
    gl_TessLevelInner[1] = TESSELATION_LEVEL;
    gl_TessLevelOuter[0] = TESSELATION_LEVEL;
    gl_TessLevelOuter[1] = TESSELATION_LEVEL;
    gl_TessLevelOuter[2] = TESSELATION_LEVEL;
    gl_TessLevelOuter[3] = TESSELATION_LEVEL;
}
