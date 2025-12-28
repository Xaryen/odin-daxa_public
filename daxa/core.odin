package daxa

foreign import lib "daxa.lib"
_ :: lib

ImplDevice                    :: struct {}
Device                        :: ^ImplDevice
ImplCommandRecorder           :: struct {}
CommandRecorder               :: ^ImplCommandRecorder
ImplExecutableCommandList     :: struct {}
ExecutableCommandList         :: ^ImplExecutableCommandList
ImplInstance                  :: struct {}
Instance                      :: ^ImplInstance
ImplRayTracingPipeline        :: struct {}
RayTracingPipeline            :: ^ImplRayTracingPipeline
ImplRayTracingPipelineLibrary :: struct {}
RayTracingPipelineLibrary     :: ^ImplRayTracingPipelineLibrary
ImplComputePipeline           :: struct {}
ComputePipeline               :: ^ImplComputePipeline
ImplRasterPipeline            :: struct {}
RasterPipeline                :: ^ImplRasterPipeline
ImplSwapchain                 :: struct {}
Swapchain                     :: ^ImplSwapchain
ImplBinarySemaphore           :: struct {}
BinarySemaphore               :: ^ImplBinarySemaphore
ImplTimelineSemaphore         :: struct {}
TimelineSemaphore             :: ^ImplTimelineSemaphore
ImplEvent                     :: struct {}
Event                         :: ^ImplEvent
ImplTimelineQueryPool         :: struct {}
TimelineQueryPool             :: ^ImplTimelineQueryPool
ImplMemoryBlock               :: struct {}
MemoryBlock                   :: ^ImplMemoryBlock
Flags                         :: u64
Bool8                         :: b8

BufferId :: struct {
	value: u64,
}

ImageId :: struct {
	value: u64,
}

ImageViewId :: struct {
	value: u64,
}

ImageViewIndex :: struct {
	value: u32,
}

SamplerId :: struct {
	value: u64,
}

TlasId :: struct {
	value: u64,
}

BlasId :: struct {
	value: u64,
}

f32vec2 :: struct {
	x, y: f32,
}

f64vec2 :: struct {
	x, y: f64,
}

u32vec2 :: struct {
	x, y: u32,
}

i32vec2 :: struct {
	x, y: i32,
}

f32vec3 :: struct {
	x, y, z: f32,
}

f64vec3 :: struct {
	x, y, z: f64,
}

u32vec3 :: struct {
	x, y, z: u32,
}

i32vec3 :: struct {
	x, y, z: i32,
}

f32vec4 :: struct {
	x, y, z, w: f32,
}

f64vec4 :: struct {
	x, y, z, w: f64,
}

u32vec4 :: struct {
	x, y, z, w: u32,
}

i32vec4 :: struct {
	x, y, z, w: i32,
}

f32mat2x2 :: struct {
	x, y: f32vec2,
}

f32mat2x3 :: struct {
	x, y: f32vec3,
}

f32mat2x4 :: struct {
	x, y: f32vec4,
}

f64mat2x2 :: struct {
	x, y: f64vec2,
}

f64mat2x3 :: struct {
	x, y: f64vec3,
}

f64mat2x4 :: struct {
	x, y: f64vec4,
}

f32mat3x2 :: struct {
	x, y, z: f32vec2,
}

f32mat3x3 :: struct {
	x, y, z: f32vec3,
}

f32mat3x4 :: struct {
	x, y, z: f32vec4,
}

f64mat3x2 :: struct {
	x, y, z: f64vec2,
}

f64mat3x3 :: struct {
	x, y, z: f64vec3,
}

f64mat3x4 :: struct {
	x, y, z: f64vec4,
}

f32mat4x2 :: struct {
	x, y, z, w: f32vec2,
}

f32mat4x3 :: struct {
	x, y, z, w: f32vec3,
}

f32mat4x4 :: struct {
	x, y, z, w: f32vec4,
}

f64mat4x2 :: struct {
	x, y, z, w: f64vec2,
}

f64mat4x3 :: struct {
	x, y, z, w: f64vec3,
}

f64mat4x4 :: struct {
	x, y, z, w: f64vec4,
}

i32mat2x2 :: struct {
	x, y: i32vec2,
}

i32mat2x3 :: struct {
	x, y: i32vec3,
}

i32mat2x4 :: struct {
	x, y: i32vec4,
}

u32mat2x2 :: struct {
	x, y: u32vec2,
}

u32mat2x3 :: struct {
	x, y: u32vec3,
}

u32mat2x4 :: struct {
	x, y: u32vec4,
}

i32mat3x2 :: struct {
	x, y, z: i32vec2,
}

i32mat3x3 :: struct {
	x, y, z: i32vec3,
}

i32mat3x4 :: struct {
	x, y, z: i32vec4,
}

u32mat3x2 :: struct {
	x, y, z: u32vec2,
}

u32mat3x3 :: struct {
	x, y, z: u32vec3,
}

u32mat3x4 :: struct {
	x, y, z: u32vec4,
}

i32mat4x2 :: struct {
	x, y, z, w: i32vec2,
}

i32mat4x3 :: struct {
	x, y, z, w: i32vec3,
}

i32mat4x4 :: struct {
	x, y, z, w: i32vec4,
}

u32mat4x2 :: struct {
	x, y, z, w: u32vec2,
}

u32mat4x3 :: struct {
	x, y, z, w: u32vec3,
}

u32mat4x4 :: struct {
	x, y, z, w: u32vec4,
}

/// ABI: Must stay compatible with 'VkAccelerationStructureInstanceKHR'
BlasInstanceData :: struct {
	transform:                                   f32mat3x4,
	instance_custom_index:                       u32,
	mask:                                        u32,
	instance_shader_binding_table_record_offset: u32,
	flags:                                       u32,
	blas_device_address:                         u64,
}

