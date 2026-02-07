.text
.globl _start
_start:
    addi x1, x0, 0              # x1 = 0 (base)

    # ===== SW: ghi 0xDDCCBBAA tại địa chỉ 0 =====
    addi x2, x0, -8730          # x2 = 0xFFFFDDAA  (→ 0xDDCCBBAA dưới dạng 32-bit 2’s complement)
    sw   x2, 0(x1)              # word@0 = 0xDDCCBBAA (ghi nguyên 32-bit từ x2)

    # ===== SW: ghi 0xFF8007E5 tại địa chỉ 4 =====
    addi x3, x0, -32731         # x3 = 0xFFFF8075 (→ 0xFF8007E5)
    sw   x3, 4(x1)              # word@4 = 0xFF8007E5

    # ===== SW: ghi 0x000007C3 tại địa chỉ 8 =====
    addi x4, x0, 1987           # x4 = 0x000007C3
    sw   x4, 8(x1)

done:
    j done
