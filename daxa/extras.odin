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




// RAI_FixedList :: distinct FixedList(RenderAttachmentInfo, 8)
// init_rai_fixed_list :: proc(rai: RenderAttachmentInfo) -> RAI_FixedList {
// 	fixed_list: RAI_FixedList
// 	dsa.push_back(&fixed_list, rai)
// 	return fixed_list
// }

// RA_FixedList :: distinct FixedList(RenderAttachment, 8)
// init_ra_fixed_list :: proc(ra: RenderAttachment) -> RA_FixedList {
// 	fixed_list: RA_FixedList
// 	dsa.push_back(&fixed_list, ra)
// 	return fixed_list
// }

Variant :: struct($RAW_UNION: typeid) {
	values: RAW_UNION, //raw union
	index: VARIANT_INDEX_TYPE,
}

// NOTE: In the wrapper Optional is replaced by Maybe(T)
// or multiple return values on case by case basis
// for parameters maybe have a set_optional() helper
Optional :: struct($T: typeid) {
	value: T,
	has_value: Bool8,
}


// SpanToConst :: struct($T: typeid) {
// 	data: ^T, //const *
// 	size: uint,
// }

// TODO: anotate most structs with #all_or_none

// TODO: decide on handling DAXA_RESULT
// could be returned as multiple values to the api user or handled internally?
// C++ api seems to be handling it on it's own?
// nvm it seems to be using exceptions for that

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






































