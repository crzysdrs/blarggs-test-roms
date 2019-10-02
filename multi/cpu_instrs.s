
.include "shell.inc"


.org   $3ffd
        jp test_complete                              ; $3ffd: $c3 $6e $06
        
.bank 1 slot 0
        .org $0        
.incbin "libs/cpu_instrs/01-special.subbin"
.incbin "libs/cpu_instrs/02-interrupts.subbin"
.incbin "libs/cpu_instrs/03-op sp,hl.subbin"
.incbin "libs/cpu_instrs/04-op r,imm.subbin"
        .bank 2 slot 0
        .org $0
.incbin "libs/cpu_instrs/05-op rp.subbin"
.incbin "libs/cpu_instrs/06-ld r,r.subbin"
.incbin "libs/cpu_instrs/07-jr,jp,call,ret,rst.subbin"
.incbin "libs/cpu_instrs/08-misc instrs.subbin"
        .bank 3 slot 0
        .org 0
.incbin "libs/cpu_instrs/09-op r,r.subbin"
.incbin "libs/cpu_instrs/10-bit ops.subbin"
.incbin "libs/cpu_instrs/11-op a,(hl).subbin" 
