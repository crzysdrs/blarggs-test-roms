
.memoryMap
     defaultSlot 0
     slot 0 $0000 size $4000
     slot 1 $C000 size $4000
.endMe

.romBankSize   $4000
.romBanks     4

.cartridgeType 1 ; MBC1+RAM
        .ramsize 00 ; 8K
        .ifdef OVERRIDE_GLOBAL_CHECKSUM
        ;; old rom has bad checksum
        .org $14e
        .dw OVERRIDE_GLOBAL_CHECKSUM
        .else
         .computeGbChecksum
        .endif
        
.computeComplementCheck
        .org 0
        .include "multi_custom.s"
        .define nv_ram_base $d600
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
     
     ; Keep unused space filled, otherwise
     ; wla moves code here
     .org $150
        ;;          .ds $2150-$150,0

;;;; Shell
.bank 0 slot 0        
.org $200
        .define NEED_CONSOLE 1
        .define CUSTOM_RESET
        .define CUSTOM_PRINT
        .define CUSTOM_EXIT
        .define RUNTIME_BEFORE
.include "shell.s"
        
init_runtime:
     call console_init
     .ifdef MULTI_TEST_NAME
          print_str MULTI_TEST_NAME,newline,newline
     .endif
     ret

std_print:
     push af
     sta  SB
     wreg SC,$81
     delay 2304
     pop  af
     jp   console_print

post_exit:
     call console_show
     call play_byte
forever:
     wreg NR52,0    ; sound off
-    jr   -

play_byte:
     ret
        
.ends
