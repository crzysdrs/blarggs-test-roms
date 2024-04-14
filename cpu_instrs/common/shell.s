; Common routines and runtime

.define RUNTIME_INCLUDED 1

                                ; A few bytes of RAM that aren't cleared
        .ifndef nv_ram_base
        .define nv_ram_base      $D800
        .endif
.define nv_ram           nv_ram_base

; Address of next normal variable
.define bss_base    nv_ram_base + 1
.define bss         bss_base 

; Address of next direct-page ($FFxx) variable
.define dp_base     $FFC0
.define dp          dp_base

; Top of stack
.define std_stack $DFFF

; Final exit result byte is written here
.define final_result     $A000

; Text output is written here as zero-terminated string
.define text_out_base    $A004



; DMG/CGB hardware identifier
.define gb_id_cgb        $10 ; mask for testing CGB bit
.define gb_id_devcart    $04 ; mask for testing "on devcart" bit
.define gb_id       nv_ram
.redefine nv_ram    nv_ram+1

.ifndef NO_COPY
; Copies C*$100 bytes from HL to $C000, then jumps to it.
; A is preserved for jumped-to code.
copy_to_wram_then_run:
     ld   b,a
     
     ld   de,$C000
     ld c, $10
-    ld   a,(hl+)
     ld   (de),a
     inc  e
     jr   nz,-
     inc  d
     dec  c
     jr   nz,-
     
     ld   a,b
     jp   $C000
.endif
       
.ifndef RST_OFFSET
     .define RST_OFFSET 0
.endif

.ifndef CUSTOM_RESET
     reset:
          di
          
          ; Run code from $C000, as is done on devcart. This
          ; ensures minimal difference in how it behaves.
          ld   hl,$4000
          ld   c,$14
          jp   copy_to_wram_then_run
     
     .bank 1 slot 1
     .org 0
          jp   std_reset
.endif


; returnOrg puts this code AFTER user code.
.ifdef RUNTIME_BEFORE
        .section "runtime"
        .define HAS_RUNTIME_SECTION
.endif

.ifdef RUNTIME_AFTER
      .section "runtime" returnorg
        jp   internal_error
       .define HAS_RUNTIME_SECTION
.endif
        
.ifndef HAS_RUNTIME_SECTION        
        jp reset
.endif
        
; Common routines
.include "gb.inc"
.include "macros.inc"
.include "delay.s"
.include "crc.s"
.include "printing.s"
.include "numbers.s"
.include "testing.s"

; Sets up hardware and runs main
std_reset:

     ; Init hardware
     di
     ld   sp,std_stack
     
     ; Save DMG/CGB id
     ld   (gb_id),a
     
     ; Clear memory except very top of stack
     ; Init hardware
     wreg TAC,$00
     wreg IF,$00
     wreg IE,$00
     
     wreg NR52,0    ; sound off
     wreg NR52,$80  ; sound on
     wreg NR51,$FF  ; mono
     wreg NR50,$77  ; volume
        ld hl, std_print
        ;ld   hl,bss_base           
        ;ld   bc,std_stack-bss_base - 2

     ;; call clear_mem
     ;; ld   bc,$FFFF-dp_base
     ;; ld   hl,dp_base
        ;; call clear_mem        
     call init_printing
     call init_testing
     call init_runtime
     call reset_crc

     .ifdef TEST_NAME
          print_str TEST_NAME,newline,newline
     .endif
     
        ;call reset_crc ; in case init_runtime prints anything
     
     delay_msec 250
     
     ; Run user code
     call main
     
     ; Default is to successful exit
     ld   a,0
     jp   exit


; Exits code and reports value of A
exit:
     ld   sp,std_stack
     push af
     call +
     pop  af
     jp   post_exit

+    push af   
     call print_newline
     call show_printing
     pop  af
     
     ; Report exit status
     cp   1
     
     ; 0: ""
     ret  c
     
     ; 1: "Failed"
     jr   nz,+
     print_str "Failed",newline
     ret
     
     ; n: "Failed #n"
+    print_str "Failed #"
     call print_dec
     call print_newline
     ret

.include "apu.s"
.include "cpu_speed.s"

                
reset:
        jp std_reset
        ret

.define STACK_HI $d65f
.define STACK_LO $d65e

main:   
        ld sp, STACK_LO
        ld b, $00
        ld c, $00
        
next_test:        
    ld a, b                                       ; $0642: $78
    srl a                                         ; $0643: $cb $3f
    srl a                                         ; $0645: $cb $3f
    inc a                                         ; $0647: $3c
    ld (BANK), a                                 ; $0648: $ea $00 $20
    ld a, b                                       ; $064b: $78
    swap a                                        ; $064c: $cb $37
    and $30                                       ; $064e: $e6 $30
    or $40                                        ; $0650: $f6 $40
    ld d, a                                       ; $0652: $57
    ld e, $00                                     ; $0653: $1e $00
    ld a, (de)                                    ; $0655: $1a
    cp $c3                                        ; $0656: $fe $c3
    jp nz, print_final_test_status                 ; $0658: $c2 $81 $06

    push bc                                       ; $065b: $c5
    call print_b_plus_1                           ; $065c: $cd $f4 $06
    ld hl, sp+$00                                 ; $065f: $f8 $00
    ld a, l                                       ; $0661: $7d
    ld (STACK_LO), a                                 ; $0662: $ea $5e $d6
    ld a, h                                       ; $0665: $7c
    ld (STACK_HI), a                                 ; $0666: $ea $5f $d6
    ld h, d                                       ; $0669: $62
    ld l, e                                       ; $066a: $6b
    jp copy_to_wram_then_run                      ; $066b: $c3 $00 $02

test_complete:  
    ld d, a                                       ; $066e: $57
    ld a, (STACK_LO)                                 ; $066f: $fa $5e $d6
    ld l, a                                       ; $0672: $6f
    ld a, (STACK_HI)                                 ; $0673: $fa $5f $d6
    ld h, a                                       ; $0676: $67
    ld sp, hl                                     ; $0677: $f9
    ld a, d                                       ; $0678: $7a
    pop bc                                        ; $0679: $c1
    call maybe_print_test_ok                      ; $067a: $cd $fd $06
    inc b                                         ; $067d: $04
    jp next_test                              ; $067e: $c3 $42 $06

print_final_test_status:
    call print_newline                            ; $0681: $cd $ca $02
    call print_newline                            ; $0684: $cd $ca $02
    ld a, c                                       ; $0687: $79
    cp $00                                        ; $0688: $fe $00
    jr nz, failed_c_tests                            ; $068a: $20 $18

    print_str "Passed all tests"        
    jr finish_tests_print                                ; $06a2: $18 $1e

failed_c_tests:
        print_str "Failed "
        ld a, c                                       ; $06b1: $79
        call print_dec
        print_str " tests."
        
finish_tests_print:
    call print_newline                            ; $06c2: $cd $ca $02
    call sound_off                            ; $06c5: $cd $b6 $04
    call sound_on                            ; $06c8: $cd $bb $04
    wreg NR11, $80
    wreg NR12, $f1
    wreg NR13, $00
    ld c, $0a                                     ; $06d7: $0e $0a

delay_c_times_250ms:
    wreg NR14, $87
    delay_msec 250
    dec c                                         ; $06ee: $0d
    jr nz, delay_c_times_250ms                    ; $06ef: $20 $e8

forever2:
    jp forever2                              ; $06f1: $c3 $f1 $06

print_b_plus_1:
    ld a, b                                       ; $06f4: $78
    inc a                                         ; $06f5: $3c
    call print_dec2                            ; $06f6: $cd $50 $03
    call console_flush                            ; $06f9: $cd $51 $08
    ret                                           ; $06fc: $c9

maybe_print_test_ok:
    ld d, a                                       ; $06fd: $57
    call cpu_norm                            ; $06fe: $cd $e3 $05
    print_str ":"
    ld a, d                                       ; $0708: $7a
    cp $00                                        ; $0709: $fe $00
    jr nz, print_test_not_ok                            ; $070b: $20 $0e

    print_str "ok  "
    call console_flush                            ; $0717: $cd $51 $08
    ret                                           ; $071a: $c9

print_test_not_ok:
    inc c                                         ; $071b: $0c
    ld a, b                                       ; $071c: $78
    call play_byte                            ; $071d: $cd $b2 $0b
    ld a, d                                       ; $0720: $7a
    call play_byte                            ; $0721: $cd $b2 $0b
    call console_inverse                            ; $0724: $cd $fb $07
    ld a, d                                       ; $0727: $7a
    call print_dec2                            ; $0728: $cd $50 $03
    call console_normal                            ; $072b: $cd $f8 $07
    print_str "  "
    call console_flush                            ; $0736: $cd $51 $08
    ret                                           ; $0739: $c9

;; ; Clears BC bytes starting at HL
;; clear_mem:
;;      ; If C>0, increment B
;;      dec  bc
;;      inc  c
;;      inc  b
     
;;      ld   a,0
;; -    ld   (hl+),a
;;      dec  c
;;      jr   nz,-
;;      dec  b
;;      jr   nz,-
;;      ret
;;         .ifndef BUILD_MULTI
;;         .ifndef BUILD_DEVCART
;; ; Reports internal error and exits with code 255
;; internal_error:
;;      print_str "Internal error"
;;      ld   a,255
;;      jp   exit
;;         .endif
;;         .endif



; build_devcart and build_multi customize this
.ifndef CUSTOM_PRINT
     .define text_out_addr    bss+0
     .redefine bss            bss+2
     
     ; Initializes text output to cartridge RAM
     init_text_out:
          ; Enable cartridge RAM and set text output pointer
          setb RAMEN,$0A
          setw text_out_addr,text_out_base
          setb text_out_base-3,$DE
          setb text_out_base-2,$B0
          setb text_out_base-1,$61
          setb text_out_base,0
          setb final_result,$80
          ret
     
     
     ; Appends character to text output string
     ; Preserved: AF, BC, DE, HL
     write_text_out:
          push hl
          push af
          ld   a,(text_out_addr)
          ld   l,a
          ld   a,(text_out_addr+1)
          ld   h,a
          inc  hl
          ld   (hl),0
          ld   a,l
          ld   (text_out_addr),a
          ld   a,h
          ld   (text_out_addr+1),a
          dec  hl
          pop  af
          ld   (hl),a
          pop  hl
          ret
     
     print_char_nocrc:
          call write_text_out
          jp   console_print
.endif


; only build_rom uses console
.ifdef NEED_CONSOLE
     .include "console.s"
.else
     console_init:
     console_print:
     console_flush:
     console_normal:
     console_inverse:
     console_show:
     console_set_mode:
          ret
.endif


; build_devcart and build_multi need to customize this
.ifndef CUSTOM_EXIT
     post_exit:
          ld   (final_result),a
     forever:
          wreg NR52,0    ; sound off
-         jr   -
.endif


.macro def_rst ARGS addr
     .bank 0 slot 0
     .org addr+RST_OFFSET
.endm
