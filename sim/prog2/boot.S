.section .text
.align 2
.globl dma_set
dma_set:
	li a5, 0x40000000 # dma_addr
	sw a0, 0x4(a5)    # Block Length Resgister
	sw a1, 0x8(a5)    # Source Base Address Register
	sw a2, 0xc(a5)    # Destin Base Address Register
	sw a3, 0x10(a5)   # Mode Register
    sw a4, 0x14(a5)   # Interrupt Enable Register
	addi t0, x0, 0x1
	sw t0, 0x0(a5)    # Run
wait_dma:
    lw t1, 0x20(a5)
    bltu x0, t1, wait_dma
    # wfi
    ret

.section .text
.align 2
.globl boot
boot:
    addi sp, sp, -4
    sw ra, 0(sp)

    # # Enable Global Interrupt
	# csrsi mstatus, 0x8
    # # Enable Local Interrupt
	# li t6, 0x800
	# csrs mie, t6

    # Move to IM
	lui a5, %hi(_dram_i_end)
	addi a5, a5, %lo(_dram_i_end)
	addi a4,a5,4
	lui a1, %hi(_dram_i_start)
	addi a1, a1, %lo(_dram_i_start)
	sub a0, a4, a1
	lui a5, %hi(_imem_start)
	addi a2, a5, %lo(_imem_start)
    addi a3, x0, 0
    addi a4, x0, 0
	call dma_set

    # Move to IM
	lui a5, %hi(__sdata_end)
	addi a5, a5, %lo(__sdata_end)
	addi a4, a5, 4
	lui a2, %hi(__sdata_start)
	addi a2, a2, %lo(__sdata_start)
	sub a0, a4, a2
	lui a5, %hi(__sdata_paddr_start)
	addi a1, a5, %lo(__sdata_paddr_start)
    addi a3, x0, 0
    addi a4, x0, 0
	call dma_set

    # Move to DM
	lui a5, %hi(__data_end)
	addi a5, a5, %lo(__data_end)
	addi a4, a5, 4
	lui a2, %hi(__data_start)
	addi a2, a2, %lo(__data_start)
	sub a0, a4, a2
	lui a5, %hi(__data_paddr_start)
	addi a1, a5, %lo(__data_paddr_start)
    addi a3, x0, 0
    addi a4, x0, 0
	call dma_set

#     # # Disable MPIE of mstatus
#     # csrwi mstatus, 0x0
#     # csrwi mie, 0x0

    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret
