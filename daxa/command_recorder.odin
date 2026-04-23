package daxa

import "core:c"
import vk "vendor:vulkan"


foreign import lib "daxa.lib"
_ :: lib

/// WARNING:
///   Checks for command types against queue type only performed in c++ api!!
PushConstantInfo :: struct {
	data: rawptr,
	size: u64,
}

CommandRecorderInfo :: struct {
	queue_type: QueueType,
	name:       SmallString,
}

ImageBlitInfo :: struct #all_or_none {
	src_image:        ImageId,
	dst_image:        ImageId,
	src_slice:        ImageArraySlice,
	src_offsets:      [2]vk.Offset3D,
	dst_slice:        ImageArraySlice,
	dst_offsets:      [2]vk.Offset3D,
	filter:           vk.Filter,
}
DEFAULT_IMAGE_BLIT_INFO :: ImageBlitInfo{
	src_image = {},
	dst_image = {},
	src_slice = DEFAULT_IMAGE_ARRAY_SLICE,
	src_offsets = {},
	dst_slice = DEFAULT_IMAGE_ARRAY_SLICE,
	dst_offsets = {},
	filter = .NEAREST,
}

BufferCopyInfo :: struct {
	src_buffer: BufferId,
	dst_buffer: BufferId,
	src_offset: c.size_t,
	dst_offset: c.size_t,
	size:       c.size_t,
}
// DEFAULT_BUFFER_COPY_INFO :: BufferCopyInfo{}

BufferImageCopyInfo :: struct #all_or_none {
	src_buffer:    BufferId,
	buffer_offset: c.size_t,
	dst_image:     ImageId,
	image_slice:   ImageArraySlice,
	image_offset:  vk.Offset3D,
	image_extent:  vk.Offset3D,
}
DEFAULT_BUFFER_IMAGE_COPY_INFO :: BufferImageCopyInfo{
	src_buffer = {},
	buffer_offset = 0,
	dst_image = {},
	image_slice = DEFAULT_IMAGE_ARRAY_SLICE,
	image_offset = {},
	image_extent = {},
}


ImageBufferCopyInfo :: struct #all_or_none {
	src_image:     ImageId,
	image_slice:   ImageArraySlice,
	image_offset:  vk.Offset3D,
	image_extent:  vk.Offset3D,
	dst_buffer:    BufferId,
	buffer_offset: c.size_t,
}
DEFAULT_IMAGE_BUFFER_COPY_INFO :: ImageBufferCopyInfo{
	src_image = {},
	image_slice = DEFAULT_IMAGE_ARRAY_SLICE,
	image_offset = {},
	image_extent = {},
	dst_buffer = {},
	buffer_offset = 0,
}

ImageCopyInfo :: struct #all_or_none {
	src_image:        ImageId,
	dst_image:        ImageId,
	src_slice:        ImageArraySlice,
	src_offset:       vk.Offset3D,
	dst_slice:        ImageArraySlice,
	dst_offset:       vk.Offset3D,
	extent:           vk.Offset3D,
}
DEFAULT_IMAGE_COPY_INFO :: ImageCopyInfo{
	src_image = {},
	dst_image = {},
	src_slice = DEFAULT_IMAGE_ARRAY_SLICE,
	src_offset = {},
	dst_slice = DEFAULT_IMAGE_ARRAY_SLICE,
	dst_offset = {},
	extent = {},
}

ImageClearInfo :: struct #all_or_none {
	image: ImageId,
	slice: ImageMipArraySlice,

	// Make sure this stays abi compatible with daxa::ClearValue
	clear_value: Variant(vk.ClearValue),
}
DEFAULT_IMAGE_CLEAR_INFO :: ImageClearInfo{
	image       = {},
	slice       = DEFAULT_IMAGE_MIP_ARRAY_SLICE,
	clear_value = {},
}

BufferClearInfo :: struct {
	buffer:      BufferId,
	offset:      c.size_t,
	size:        c.size_t,
	clear_value: u32,
}

AttachmentResolveInfo :: struct #all_or_none {
	mode:  vk.ResolveModeFlags,
	image: ImageViewId,
}
DEFAULT_RENDER_ATTACHMENT_RESOLVE_INFO :: AttachmentResolveInfo{
	mode = {.AVERAGE},
	image = {},
}

RenderAttachmentInfo :: struct #all_or_none {
	image_view: ImageViewId,
	load_op:    vk.AttachmentLoadOp,
	store_op:   vk.AttachmentStoreOp,

	clear_value: Variant(vk.ClearValue),
	resolve: Optional(AttachmentResolveInfo),
}
DEFAULT_RENDER_ATTACHMENT_INFO :: RenderAttachmentInfo{
	image_view = {},
	load_op = .DONT_CARE,
	store_op = .STORE,
	clear_value = {},
	resolve = {},
}

RenderPassBeginInfo :: struct {
	color_attachments: FixedList(RenderAttachmentInfo, 8),
	depth_attachment: Optional(RenderAttachmentInfo),
	stencil_attachment: Optional(RenderAttachmentInfo),
	render_area: vk.Rect2D,
}
// DEFAULT_RENDERPASS_BEGIN_INFO :: RenderPassBeginInfo{}

TraceRaysInfo :: struct {
	width:                  u32,
	height:                 u32,
	depth:                  u32,
	raygen_handle_offset:   u32,
	miss_handle_offset:     u32,
	hit_handle_offset:      u32,
	callable_handle_offset: u32,
	shader_binding_table:   RayTracingShaderBindingTable,
}

TraceRaysIndirectInfo :: struct {
	indirect_device_address: u64,
	raygen_handle_offset:    u32,
	miss_handle_offset:      u32,
	hit_handle_offset:       u32,
	callable_handle_offset:  u32,
	shader_binding_table:    RayTracingShaderBindingTable,
}

DispatchInfo :: struct {
	x: u32,
	y: u32,
	z: u32,
}

DispatchIndirectInfo :: struct {
	indirect_buffer: BufferId,
	offset:          c.size_t,
}

DrawMeshTasksInfo :: struct {
	x: u32,
	y: u32,
	z: u32,
}
DEFAULT_DRAW_MESH_TASKS_INFO :: DrawMeshTasksInfo{}

DrawMeshTasksIndirectInfo :: struct #all_or_none {
	indirect_buffer: BufferId,
	offset:          c.size_t,
	draw_count:      u32,
	stride:          u32,
}
DEFAULT_DRAW_MESH_TASKS_INDIRECT_INFO :: DrawMeshTasksIndirectInfo{
	indirect_buffer = {},
	offset = 0,
	draw_count = 1,
	stride = 12,
}

DrawMeshTasksIndirectCountInfo :: struct {
	indirect_buffer: BufferId,
	offset:          c.size_t,
	count_buffer:    BufferId,
	count_offset:    c.size_t,
	max_count:       u32,
	stride:          u32,
}

DrawInfo :: struct #all_or_none {
	vertex_count:   u32,
	instance_count: u32,
	first_vertex:   u32,
	first_instance: u32,
}
DEFAULT_DRAW_INFO :: DrawInfo{
	vertex_count = 0,
	instance_count = 1,
	first_vertex = 0,
	first_instance = 0,
}

DrawIndexedInfo :: struct #all_or_none {
	index_count:    u32,
	instance_count: u32,
	first_index:    u32,
	vertex_offset:  i32,
	first_instance: u32,
}
DEFAULT_DRAW_INDEXED_INFO :: DrawIndexedInfo{
	index_count = 0,
	instance_count = 1,
	first_index = 0,
	vertex_offset = 0,
	first_instance = 0,
}

DrawIndirectInfo :: struct #all_or_none {
	indirect_buffer:        BufferId,
	indirect_buffer_offset: c.size_t,
	draw_count:             u32,
	draw_command_stride:    u32,
	is_indexed:             Bool8,
}
DEFAULT_DRAW_INDIRECT_COUNT_INFO :: DrawIndirectCountInfo{
	indirect_buffer = {},
	indirect_buffer_offset = 0,
	count_buffer = {},
	count_buffer_offset = 0,
	max_draw_count = u32(max(u16)),
	draw_command_stride = 0,
	is_indexed = false,
}

DrawIndirectCountInfo :: struct {
	indirect_buffer:        BufferId,
	indirect_buffer_offset: c.size_t,
	count_buffer:           BufferId,
	count_buffer_offset:    c.size_t,
	max_draw_count:         u32,
	draw_command_stride:    u32,
	is_indexed:             Bool8,
}

ResetEventsInfo :: struct {
	event: ^Event,
	stage: vk.PipelineStageFlags,
}

WaitEventsInfo :: struct {
	events:      ^Event,
	event_count: c.size_t,
}

WriteTimestampInfo :: struct {
	query_pool:     ^TimelineQueryPool,
	pipeline_stage: vk.PipelineStageFlags2,
	query_index:    u32,
}

ResetTimestampsInfo :: struct {
	query_pool:  ^TimelineQueryPool,
	start_index: u32,
	count:       u32,
}

CommandLabelInfo :: struct {
	label_color: f32vec4,
	name:        SmallString,
}

ResetEventInfo :: struct {
	barrier:     ^Event,
	stage_masks: vk.PipelineStageFlags,
}

DepthBiasInfo :: struct {
	constant_factor: f32,
	clamp:           f32,
	slope_factor:    f32,
}

SetIndexBufferInfo :: struct #all_or_none {
	buffer:     BufferId,
	offset:     c.size_t,
	index_type: vk.IndexType,
}
DEFAULT_SET_INDEX_BUFFER_INFO :: SetIndexBufferInfo{
	buffer = {},
	offset = 0,
	index_type = .UINT32,
}

BuildAccelerationStucturesInfo :: struct {
	tlas_build_infos:      ^TlasBuildInfo,
	tlas_build_info_count: c.size_t,
	blas_build_infos:      ^BlasBuildInfo,
	blas_build_info_count: c.size_t,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	cmd_set_rasterization_samples     :: proc(cmd_enc: CommandRecorder, samples: vk.SampleCountFlags) -> Result ---
	cmd_copy_buffer_to_buffer         :: proc(cmd_enc: CommandRecorder, info: ^BufferCopyInfo) -> Result ---
	cmd_copy_buffer_to_image          :: proc(cmd_enc: CommandRecorder, info: ^BufferImageCopyInfo) -> Result ---
	cmd_copy_image_to_buffer          :: proc(cmd_enc: CommandRecorder, info: ^ImageBufferCopyInfo) -> Result ---
	cmd_copy_image_to_image           :: proc(cmd_enc: CommandRecorder, info: ^ImageCopyInfo) -> Result ---
	cmd_blit_image_to_image           :: proc(cmd_enc: CommandRecorder, info: ^ImageBlitInfo) -> Result ---
	cmd_build_acceleration_structures :: proc(cmd_rec: CommandRecorder, info: ^BuildAccelerationStucturesInfo) -> Result ---
	cmd_clear_buffer                  :: proc(cmd_enc: CommandRecorder, info: ^BufferClearInfo) -> Result ---
	cmd_clear_image                   :: proc(cmd_enc: CommandRecorder, info: ^ImageClearInfo) -> Result ---

	/// @brief  Successive pipeline barrier calls are combined.
	///         As soon as a non-pipeline barrier command is recorded, the currently recorded barriers are flushed with a vkCmdPipelineBarrier2 call.
	/// @param info parameters.
	cmd_pipeline_barrier :: proc(cmd_enc: CommandRecorder, info: ^BarrierInfo) ---

	/// @brief  Successive pipeline barrier calls are combined.
	///         As soon as a non-pipeline barrier command is recorded, the currently recorded barriers are flushed with a vkCmdPipelineBarrier2 call.
	/// @param info parameters.
	cmd_pipeline_image_barrier   :: proc(cmd_enc: CommandRecorder, info: ^ImageBarrierInfo) -> Result ---
	cmd_signal_event             :: proc(cmd_enc: CommandRecorder, info: ^EventSignalInfo) ---
	cmd_wait_events              :: proc(cmd_enc: CommandRecorder, infos: ^EventWaitInfo, info_count: c.size_t) ---
	cmd_wait_event               :: proc(cmd_enc: CommandRecorder, info: ^EventWaitInfo) ---
	cmd_reset_event              :: proc(cmd_enc: CommandRecorder, info: ^ResetEventInfo) ---
	cmd_push_constant            :: proc(cmd_enc: CommandRecorder, info: ^PushConstantInfo) -> Result ---
	cmd_set_ray_tracing_pipeline :: proc(cmd_enc: CommandRecorder, pipeline: RayTracingPipeline) -> Result ---
	cmd_set_compute_pipeline     :: proc(cmd_enc: CommandRecorder, pipeline: ComputePipeline) -> Result ---
	cmd_set_raster_pipeline      :: proc(cmd_enc: CommandRecorder, pipeline: RasterPipeline) -> Result ---
	cmd_dispatch                 :: proc(cmd_enc: CommandRecorder, info: ^DispatchInfo) -> Result ---
	cmd_dispatch_indirect        :: proc(cmd_enc: CommandRecorder, info: ^DispatchIndirectInfo) -> Result ---

	/// @brief  Destroys the buffer AFTER the gpu is finished executing the command list.
	///         Useful for large uploads exceeding staging memory pools.
	cmd_destroy_buffer_deferred :: proc(cmd_enc: CommandRecorder, buffer: BufferId) -> Result ---

	/// @brief  Destroys the image AFTER the gpu is finished executing the command list.
	///         Useful for large uploads exceeding staging memory pools.
	cmd_destroy_image_deferred :: proc(cmd_enc: CommandRecorder, image: ImageId) -> Result ---

	/// @brief  Destroys the image view AFTER the gpu is finished executing the command list.
	///         Useful for large uploads exceeding staging memory pools.
	cmd_destroy_image_view_deferred :: proc(cmd_enc: CommandRecorder, image_view: ImageViewId) -> Result ---

	/// @brief  Destroys the sampler AFTER the gpu is finished executing the command list.
	///         Useful for large uploads exceeding staging memory pools.
	cmd_destroy_sampler_deferred :: proc(cmd_enc: CommandRecorder, sampler: SamplerId) -> Result ---
	cmd_trace_rays               :: proc(cmd_enc: CommandRecorder, info: ^TraceRaysInfo) -> Result ---
	cmd_trace_rays_indirect      :: proc(cmd_enc: CommandRecorder, info: ^TraceRaysIndirectInfo) -> Result ---

	/// @brief  Starts a renderpass scope akin to the dynamic rendering feature in vulkan.
	///         Between the begin and end renderpass commands, the renderpass persists and draw-calls can be recorded.
	/// @param info parameters.
	cmd_begin_renderpass :: proc(cmd_enc: CommandRecorder, info: ^RenderPassBeginInfo) -> Result ---

	/// @brief  Ends a renderpass scope akin to the dynamic rendering feature in vulkan.
	///         Between the begin and end renderpass commands, the renderpass persists and draw-calls can be recorded.
	cmd_end_renderpass                 :: proc(cmd_enc: CommandRecorder) ---
	cmd_set_viewport                   :: proc(cmd_enc: CommandRecorder, info: ^vk.Viewport) ---
	cmd_set_scissor                    :: proc(cmd_enc: CommandRecorder, info: ^vk.Rect2D) ---
	cmd_set_depth_bias                 :: proc(cmd_enc: CommandRecorder, info: ^DepthBiasInfo) ---
	cmd_set_index_buffer               :: proc(cmd_enc: CommandRecorder, info: ^SetIndexBufferInfo) -> Result ---
	cmd_draw                           :: proc(cmd_enc: CommandRecorder, info: ^DrawInfo) ---
	cmd_draw_indexed                   :: proc(cmd_enc: CommandRecorder, info: ^DrawIndexedInfo) ---
	cmd_draw_indirect                  :: proc(cmd_enc: CommandRecorder, info: ^DrawIndirectInfo) -> Result ---
	cmd_draw_indirect_count            :: proc(cmd_enc: CommandRecorder, info: ^DrawIndirectCountInfo) -> Result ---
	cmd_draw_mesh_tasks                :: proc(cmd_enc: CommandRecorder, info: ^DrawMeshTasksInfo) -> Result ---
	cmd_draw_mesh_tasks_indirect       :: proc(cmd_enc: CommandRecorder, info: ^DrawMeshTasksIndirectInfo) -> Result ---
	cmd_draw_mesh_tasks_indirect_count :: proc(cmd_enc: CommandRecorder, info: ^DrawMeshTasksIndirectCountInfo) -> Result ---
	cmd_write_timestamp                :: proc(cmd_enc: CommandRecorder, info: ^WriteTimestampInfo) ---
	cmd_reset_timestamps               :: proc(cmd_enc: CommandRecorder, info: ^ResetTimestampsInfo) ---
	cmd_begin_label                    :: proc(cmd_enc: CommandRecorder, info: ^CommandLabelInfo) ---
	cmd_end_label                      :: proc(cmd_enc: CommandRecorder) ---
	cmd_reset_assumed_state            :: proc(cmd_enc: CommandRecorder) ---

	// Is called by all other commands. Flushes internal pipeline barrier list to actual vulkan call.
	cmd_flush_barriers             :: proc(cmd_enc: CommandRecorder) ---
	cmd_complete_current_commands  :: proc(cmd_enc: CommandRecorder, out_executable_cmds: ^ExecutableCommandList) -> Result ---
	cmd_info                       :: proc(cmd_enc: CommandRecorder) -> ^CommandRecorderInfo ---
	cmd_get_vk_command_buffer      :: proc(cmd_enc: CommandRecorder) -> vk.CommandBuffer ---
	cmd_get_vk_command_pool        :: proc(cmd_enc: CommandRecorder) -> vk.CommandPool ---
	destroy_command_recorder       :: proc(cmd_enc: CommandRecorder) ---
	executable_commands_inc_refcnt :: proc(executable_commands: ExecutableCommandList) -> u64 ---
	executable_commands_dec_refcnt :: proc(executable_commands: ExecutableCommandList) -> u64 ---
}

