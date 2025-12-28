package daxa

import dsa "small_array"
import vk "vendor:vulkan"

MAX_PUSH_CONSTANT_WORD_SIZE :: (32)
MAX_PUSH_CONSTANT_BYTE_SIZE :: (MAX_PUSH_CONSTANT_WORD_SIZE * 4)
PIPELINE_LAYOUT_COUNT       :: (MAX_PUSH_CONSTANT_WORD_SIZE + 1)

SMALL_STRING_CAPACITY :: 63
VARIANT_INDEX_TYPE :: u8
FIXED_LIST_SIZE_T  :: u8
#assert(FIXED_LIST_SIZE_T == dsa.FIXED_LIST_SIZE_T)

// fixed lists are replaced by small_array and can be operated on by its' procs
FixedList :: dsa.Small_Array

SmallString :: distinct FixedList(u8, SMALL_STRING_CAPACITY)

Variant :: struct($RAW_UNION: typeid) {
	values: RAW_UNION, //raw union
	index: VARIANT_INDEX_TYPE,
}
Optional :: struct($T: typeid) {
	value: T,
	has_value: Bool8,
}

// SpanToConst :: struct($T: typeid) {
// 	data: ^T, //const *
// 	size: uint,
// }

// things that appear to need manual refcnt
// instance
// device
// memory block
// timeline query pool
// binary sema
// timeline sema
// event
// swapchain
// executable commands
// RT pipeline
// RT pipeline library
// compute pipeline
// raster_pipeline

// things that need manual destroy
// buffer   - can be deferred
// image  - can be deferred
// image view  - can be deferred
// sampler  - can be deferred
// blas
// tlas
// command recorder






































