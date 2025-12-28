package daxa

import vk "vendor:vulkan"

foreign import lib "daxa.lib"
_ :: lib


// TODO:    Rename errors based on their fatality!
//          DAXA_RESULT_FATAL_ERROR should be the prefix for unrecoverable errors.
Result :: enum i32 {
	SUCCESS                                              = 0,
	NOT_READY                                            = 1,
	TIMEOUT                                              = 2,
	EVENT_SET                                            = 3,
	EVENT_RESET                                          = 4,
	INCOMPLETE                                           = 5,
	ERROR_OUT_OF_HOST_MEMORY                             = -1,
	ERROR_OUT_OF_DEVICE_MEMORY                           = -2,
	ERROR_INITIALIZATION_FAILED                          = -3,
	ERROR_DEVICE_LOST                                    = -4,
	ERROR_MEMORY_MAP_FAILED                              = -5,
	ERROR_LAYER_NOT_PRESENT                              = -6,
	ERROR_EXTENSION_NOT_PRESENT                          = -7,
	ERROR_FEATURE_NOT_PRESENT                            = -8,
	ERROR_INCOMPATIBLE_DRIVER                            = -9,
	ERROR_TOO_MANY_OBJECTS                               = -10,
	ERROR_FORMAT_NOT_SUPPORTED                           = -11,
	ERROR_FRAGMENTED_POOL                                = -12,
	ERROR_UNKNOWN                                        = -13,
	ERROR_OUT_OF_POOL_MEMORY                             = -1000069000,
	ERROR_INVALID_EXTERNAL_HANDLE                        = -1000072003,
	ERROR_FRAGMENTATION                                  = -1000161000,
	ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS                 = -1000257000,
	PIPELINE_COMPILE_REQUIRED                            = 1000297000,
	ERROR_SURFACE_LOST_KHR                               = -1000000000,
	ERROR_NATIVE_WINDOW_IN_USE_KHR                       = -1000000001,
	SUBOPTIMAL_KHR                                       = 1000001003,
	ERROR_OUT_OF_DATE_KHR                                = -1000001004,
	ERROR_INCOMPATIBLE_DISPLAY_KHR                       = -1000003001,
	ERROR_VALIDATION_FAILED_EXT                          = -1000011001,
	ERROR_INVALID_SHADER_NV                              = -1000012000,
	ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR                  = -1000023000,
	ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR         = -1000023001,
	ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR      = -1000023002,
	ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR         = -1000023003,
	ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR          = -1000023004,
	ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR            = -1000023005,
	ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT   = -1000158000,
	ERROR_NOT_PERMITTED_KHR                              = -1000174001,
	ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT            = -1000255000,
	THREAD_IDLE_KHR                                      = 1000268000,
	THREAD_DONE_KHR                                      = 1000268001,
	OPERATION_DEFERRED_KHR                               = 1000268002,
	OPERATION_NOT_DEFERRED_KHR                           = 1000268003,
	MISSING_EXTENSION                                    = 1073741824,
	INVALID_BUFFER_ID                                    = 1073741825,
	INVALID_IMAGE_ID                                     = 1073741826,
	INVALID_IMAGE_VIEW_ID                                = 1073741827,
	INVALID_SAMPLER_ID                                   = 1073741828,
	BUFFER_DOUBLE_FREE                                   = 1073741829,
	IMAGE_DOUBLE_FREE                                    = 1073741830,
	IMAGE_VIEW_DOUBLE_FREE                               = 1073741831,
	SAMPLER_DOUBLE_FREE                                  = 1073741832,
	INVALID_BUFFER_INFO                                  = 1073741833,
	INVALID_IMAGE_INFO                                   = 1073741834,
	INVALID_IMAGE_VIEW_INFO                              = 1073741835,
	INVALID_SAMPLER_INFO                                 = 1073741836,
	COMMAND_LIST_COMPLETED                               = 1073741837,
	COMMAND_LIST_NOT_COMPLETED                           = 1073741838,
	INVALID_CLEAR_VALUE                                  = 1073741839,
	BUFFER_NOT_HOST_VISIBLE                              = 1073741840,
	BUFFER_NOT_DEVICE_VISIBLE                            = 1073741841,
	INCOMPLETE_COMMAND_LIST                              = 1073741842,
	DEVICE_DOES_NOT_SUPPORT_BUFFER_COUNT                 = 1073741843,
	DEVICE_DOES_NOT_SUPPORT_IMAGE_COUNT                  = 1073741844,
	DEVICE_DOES_NOT_SUPPORT_SAMPLER_COUNT                = 1073741845,
	FAILED_TO_CREATE_NULL_BUFFER                         = 1073741846,
	FAILED_TO_CREATE_NULL_IMAGE                          = 1073741847,
	FAILED_TO_CREATE_NULL_IMAGE_VIEW                     = 1073741848,
	FAILED_TO_CREATE_NULL_SAMPLER                        = 1073741849,
	FAILED_TO_CREATE_BUFFER                              = 1073741850,
	FAILED_TO_CREATE_IMAGE                               = 1073741851,
	FAILED_TO_CREATE_IMAGE_VIEW                          = 1073741852,
	FAILED_TO_CREATE_DEFAULT_IMAGE_VIEW                  = 1073741853,
	FAILED_TO_CREATE_SAMPLER                             = 1073741854,
	FAILED_TO_CREATE_BDA_BUFFER                          = 1073741855,
	FAILED_TO_SUBMIT_DEVICE_INIT_COMMANDS                = 1073741856,
	INVALID_BUFFER_RANGE                                 = 1073741857,
	INVALID_BUFFER_OFFSET                                = 1073741858,
	NO_SUITABLE_FORMAT_FOUND                             = 1073741860,
	RANGE_OUT_OF_BOUNDS                                  = 1073741861,
	NO_SUITABLE_DEVICE_FOUND                             = 1073741862,
	EXCEEDED_MAX_BUFFERS                                 = 1073741863,
	EXCEEDED_MAX_IMAGES                                  = 1073741864,
	EXCEEDED_MAX_IMAGE_VIEWS                             = 1073741865,
	EXCEEDED_MAX_SAMPLERS                                = 1073741866,
	DEVICE_SURFACE_UNSUPPORTED_PRESENT_MODE              = 1073741867,
	COMMAND_REFERENCES_INVALID_BUFFER_ID                 = 1073741868,
	COMMAND_REFERENCES_INVALID_IMAGE_ID                  = 1073741869,
	COMMAND_REFERENCES_INVALID_IMAGE_VIEW_ID             = 1073741870,
	COMMAND_REFERENCES_INVALID_SAMPLER_ID                = 1073741871,
	INVALID_ACCELERATION_STRUCTURE_ID                    = 1073741872,
	EXCEEDED_MAX_ACCELERATION_STRUCTURES                 = 1073741873,
	DEVICE_DOES_NOT_SUPPORT_RAYTRACING                   = 1073741874,
	DEVICE_DOES_NOT_SUPPORT_MESH_SHADER                  = 1073741875,
	INVALID_TLAS_ID                                      = 1073741876,
	INVALID_BLAS_ID                                      = 1073741877,
	INVALID_WITHOUT_ENABLING_RAY_TRACING                 = 1073741878,
	NO_COMPUTE_PIPELINE_SET                              = 1073741879,
	NO_RASTER_PIPELINE_SET                               = 1073741880,
	NO_RAYTRACING_PIPELINE_SET                           = 1073741881,
	NO_PIPELINE_SET                                      = 1073741882,
	PUSH_CONSTANT_RANGE_EXCEEDED                         = 1073741883,
	MESH_SHADER_NOT_DEVICE_ENABLED                       = 1073741884,
	ERROR_COPY_OUT_OF_BOUNDS                             = 1073741885,
	ERROR_NO_GRAPHICS_QUEUE_FOUND                        = 1073741886,
	ERROR_COULD_NOT_QUERY_QUEUE                          = 1073741887,
	ERROR_INVALID_QUEUE                                  = 1073741888,
	ERROR_CMD_LIST_SUBMIT_QUEUE_FAMILY_MISMATCH          = 1073741889,
	ERROR_PRESENT_QUEUE_FAMILY_MISMATCH                  = 1073741890,
	ERROR_INVALID_QUEUE_FAMILY                           = 1073741891,
	ERROR_INVALID_DEVICE_INDEX                           = 1073741892,
	ERROR_DEVICE_NOT_SUPPORTED                           = 1073741893,
	DEVICE_DOES_NOT_SUPPORT_ACCELERATION_STRUCTURE_COUNT = 1073741894,
	ERROR_NO_SUITABLE_DEVICE_FOUND                       = 1073741895,
	ERROR_COMPUTE_FAMILY_CMD_ON_TRANSFER_QUEUE_RECORDER  = 1073741896,
	ERROR_MAIN_FAMILY_CMD_ON_TRANSFER_QUEUE_RECORDER     = 1073741897,
	ERROR_MAIN_FAMILY_CMD_ON_COMPUTE_QUEUE_RECORDER      = 1073741898,
	ERROR_ZERO_REQUIRED_MEMORY_TYPE_BITS                 = 1073741899,
	ERROR_ALLOC_FLAGS_MUST_BE_ZERO_ON_BLOCK_ALLOCATION   = 1073741900,
	ERROR_EXCEEDED_MAX_COMMAND_POOLS                     = 1073741901,
	ERROR_CMD_LIST_ALREADY_COMPLETED                     = 1073741902,
	MAX_ENUM                                             = 2147483647,
}

// ImageLayout matches vulkan's image layouts
ImageLayout :: enum i32 {
	UNDEFINED            = 0,
	GENERAL              = 1,
	// TRANSFER_SRC_OPTIMAL = 6, // deprecated
	// TRANSFER_DST_OPTIMAL = 7, // deprecated
	// READ_ONLY_OPTIMAL    = 1000314000, // deprecated
	// ATTACHMENT_OPTIMAL   = 1000314001, // deprecated
	PRESENT_SRC          = 1000001002,
	MAX_ENUM             = 2147483647,
}

ImageMipArraySlice :: struct {
	base_mip_level:   u32,
	level_count:      u32,
	base_array_layer: u32,
	layer_count:      u32,
}
DEFAULT_IMAGE_MIP_ARRAY_SLICE :: ImageMipArraySlice {
	base_mip_level   = 0,
	level_count      = 1,
	base_array_layer = 0,
	layer_count      = 1,
}

ImageArraySlice :: struct {
	mip_level:        u32,
	base_array_layer: u32,
	layer_count:      u32,
}
DEFAULT_IMAGE_ARRAY_SLICE :: ImageArraySlice{
	mip_level        = 0,
	base_array_layer = 0,
	layer_count      = 1,
}

ImageSlice :: struct {
	mip_level:   u32,
	array_layer: u32,
}

MemoryFlag :: enum u32 {
	HOST_ACCESS_SEQUENTIAL_WRITE = 10,
	HOST_ACCESS_RANDOM = 11,
}
MemoryFlags :: bit_set[MemoryFlag; u32]
MEMORY_FLAG_NONE :: MemoryFlags{}

MemoryBlockInfo :: struct {
	requirements: vk.MemoryRequirements,
	flags:        MemoryFlags,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	memory_block_info       :: proc(memory_block: MemoryBlock) -> ^MemoryBlockInfo ---
	memory_block_inc_refcnt :: proc(memory_block: MemoryBlock) -> u64 ---
	memory_block_dec_refcnt :: proc(memory_block: MemoryBlock) -> u64 ---
}

TimelineQueryPoolInfo :: struct {
	query_count: u32,
	name:        SmallString,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	timeline_query_pool_info          :: proc(timeline_query_pool: TimelineQueryPool) -> ^TimelineQueryPoolInfo ---
	timeline_query_pool_query_results :: proc(timeline_query_pool: TimelineQueryPool, start: u32, count: u32, out_results: ^u64) -> Result ---
	timeline_query_pool_inc_refcnt    :: proc(timeline_query_pool: TimelineQueryPool) -> u64 ---
	timeline_query_pool_dec_refcnt    :: proc(timeline_query_pool: TimelineQueryPool) -> u64 ---
}

QueueFamily :: enum i32 {
	MAIN     = 0,
	COMPUTE  = 1,
	TRANSFER = 2,
	MAX_ENUM = 3,
}

RayTracingShaderBindingTable :: struct {
	raygen_region:   vk.StridedDeviceAddressRegionKHR,
	miss_region:     vk.StridedDeviceAddressRegionKHR,
	hit_region:      vk.StridedDeviceAddressRegionKHR,
	callable_region: vk.StridedDeviceAddressRegionKHR,
}

