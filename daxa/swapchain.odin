package daxa

import "core:c"
import vk "vendor:vulkan"

foreign import lib "daxa.lib"
_ :: lib

NativeWindowPlatformIndex :: enum i32 {
	WIN32    = 0,
	XLIB     = 1,
	WAYLAND  = 2,
	MAX_ENUM = 2147483647,
}

SwapchainInfo :: struct {
	native_window:                NativeWindowInfo,
	surface_format:               vk.SurfaceFormatKHR,
	present_mode:                 vk.PresentModeKHR,
	present_operation:            vk.SurfaceTransformFlagsKHR,
	image_usage:                  ImageUsageFlags,
	max_allowed_frames_in_flight: c.size_t,
	queue_type:                   QueueType,
	name:                         SmallString,
}

NativeWindowInfoWin32 :: struct {
	hwnd: rawptr,
}

NativeWindowInfoXlib :: struct{
	window: rawptr,
}

NativeWindowInfoWayland :: struct{
	display: rawptr,
	surface: rawptr,
	width:   u32,
	height:  u32,
}

NativeWindowInfoUnion :: struct #raw_union {
	win32:   NativeWindowInfoWin32,
	xlib:    NativeWindowInfoXlib,
	wayland: NativeWindowInfoWayland,
}

NativeWindowInfo :: Variant(NativeWindowInfoUnion)

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	swp_get_surface_extent         :: proc(swapchain: Swapchain) -> vk.Extent2D ---
	swp_get_format                 :: proc(swapchain: Swapchain) -> vk.Format ---
	swp_get_color_space            :: proc(swapchain: Swapchain) -> vk.ColorSpaceKHR ---
	swp_resize                     :: proc(swapchain: Swapchain) -> Result ---
	swp_set_present_mode           :: proc(swapchain: Swapchain, present_mode: vk.PresentModeKHR) -> Result ---
	swp_wait_for_next_frame        :: proc(swapchain: Swapchain) -> Result ---
	swp_acquire_next_image         :: proc(swapchain: Swapchain, out_image: ^ImageId) -> Result ---
	swp_current_acquire_semaphore  :: proc(swapchain: Swapchain) -> ^BinarySemaphore ---
	swp_current_present_semaphore  :: proc(swapchain: Swapchain) -> ^BinarySemaphore ---
	swp_current_cpu_timeline_value :: proc(swapchain: Swapchain) -> u64 ---
	swp_gpu_timeline_semaphore     :: proc(swapchain: Swapchain) -> ^TimelineSemaphore ---
	swp_info                       :: proc(swapchain: Swapchain) -> ^SwapchainInfo ---
	swp_get_vk_swapchain           :: proc(swapchain: Swapchain) -> vk.SwapchainKHR ---
	swp_get_vk_surface             :: proc(swapchain: Swapchain) -> vk.SurfaceKHR ---
	swp_inc_refcnt                 :: proc(swapchain: Swapchain) -> u64 ---
	swp_dec_refcnt                 :: proc(swapchain: Swapchain) -> u64 ---
}
