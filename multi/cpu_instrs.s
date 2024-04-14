
.include "shell.inc"


.org   $3ffd
        jp test_complete                              ; $3ffd: $c3 $6e $06

.bank 1 slot 0
        .org $0        
.incbin "libs/cpu_instrs/01-special.multi.gb"  SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/02-interrupts.multi.gb" SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/03-op sp,hl.multi.gb" SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/04-op r,imm.multi.gb" SKIP 4096 READ 4096
        .bank 2 slot 0
        .org $0
.incbin "libs/cpu_instrs/05-op rp.multi.gb" SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/06-ld r,r.multi.gb" SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/07-jr,jp,call,ret,rst.multi.gb" SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/08-misc instrs.multi.gb" SKIP 4096 READ 4096
        .bank 3 slot 0
        .org 0
.incbin "libs/cpu_instrs/09-op r,r.multi.gb" SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/10-bit ops.multi.gb" SKIP 4096 READ 4096
.incbin "libs/cpu_instrs/11-op a,(hl).multi.gb"  SKIP 4096 READ 4096
