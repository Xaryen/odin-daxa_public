package daxa

import "core:c"
import vk "vendor:vulkan"

foreign import lib "daxa.lib"
_ :: lib

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	default_format_selector :: proc(format: vk.Format) -> i32 ---
}

/// @brief  A platform-dependent window resource.
///         On Windows, this is an `HWND`
///         On Linux X11, this is a `Window`
///         On Linux Wayland, this is a `wl_surface *`
NativeWindowHandle :: rawptr

NativeWindowPlatform :: enum i32 {
	UNKNOWN     = 0,
	WIN32_API   = 1,
	XLIB_API    = 2,
	WAYLAND_API = 3,
	MAX_ENUM    = 2147483647,
}

SwapchainInfo :: struct {
	native_window:                NativeWindowHandle,
	native_window_platform:       NativeWindowPlatform,
	surface_format_selector:      proc "c" (vk.Format) -> i32,
	present_mode:                 vk.PresentModeKHR,
	present_operation:            vk.SurfaceTransformFlagsKHR,
	image_usage:                  ImageUsageFlags,
	max_allowed_frames_in_flight: c.size_t,
	queue_family:                 QueueFamily,
	name:                         SmallString,
}

@(default_calling_convention="c", link_prefix="daxa_")
foreign lib {
	swp_get_surface_extent         :: proc(swapchain: Swapchain) -> vk.Extent2D ---
	swp_get_format                 :: proc(swapchain: Swapchain) -> vk.Format ---
	swp_get_color_space            :: proc(swapchain: Swapchain) -> vk.ColorSpaceKHR ---
	swp_resize                     :: proc(swapchain: Swapchain) -> Result ---
	swp_set_present_mode           :: proc(swapchain: Swapchain, present_mode: vk.PresentModeKHR) -> Result ---
	swp_wait_for_next_frame        :: proc(swapchain: Swapchain) -> Result ---
	swp_acquire_next_image         :: proc(swapchain: Swapchain, out_image_id: ^ImageId) -> Result ---
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

