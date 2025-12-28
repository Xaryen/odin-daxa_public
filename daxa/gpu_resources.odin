package daxa

import "core:c"
import vk "vendor:vulkan"

foreign import lib "daxa.lib"
_ :: lib

/** \struct VmaAllocation
\brief Represents single memory allocation.

It may be either dedicated block of `VkDeviceMemory` or a specific region of a bigger block of this type
plus unique offset.

There are multiple ways to create such object.
You need to fill structure VmaAllocationCreateInfo.
For more information see [Choosing memory type](@ref choosing_memory_type).

Although the library provides convenience functions that create Vulkan buffer or image,
allocate memory for it and bind them together,
binding of the allocation to a buffer or an image is out of scope of the allocation itself.
Allocation object can exist without buffer/image bound,
binding can be done manually by the user, and destruction of it can be done
independently of destruction of the allocation.

The object also remembers its size and some other information.
To retrieve this information, use function vmaGetAllocationInfo() and inspect
returned structure VmaAllocationInfo.
*/
VmaAllocation_T :: struct{}
VmaAllocation   :: ^VmaAllocation_T

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	default_view          :: proc(image: ImageId) -> ImageViewId ---
	index_of_buffer       :: proc(id: BufferId) -> u32 ---
	index_of_image        :: proc(id: ImageId) -> u32 ---
	index_of_image_view   :: proc(id: ImageViewId) -> u32 ---
	index_of_sampler      :: proc(id: SamplerId) -> u32 ---
	version_of_buffer     :: proc(id: BufferId) -> u64 ---
	version_of_image      :: proc(id: ImageId) -> u64 ---
	version_of_image_view :: proc(id: ImageViewId) -> u64 ---
	version_of_sampler    :: proc(id: SamplerId) -> u64 ---
}

DeviceAddress :: struct {
	address: u64,
}

BufferInfo :: struct {
	size: c.size_t,

	// Ignored when allocating with a memory block.
	allocate_info: MemoryFlags,
	name:          SmallString,
}
DEFAULT_BUFFER_INFO :: BufferInfo{
	size = 0,
	allocate_info = MEMORY_FLAG_NONE,
	name = {},
}

ImageFlag :: enum u32 {
	ALLOW_MUTABLE_FORMAT = 3,
	COMPATIBLE_CUBE = 4,
	COMPATIBLE_2D_ARRAY = 5,
	ALLOW_ALIAS = 10,
}
ImageFlags :: bit_set[ImageFlag; u32]
IMAGE_FLAG_NONE :: ImageFlags{}

ImageUsageFlag :: enum u32 {
	TRANSFER_SRC = 0,
	TRANSFER_DST,
	SHADER_SAMPLED,
	SHADER_STORAGE,
	COLOR_ATTACHMENT,
	DEPTH_STENCIL_ATTACHMENT,
	TRANSIENT_ATTACHMENT,
	FRAGMENT_SHADING_RATE_ATTACHMENT = 8,
	FRAGMENT_DENSITY_MAP             = 9,
	HOST_TRANSFER                    = 22,
}
ImageUsageFlags :: bit_set[ImageUsageFlag; u32]
IMAGE_USAGE_FLAG_NONE :: ImageUsageFlags{}

SharingMode :: enum i32 {
	EXCLUSIVE  = 0,
	CONCURRENT = 1,
}

ImageInfo :: struct {
	flags:             ImageFlags,
	dimensions:        u32,
	format:            vk.Format,
	size:              vk.Extent3D,
	mip_level_count:   u32,
	array_layer_count: u32,
	sample_count:      u32,
	usage:             ImageUsageFlags,
	sharing_mode:      SharingMode,

	// Ignored when allocating with a memory block.
	allocate_info: MemoryFlags,
	name:          SmallString,
}
DEFAULT_IMAGE_INFO :: ImageInfo{
	flags             = IMAGE_FLAG_NONE,
	dimensions        = 2,
	format            = .R8G8B8A8_SRGB,
	size              = {0, 0, 0},
	mip_level_count   = 1,
	array_layer_count = 1,
	sample_count      = 1,
	usage             = {},
	sharing_mode      = .EXCLUSIVE,
	allocate_info     = {},
	name              = {},
}

ImageViewInfo :: struct {
	type:   vk.ImageViewType,
	format: vk.Format,
	image:  ImageId,
	slice:  ImageMipArraySlice,
	name:   SmallString,
}
DEFAULT_IMAGE_VIEW_INFO :: ImageViewInfo{
	type   = .D2,
	format = .R8G8B8A8_SRGB,
	image  = {},
	slice  = {},
	name   = {},
}

SamplerInfo :: struct {
	magnification_filter:            vk.Filter,
	minification_filter:             vk.Filter,
	mipmap_filter:                   vk.Filter,
	reduction_mode:                  vk.SamplerReductionMode,
	address_mode_u:                  vk.SamplerAddressMode,
	address_mode_v:                  vk.SamplerAddressMode,
	address_mode_w:                  vk.SamplerAddressMode,
	mip_lod_bias:                    f32,
	enable_anisotropy:               Bool8,
	max_anisotropy:                  f32,
	enable_compare:                  Bool8,
	compare_op:                      vk.CompareOp,
	min_lod:                         f32,
	max_lod:                         f32,
	border_color:                    vk.BorderColor,
	enable_unnormalized_coordinates: Bool8,
	name:                            SmallString,
}
DEFAULT_SAMPLER_INFO :: SamplerInfo{
	magnification_filter =            .LINEAR,
	minification_filter =             .LINEAR,
	mipmap_filter =                   .LINEAR,
	reduction_mode =                  .WEIGHTED_AVERAGE,
	address_mode_u =                  .CLAMP_TO_EDGE,
	address_mode_v =                  .CLAMP_TO_EDGE,
	address_mode_w =                  .CLAMP_TO_EDGE,
	mip_lod_bias =                    0.5,
	enable_anisotropy =               false,
	max_anisotropy =                  0,
	enable_compare =                  false,
	compare_op =                      .ALWAYS,
	min_lod =                         0,
	max_lod =                         1000,
	border_color =                    .INT_TRANSPARENT_BLACK,
	enable_unnormalized_coordinates = false,
	name =                            {},
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	memory_block_get_vma_allocation :: proc(memory_block: MemoryBlock) -> VmaAllocation ---
}

GeometryFlag :: enum i32 {
	OPAQUE                          = 1,
	NO_DUPLICATE_ANY_HIT_INVOCATION = 2,
}
GeometryFlags :: bit_set[GeometryFlag;i32]

BlasTriangleGeometryInfo :: struct {
	vertex_format:  vk.Format,
	vertex_data:    DeviceAddress,
	vertex_stride:  u64,
	max_vertex:     u32,
	index_type:     vk.IndexType,
	index_data:     DeviceAddress,
	transform_data: DeviceAddress,
	count:          u32,
	flags:          GeometryFlags,
}
DEFAULT_BLAS_TRIANGLE_GEOMETRY_INFO :: BlasTriangleGeometryInfo{
	vertex_format = .R32G32B32_SFLOAT,
	vertex_data = {},
	vertex_stride = 24,
	max_vertex = 0,
	index_type = .UINT32,
	index_data = {},
	transform_data = {},
	count = 0,
	flags = {.OPAQUE},
}

BlasAabbGeometryInfo :: struct {
	data:   DeviceAddress,
	stride: u64,
	count:  u32,
	flags:  GeometryFlags,
}
DEFAULT_BLAS_AABB_GEOMETRY_INFO :: BlasAabbGeometryInfo{
	data = {},
	stride = 24,
	count = 0,
	flags = {.OPAQUE},
}

/// Instances are defines as VkAccelerationStructureInstanceKHR;
TlasInstanceInfo :: struct {
	data:                      DeviceAddress,
	count:                     u32,
	is_data_array_of_pointers: Bool8,
	flags:                     GeometryFlags,
}
DEFAULT_TLAS_INSTANCE_INFO :: TlasInstanceInfo{
	data = {},
	count = 0,
	is_data_array_of_pointers = false,
	flags = {.OPAQUE},
}

// the spans could maybe be refactored to be slices in the api end?
BlasTriangleGeometryInfoSpan :: struct {
	triangles: ^BlasTriangleGeometryInfo,
	count:     c.size_t,
}

BlasAabbsGeometryInfoSpan :: struct {
	aabbs: ^BlasAabbGeometryInfo,
	count: c.size_t,
}

BlasGeometryInfoSpansUnion :: struct #raw_union {
	triangles: BlasTriangleGeometryInfoSpan,
	aabbs:     BlasAabbsGeometryInfoSpan,
}

BuildAccelerationStructureFlag :: enum i32 {
	ALLOW_UPDATE      = 1,
	ALLOW_COMPACTION  = 2,
	PREFER_FAST_TRACE = 4,
	PREFER_FAST_BUILD = 8,
	LOW_MEMORY        = 16,
}
BuildAcclelerationStructureFlags :: bit_set[BuildAccelerationStructureFlag; i32]


TlasBuildInfo :: struct {
	flags:          BuildAcclelerationStructureFlags,
	update:         Bool8,
	src_tlas:       TlasId,
	dst_tlas:       TlasId,
	instances:      ^TlasInstanceInfo,
	instance_count: u32,
	scratch_data:   DeviceAddress,
}
DEFAULT_TLAS_BUILD_INFO :: TlasBuildInfo{
	flags = {.PREFER_FAST_TRACE},
	update = false,
	src_tlas = {},
	dst_tlas = {},
	instances = {},
	instance_count = {},
	scratch_data = {},
}

BlasBuildInfo :: struct {
	flags:    BuildAcclelerationStructureFlags,
	update:   Bool8,
	src_blas: BlasId,
	dst_blas: BlasId,

	geometries: struct {
		values: BlasGeometryInfoSpansUnion,
		index:  u8,
	},

	scratch_data: DeviceAddress,
}
DEFAULT_BLAS_BUILD_INFO :: BlasBuildInfo{
	flags = {.PREFER_FAST_TRACE},
	update = false,
	src_blas = {},
	dst_blas = {},
	geometries = {},
	scratch_data = {},
}

TlasInfo :: struct {
	size: u64,
	name: SmallString,
}
DEFAULT_TLAS_INFO :: TlasInfo{}

BlasInfo :: struct {
	size: u64,
	name: SmallString,
}
DEFAULT_BLAS_INFO :: BlasInfo{}

