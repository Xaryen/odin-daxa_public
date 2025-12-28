package daxa

import "core:c"
import vk "vendor:vulkan"


foreign import lib "daxa.lib"
_ :: lib

ShaderInfo :: struct {
	byte_code:      ^u32,
	byte_code_size: u32,
	create_flags:   vk.PipelineShaderStageCreateFlags,

	required_subgroup_size: Optional(u32),

	entry_point: SmallString,
}

// RAY TRACING PIPELINE
RayTracingShaderInfo :: struct {
	info: ShaderInfo,
}

RayTracingShaderGroupInfo :: struct {
	// TODO: daxa types?
	type:                      vk.RayTracingShaderGroupTypeKHR,
	general_shader_index:      u32,
	closest_hit_shader_index:  u32,
	any_hit_shader_index:      u32,
	intersection_shader_index: u32,
}

RayTracingPipelineInfo :: struct {
	ray_gen_stages: struct {
		data: ^RayTracingShaderInfo,
		size: c.size_t,
	},

	miss_stages: struct {
		data: ^RayTracingShaderInfo,
		size: c.size_t,
	},

	callable_stages: struct {
		data: ^RayTracingShaderInfo,
		size: c.size_t,
	},

	intersection_stages: struct {
		data: ^RayTracingShaderInfo,
		size: c.size_t,
	},

	closest_hit_stages: struct {
		data: ^RayTracingShaderInfo,
		size: c.size_t,
	},

	any_hit_stages: struct {
		data: ^RayTracingShaderInfo,
		size: c.size_t,
	},

	shader_groups: struct {
		data: ^RayTracingShaderGroupInfo,
		size: c.size_t,
	},

	pipeline_libraries: struct {
		data: ^RayTracingPipelineLibrary,
		size: c.size_t,
	},

	max_ray_recursion_depth: u32,
	push_constant_size:      u32,
	name:                    SmallString,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	ray_tracing_pipeline_info               :: proc(ray_tracing_pipeline: RayTracingPipeline) -> ^RayTracingPipelineInfo ---
	ray_tracing_pipeline_create_default_sbt :: proc(pipeline: RayTracingPipeline, out_sbt: ^RayTracingShaderBindingTable, out_buffer: ^BufferId) -> Result ---

	// out_blob must be the size of the group_count * raytracing_properties.shaderGroupHandleSize
	// if group_count is -1, this function will infer it from the groups specified in pipeline creation
	ray_tracing_pipeline_get_shader_group_handles :: proc(pipeline: RayTracingPipeline, out_blob: rawptr, first_group: u32, group_count: i32) -> Result ---
	ray_tracing_pipeline_inc_refcnt               :: proc(pipeline: RayTracingPipeline) -> u64 ---
	ray_tracing_pipeline_dec_refcnt               :: proc(pipeline: RayTracingPipeline) -> u64 ---
	ray_tracing_pipeline_library_info             :: proc(pipeline_library: RayTracingPipelineLibrary) -> ^RayTracingPipelineInfo ---

	// out_blob must be the size of the group_count * raytracing_properties.shaderGroupHandleSize
	// if group_count is -1, this function will infer it from the groups specified in pipeline creation
	ray_tracing_pipeline_library_get_shader_group_handles :: proc(pipeline_library: RayTracingPipelineLibrary, out_blob: rawptr, first_group: u32, group_count: i32) -> Result ---
	ray_tracing_pipeline_library_inc_refcnt               :: proc(pipeline_library: RayTracingPipelineLibrary) -> u64 ---
	ray_tracing_pipeline_library_dec_refcnt               :: proc(pipeline_library: RayTracingPipelineLibrary) -> u64 ---
}

// COMPUTE PIPELINE
ComputePipelineInfo :: struct {
	shader_info:        ShaderInfo,
	push_constant_size: u32,
	name:               SmallString,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	compute_pipeline_info       :: proc(compute_pipeline: ComputePipeline) -> ^ComputePipelineInfo ---
	compute_pipeline_inc_refcnt :: proc(pipeline: ComputePipeline) -> u64 ---
	compute_pipeline_dec_refcnt :: proc(pipeline: ComputePipeline) -> u64 ---
}

// RASTER PIPELINE
DepthTestInfo :: struct #all_or_none {
	depth_attachment_format: vk.Format,
	enable_depth_write:      Bool8,
	depth_test_compare_op:   vk.CompareOp,
	min_depth_bounds:        f32,
	max_depth_bounds:        f32,
}
DEFAULT_DEPTH_TEST_INFO :: DepthTestInfo{
	depth_attachment_format = .UNDEFINED,
	enable_depth_write      = false,
	depth_test_compare_op   = .LESS_OR_EQUAL,
	min_depth_bounds        = 0,
	max_depth_bounds        = 1,
}

ConservativeRasterInfo :: struct {
	mode: vk.ConservativeRasterizationModeEXT,
	size: f32,
}

LineRasterInfo :: struct {
	mode:            vk.LineRasterizationModeKHR,
	stippled:        Bool8,
	stipple_factor:  u32,
	stipple_pattern: u16,
}

RasterizerInfo :: struct {
	primitive_topology:         vk.PrimitiveTopology,
	primitive_restart_enable:   Bool8,
	polygon_mode:               vk.PolygonMode,
	face_culling:               vk.CullModeFlags,
	front_face_winding:         vk.FrontFace,
	depth_clamp_enable:         Bool8,
	rasterizer_discard_enable:  Bool8,
	depth_bias_enable:          Bool8,
	depth_bias_constant_factor: f32,
	depth_bias_clamp:           f32,
	depth_bias_slope_factor:    f32,
	line_width:                 f32,

	conservative_raster_info: Optional(ConservativeRasterInfo),
	line_raster_info: Optional(LineRasterInfo),

	static_state_sample_count: Optional(vk.SampleCountFlags),
}
DEFAULT_RASTERIZATION_INFO :: RasterizerInfo{
	primitive_topology = .TRIANGLE_LIST,
	primitive_restart_enable = false,
	polygon_mode = .FILL,
	face_culling = {},
	front_face_winding = .CLOCKWISE,
	depth_clamp_enable = false,
	rasterizer_discard_enable = false,
	depth_bias_enable = false,
	depth_bias_constant_factor = 0,
	depth_bias_clamp = 0,
	depth_bias_slope_factor = 0,
	line_width = 1,
	conservative_raster_info = {},
	line_raster_info = {},
	static_state_sample_count = {value = {._1}, has_value = true},
}

BlendInfo :: struct {
	src_color_blend_factor: vk.BlendFactor,
	dst_color_blend_factor: vk.BlendFactor,
	color_blend_op:         vk.BlendOp,
	src_alpha_blend_factor: vk.BlendFactor,
	dst_alpha_blend_factor: vk.BlendFactor,
	alpha_blend_op:         vk.BlendOp,
	color_write_mask:       vk.ColorComponentFlags,
}
DEFAULT_BLEND_INFO :: BlendInfo{
	src_color_blend_factor = .ONE,
	dst_color_blend_factor = .ZERO,
	color_blend_op = .ADD,
	src_alpha_blend_factor = .ONE,
	dst_alpha_blend_factor = .ZERO,
	alpha_blend_op = .ADD,
	color_write_mask = {.R, .G, .B, .A}
}

RenderAttachment :: struct {
	format: vk.Format,

	blend: Optional(BlendInfo),
}

TesselationInfo :: struct {
	control_points: u32,
	origin:         vk.TessellationDomainOrigin,
}

RasterPipelineInfo :: struct {
	mesh_shader_info: Optional(ShaderInfo),
	vertex_shader_info: Optional(ShaderInfo),
	tesselation_control_shader_info: Optional(ShaderInfo),
	tesselation_evaluation_shader_info: Optional(ShaderInfo),
	fragment_shader_info: Optional(ShaderInfo),
	task_shader_info: Optional(ShaderInfo),

	color_attachments: FixedList(RenderAttachment, 8),

	depth_test: Optional(DepthTestInfo),
	tesselation: Optional(TesselationInfo),

	raster:             RasterizerInfo,
	push_constant_size: u32,
	name:               SmallString,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	raster_pipeline_info       :: proc(raster_pipeline: RasterPipeline) -> ^RasterPipelineInfo ---
	raster_pipeline_inc_refcnt :: proc(pipeline: RasterPipeline) -> u64 ---
	raster_pipeline_dec_refcnt :: proc(pipeline: RasterPipeline) -> u64 ---
}

