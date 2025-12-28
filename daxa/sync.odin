package daxa

import vk "vendor:vulkan"

foreign import lib "daxa.lib"
_ :: lib

Access :: struct {
	stages:      vk.PipelineStageFlags2,
	access_type: vk.AccessFlags2,
}

BarrierInfo :: struct {
	src_access: Access,
	dst_access: Access,
}

ImageLayoutOperation :: enum i32 {
	NONE           = 0,
	TO_GENERAL     = 1,
	TO_PRESENT_SRC = 2,
}

ImageBarrierInfo :: struct {
	src_access:       Access,
	dst_access:       Access,
	image_id:         ImageId,
	layout_operation: ImageLayoutOperation,
}

BinarySemaphoreInfo :: struct {
	name: SmallString,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	binary_semaphore_info             :: proc(binary_semaphore: BinarySemaphore) -> ^BinarySemaphoreInfo ---
	binary_semaphore_get_vk_semaphore :: proc(binary_semaphore: BinarySemaphore) -> vk.Semaphore ---
	binary_semaphore_inc_refcnt       :: proc(binary_semaphore: BinarySemaphore) -> u64 ---
	binary_semaphore_dec_refcnt       :: proc(binary_semaphore: BinarySemaphore) -> u64 ---
}

TimelineSemaphoreInfo :: struct {
	initial_value: u64,
	name:          SmallString,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	timeline_semaphore_info             :: proc(timeline_semaphore: TimelineSemaphore) -> ^TimelineSemaphoreInfo ---
	timeline_semaphore_get_value        :: proc(timeline_semaphore: TimelineSemaphore, out_value: ^u64) -> Result ---
	timeline_semaphore_set_value        :: proc(timeline_semaphore: TimelineSemaphore, value: u64) -> Result ---
	timeline_semaphore_wait_for_value   :: proc(timeline_semaphore: TimelineSemaphore, value: u64, timeout: u64) -> Result ---
	timeline_semaphore_get_vk_semaphore :: proc(timeline_semaphore: TimelineSemaphore) -> vk.Semaphore ---
	timeline_semaphore_inc_refcnt       :: proc(timeline_semaphore: TimelineSemaphore) -> u64 ---
	timeline_semaphore_dec_refcnt       :: proc(timeline_semaphore: TimelineSemaphore) -> u64 ---
}

EventInfo :: struct {
	name: SmallString,
}

EventSignalInfo :: struct {
	barriers:            ^BarrierInfo,
	barrier_count:       u64,
	image_barriers:      ^ImageBarrierInfo,
	image_barrier_count: u64,
	event:               ^Event,
}

EventWaitInfo :: EventSignalInfo

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	event_info       :: proc(event: Event) -> ^EventInfo ---
	event_inc_refcnt :: proc(event: Event) -> u64 ---
	event_dec_refcnt :: proc(event: Event) -> u64 ---
}

TimelinePair :: struct {
	semaphore: TimelineSemaphore,
	value:     u64,
}

ACCESS_NONE :: Access{}

ACCESS_TRANSFER_READ :: Access{stages = {.TRANSFER}, access_type = {.MEMORY_READ}}
ACCESS_HOST_WRITE :: Access{stages = {.HOST}, access_type = {.MEMORY_WRITE}}
ACCESS_TRANSFER_WRITE :: Access{stages = {.TRANSFER}, access_type = {.MEMORY_WRITE}}

ACCESS_TOP_OF_PIPE_READ            :: Access{stages = {.TOP_OF_PIPE},                       access_type = {.MEMORY_READ}}
ACCESS_DRAW_INDIRECT_READ          :: Access{stages = {.DRAW_INDIRECT},                     access_type = {.MEMORY_READ}}
ACCESS_VERTEX_SHADER_READ          :: Access{stages = {.VERTEX_SHADER},                     access_type = {.MEMORY_READ}}
ACCESS_TESSELLATION_CONTROL_SHADER_READ :: Access{stages = {.TESSELLATION_CONTROL_SHADER}, access_type = {.MEMORY_READ}}
ACCESS_TESSELLATION_EVALUATION_SHADER_READ :: Access{stages = {.TESSELLATION_EVALUATION_SHADER}, access_type = {.MEMORY_READ}}
ACCESS_GEOMETRY_SHADER_READ        :: Access{stages = {.GEOMETRY_SHADER},                   access_type = {.MEMORY_READ}}
ACCESS_FRAGMENT_SHADER_READ        :: Access{stages = {.FRAGMENT_SHADER},                   access_type = {.MEMORY_READ}}
ACCESS_EARLY_FRAGMENT_TESTS_READ   :: Access{stages = {.EARLY_FRAGMENT_TESTS},              access_type = {.MEMORY_READ}}
ACCESS_LATE_FRAGMENT_TESTS_READ    :: Access{stages = {.LATE_FRAGMENT_TESTS},               access_type = {.MEMORY_READ}}
ACCESS_COLOR_ATTACHMENT_OUTPUT_READ :: Access{stages = {.COLOR_ATTACHMENT_OUTPUT},          access_type = {.MEMORY_READ}}
ACCESS_COMPUTE_SHADER_READ         :: Access{stages = {.COMPUTE_SHADER},                    access_type = {.MEMORY_READ}}
ACCESS_BOTTOM_OF_PIPE_READ         :: Access{stages = {.BOTTOM_OF_PIPE},                    access_type = {.MEMORY_READ}}
ACCESS_HOST_READ                   :: Access{stages = {.HOST},                              access_type = {.MEMORY_READ}}
ACCESS_ALL_GRAPHICS_READ           :: Access{stages = {.ALL_GRAPHICS},                      access_type = {.MEMORY_READ}}
ACCESS_READ                        :: Access{stages = {.ALL_COMMANDS},                      access_type = {.MEMORY_READ}}
ACCESS_COPY_READ                   :: Access{stages = {.COPY},                              access_type = {.MEMORY_READ}}
ACCESS_RESOLVE_READ                :: Access{stages = {.RESOLVE},                           access_type = {.MEMORY_READ}}
ACCESS_BLIT_READ                   :: Access{stages = {.BLIT},                              access_type = {.MEMORY_READ}}
ACCESS_CLEAR_READ                  :: Access{stages = {.CLEAR},                             access_type = {.MEMORY_READ}}
ACCESS_INDEX_INPUT_READ            :: Access{stages = {.INDEX_INPUT},                       access_type = {.MEMORY_READ}}
ACCESS_PRE_RASTERIZATION_SHADERS_READ :: Access{stages = {.PRE_RASTERIZATION_SHADERS},      access_type = {.MEMORY_READ}}

ACCESS_TASK_SHADER_READ            :: Access{stages = {.TASK_SHADER_EXT},                       access_type = {.MEMORY_READ}}
ACCESS_MESH_SHADER_READ            :: Access{stages = {.MESH_SHADER_EXT},                       access_type = {.MEMORY_READ}}
ACCESS_ACCELERATION_STRUCTURE_BUILD_READ :: Access{stages = {.ACCELERATION_STRUCTURE_BUILD_KHR}, access_type = {.MEMORY_READ}}
ACCESS_RAY_TRACING_SHADER_READ     :: Access{stages = {.RAY_TRACING_SHADER_KHR},                access_type = {.MEMORY_READ}}

ACCESS_TOP_OF_PIPE_WRITE           :: Access{stages = {.TOP_OF_PIPE},                       access_type = {.MEMORY_WRITE}}
ACCESS_DRAW_INDIRECT_WRITE         :: Access{stages = {.DRAW_INDIRECT},                     access_type = {.MEMORY_WRITE}}
ACCESS_VERTEX_SHADER_WRITE         :: Access{stages = {.VERTEX_SHADER},                     access_type = {.MEMORY_WRITE}}
ACCESS_TESSELLATION_CONTROL_SHADER_WRITE :: Access{stages = {.TESSELLATION_CONTROL_SHADER}, access_type = {.MEMORY_WRITE}}
ACCESS_TESSELLATION_EVALUATION_SHADER_WRITE :: Access{stages = {.TESSELLATION_EVALUATION_SHADER}, access_type = {.MEMORY_WRITE}}
ACCESS_GEOMETRY_SHADER_WRITE       :: Access{stages = {.GEOMETRY_SHADER},                   access_type = {.MEMORY_WRITE}}
ACCESS_FRAGMENT_SHADER_WRITE       :: Access{stages = {.FRAGMENT_SHADER},                   access_type = {.MEMORY_WRITE}}
ACCESS_EARLY_FRAGMENT_TESTS_WRITE  :: Access{stages = {.EARLY_FRAGMENT_TESTS},              access_type = {.MEMORY_WRITE}}
ACCESS_LATE_FRAGMENT_TESTS_WRITE   :: Access{stages = {.LATE_FRAGMENT_TESTS},               access_type = {.MEMORY_WRITE}}
ACCESS_COLOR_ATTACHMENT_OUTPUT_WRITE :: Access{stages = {.COLOR_ATTACHMENT_OUTPUT},         access_type = {.MEMORY_WRITE}}
ACCESS_COMPUTE_SHADER_WRITE        :: Access{stages = {.COMPUTE_SHADER},                    access_type = {.MEMORY_WRITE}}
ACCESS_BOTTOM_OF_PIPE_WRITE        :: Access{stages = {.BOTTOM_OF_PIPE},                    access_type = {.MEMORY_WRITE}}
ACCESS_ALL_GRAPHICS_WRITE          :: Access{stages = {.ALL_GRAPHICS},                      access_type = {.MEMORY_WRITE}}
ACCESS_WRITE                       :: Access{stages = {.ALL_COMMANDS},                      access_type = {.MEMORY_WRITE}}
ACCESS_COPY_WRITE                  :: Access{stages = {.COPY},                              access_type = {.MEMORY_WRITE}}
ACCESS_RESOLVE_WRITE               :: Access{stages = {.RESOLVE},                           access_type = {.MEMORY_WRITE}}
ACCESS_BLIT_WRITE                  :: Access{stages = {.BLIT},                              access_type = {.MEMORY_WRITE}}
ACCESS_CLEAR_WRITE                 :: Access{stages = {.CLEAR},                             access_type = {.MEMORY_WRITE}}
ACCESS_INDEX_INPUT_WRITE           :: Access{stages = {.INDEX_INPUT},                       access_type = {.MEMORY_WRITE}}
ACCESS_PRE_RASTERIZATION_SHADERS_WRITE :: Access{stages = {.PRE_RASTERIZATION_SHADERS},     access_type = {.MEMORY_WRITE}}

ACCESS_TASK_SHADER_WRITE           :: Access{stages = {.TASK_SHADER_EXT},                       access_type = {.MEMORY_WRITE}}
ACCESS_MESH_SHADER_WRITE           :: Access{stages = {.MESH_SHADER_EXT},                       access_type = {.MEMORY_WRITE}}
ACCESS_ACCELERATION_STRUCTURE_BUILD_WRITE :: Access{stages = {.ACCELERATION_STRUCTURE_BUILD_KHR}, access_type = {.MEMORY_WRITE}}
ACCESS_RAY_TRACING_SHADER_WRITE    :: Access{stages = {.RAY_TRACING_SHADER_KHR},                access_type = {.MEMORY_WRITE}}

ACCESS_TOP_OF_PIPE_READ_WRITE      :: Access{stages = {.TOP_OF_PIPE},                       access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_DRAW_INDIRECT_READ_WRITE    :: Access{stages = {.DRAW_INDIRECT},                     access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_VERTEX_SHADER_READ_WRITE    :: Access{stages = {.VERTEX_SHADER},                     access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_TESSELLATION_CONTROL_SHADER_READ_WRITE :: Access{stages = {.TESSELLATION_CONTROL_SHADER}, access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_TESSELLATION_EVALUATION_SHADER_READ_WRITE :: Access{stages = {.TESSELLATION_EVALUATION_SHADER}, access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_GEOMETRY_SHADER_READ_WRITE  :: Access{stages = {.GEOMETRY_SHADER},                   access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_FRAGMENT_SHADER_READ_WRITE  :: Access{stages = {.FRAGMENT_SHADER},                   access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_EARLY_FRAGMENT_TESTS_READ_WRITE :: Access{stages = {.EARLY_FRAGMENT_TESTS},          access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_LATE_FRAGMENT_TESTS_READ_WRITE :: Access{stages = {.LATE_FRAGMENT_TESTS},            access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_COLOR_ATTACHMENT_OUTPUT_READ_WRITE :: Access{stages = {.COLOR_ATTACHMENT_OUTPUT},    access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_COMPUTE_SHADER_READ_WRITE   :: Access{stages = {.COMPUTE_SHADER},                    access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_TRANSFER_READ_WRITE         :: Access{stages = {.TRANSFER},                          access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_BOTTOM_OF_PIPE_READ_WRITE   :: Access{stages = {.BOTTOM_OF_PIPE},                    access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_HOST_READ_WRITE             :: Access{stages = {.HOST},                              access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_ALL_GRAPHICS_READ_WRITE     :: Access{stages = {.ALL_GRAPHICS},                      access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_READ_WRITE                  :: Access{stages = {.ALL_COMMANDS},                      access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_COPY_READ_WRITE             :: Access{stages = {.COPY},                              access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_RESOLVE_READ_WRITE          :: Access{stages = {.RESOLVE},                           access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_BLIT_READ_WRITE             :: Access{stages = {.BLIT},                              access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_CLEAR_READ_WRITE            :: Access{stages = {.CLEAR},                             access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_INDEX_INPUT_READ_WRITE      :: Access{stages = {.INDEX_INPUT},                       access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_PRE_RASTERIZATION_SHADERS_READ_WRITE :: Access{stages = {.PRE_RASTERIZATION_SHADERS}, access_type = {.MEMORY_READ, .MEMORY_WRITE}}

ACCESS_TASK_SHADER_READ_WRITE      :: Access{stages = {.TASK_SHADER_EXT},                       access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_MESH_SHADER_READ_WRITE      :: Access{stages = {.MESH_SHADER_EXT},                       access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_ACCELERATION_STRUCTURE_BUILD_READ_WRITE :: Access{stages = {.ACCELERATION_STRUCTURE_BUILD_KHR}, access_type = {.MEMORY_READ, .MEMORY_WRITE}}
ACCESS_RAY_TRACING_SHADER_READ_WRITE :: Access{stages = {.RAY_TRACING_SHADER_KHR},             access_type = {.MEMORY_READ, .MEMORY_WRITE}}
