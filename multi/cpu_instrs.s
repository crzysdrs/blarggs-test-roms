
.include "shell.inc"


.org   $3ffd
        jp $066e                              ; $3ffd: $c3 $6e $06
        
.bank 1 slot 0
        .org $0        
.incbin "libs/cpu_instrs/01-special.bin"
.incbin "libs/cpu_instrs/02-interrupts.bin"
.incbin "libs/cpu_instrs/03-op sp,hl.bin"
.incbin "libs/cpu_instrs/04-op r,imm.bin"
        .bank 2 slot 0
        .org $0
.incbin "libs/cpu_instrs/05-op rp.bin"
.incbin "libs/cpu_instrs/06-ld r,r.bin"
.incbin "libs/cpu_instrs/07-jr,jp,call,ret,rst.bin"
.incbin "libs/cpu_instrs/08-misc instrs.bin"
        .bank 3 slot 0
        .org 0
.incbin "libs/cpu_instrs/09-op r,r.bin"
.incbin "libs/cpu_instrs/10-bit ops.bin"
.incbin "libs/cpu_instrs/11-op a,(hl).bin" 
