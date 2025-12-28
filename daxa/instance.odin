package daxa

import vk "vendor:vulkan"

INSTANCE_FLAG_DEBUG_UTIL:                InstanceFlags : 0x1
INSTANCE_FLAG_PARENT_MUST_OUTLIVE_CHILD: InstanceFlags : 0x2

foreign import lib "daxa.lib"
_ :: lib

InstanceFlags :: Flags

InstanceInfo :: struct {
	flags:       InstanceFlags,
	engine_name: SmallString,
	app_name:    SmallString,
}
DEFAULT_INSTANCE_INFO :: InstanceInfo{
	flags = INSTANCE_FLAG_DEBUG_UTIL,
	engine_name = {},
	app_name = {},
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	create_instance :: proc(info: ^InstanceInfo, out_instance: ^Instance) -> Result ---

	instance_create_device_2 :: proc(instance: Instance, info: ^DeviceInfo2, out_device: ^Device) -> Result ---

	// Can be used to autofill the physical_device_index in a partially filled daxa_DeviceInfo2.
	instance_choose_device :: proc(instance: Instance, desired_implicit_features: ImplicitFeatureFlags, info: ^DeviceInfo2) -> Result ---

	// Returns previous ref count.
	instance_inc_refcnt :: proc(instance: Instance) -> u64 ---

	// Returns previous ref count.
	instance_dec_refcnt              :: proc(instance: Instance) -> u64 ---
	instance_info                    :: proc(instance: Instance) -> ^InstanceInfo ---
	instance_get_vk_instance         :: proc(instance: Instance) -> vk.Instance ---
	instance_list_devices_properties :: proc(instance: Instance, properties: ^^DeviceProperties, property_count: ^u32) ---
}

