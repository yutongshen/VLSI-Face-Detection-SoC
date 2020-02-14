.section .text
.align 2
.globl main
main:
    addi sp, sp, -4
    sw ra, 0(sp)

    # Input
    li a0, 800 * 160 * 3   # Input length
	lui a1, %hi(_binary_input_0_dat_start)
	addi a1, a1, %lo(_binary_input_0_dat_start)
    li a2, 0x08000000  # Conv Base Addr
    addi a3, x0, 0     # DMA mode
    addi a4, x0, 0
	call dma_set

    # Layer1 parameter
    li a0, 2708        # Weights length
	lui a1, %hi(_binary_layer_3_param_dat_start)
	addi a1, a1, %lo(_binary_layer_3_param_dat_start)
    li a2, 0x08080000  # Kernel Base Addr
    addi a3, x0, 0     # DMA mode
    addi a4, x0, 0
	call dma_set

    li a2, 0x08100000  # Conv accelerater configuration register base address
    li t0, 1           # Input mode
    sw t0, 0x4(a2)
    li t0, 5           # Kernel size
    sw t0, 0x8(a2)
    li t0, 1           # Output channel
    sw t0, 0xC(a2)
    li t0, 32 # 160         # Input height
    sw t0, 0x10(a2)
    li t0, 32 # 800         # Input width
    sw t0, 0x14(a2)
    li t0, 3           # Input channel
    sw t0, 0x18(a2)
    li t0, 1           # Stride
    sw t0, 0x1C(a2)
    sw t0, 0x0(a2)     # Run

    # Waiting for ConvAcc finish
    li t0, 0x08100020
wait_conv_s1_l1:
    lw t1, 0x0(t0)     # Check busy signal
    bltu x0, t1, wait_conv_s1_l1
    
    # Move result to DRAM
    li a0, 1 * 55 * 55 * 2
    li a1, 0x08000000  # Conv Base Addr
    lui a2, %hi(_test_start)
    addi a2, a2, %lo(_test_start)
    addi a3, x0, 0
    addi a4, x0, 0
    call dma_set


#     # ====== Segment1 ======
#     # Input
#     li a0, 800 * 160   # Input length
# 	lui a1, %hi(_binary_input_0_dat_start)
# 	addi a1, a1, %lo(_binary_input_0_dat_start)
#     li a2, 0x08000000  # Conv Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     # Layer1 parameter
#     li a0, 52 * 2      # Weights length
# 	lui a1, %hi(_binary_layer_1_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_1_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b10        # Input mode
#     sw t0, 0x4(a2)
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)
#     li t0, 2           # Output channel
#     sw t0, 0xC(a2)
#     li t0, 160         # Input height
#     sw t0, 0x10(a2)
#     li t0, 800         # Input width
#     sw t0, 0x14(a2)
#     li t0, 1           # Input channel
#     sw t0, 0x18(a2)
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020
# wait_conv_s1_l1:
#     lw t1, 0x0(t0)     # Check busy signal
#     bltu x0, t1, wait_conv_s1_l1
# 
#     # Layer2 parameter
#     li a0, 204 * 2     # Weights length
# 	lui a1, %hi(_binary_layer_2_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_2_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b11        # Input mode
#     sw t0, 0x4(a2)                                                           
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)                                                           
#     li t0, 4           # Output channel
#     sw t0, 0xC(a2)                                                           
#     li t0, 78          # Input height
#     sw t0, 0x10(a2)                                                          
#     li t0, 398         # Input width
#     sw t0, 0x14(a2)                                                          
#     li t0, 2           # Input channel
#     sw t0, 0x18(a2)                                                          
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)                                                          
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020  # Check busy signal
# wait_conv_s1_l2:
#     lw t1, 0x0(t0)
#     bltu x0, t1, wait_conv_s1_l2
# 
#     # Move result to DRAM
#     li a0, 197 * 37 * 4 * 2
#     li a1, 0x08000000  # Conv Base Addr
#     lui a2, %hi(_test_start)
#     addi a2, a2, %lo(_test_start)
#     addi a3, x0, 0
#     addi a4, x0, 0
#     call dma_set
# 
#     # ====== Segment2 ======
#     # Input
#     li a0, 800 * 160   # Input length
# 	lui a1, %hi(_binary_input_0_dat_start)
# 	addi a1, a1, %lo(_binary_input_0_dat_start)
#     li t0, 800 * 148   # Segment2 input offset
#     add a1, a1, t0
#     li a2, 0x08000000  # Conv Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     # Layer1 parameter
#     li a0, 52 * 2      # Weights length
# 	lui a1, %hi(_binary_layer_1_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_1_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b10        # Input mode
#     sw t0, 0x4(a2)
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)
#     li t0, 2           # Output channel
#     sw t0, 0xC(a2)
#     li t0, 160         # Input height
#     sw t0, 0x10(a2)
#     li t0, 800         # Input width
#     sw t0, 0x14(a2)
#     li t0, 1           # Input channel
#     sw t0, 0x18(a2)
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020
# wait_conv_s2_l1:
#     lw t1, 0x0(t0)     # Check busy signal
#     bltu x0, t1, wait_conv_s2_l1
# 
#     # Layer2 parameter
#     li a0, 204 * 2     # Weights length
# 	lui a1, %hi(_binary_layer_2_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_2_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b11        # Input mode
#     sw t0, 0x4(a2)                                                           
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)                                                           
#     li t0, 4           # Output channel
#     sw t0, 0xC(a2)                                                           
#     li t0, 78          # Input height
#     sw t0, 0x10(a2)                                                          
#     li t0, 398         # Input width
#     sw t0, 0x14(a2)                                                          
#     li t0, 2           # Input channel
#     sw t0, 0x18(a2)                                                          
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)                                                          
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020  # Check busy signal
# wait_conv_s2_l2:
#     lw t1, 0x0(t0)
#     bltu x0, t1, wait_conv_s2_l2
# 
#     # Move result to DRAM
#     li a0, 197 * 37 * 4 * 2
#     li a1, 0x08000000              # Conv Base Addr
#     lui a2, %hi(_test_start)
#     addi a2, a2, %lo(_test_start)
#     li t0, 197 * 37 * 4 * 2        # Segment2 output offset
#     add a2, a2, t0
#     addi a3, x0, 0
#     addi a4, x0, 0
#     call dma_set
# 
#     # ====== Segment3 ======
#     # Input
#     li a0, 800 * 160   # Input length
# 	lui a1, %hi(_binary_input_0_dat_start)
# 	addi a1, a1, %lo(_binary_input_0_dat_start)
#     li t0, 800 * 296   # Segment3 input offset
#     add a1, a1, t0
#     li a2, 0x08000000  # Conv Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     # Layer1 parameter
#     li a0, 52 * 2      # Weights length
# 	lui a1, %hi(_binary_layer_1_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_1_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b10        # Input mode
#     sw t0, 0x4(a2)
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)
#     li t0, 2           # Output channel
#     sw t0, 0xC(a2)
#     li t0, 160         # Input height
#     sw t0, 0x10(a2)
#     li t0, 800         # Input width
#     sw t0, 0x14(a2)
#     li t0, 1           # Input channel
#     sw t0, 0x18(a2)
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020
# wait_conv_s3_l1:
#     lw t1, 0x0(t0)     # Check busy signal
#     bltu x0, t1, wait_conv_s3_l1
# 
#     # Layer2 parameter
#     li a0, 204 * 2     # Weights length
# 	lui a1, %hi(_binary_layer_2_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_2_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b11        # Input mode
#     sw t0, 0x4(a2)                                                           
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)                                                           
#     li t0, 4           # Output channel
#     sw t0, 0xC(a2)                                                           
#     li t0, 78          # Input height
#     sw t0, 0x10(a2)                                                          
#     li t0, 398         # Input width
#     sw t0, 0x14(a2)                                                          
#     li t0, 2           # Input channel
#     sw t0, 0x18(a2)                                                          
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)                                                          
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020  # Check busy signal
# wait_conv_s3_l2:
#     lw t1, 0x0(t0)
#     bltu x0, t1, wait_conv_s3_l2
# 
#     # Move result to DRAM
#     li a0, 197 * 37 * 4 * 2         # Length
#     li a1, 0x08000000               # Conv Base Addr
#     lui a2, %hi(_test_start)
#     addi a2, a2, %lo(_test_start)
#     li t0, (197 * 37 * 4 * 2) * 2   # Segment3 output offset
#     add a2, a2, t0
#     addi a3, x0, 0
#     addi a4, x0, 0
#     call dma_set
# 
#     # ====== Segment4 ====== 
#     # Input
#     li a0, 800 * 160   # Input length
# 	lui a1, %hi(_binary_input_0_dat_start)
# 	addi a1, a1, %lo(_binary_input_0_dat_start)
#     li t0, 800 * 444   # Segment4 input offset
#     add a1, a1, t0
#     li a2, 0x08000000  # Conv Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     # Layer1 parameter
#     li a0, 52 * 2      # Weights length
# 	lui a1, %hi(_binary_layer_1_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_1_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b10        # Input mode
#     sw t0, 0x4(a2)
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)
#     li t0, 2           # Output channel
#     sw t0, 0xC(a2)
#     li t0, 156         # Input height
#     sw t0, 0x10(a2)
#     li t0, 800         # Input width
#     sw t0, 0x14(a2)
#     li t0, 1           # Input channel
#     sw t0, 0x18(a2)
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020
# wait_conv_s4_l1:
#     lw t1, 0x0(t0)     # Check busy signal
#     bltu x0, t1, wait_conv_s4_l1
# 
#     # Layer2 parameter
#     li a0, 204 * 2     # Weights length
# 	lui a1, %hi(_binary_layer_2_param_dat_start)
# 	addi a1, a1, %lo(_binary_layer_2_param_dat_start)
#     li a2, 0x0803F800  # Kernel Base Addr
#     addi a3, x0, 0     # DMA mode
#     addi a4, x0, 0
# 	call dma_set
# 
#     li a2, 0x08040000  # Conv accelerater configuration register base address
#     li t0, 0b11        # Input mode
#     sw t0, 0x4(a2)                                                           
#     li t0, 5           # Kernel size
#     sw t0, 0x8(a2)                                                           
#     li t0, 4           # Output channel
#     sw t0, 0xC(a2)                                                           
#     li t0, 76          # Input height
#     sw t0, 0x10(a2)                                                          
#     li t0, 398         # Input width
#     sw t0, 0x14(a2)                                                          
#     li t0, 2           # Input channel
#     sw t0, 0x18(a2)                                                          
#     li t0, 1           # Stride
#     sw t0, 0x1C(a2)                                                          
#     sw t0, 0x0(a2)     # Run
# 
#     # Waiting for ConvAcc finish
#     li t0, 0x08040020  # Check busy signal
# wait_conv_s4_l2:
#     lw t1, 0x0(t0)
#     bltu x0, t1, wait_conv_s4_l2
# 
#     # Move result to DRAM
#     li a0, 197 * 36 * 4 * 2         # Length
#     li a1, 0x08000000               # Conv Base Addr
#     lui a2, %hi(_test_start)
#     addi a2, a2, %lo(_test_start)
#     li t0, (197 * 37 * 4 * 2) * 3   # Segment4 output offset
#     add a2, a2, t0
#     addi a3, x0, 0
#     addi a4, x0, 0
#     call dma_set

    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret
