#version 450
#extension GL_EXT_debug_printf : enable

#include <daxa/daxa.inl>

struct Vertex {
	daxa_f32vec3 pos;
};
DAXA_DECL_BUFFER_PTR(Vertex)

struct Params {
	daxa_f32mat4x4         mvp;
	float                  scale;
	daxa_BufferPtr(Vertex) ptr;
	daxa_SamplerId         smp;
	daxa_ImageViewId       tex;
};
DAXA_DECL_PUSH_CONSTANT(Params, push)


#if DAXA_SHADER_STAGE == DAXA_SHADER_STAGE_VERTEX

layout(location = 0) out daxa_f32vec3 uvw;
void main() {
	daxa_BufferPtr(Vertex) vertices_ptr = push.ptr;
    Vertex vert = deref_i(push.ptr, gl_VertexIndex);
	vec4 position = daxa_f32vec4(vert.pos.xyz, 1);
	gl_Position = push.mvp * position;
	// debugPrintfEXT("%v4f \n", gl_Position);
	uvw = ((position.xyz * push.scale) + 1.0) * 0.5;
}

#elif DAXA_SHADER_STAGE == DAXA_SHADER_STAGE_FRAGMENT

layout(location = 0) in daxa_f32vec3 uvw;
layout(location = 0) out daxa_f32vec4 frag_color;
void main() {
	frag_color = texture(daxa_sampler3D(push.tex, push.smp), uvw);
}

#endif
