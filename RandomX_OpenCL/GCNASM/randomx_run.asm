/*
Copyright (c) 2019 SChernykh

This file is part of RandomX OpenCL.

RandomX OpenCL is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

RandomX OpenCL is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RandomX OpenCL. If not, see <http://www.gnu.org/licenses/>.
*/

.amdcl2
.gpu GFX900
.64bit
.arch_minor 0
.arch_stepping 0
.driver_version 223600
.kernel randomx_run
	.config
		.dims x
		.cws 64, 1, 1
		.sgprsnum 96
		# 6 waves per SIMD: 37-40 VGPRs
		# 5 waves per SIMD: 41-48 VGPRs
		# 4 waves per SIMD: 49-64 VGPRs
		# 3 waves per SIMD: 65-84 VGPRs
		# 2 waves per SIMD: 85-128 VGPRs
		# 1 wave  per SIMD: 129-256 VGPRs
		.vgprsnum 128
		.localsize 256
		.floatmode 0xc0
		.pgmrsrc1 0x00ac0049
		.pgmrsrc2 0x00000090
		.dx10clamp
		.ieeemode
		.useargs
		.priority 0
		.arg _.global_offset_0, "size_t", long
		.arg _.global_offset_1, "size_t", long
		.arg _.global_offset_2, "size_t", long
		.arg _.printf_buffer, "size_t", void*, global, , rdonly
		.arg _.vqueue_pointer, "size_t", long
		.arg _.aqlwrap_pointer, "size_t", long
		.arg dataset, "uchar*", uchar*, global, const, rdonly
		.arg scratchpad, "uchar*", uchar*, global, 
		.arg registers, "ulong*", ulong*, global, 
		.arg rounding_modes, "uint*", uint*, global, , rdonly
		.arg programs, "uint*", uint*, global, 
		.arg batch_size, "uint", uint
	.text
		s_icache_inv
		v_lshl_add_u32  v1, s8, 6, v0
		s_load_dwordx2  s[0:1], s[4:5], 0x0
		s_load_dwordx2  s[2:3], s[4:5], 0x40
		s_waitcnt       lgkmcnt(0)
		v_add_u32       v1, s0, v1
		v_lshrrev_b32   v2, 6, v1
		v_lshlrev_b32   v3, 5, v2
		v_and_b32       v1, 63, v1
		v_mov_b32       v4, 0
		v_lshlrev_b64   v[3:4], 3, v[3:4]
		v_lshlrev_b32   v5, 4, v1
		v_add_co_u32    v3, vcc, s2, v3
		v_mov_b32       v6, s3
		v_addc_co_u32   v4, vcc, v6, v4, vcc
		v_add_co_u32    v6, vcc, v3, v5
		v_addc_co_u32   v7, vcc, v4, 0, vcc
		global_load_dwordx4 v[6:9], v[6:7], off
		v_lshrrev_b32   v0, 6, v0
		v_lshlrev_b32   v0, 8, v0
		v_add_u32       v10, v0, v5
		s_waitcnt       vmcnt(0)
		ds_write2_b64   v10, v[6:7], v[8:9] offset1:1
		s_waitcnt       lgkmcnt(0)
		s_mov_b64       s[0:1], exec
		v_cmpx_le_u32   s[2:3], v1, 7
		s_cbranch_execz program_end

		# Base address for non-strided scratchpads
		s_mov_b32       s2, 2097152 + 64
		v_mul_lo_u32    v2, v2, s2

		# Base address for strided scratchpads
		#v_lshlrev_b32   v2, 6, v2

		# v41, v44 = 0
		v_mov_b32       v41, 0
		v_mov_b32       v44, 0

		ds_read_b32     v6, v0 offset:152
		v_cmp_lt_u32    s[2:3], v1, 4
		ds_read2_b64    v[34:37], v0 offset0:18 offset1:16
		ds_read_b64     v[11:12], v0 offset:136
		s_movk_i32      s9, 0x0
		s_mov_b64       s[6:7], exec
		s_andn2_b64     exec, s[6:7], s[2:3]
		ds_read_b64     v[13:14], v0 offset:160
		s_andn2_b64     exec, s[6:7], exec
		v_mov_b32       v13, 0
		v_mov_b32       v14, 0
		s_mov_b64       exec, s[6:7]
		s_lshl_b64      s[6:7], s[8:9], 14
		v_add3_u32      v5, v0, v5, 64
		s_mov_b64       s[8:9], exec
		s_andn2_b64     exec, s[8:9], s[2:3]
		ds_read_b64     v[15:16], v0 offset:168
		s_andn2_b64     exec, s[8:9], exec
		v_mov_b32       v15, 0
		v_mov_b32       v16, 0
		s_mov_b64       exec, s[8:9]
		s_load_dwordx4  s[8:11], s[4:5], 0x30

		# batch_size
		s_load_dword    s16, s[4:5], 0x58

		s_load_dwordx2  s[4:5], s[4:5], 0x50
		v_lshlrev_b32   v1, 3, v1
		v_add_u32       v17, v0, v1
		s_waitcnt       lgkmcnt(0)
		v_add_co_u32    v2, vcc, s10, v2
		v_mov_b32       v18, s11
		v_addc_co_u32   v18, vcc, v18, 0, vcc
		v_mov_b32       v19, 0xffffff
		v_add_co_u32    v6, vcc, s8, v6
		v_mov_b32       v20, s9
		v_addc_co_u32   v20, vcc, v20, 0, vcc
		ds_read_b64     v[21:22], v17
		s_add_u32       s4, s4, s6
		s_addc_u32      s5, s5, s7
		v_cndmask_b32   v19, v19, -1, s[2:3]
		v_lshl_add_u32  v8, v35, 3, v0
		v_lshl_add_u32  v7, v34, 3, v0
		v_lshl_add_u32  v12, v12, 3, v0
		v_lshl_add_u32  v0, v11, 3, v0
		v_mov_b32       v10, v36
		v_mov_b32       v23, v37
		s_movk_i32      s2, 0x7ff

		# batch_size
		s_mov_b32       s3, s16

		# Scratchpad masks for strided scratchpads
		#v_mov_b32       v38, 16320
		#v_mov_b32       v39, 262080

		# Scratchpad masks for non-strided scratchpads
		v_mov_b32       v38, 16376
		v_mov_b32       v39, 262136

		# load scratchpad base address
		v_readlane_b32	s0, v2, 0
		v_readlane_b32	s1, v18, 0

main_loop:
		# const uint2 spMix = as_uint2(R[readReg0] ^ R[readReg1]);
		ds_read_b64     v[24:25], v0
		ds_read_b64     v[26:27], v12
		s_waitcnt       lgkmcnt(0)
		v_xor_b32       v25, v27, v25
		v_xor_b32       v24, v26, v24

		# spAddr1 ^= spMix.y;
		# spAddr0 ^= spMix.x;
		v_xor_b32       v10, v25, v10
		v_xor_b32       v23, v24, v23

		# spAddr1 &= ScratchpadL3Mask64;
		# spAddr0 &= ScratchpadL3Mask64;
		v_and_b32       v10, 0x1fffc0, v10
		v_and_b32       v23, 0x1fffc0, v23

		# Offset for non-strided scratchpads
		# offset1 = spAddr1 + sub * 8
		# offset0 = spAddr0 + sub * 8
		v_add_u32       v10, v10, v1
		v_add_u32       v23, v23, v1

		# Offset for strided scratchpads
		# offset1 = mad24(spAddr1, batch_size, sub * 8)
		# offset0 = mad24(spAddr0, batch_size, sub * 8)
		#v_mad_u32_u24   v10, v10, s3, v1
		#v_mad_u32_u24   v23, v23, s3, v1

		# __global ulong* p1 = (__global ulong*)(scratchpad + offset1);
		# __global ulong* p0 = (__global ulong*)(scratchpad + offset0);
		v_add_co_u32    v26, vcc, v2, v10
		v_addc_co_u32   v27, vcc, v18, 0, vcc
		v_add_co_u32    v23, vcc, v2, v23
		v_addc_co_u32   v24, vcc, v18, 0, vcc

		# load from spAddr1
		global_load_dwordx2 v[28:29], v[26:27], off

		# load from spAddr0
		global_load_dwordx2 v[30:31], v[23:24], off
		s_waitcnt       vmcnt(1)

		v_cvt_f64_i32   v[32:33], v28
		v_cvt_f64_i32   v[28:29], v29
		s_waitcnt       vmcnt(0)

		# R[sub] ^= *p0;
		v_xor_b32       v34, v21, v30
		v_xor_b32       v35, v22, v31

		v_add_co_u32    v22, vcc, v6, v36
		v_addc_co_u32   v25, vcc, v20, 0, vcc
		v_or_b32        v30, v32, v13
		v_and_or_b32    v31, v33, v19, v14
		v_or_b32        v28, v28, v15
		v_and_or_b32    v29, v29, v19, v16
		v_add_co_u32    v21, vcc, v22, v1
		v_addc_co_u32   v22, vcc, v25, 0, vcc
		ds_write2_b64   v5, v[30:31], v[28:29] offset1:1
		s_waitcnt       lgkmcnt(0)

		# Program 0
		s_mov_b64 exec, 1

		# load VM integer registers
		v_readlane_b32	s16, v34, 0
		v_readlane_b32	s17, v35, 0
		v_readlane_b32	s18, v34, 1
		v_readlane_b32	s19, v35, 1
		v_readlane_b32	s20, v34, 2
		v_readlane_b32	s21, v35, 2
		v_readlane_b32	s22, v34, 3
		v_readlane_b32	s23, v35, 3
		v_readlane_b32	s24, v34, 4
		v_readlane_b32	s25, v35, 4
		v_readlane_b32	s26, v34, 5
		v_readlane_b32	s27, v35, 5
		v_readlane_b32	s28, v34, 6
		v_readlane_b32	s29, v35, 6
		v_readlane_b32	s30, v34, 7
		v_readlane_b32	s31, v35, 7

		# call JIT code
		s_swappc_b64    s[12:13], s[4:5]

		# store VM integer registers
		v_writelane_b32 v28, s16, 0
		v_writelane_b32 v29, s17, 0
		v_writelane_b32 v28, s18, 1
		v_writelane_b32 v29, s19, 1
		v_writelane_b32 v28, s20, 2
		v_writelane_b32 v29, s21, 2
		v_writelane_b32 v28, s22, 3
		v_writelane_b32 v29, s23, 3
		v_writelane_b32 v28, s24, 4
		v_writelane_b32 v29, s25, 4
		v_writelane_b32 v28, s26, 5
		v_writelane_b32 v29, s27, 5
		v_writelane_b32 v28, s28, 6
		v_writelane_b32 v29, s29, 6
		v_writelane_b32 v28, s30, 7
		v_writelane_b32 v29, s31, 7

		# Restore execution mask
		s_mov_b32       s14, 0xff
		s_mov_b32       s15, 0
		s_mov_b64       exec, s[14:15]

		# Write out VM integer registers
		ds_write_b64    v17, v[28:29]

		global_load_dwordx2 v[21:22], v[21:22], off
		s_waitcnt       vmcnt(0) & lgkmcnt(0)
		v_xor_b32       v21, v28, v21
		v_xor_b32       v22, v29, v22
		ds_read_b32     v28, v7
		ds_read_b32     v29, v8
		ds_write_b64    v17, v[21:22]
		s_waitcnt       lgkmcnt(1)
		ds_read2_b64    v[30:33], v17 offset0:8 offset1:16
		v_xor_b32       v10, v28, v37
		s_waitcnt       lgkmcnt(0)
		v_xor_b32       v30, v32, v30
		v_xor_b32       v31, v33, v31
		v_xor_b32       v10, v10, v29
		global_store_dwordx2 v[26:27], v[21:22], off
		v_and_b32       v10, 0x7fffffc0, v10
		global_store_dwordx2 v[23:24], v[30:31], off
		s_cmp_eq_u32    s2, 0
		s_cbranch_scc1  main_loop_end
		s_sub_i32       s2, s2, 1
		v_mov_b32       v37, v36
		v_mov_b32       v23, 0
		v_mov_b32       v36, v10
		v_mov_b32       v10, 0
		s_branch        main_loop
main_loop_end:

		v_add_co_u32    v0, vcc, v3, v1
		v_addc_co_u32   v1, vcc, v4, 0, vcc
		global_store_dwordx2 v[0:1], v[21:22], off
		global_store_dwordx2 v[0:1], v[30:31], off inst_offset:64
		global_store_dwordx2 v[0:1], v[32:33], off inst_offset:128
program_end:
		s_endpgm
