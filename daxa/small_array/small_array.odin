// This is a fork of the odin core/container/small_array
// modified to use same index size as the daxa::FixedList for abi compat

// odin core lib license:
// Copyright (c) 2016-2025 Ginger Bill. All rights reserved.

// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.

// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:

// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.

package abi_small_array

import "base:builtin"
@require import "base:intrinsics"
@require import "base:runtime"

FIXED_LIST_SIZE_T :: u8

// NOTE: also swapped the parameter order here to match FixedList 
// and renamed second field to size for consistency
Small_Array :: struct($T: typeid, $N: FIXED_LIST_SIZE_T) where N >= 0 {
	data: [N]T,
	size:  FIXED_LIST_SIZE_T,
}

len :: proc "contextless" (a: $A/Small_Array) -> FIXED_LIST_SIZE_T {
	return a.size
}

cap :: proc "contextless" (a: $A/Small_Array) -> FIXED_LIST_SIZE_T {
	return builtin.len(a.data)
}

space :: proc "contextless" (a: $A/Small_Array) -> FIXED_LIST_SIZE_T {
	return builtin.len(a.data) - a.size
}

slice :: proc "contextless" (a: ^$A/Small_Array($T, $N)) -> []T {
	return a.data[:a.size]
}

get :: proc "contextless" (a: $A/Small_Array($T, $N), index: int) -> T {
	return a.data[index]
}

get_ptr :: proc "contextless" (a: ^$A/Small_Array($T, $N), index: int) -> ^T {
	return &a.data[index]
}

get_safe :: proc "contextless" (a: $A/Small_Array($T, $N), index: int) -> (T, bool) #no_bounds_check {
	if index < 0 || index >= a.size {
		return {}, false
	}
	return a.data[index], true
}

get_ptr_safe :: proc "contextless" (a: ^$A/Small_Array($T, $N), index: int) -> (^T, bool) #no_bounds_check {
	if index < 0 || index >= a.size {
		return {}, false
	}
	return &a.data[index], true
}

set :: proc "contextless" (a: ^$A/Small_Array($T, $N), index: int, item: T) {
	a.data[index] = item
}

resize :: proc "contextless" (a: ^$A/Small_Array($T, $N), length: int) {
	prev_len := a.size
	a.size = min(length, builtin.len(a.data))
	if prev_len < a.size {
		intrinsics.mem_zero(&a.data[prev_len], size_of(T)*(a.size-prev_len))
	}
}

non_zero_resize :: proc "contextless" (a: ^$A/Small_Array, length: int) {
	a.size = min(length, builtin.len(a.data))
}

push_back :: proc "contextless" (a: ^$A/Small_Array($T, $N), item: T) -> bool {
	if a.size < cap(a^) {
		a.data[a.size] = item
		a.size += 1
		return true
	}
	return false
}

push_front :: proc "contextless" (a: ^$A/Small_Array($T, $N), item: T) -> bool {
	if a.size < cap(a^) {
		a.size += 1
		data := slice(a)
		copy(data[1:], data[:])
		data[0] = item
		return true
	}
	return false
}

pop_back :: proc "odin" (a: ^$A/Small_Array($T, $N), loc := #caller_location) -> T {
	assert(condition=(N > 0 && a.size > 0), loc=loc)
	item := a.data[a.size-1]
	a.size -= 1
	return item
}

pop_front :: proc "odin" (a: ^$A/Small_Array($T, $N), loc := #caller_location) -> T {
	assert(condition=(N > 0 && a.size > 0), loc=loc)
	item := a.data[0]
	s := slice(a)
	copy(s[:], s[1:])
	a.size -= 1
	return item
}

pop_back_safe :: proc "contextless" (a: ^$A/Small_Array($T, $N)) -> (item: T, ok: bool) {
	if N > 0 && a.size > 0 {
		item = a.data[a.size-1]
		a.size -= 1
		ok = true
	}
	return
}

pop_front_safe :: proc "contextless" (a: ^$A/Small_Array($T, $N)) -> (item: T, ok: bool) {
	if N > 0 && a.size > 0 {
		item = a.data[0]
		s := slice(a)
		copy(s[:], s[1:])
		a.size -= 1
		ok = true
	}
	return
}

consume :: proc "odin" (a: ^$A/Small_Array($T, $N), count: int, loc := #caller_location) {
	assert(condition=a.size >= count, loc=loc)
	a.size -= count
}

ordered_remove :: proc "contextless" (a: ^$A/Small_Array($T, $N), index: int, loc := #caller_location) #no_bounds_check {
	runtime.bounds_check_error_loc(loc, index, a.size)
	if index+1 < a.size {
		copy(a.data[index:], a.data[index+1:])
	}
	a.size -= 1
}

unordered_remove :: proc "contextless" (a: ^$A/Small_Array($T, $N), index: int, loc := #caller_location) #no_bounds_check {
	runtime.bounds_check_error_loc(loc, index, a.size)
	n := a.size-1
	if index != n {
		a.data[index] = a.data[n]
	}
	a.size -= 1
}

clear :: proc "contextless" (a: ^$A/Small_Array($T, $N)) {
	resize(a, 0)
}

push_back_elems :: proc "contextless" (a: ^$A/Small_Array($T, $N), items: ..T) -> bool {
	if a.size + u8(builtin.len(items)) <= cap(a^) {
		n := u8(copy(a.data[a.size:], items[:]))
		a.size += n
		return true
	}
	return false
}

inject_at :: proc "contextless" (a: ^$A/Small_Array($T, $N), item: T, index: int) -> bool #no_bounds_check {
	if a.size < cap(a^) && index >= 0 && index <= len(a^) {
		a.size += 1
		for i := a.size - 1; i >= index + 1; i -= 1 {
			a.data[i] = a.data[i - 1]
		}
		a.data[index] = item
		return true
	}
	return false
}

// Alias for `push_back`
append_elem  :: push_back
// Alias for `push_back_elems`
append_elems :: push_back_elems

push   :: proc{push_back, push_back_elems}
// Alias for `push`
append :: proc{push_back, push_back_elems}
