package main

import "base:runtime"
import "core:strings"
import "core:slice"
import "core:fmt"
import "core:log"
import "core:bytes"
import "vendor:glfw"

import vk "vendor:vulkan"

import "daxa"

Program :: struct {
	ctx:                 runtime.Context,
	window:              glfw.WindowHandle,
	w, h:                i32,
	device:              daxa.Device,
	instance:            daxa.Instance,
	swapchain:           daxa.Swapchain,
	framebuffer_resized: bool,
	running:             bool,
}
ctx := Program{}

small_string :: proc(s: string) -> daxa.SmallString {
	ss: daxa.SmallString
	copy(ss.data[:], s)
	ss.size = u8(len(s))
	return ss
}

result :: proc(res: daxa.Result, loc := #caller_location, exp := #caller_expression) {
	if res > .SUCCESS {
		log.errorf("DAXA ERROR: %v %v %v", res, loc, exp)
		assert(false, "result failed")
	}
	log.debug(res, loc, exp)
}

get_native_handle :: proc() -> daxa.NativeWindowHandle {
	return glfw.GetWin32Window(ctx.window)
}

get_native_platform :: proc() -> daxa.NativeWindowPlatform {
	switch glfw.GetPlatform() {
	case glfw.PLATFORM_WIN32: return daxa.NativeWindowPlatform.WIN32_API
	case: panic("Unsupported Platform.")
	}
}

poll_events :: proc() {
	glfw.PollEvents()
	ctx.running = !glfw.WindowShouldClose(ctx.window)
	glfw.SetWindowShouldClose(ctx.window, false)
}
	
main :: proc() {
	context.logger = log.create_console_logger(lowest = log.Level.Info)
	ctx.ctx = context

	if !glfw.Init() {log.panic("glfw: could not be initialized")}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)

	ctx.w = 800
	ctx.h = 800

	ctx.window = glfw.CreateWindow(ctx.w, ctx.h, "Daxa - Odin", nil, nil)
	defer glfw.DestroyWindow(ctx.window)

	glfw.SetFramebufferSizeCallback(ctx.window, proc "c" (_: glfw.WindowHandle, _, _: i32) {
		ctx.framebuffer_resized = true
	})

	instance_info := daxa.DEFAULT_INSTANCE_INFO
	instance_info.engine_name = small_string("daxa")
	instance_info.app_name    = small_string("daxa app")

	result(daxa.create_instance(&instance_info, &ctx.instance))

	device_info := daxa.DEFAULT_DEVICE_INFO_2
	result(daxa.instance_choose_device(ctx.instance, {.SWAPCHAIN}, &device_info))
	result(daxa.instance_create_device_2(ctx.instance, &device_info, &ctx.device))

	test_props := daxa.dvc_properties(ctx.device)
	log.infof("%s", bytes.trim_null(test_props.device_name[:]))


	swapchaininfo := daxa.SwapchainInfo{
		native_window           = get_native_handle(),
		native_window_platform  = get_native_platform(),
		surface_format_selector = proc "c" (format: vk.Format) -> i32 {
			#partial switch format {
			case .R8G8B8A8_UNORM: return 100
			case: return daxa.default_format_selector(format)
			}
		},
		present_mode                 = .FIFO,
		present_operation            = {.IDENTITY},
		image_usage                  = {.TRANSFER_DST},
		max_allowed_frames_in_flight = 2,
		name                         = small_string("test swapchain"),
	}
	result(daxa.dvc_create_swapchain(ctx.device, &swapchaininfo, &ctx.swapchain))

	
	// tests start here:
	test_matrix_layout()

	pink_screen()
	triangle()
	compute_triangle()

	cmd_simplest_test()
	cmd_copy_test()
	cmd_deferred_destruction_test()
	cmd_multiple_ecl_test()
	cmd_build_acceleration_structure_test()
	
	async_queues_basics()
	async_queues_simple_submit_chain()
	async_queues_mesh_shader_test()

	result(daxa.dvc_wait_idle(ctx.device))
	result(daxa.dvc_collect_garbage(ctx.device))
	daxa.dvc_dec_refcnt(ctx.device)
	daxa.instance_dec_refcnt(ctx.instance)

	log.info("finished running")
}

compute_triangle :: proc() {
	
	size_x := daxa.swp_get_surface_extent(ctx.swapchain).width
	size_y := daxa.swp_get_surface_extent(ctx.swapchain).height

	render_image: daxa.ImageId
	render_image_info := daxa.DEFAULT_IMAGE_INFO
	render_image_info.dimensions = 2
	render_image_info.format = .R8G8B8A8_UNORM
	render_image_info.size = {size_x, size_y, 1}
	render_image_info.usage = {.SHADER_STORAGE, .TRANSFER_SRC}
	render_image_info.name = small_string("render_image")
	result(daxa.dvc_create_image(
		device = ctx.device,
		info = &render_image_info,
		out_id = &render_image,
	))

	comp_shader := #load("test_shaders/compute_triangle/comp.spv", []u32)

	compute_pipeline: daxa.ComputePipeline 
	result(daxa.dvc_create_compute_pipeline(
		device = ctx.device,
		info = &{
			shader_info = {
				 byte_code = &comp_shader[0],
				byte_code_size = u32(len(comp_shader)),
				create_flags = {},
				entry_point = small_string("main"),
			},
			push_constant_size = size_of(ComputePush),
			name = small_string("my compute shader"),
		},
		out_pipeline = &compute_pipeline
	))

	ComputePush :: struct {
		image:     daxa.ImageViewId,
		frame_dim: [2]u32,
	}

	push_constant: ComputePush

	i: int = -1 
	ctx.running = true
	for ctx.running {
		i += 1
		log.debug("begin frame:", i)
		poll_events()

		if ctx.framebuffer_resized {
			result(daxa.swp_resize(ctx.swapchain))
			daxa.dvc_destroy_image(ctx.device, render_image)
			size_x = daxa.swp_get_surface_extent(ctx.swapchain).width
			size_y = daxa.swp_get_surface_extent(ctx.swapchain).height
			render_image_info.size = {size_x, size_y, 1}
			result(daxa.dvc_create_image(
				device = ctx.device,
				info = &render_image_info,
				out_id = &render_image,
			))
			ctx.framebuffer_resized = false
		}

		swapchain_image: daxa.ImageId
		acq_result := daxa.swp_acquire_next_image(ctx.swapchain, &swapchain_image)
		assert(daxa.version_of_image(swapchain_image) != 0)

		recorder: daxa.CommandRecorder
		result(daxa.dvc_create_command_recorder(
			ctx.device,
			&{ name = small_string("my command recorder") },
			&recorder,
		))


		swapchain_image_info: daxa.ImageInfo
		result(daxa.dvc_info_image(
			ctx.device,
			swapchain_image,
			&swapchain_image_info
		))

		result(daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info = &{
				dst_access = daxa.ACCESS_COMPUTE_SHADER_READ_WRITE,
				image_id   = render_image,
				layout_operation = .TO_GENERAL,
			},
		))

		result(daxa.cmd_set_compute_pipeline(
			cmd_enc = recorder,
			pipeline = compute_pipeline,
		))

		push_constant = {
			image = daxa.default_view(render_image),
			frame_dim = { size_x, size_y },
		}

		result(daxa.cmd_push_constant(
			cmd_enc = recorder,
			info = &{
				data = &push_constant,
				size = size_of(push_constant),
			},
		))

		result(daxa.cmd_dispatch(
			cmd_enc = recorder,
			info = &{
				x = (size_x + 7) / 8,
				y = (size_y + 7) / 8,
				z = 1,
			}
		))

		result(daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info = &{
				dst_access = daxa.ACCESS_BLIT_READ,
				image_id   = render_image,
				layout_operation = .TO_GENERAL,
			},
		))

		result(daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info = &{
				dst_access = daxa.ACCESS_BLIT_WRITE,
				image_id   = swapchain_image,
				layout_operation = .TO_GENERAL,
			},
		))

		result(daxa.cmd_blit_image_to_image(
			cmd_enc = recorder,
			info = &{
				src_image        = render_image,
				src_image_layout = .GENERAL,
				dst_image        = swapchain_image,
				dst_image_layout = .GENERAL,
				src_slice        = daxa.DEFAULT_IMAGE_ARRAY_SLICE,
				dst_slice        = daxa.DEFAULT_IMAGE_ARRAY_SLICE,
				src_offsets      = {{0, 0, 0}, { i32(size_x), i32(size_y), 1 } },
				dst_offsets      = {{0, 0, 0}, { i32(size_x), i32(size_y), 1 } },
				filter           = .NEAREST,
			}
		))

		result(daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info = &{
				src_access = daxa.ACCESS_BLIT_WRITE,
				image_id   = swapchain_image,
				layout_operation = .TO_PRESENT_SRC,
			}
		))

		executable_commands: daxa.ExecutableCommandList
		result(daxa.cmd_complete_current_commands(recorder, &executable_commands))

		daxa.destroy_command_recorder(recorder)

		acquire_semaphore := daxa.swp_current_acquire_semaphore(ctx.swapchain)
		present_semaphore := daxa.swp_current_present_semaphore(ctx.swapchain)

		current_timeline_pair :: proc() -> daxa.TimelinePair {
			gpu_value := daxa.swp_gpu_timeline_semaphore(ctx.swapchain)^
			cpu_value := daxa.swp_current_cpu_timeline_value(ctx.swapchain)
			return {gpu_value, cpu_value}
		}

		timeline_pair := current_timeline_pair()
		result(daxa.dvc_submit(
			device = ctx.device,
			info = &{
				command_lists = &executable_commands,
				command_list_count = 1,
				wait_binary_semaphores = acquire_semaphore,
				wait_binary_semaphore_count = 1,
				signal_binary_semaphores = present_semaphore,
				signal_binary_semaphore_count = 1,
				signal_timeline_semaphores = &timeline_pair,
				signal_timeline_semaphore_count = 1,
			},
		))

		daxa.executable_commands_dec_refcnt(executable_commands)

		result(daxa.dvc_present(
			device = ctx.device,
			info = &{
				wait_binary_semaphores      = present_semaphore,
				wait_binary_semaphore_count = 1,
				swapchain                   = ctx.swapchain,
				queue                       = {},
			}
		))

		result(daxa.dvc_collect_garbage(ctx.device))

		log.debug("end frame:", i)
		if i > 60 do break
	}

}

triangle :: proc() {

	MyVertex :: struct {
		position: [3]f32,
		color:    [3]f32,
	}
	
	MyPushConstant :: struct {
		vertices: daxa.DeviceAddress,
	}
	
	vert_shader := #load("test_shaders/triangle/vert.spv", []u32)
	frag_shader := #load("test_shaders/triangle/frag.spv", []u32)

	raster_pipeline: daxa.RasterPipeline 
	result(daxa.dvc_create_raster_pipeline(
		device       = ctx.device,
		info         = &{
			vertex_shader_info = {
				value = {
				byte_code = &vert_shader[0],
				byte_code_size = u32(len(vert_shader)),
				create_flags = {},
				entry_point = small_string("main") },
				has_value = true
			},
				
			fragment_shader_info = {
				value = { byte_code = &frag_shader[0],
					byte_code_size = u32(len(frag_shader)),
					create_flags = {},
					entry_point = small_string("main") },
				has_value = true
			},

			color_attachments = { 
				data = { 0 = {
					format = daxa.swp_get_format(ctx.swapchain)
				}, 1..<7 = {}},
				size = 1,
			},

			depth_test         = { value = {}, has_value = false, },
			raster             = daxa.DEFAULT_RASTERIZATION_INFO,
			push_constant_size = daxa.MAX_PUSH_CONSTANT_BYTE_SIZE,
			name = small_string("my raster pipeline"),
		},
		out_pipeline = &raster_pipeline
	))

	vertex_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		device = ctx.device,
		info = &{
			size = size_of(MyVertex) * 3,
			allocate_info = {.HOST_ACCESS_SEQUENTIAL_WRITE},
			name = small_string("vertex buffer",)
		},
		out_id = &vertex_buffer,
	))

	vert_buf_ptr: [^]MyVertex
	result(daxa.dvc_buffer_host_address(
		device   = ctx.device,
		buffer   = vertex_buffer,
		out_addr = (^rawptr)(&vert_buf_ptr),
	))

	vert_buf_ptr[0] = { position = {-0.5, +0.5, 0.0}, color = {1.0, 0.0, 0.0}}
	vert_buf_ptr[1] = { position = {+0.5, +0.5, 0.0}, color = {0.0, 1.0, 0.0}}
	vert_buf_ptr[2] = { position = {+0.0, -0.5, 0.0}, color = {0.0, 0.0, 1.0}}

	push_constant: MyPushConstant
	result(daxa.dvc_buffer_device_address(
		device   = ctx.device,
		buffer   = vertex_buffer,
		out_addr = &push_constant.vertices,
	))


	i: int = -1
	ctx.running = true
	for ctx.running {
		i += 1
		log.debug("begin frame:", i)
		poll_events()

		if ctx.framebuffer_resized {
			result(daxa.swp_resize(ctx.swapchain))
			ctx.framebuffer_resized = false
		}

		swapchain_image: daxa.ImageId
		acq_result := daxa.swp_acquire_next_image(ctx.swapchain, &swapchain_image)
		// log.info(acq_result) // needs the "is_empty" check?
		assert(acq_result == .SUCCESS)
		assert(daxa.version_of_image(swapchain_image) != 0) //this is an empty check?


		recorder: daxa.CommandRecorder
		result(daxa.dvc_create_command_recorder(
			ctx.device,
			&{ name = small_string("my command recorder") },
			&recorder,
		))


		swapchain_image_info: daxa.ImageInfo
		result(daxa.dvc_info_image(
			ctx.device,
			swapchain_image,
			&swapchain_image_info
		))


		daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info = &{
				dst_access = daxa.ACCESS_COLOR_ATTACHMENT_OUTPUT_READ_WRITE,
				image_id   = swapchain_image,
				layout_operation = .TO_GENERAL,
			},
		)

		attachment := daxa.DEFAULT_RENDER_ATTACHMENT_INFO
		attachment.image_view = daxa.default_view(swapchain_image)
		attachment.load_op    = .CLEAR
		attachment.clear_value = {
			values = { color = { float32 = ([4]f32{0.1, 0, 0.5, 1})}},
			index = 0,
		}
		result(daxa.cmd_begin_renderpass(
			cmd_enc = recorder,
			info = &{
				color_attachments = { data = { 
					0 = attachment,
					1..<7 = {}},
					size = 1 },
				render_area = { extent = {
					width  = swapchain_image_info.size.width,
					height = swapchain_image_info.size.height,
				}},
			},
		))

		result(daxa.cmd_set_raster_pipeline(
			cmd_enc = recorder,
			pipeline = raster_pipeline,
		))

		result(daxa.cmd_push_constant(
			cmd_enc = recorder,
			info = &{
				data = &push_constant,
				size = size_of(push_constant),
			},
		))

		daxa.cmd_draw(
			cmd_enc = recorder,
			info = &{
				vertex_count   = 3,
				instance_count = 1,
				first_vertex   = 0,
				first_instance = 0,
			},
		)

		daxa.cmd_end_renderpass(recorder)


		daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info = &{
				src_access = daxa.ACCESS_COLOR_ATTACHMENT_OUTPUT_READ_WRITE,
				image_id   = swapchain_image,
				layout_operation = .TO_PRESENT_SRC,
			}
		)


		executable_commands: daxa.ExecutableCommandList
		result(daxa.cmd_complete_current_commands(recorder, &executable_commands))

		daxa.destroy_command_recorder(recorder)

		acquire_semaphore := daxa.swp_current_acquire_semaphore(ctx.swapchain)
		present_semaphore := daxa.swp_current_present_semaphore(ctx.swapchain)

		current_timeline_pair :: proc() -> daxa.TimelinePair {
			gpu_value := daxa.swp_gpu_timeline_semaphore(ctx.swapchain)^
			cpu_value := daxa.swp_current_cpu_timeline_value(ctx.swapchain)
			return {gpu_value, cpu_value}
		}

		timeline_pair := current_timeline_pair()
		result(daxa.dvc_submit(
			device = ctx.device,
			info = &{
				command_lists = &executable_commands,
				command_list_count = 1,
				wait_binary_semaphores = acquire_semaphore,
				wait_binary_semaphore_count = 1,
				signal_binary_semaphores = present_semaphore,
				signal_binary_semaphore_count = 1,
				signal_timeline_semaphores = &timeline_pair,
				signal_timeline_semaphore_count = 1,
			},
		))

		daxa.executable_commands_dec_refcnt(executable_commands)

		result(daxa.dvc_present(
			device = ctx.device,
			info = &{
				wait_binary_semaphores      = present_semaphore,
				wait_binary_semaphore_count = 1,
				swapchain                   = ctx.swapchain,
				queue                       = {},
			}
		))

		result(daxa.dvc_collect_garbage(ctx.device))

		log.debug("end frame:", i)
		if i > 60 do break
	}
}

pink_screen :: proc() {
	i: int = -1
	ctx.running = true
	for ctx.running {
		i += 1
		log.debug("begin frame:", i)
		poll_events()


		if ctx.framebuffer_resized {
			result(daxa.swp_resize(ctx.swapchain))
			ctx.framebuffer_resized = false
		}

		swapchain_image: daxa.ImageId
		acq_result := daxa.swp_acquire_next_image(ctx.swapchain, &swapchain_image)
		// log.info(acq_result) // needs the "is_empty" check?
		assert(acq_result == .SUCCESS)
		assert(daxa.version_of_image(swapchain_image) != 0) //this is an empty check?


		swapchain_image_view := daxa.default_view(swapchain_image)
		swapchain_image_info: daxa.ImageViewInfo
		result(daxa.dvc_info_image_view(
			ctx.device,
			swapchain_image_view,
			&swapchain_image_info,
		))


		recorder: daxa.CommandRecorder
		result(daxa.dvc_create_command_recorder(
			ctx.device,
			&{ name = small_string("my command recorder") },
			&recorder,
		))

		result(daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info    = &{
				dst_access       = daxa.ACCESS_TRANSFER_WRITE,
				image_id         = swapchain_image,
				layout_operation = .TO_GENERAL,
			}
		))

		result(daxa.cmd_clear_image(
			cmd_enc = recorder,
			info    = &{
				image_layout = .GENERAL,
				clear_value = {
					values = { color = { float32 = ([4]f32{1, 0, 1, 1})}},
					index = 0,
				},
				image     = swapchain_image,
				dst_slice = swapchain_image_info.slice,
			}
		))

		result(daxa.cmd_pipeline_image_barrier(
			cmd_enc = recorder,
			info = &{
				src_access       = daxa.ACCESS_TRANSFER_WRITE,
				image_id         = swapchain_image,
				layout_operation = .TO_PRESENT_SRC,
			}
		))

		executable_commands: daxa.ExecutableCommandList
		result(daxa.cmd_complete_current_commands(recorder, &executable_commands))

		daxa.destroy_command_recorder(recorder)

		acquire_semaphore := daxa.swp_current_acquire_semaphore(ctx.swapchain)
		present_semaphore := daxa.swp_current_present_semaphore(ctx.swapchain)

		current_timeline_pair :: proc() -> daxa.TimelinePair {
			gpu_value := daxa.swp_gpu_timeline_semaphore(ctx.swapchain)^
			cpu_value := daxa.swp_current_cpu_timeline_value(ctx.swapchain)
			return {gpu_value, cpu_value}
		}

		timeline_pair := current_timeline_pair()
		result(daxa.dvc_submit(
			device = ctx.device,
			info = &{
				command_lists = &executable_commands,
				command_list_count = 1,
				wait_binary_semaphores = acquire_semaphore,
				wait_binary_semaphore_count = 1,
				signal_binary_semaphores = present_semaphore,
				signal_binary_semaphore_count = 1,
				signal_timeline_semaphores = &timeline_pair,
				signal_timeline_semaphore_count = 1,
			},
		))

		daxa.executable_commands_dec_refcnt(executable_commands)

		result(daxa.dvc_present(
			device = ctx.device,
			info = &{
				wait_binary_semaphores      = present_semaphore,
				wait_binary_semaphore_count = 1,
				swapchain                   = ctx.swapchain,
				queue                       = {},
			}
		))
		// daxa.binary_semaphore_dec_refcnt(acquire_semaphore^)
		// daxa.binary_semaphore_dec_refcnt(present_semaphore^)

		result(daxa.dvc_collect_garbage(ctx.device))

		log.debug("end frame:", i)
		if i > 60 do break
	}
}

cmd_simplest_test :: proc() {

	recorder: daxa.CommandRecorder
	result(daxa.dvc_create_command_recorder(
		ctx.device,
		&{},
		&recorder,
	))

	// CommandRecorder can create ExecutableCommandList from the currently recorded commands.
	executable_commands: daxa.ExecutableCommandList
	daxa.cmd_complete_current_commands(recorder, &executable_commands)

	daxa.destroy_command_recorder(recorder)

	

	daxa.dvc_submit(
		ctx.device,
		info = &{ command_lists = &executable_commands, },
	)

	daxa.executable_commands_dec_refcnt(executable_commands)
	result(daxa.dvc_collect_garbage(ctx.device))
	/// WARNING:    ALL CommandRecorders from a device MUST be destroyed prior to calling collect_garbage or destroying the device!
	///             This is because The device can only do the internal cleanup when no commands get recorded in parallel!
}

cmd_copy_test :: proc() {

	recorder: daxa.CommandRecorder
	result(daxa.dvc_create_command_recorder(
		ctx.device,
		&{name = small_string("copy command list")},
		&recorder,
	))

	SIZE_X :: 3
	SIZE_Y :: 3
	SIZE_Z :: 3

	get_printable_char_buffer :: proc(in_data: $T/[$SZ][$SY][$SX][4]f32) -> []byte {
		data: [dynamic]byte

		pixel_lit := "\033[48;2;000;000;000m  "
		pixel := transmute([]u8)strings.clone(pixel_lit)
		defer delete(pixel)
		line_terminator    := "\033[0m "
		newline_terminator := "\033[0m\n"

		resize(&data,
			SX * SY * SZ * len(pixel) + 
			SY * SZ * len(line_terminator) + 
			SZ * len(newline_terminator) + 1
		)
		output_index := uint(0)

		for zi in 0..< SZ {
			for yi in 0..< SY {
				for xi in 0..< SX {
					r := cast(u8)(in_data[zi][yi][xi][0] * 255.0)
					g := cast(u8)(in_data[zi][yi][xi][1] * 255.0)
					b := cast(u8)(in_data[zi][yi][xi][2] * 255.0)
					next_pixel := pixel
					next_pixel[7 + 0 * 4 + 0] = (u8('0') + (r / 100))
					next_pixel[7 + 0 * 4 + 1] = (u8('0') + (r % 100) / 10)
					next_pixel[7 + 0 * 4 + 2] = (u8('0') + (r % 10))
					next_pixel[7 + 1 * 4 + 0] = (u8('0') + (g / 100))
					next_pixel[7 + 1 * 4 + 1] = (u8('0') + (g % 100) / 10)
					next_pixel[7 + 1 * 4 + 2] = (u8('0') + (g % 10))
					next_pixel[7 + 2 * 4 + 0] = (u8('0') + (b / 100))
					next_pixel[7 + 2 * 4 + 1] = (u8('0') + (b % 100) / 10)
					next_pixel[7 + 2 * 4 + 2] = (u8('0') + (b % 10))
					copy(data[output_index:], next_pixel)
					output_index += len(pixel)
				}
				copy(data[output_index:], line_terminator)
				output_index += len(line_terminator)
			}
			copy(data[output_index:], newline_terminator)
			output_index += len(newline_terminator)
		}
		data[len(data)-1] = 0 //null terminator

		return data[:]
	}

	ImageArray :: [SIZE_X][SIZE_Y][SIZE_Z][4]f32
	data: ImageArray

	for zi in 0..< SIZE_Z {
		for yi in 0..< SIZE_Y {
			for xi in 0..< SIZE_X {
				data[zi][yi][xi][0] = (f32)(xi) / (f32)(SIZE_X - 1)
				data[zi][yi][xi][1] = (f32)(yi) / (f32)(SIZE_Y - 1)
				data[zi][yi][xi][2] = (f32)(zi) / (f32)(SIZE_Z - 1)
				data[zi][yi][xi][3] = 1.0
			}
		}
	}

	staging_upload_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		ctx.device,
		&{size = size_of(data),
			allocate_info = {.HOST_ACCESS_SEQUENTIAL_WRITE},
			name = small_string("staging_upload_buffer"),
		},
		&staging_upload_buffer,
	))

	device_local_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		ctx.device,
		&{size = size_of(data),
			name = small_string("device_local_buffer"),
		},
		&device_local_buffer,
	))

	staging_readback_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		ctx.device,
		&{size = size_of(data),
			allocate_info = {.HOST_ACCESS_RANDOM},
			name = small_string("staging_readback_buffer"),
		},
		&staging_readback_buffer,
	))

	image_1: daxa.ImageId
	image_1_info := daxa.DEFAULT_IMAGE_INFO
	image_1_info.dimensions = 2 + (u32)(SIZE_Z > 1)
	image_1_info.format = .R32G32B32A32_SFLOAT
	image_1_info.size = {SIZE_X, SIZE_Y, SIZE_Z}
	image_1_info.usage = {.SHADER_STORAGE, .TRANSFER_DST, .TRANSFER_SRC}
	image_1_info.name = small_string("image_1")

	result(daxa.dvc_create_image(
		ctx.device,
		&image_1_info,
		&image_1,
	))

	image_2: daxa.ImageId
	image_2_info := daxa.DEFAULT_IMAGE_INFO
	image_2_info.dimensions = 2 + (u32)(SIZE_Z > 1)
	image_2_info.format = .R32G32B32A32_SFLOAT
	image_2_info.size = {SIZE_X, SIZE_Y, SIZE_Z}
	image_2_info.usage = {.SHADER_STORAGE, .TRANSFER_DST, .TRANSFER_SRC}
	image_2_info.name = small_string("image_2")

	result(daxa.dvc_create_image(
		ctx.device,
		&image_2_info,
		&image_2,
	))


	timeline_query_pool: daxa.TimelineQueryPool
	result(daxa.dvc_create_timeline_query_pool(
		device = ctx.device,
		info   = &{
			query_count = 2,
			name        = small_string("timeline_query",)
		},
		out_timeline_query_pool = &timeline_query_pool
	))

	buffer_ptr: ^ImageArray
	result(daxa.dvc_buffer_host_address(
		device   = ctx.device,
		buffer   = staging_upload_buffer,
		out_addr = (^rawptr)(&buffer_ptr),
	))

	buffer_ptr^ = data

	daxa.cmd_reset_timestamps(
		cmd_enc = recorder,
		info = &{
			query_pool = &timeline_query_pool,
			start_index = 0,
			count = daxa.timeline_query_pool_info(timeline_query_pool).query_count,
		}
	)

	daxa.cmd_write_timestamp(
		cmd_enc = recorder,
		info = &{
			query_pool = &timeline_query_pool,
			pipeline_stage = {.BOTTOM_OF_PIPE},
			query_index = 0,
		}
	)

	daxa.cmd_pipeline_barrier(
		cmd_enc = recorder,
		info = &{
			src_access = daxa.ACCESS_HOST_WRITE,
			dst_access = daxa.ACCESS_TRANSFER_READ,
		},
	)

	daxa.cmd_copy_buffer_to_buffer(
		cmd_enc = recorder,
		info = &{
			src_buffer = staging_upload_buffer,
			dst_buffer = device_local_buffer,
			size = size_of(data),
		}
	)

	// Barrier to make sure device_local_buffer is has no read after write hazard.
	daxa.cmd_pipeline_barrier(
		cmd_enc = recorder,
		info = &{
			src_access = daxa.ACCESS_TRANSFER_WRITE,
			dst_access = daxa.ACCESS_TRANSFER_READ,
		},
	)

	daxa.cmd_pipeline_image_barrier(
		cmd_enc = recorder,
		info = &{
		src_access = daxa.ACCESS_TRANSFER_WRITE,
		dst_access = daxa.ACCESS_TRANSFER_WRITE,
		image_id = image_1,
		layout_operation = .TO_GENERAL,
	})

	bi_info := daxa.DEFAULT_BUFFER_IMAGE_COPY_INFO
	bi_info.buffer = device_local_buffer
	bi_info.image = image_1
	bi_info.image_extent = {SIZE_X, SIZE_Y, SIZE_Z}
	daxa.cmd_copy_buffer_to_image(
		cmd_enc = recorder,
		info = &bi_info
	)

	daxa.cmd_pipeline_image_barrier(
		cmd_enc = recorder,
		info = &{
		src_access = daxa.ACCESS_TRANSFER_WRITE,
		dst_access = daxa.ACCESS_TRANSFER_READ,
		image_id = image_1,
		layout_operation = .TO_GENERAL,
	})

	daxa.cmd_pipeline_image_barrier(
		cmd_enc = recorder,
		info = &{
		dst_access = daxa.ACCESS_TRANSFER_WRITE,
		image_id = image_2,
		layout_operation = .TO_GENERAL,
	})

	ii_info := daxa.DEFAULT_IMAGE_COPY_INFO
	ii_info.src_image = image_1
	ii_info.dst_image = image_2
	ii_info.extent = {SIZE_X, SIZE_Y, SIZE_Z}
	daxa.cmd_copy_image_to_image(
		cmd_enc = recorder,
		info = &ii_info,
	)

	daxa.cmd_pipeline_image_barrier(
		cmd_enc = recorder,
		info = &{
		src_access = daxa.ACCESS_TRANSFER_WRITE,
		dst_access = daxa.ACCESS_TRANSFER_READ,
		image_id = image_2,
		layout_operation = .TO_GENERAL,
	})

	// Barrier to make sure device_local_buffer is has no write after read hazard.
	daxa.cmd_pipeline_barrier(
		cmd_enc = recorder,
		info = &{
		src_access = daxa.ACCESS_TRANSFER_READ,
		dst_access = daxa.ACCESS_TRANSFER_WRITE,
	})

	ib_info := daxa.DEFAULT_IMAGE_BUFFER_COPY_INFO
	ib_info.image = image_2
	ib_info.image_extent = {SIZE_X, SIZE_Y, SIZE_Z}
	ib_info.buffer = device_local_buffer
	daxa.cmd_copy_image_to_buffer(
		cmd_enc = recorder,
		info = &ib_info,
	)

	// Barrier to make sure device_local_buffer is has no read after write hazard.
	daxa.cmd_pipeline_barrier(
		cmd_enc = recorder,
		info = &{
			src_access = daxa.ACCESS_TRANSFER_WRITE,
			dst_access = daxa.ACCESS_TRANSFER_READ,
		}
	)

	daxa.cmd_copy_buffer_to_buffer(
		cmd_enc = recorder,
		info = &{
			src_buffer = device_local_buffer,
			dst_buffer = staging_readback_buffer,
			size = size_of(data),
		}
	)

	// Barrier to make sure staging_readback_buffer is has no read after write hazard.
	daxa.cmd_pipeline_barrier(
		cmd_enc = recorder,
		info = &{
			src_access = daxa.ACCESS_TRANSFER_WRITE,
			dst_access = daxa.ACCESS_HOST_READ,
		}
	)

	daxa.cmd_write_timestamp(
		cmd_enc = recorder,
		info = &{
			query_pool = &timeline_query_pool,
			pipeline_stage = {.BOTTOM_OF_PIPE},
			query_index = 1,
		}
	)

	executable_commands: daxa.ExecutableCommandList
	result(daxa.cmd_complete_current_commands(recorder, &executable_commands))

	
	result(daxa.dvc_submit(
		ctx.device,
		&{
			command_lists = &executable_commands,
			command_list_count = 1,
		},
	))

	result(daxa.dvc_wait_idle(ctx.device))


	query_results: [4]u64
	result(daxa.timeline_query_pool_query_results(timeline_query_pool, 0, 2, &query_results[0]))
	
	log.info(query_results)

	if ((query_results[1] != 0) && (query_results[3] != 0)) {
		log.infof("gpu execution took %v ms", f64(query_results[2] - query_results[0]) / 1_000_000)
	}

	readback_data_ptr: ^ImageArray
	result(daxa.dvc_buffer_host_address(
		device   = ctx.device,
		buffer   = staging_readback_buffer,
		out_addr = (^rawptr)(&readback_data_ptr),
	))

	readback_data := readback_data_ptr^

	log.info("Original data: ")
	{
		buf := get_printable_char_buffer(data)
		fmt.println(transmute(string)buf)
	}

	log.info("Readback data: ")
	{
		buf := get_printable_char_buffer(readback_data)
		fmt.println(transmute(string)buf)
	}

	assert(data == readback_data)

	daxa.dvc_destroy_buffer(ctx.device, staging_upload_buffer)
	daxa.dvc_destroy_buffer(ctx.device, device_local_buffer)
	daxa.dvc_destroy_buffer(ctx.device, staging_readback_buffer)
	daxa.dvc_destroy_image(ctx.device, image_1)
	daxa.dvc_destroy_image(ctx.device, image_2)

}

cmd_deferred_destruction_test :: proc() {

	recorder: daxa.CommandRecorder
	result(daxa.dvc_create_command_recorder(ctx.device, &{{},small_string("deferred destruction cmd")}, &recorder))

	buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(ctx.device, &{size = 4}, out_id = &buffer))

	image: daxa.ImageId
	image_info := daxa.DEFAULT_IMAGE_INFO
	image_info.size = {1, 1, 1}
	image_info.usage = {.COLOR_ATTACHMENT}
	result(daxa.dvc_create_image(
		device = ctx.device,
		info = &image_info,
		out_id = &image,
	))

	image_view: daxa.ImageViewId
	image_view_info := daxa.DEFAULT_IMAGE_VIEW_INFO
	image_view_info.image = image
	result(daxa.dvc_create_image_view(ctx.device, &image_view_info, &image_view))

	sampler: daxa.SamplerId
	sampler_info := daxa.DEFAULT_SAMPLER_INFO
	result(daxa.dvc_create_sampler(ctx.device, &sampler_info, &sampler))

	// The gpu resources are not destroyed here. Their destruction is deferred until the command list completes execution on the gpu.
	daxa.cmd_destroy_buffer_deferred(recorder, buffer)
	daxa.cmd_destroy_image_deferred(recorder, image)
	daxa.cmd_destroy_image_view_deferred(recorder, image_view)
	daxa.cmd_destroy_sampler_deferred(recorder, sampler)

	executable_commands: daxa.ExecutableCommandList
	result(daxa.cmd_complete_current_commands(recorder, &executable_commands))

	// Even after this call the resources will still be alive, as zombie resources are not checked to be dead in submit calls.
	result(daxa.dvc_submit(ctx.device, &{command_lists = &executable_commands, command_list_count = 1,},))
}

cmd_multiple_ecl_test :: proc() {
	buf_a: daxa.BufferId
	result(daxa.dvc_create_buffer(ctx.device, &{size = 4, allocate_info = {.HOST_ACCESS_SEQUENTIAL_WRITE}, name = small_string("buf_a")}, out_id = &buf_a))
	buf_b: daxa.BufferId
	result(daxa.dvc_create_buffer(ctx.device, &{size = 4, name = small_string("buf_b")}, out_id = &buf_b))
	buf_c: daxa.BufferId
	result(daxa.dvc_create_buffer(ctx.device, &{size = 4, allocate_info = {.HOST_ACCESS_RANDOM}, name = small_string("buf_c")}, out_id = &buf_c))
	
	TEST_VALUE :: 0xf0abf0ab 


	value_ptr: ^u32
	result(daxa.dvc_buffer_host_address(
		device   = ctx.device,
		buffer   = buf_a,
		out_addr = (^rawptr)(&value_ptr),
	))
	value_ptr^ = TEST_VALUE

	recorder: daxa.CommandRecorder
	result(daxa.dvc_create_command_recorder(ctx.device, &{}, &recorder))

	result(daxa.cmd_copy_buffer_to_buffer(
		cmd_enc = recorder,
		info = &{
			src_buffer = buf_a,
			dst_buffer = buf_b,
			size = 4,
		}
	))

	executable_commands_0: daxa.ExecutableCommandList
	result(daxa.cmd_complete_current_commands(recorder, &executable_commands_0))
	result(daxa.dvc_create_command_recorder(ctx.device, &{}, &recorder))


	result(daxa.cmd_copy_buffer_to_buffer(
		cmd_enc = recorder,
		info = &{
			src_buffer = buf_b,
			dst_buffer = buf_c,
			size = 4,
		}
	))

	executable_commands_1: daxa.ExecutableCommandList
	result(daxa.cmd_complete_current_commands(recorder, &executable_commands_1))
	result(daxa.dvc_create_command_recorder(ctx.device, &{}, &recorder))


	sema: daxa.BinarySemaphore
	result(daxa.dvc_create_binary_semaphore(
		ctx.device,
		info = &{ small_string("binary sema") },
		out_binary_semaphore = &sema,
	))


	result(daxa.dvc_submit(
		ctx.device,
		&{
			command_lists = &executable_commands_0,
			command_list_count = 1,
			signal_binary_semaphores = &sema,
			signal_binary_semaphore_count = 1,
		},
	))

	result(daxa.dvc_submit(
		ctx.device,
		&{
			wait_stages = {.TRANSFER},
			command_lists = &executable_commands_1,
			command_list_count = 1,
			wait_binary_semaphores = &sema,
			wait_binary_semaphore_count = 1,
		},
	))

	daxa.executable_commands_dec_refcnt(executable_commands_0)
	daxa.executable_commands_dec_refcnt(executable_commands_1)

	result(daxa.dvc_wait_idle(ctx.device))

	readback_value_ptr: ^u32
	result(daxa.dvc_buffer_host_address(
		device   = ctx.device,
		buffer   = buf_c,
		out_addr = (^rawptr)(&readback_value_ptr),
	))
	readback_value := readback_value_ptr^

	assert(readback_value == TEST_VALUE, "TEST VALUE DOES NOT MATCH READBACK VALUE")

	daxa.binary_semaphore_dec_refcnt(sema)
	daxa.dvc_destroy_buffer(ctx.device, buf_c)
        daxa.dvc_destroy_buffer(ctx.device, buf_b)
        daxa.dvc_destroy_buffer(ctx.device, buf_a)

        daxa.dvc_wait_idle(ctx.device)
	result(daxa.dvc_collect_garbage(ctx.device))
}

cmd_build_acceleration_structure_test :: proc(){
	
	vertices := [?]f32{
		0.25, 0.75, 0.5,
		0.5,  0.25, 0.5,
		0.75, 0.75, 0.5,
	}
	vertex_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		ctx.device,
		&{
			size = size_of(vertices),
			allocate_info = {.HOST_ACCESS_RANDOM},
			name = small_string("vertex buffer")
		},
		out_id = &vertex_buffer
	))
	defer daxa.dvc_destroy_buffer(ctx.device, vertex_buffer)
	vertex_ptr := &vertices
	result(daxa.dvc_buffer_host_address(ctx.device, vertex_buffer, (^rawptr)(&vertex_ptr),))
	vertex_ptr^ = vertices

	indices := [?]u32{0, 1, 2}
	index_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		ctx.device,
		&{
			size = size_of(indices),
			allocate_info = {.HOST_ACCESS_RANDOM},
			name = small_string("vertex buffer"),
		},
		out_id = &index_buffer,
	))
	defer daxa.dvc_destroy_buffer(ctx.device, index_buffer)
	index_ptr := &indices
	result(daxa.dvc_buffer_host_address(ctx.device, index_buffer, (^rawptr)(&index_ptr),))
	index_ptr^ = indices

	transform := #row_major matrix[3, 4]f32{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
	}
	transform_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		ctx.device,
		&{
			size = size_of(transform),
			allocate_info = {.HOST_ACCESS_RANDOM},
			name = small_string("transform buffer"),
		},
		out_id = &transform_buffer,
	))
	defer daxa.dvc_destroy_buffer(ctx.device, transform_buffer)
	transform_ptr := &transform
	result(daxa.dvc_buffer_host_address(ctx.device, transform_buffer, (^rawptr)(&transform_ptr),))
	transform_ptr^ = transform

	// Now the geometry for the BLAS is described as a series of geometries and instances of geometries:

	geometries := daxa.BlasTriangleGeometryInfo{
		vertex_format  = .R32G32B32_SFLOAT,
		vertex_data    = device_address(vertex_buffer),
		vertex_stride  = size_of([3]f32),
		max_vertex     = u32((len(vertices) - 1)),
		index_type     = .UINT32,
		index_data     = device_address(index_buffer),
		transform_data = device_address(transform_buffer),
		count          = 1,
		flags          = {},
	}

	accel_build_info := daxa.BlasBuildInfo{
		flags = {.PREFER_FAST_TRACE},
		dst_blas = {}, // Ignored in get_acceleration_structure_build_sizes, fill out later.
		geometries = { { triangles = { triangles = &geometries, count = 1 } }, 0 },
		scratch_data = {}, // Ignored in get_acceleration_structure_build_sizes, fill out later.
	}

	accel_build_size_info: daxa.AccelerationStructureBuildSizesInfo
	result(daxa.dvc_get_blas_build_sizes(ctx.device, &accel_build_info, &accel_build_size_info))

	scratch_buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		device = ctx.device,
		info = &{
			size = uint(accel_build_size_info.build_scratch_size),
			name = small_string("scratch buffer"),
		},
		out_id = &scratch_buffer,
	))
	defer daxa.dvc_destroy_buffer(ctx.device, scratch_buffer)

	blas: daxa.BlasId
	result(daxa.dvc_create_blas(
		device = ctx.device,
		info = &{
			size = accel_build_size_info.acceleration_structure_size,
			name = small_string("test blas"),
		},
		out_id = &blas,
	))
	defer daxa.dvc_destroy_blas(ctx.device, blas)

	device_address :: proc(buffer: daxa.BufferId) -> daxa.DeviceAddress {
		address: daxa.DeviceAddress
		result(daxa.dvc_buffer_device_address(
			device   = ctx.device,
			buffer   = buffer,
			out_addr = &address,
		))
		return address
	}

	accel_build_info.dst_blas = blas
	accel_build_info.scratch_data = device_address(scratch_buffer)


	recorder: daxa.CommandRecorder
	result(daxa.dvc_create_command_recorder(ctx.device, &{}, &recorder))


	result(daxa.cmd_build_acceleration_structures(
		recorder,
		&{ blas_build_infos = &accel_build_info, blas_build_info_count = 1 },
	))

	daxa.cmd_pipeline_barrier(
		cmd_enc = recorder,
		info = &{
			src_access = daxa.ACCESS_ACCELERATION_STRUCTURE_BUILD_WRITE,
			dst_access = daxa.ACCESS_ACCELERATION_STRUCTURE_BUILD_READ,
		},
	)
	
	executable_commands: daxa.ExecutableCommandList
	result(daxa.cmd_complete_current_commands(recorder, &executable_commands))
	
	result(daxa.dvc_submit(
		ctx.device,
		&{
			command_lists = &executable_commands,
			command_list_count = 1,
		},
	))
	daxa.dvc_wait_idle(ctx.device)

}

async_queues_basics :: proc() {

	compute_queue_count, transfer_queue_count: u32
	result(daxa.dvc_queue_count(ctx.device, .COMPUTE, &compute_queue_count))
	result(daxa.dvc_queue_count(ctx.device, .TRANSFER, &transfer_queue_count))
	log.info("Device has", compute_queue_count, "async compute and", transfer_queue_count, "async transfer queues.")
	// currently 4 by default, up to max of 8, can be specified when compiling the c++ lib
	log.infof("Daxa's maximum for async compute queues is %v and daxa's maximum for async transfer queues is %v.", daxa.MAX_COMPUTE_QUEUE_COUNT, daxa.MAX_TRANSFER_QUEUE_COUNT)

	daxa.dvc_queue_wait_idle(ctx.device, {.MAIN, 0})
	for queue in 0..< compute_queue_count {
	    daxa.dvc_queue_wait_idle(ctx.device, {.COMPUTE, queue})
	}     
	for queue in 0..< transfer_queue_count {
	    daxa.dvc_queue_wait_idle(ctx.device, {.TRANSFER, queue})
	}   
}

async_queues_simple_submit_chain :: proc() {
	
	{
		commands: daxa.ExecutableCommandList
		recorder: daxa.CommandRecorder
		result(daxa.dvc_create_command_recorder(ctx.device, &{}, &recorder))
		result(daxa.cmd_complete_current_commands(recorder, &commands))
	}

	sema0, sema1: daxa.BinarySemaphore
	result(daxa.dvc_create_binary_semaphore( ctx.device, &{name = small_string("sema 0")}, &sema0))
	result(daxa.dvc_create_binary_semaphore( ctx.device, &{name = small_string("sema 1")}, &sema1))

	initial_value := u32(42)

	buffer: daxa.BufferId
	result(daxa.dvc_create_buffer(
		device = ctx.device,
		info = &{
			size = size_of([4]u32),
			allocate_info = {.HOST_ACCESS_RANDOM},
			name = small_string("buffer"),
		},
		out_id = &buffer,
	))
	buffer_ptr: ^[4]u32
	result(daxa.dvc_buffer_host_address(ctx.device, buffer, (^rawptr)(&buffer_ptr)))
	buffer_ptr[0] = initial_value

	{
		// Copy from index 0 to index 1
		// Command recorders queue family MUST match the queue it is submitted to.
		// Commands for a transfer queue MUST ONLY be recorded by a transfer command recorder!
		// A generic or compute command recorder can not record commands for a transfer queue!
		// Tho transfer command recorders CAN record commands for any queue.
		recorder: daxa.CommandRecorder
		result(daxa.dvc_create_command_recorder(ctx.device, &{queue_family = .TRANSFER}, &recorder))
		daxa.cmd_pipeline_barrier(recorder, &{ daxa.ACCESS_TRANSFER_WRITE, daxa.ACCESS_TRANSFER_READ_WRITE} )
	
		result(daxa.cmd_copy_buffer_to_buffer(
			cmd_enc = recorder,
			info = &{
				src_buffer = buffer,
				dst_buffer = buffer,
				src_offset = size_of(u32) * 0,
				dst_offset = size_of(u32) * 1,
				size = size_of(u32),
			}
		))

		daxa.cmd_pipeline_barrier( cmd_enc = recorder, info = &{ daxa.ACCESS_TRANSFER_WRITE, daxa.ACCESS_TRANSFER_READ_WRITE })
		
		commands: daxa.ExecutableCommandList
		result(daxa.cmd_complete_current_commands(recorder, &commands))
		daxa.dvc_submit(
			ctx.device, 
			info = &{
				queue = {.TRANSFER, 0},
				command_lists = &commands,
				command_list_count = 1,
				signal_binary_semaphores = &sema0,
				signal_binary_semaphore_count = 1,
			}
		)
	}

	{
		// Copy from index 1 to index 2
		// Command recorders queue family MUST match the queue it is submitted to.
		// Commands for a compute queue can only be recorded by a compute or a transfer command recorder!
		// A generic command recorder is not allowed to record commands for a compute queue!
		recorder: daxa.CommandRecorder
		result(daxa.dvc_create_command_recorder(ctx.device, &{queue_family = .COMPUTE}, &recorder))
		daxa.cmd_pipeline_barrier(recorder, &{ daxa.ACCESS_TRANSFER_READ_WRITE, daxa.ACCESS_TRANSFER_READ_WRITE} )
	
		result(daxa.cmd_copy_buffer_to_buffer(
			cmd_enc = recorder,
			info = &{
				src_buffer = buffer,
				dst_buffer = buffer,
				src_offset = size_of(u32) * 1,
				dst_offset = size_of(u32) * 2,
				size = size_of(u32),
			}
		))

		daxa.cmd_pipeline_barrier( cmd_enc = recorder, info = &{ daxa.ACCESS_TRANSFER_WRITE, daxa.ACCESS_TRANSFER_READ_WRITE })
		
		commands: daxa.ExecutableCommandList
		result(daxa.cmd_complete_current_commands(recorder, &commands))
		daxa.dvc_submit(
			ctx.device, 
			info = &{
				queue = {.COMPUTE, 1},
				command_lists = &commands,
				command_list_count = 1,
				wait_binary_semaphores = &sema0,
				wait_binary_semaphore_count = 1,
				signal_binary_semaphores = &sema1,
				signal_binary_semaphore_count = 1,
			}
		)
	}

	{
		// Copy from index 2 to index 3
		// Any command recorder type can be used to submit commands to the main queue.
		recorder: daxa.CommandRecorder
		// daxa::QueueFamily::MAIN // The default is the main queue family
		// The Queue MUST be main here as its a generic command recorder
		result(daxa.dvc_create_command_recorder(ctx.device, &{}, &recorder))
		daxa.cmd_pipeline_barrier(recorder, &{ daxa.ACCESS_TRANSFER_READ_WRITE, daxa.ACCESS_TRANSFER_READ_WRITE} )
	
		result(daxa.cmd_copy_buffer_to_buffer(
			cmd_enc = recorder,
			info = &{
				src_buffer = buffer,
				dst_buffer = buffer,
				src_offset = size_of(u32) * 2,
				dst_offset = size_of(u32) * 3,
				size = size_of(u32),
			}
		))

		daxa.cmd_pipeline_barrier( cmd_enc = recorder, info = &{ daxa.ACCESS_TRANSFER_WRITE, daxa.ACCESS_TRANSFER_READ_WRITE })
		
		commands: daxa.ExecutableCommandList
		result(daxa.cmd_complete_current_commands(recorder, &commands))
		daxa.dvc_submit(
			ctx.device, 
			info = &{
				// .queue = daxa::Queue::MAIN, // The default is the main queue.
				command_lists = &commands,
				command_list_count = 1,
				wait_binary_semaphores = &sema1,
				wait_binary_semaphore_count = 1,
			}
		)
	}

	// The semaphores make sure that the queues submissions are processed in the correct order (transfer0 -> comp0 -> main).

	// As the queues are synchronized via semaphores and the main queue is the last to run,
	// we can safely assume that all work is done, as soon as the main queue is drained.
	daxa.dvc_queue_wait_idle(ctx.device, {.MAIN, 0})

	result_ptr: ^[4]u32
	daxa.dvc_buffer_host_address(ctx.device, buffer, (^rawptr)(&result_ptr))

	assert(result_ptr[3] == initial_value)

	daxa.binary_semaphore_dec_refcnt(sema0)
	daxa.binary_semaphore_dec_refcnt(sema1)
	daxa.dvc_destroy_buffer(ctx.device, buffer)
}

async_queues_mesh_shader_test :: proc() {
	
}

test_matrix_layout :: proc() {

	// daxa matrices are row major!
	daxa_matrix := daxa.f32mat4x3{
		{4, 5, 6},
		{3, 4, 5},
		{2, 3, 4},
		{1, 2, 3},
	}

	odin_matrix_col := matrix[4, 3]f32{
		4, 5, 6,
		3, 4, 5,
		2, 3, 4,
		1, 2, 3,
	}

	odin_matrix_row := #row_major matrix[4, 3]f32{
		4, 5, 6,
		3, 4, 5,
		2, 3, 4,
		1, 2, 3,
	}

	odin_matrix_col_bytes := transmute([12]f32)odin_matrix_col
	odin_matrix_row_bytes := transmute([12]f32)odin_matrix_row
	daxa_matrix_bytes     := transmute([12]f32)daxa_matrix
	fmt.println(odin_matrix_col_bytes)
	fmt.println(odin_matrix_row_bytes)
	fmt.println(daxa_matrix_bytes)

	assert(odin_matrix_col_bytes != daxa_matrix_bytes) 
	assert(odin_matrix_row_bytes == daxa_matrix_bytes) 
}
