; Build as GB ROM

.memoryMap
     defaultSlot 0
     slot 0 $0000 size $4000
     slot 1 $C000 size $4000
.endMe

.romBankSize   $4000
.romBanks      2
.romSize       0

.cartridgeType 3 ; MBC1+RAM+battery
.ramsize 02 ; 8K
.computeChecksum
.computeComplementCheck
.emptyfill $FF

;;;; GB ROM header
     ; Reserve space for RST handlers
     .org $70

          ; Keep unused space filled, otherwise
          ; wla moves code here
          .ds $90,0
     
     ; GB header read by bootrom
     .org $100
          nop
          jp   reset
     
     ; Nintendo logo required for proper boot
     .byte $CE,$ED,$66,$66,$CC,$0D,$00,$0B
     .byte $03,$73,$00,$83,$00,$0C,$00,$0D
     .byte $00,$08,$11,$1F,$88,$89,$00,$0E
     .byte $DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
     .byte $BB,$BB,$67,$63,$6E,$0E,$EC,$CC
     .byte $DD,$DC,$99,$9F,$BB,$B9,$33,$3E
     
     ; Internal name
     .ifdef ROM_NAME
          .byte ROM_NAME
          .if ROM_NAME.length < 15
          .ds 15 - ROM_NAME.length, 0 
          .endif
     .endif
     
     ; CGB/DMG requirements
     .org $143
          .ifdef REQUIRE_CGB
               .byte $C0
          .else
               .ifndef REQUIRE_DMG
                    .byte $80
               .endif
          .endif
          .byte 0,0,0
     
     .org $14A
          .byte 0,0,0
     
.org $2150

;;;; Shell

.define NEED_CONSOLE 1
.include "shell.s"

init_runtime:
     ret

play_byte:
     ret

.ends
