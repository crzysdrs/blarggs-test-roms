; Sound chip utilities

; Turns APU off
; Preserved: BC, DE, HL
sound_off:
	wreg	NR52,0
	ret
        
; Turns APU on
; Preserved: BC, DE, HL
sound_on:
	wreg	NR52,$80	; power
	wreg NR51,$FF	; mono
	wreg NR50,$77	; volume
	ret

.define sync_apu_time 4073
sync_apu:
        wreg NR24,$00
        wreg NR21, $3e        
        wreg NR22, $08
        wreg NR24, $c0
-:      ldh a, ($26)
        and $02
        jr nz, -
        ret
        
; Synchronizes to first square sweep within
; tens of clocks. Uses square 1 channel.
; Preserved: BC, DE, HL
sync_sweep:
	wreg	NR10,$11	; sweep period = 1, shift = 1
	wreg	NR12,$08	; silent without disabling channel
	wreg	NR13,$FF	; freq = $3FF
	wreg	NR14,$83	; start
-	lda	NR52
	and	$01
	jr	nz,-
	ret

; Copies 16-byte wave from (HL) to wave RAM
; Preserved: BC, DE
load_wave:
	push	bc
	wreg	NR30,$00	; disable while writing
	ld	c,$30
-	ld	a,(hl+)
	ld	($FF00+c),a
	inc	c
	bit	6,c
	jr	z,-
	pop	bc
	ret
          
unknown2:
         xor a
        sta NR52
    dec a
    sta NR52
    sta NR51
    sta NR50
        wreg NR12, $f1
        wreg NR14, $86
        delay_msec 250
    ret

        
unknown_agian:
        push bc
        ld c, a
        ld b, $08
        wreg NR10, $00
        wreg NR11, $80
        wreg NR13, $f8
- ld a, $60
        rl c
        jr nc, +
        ld a, $a0
+       sta NR12
        wreg NR14, $87
        delay $13b
        wreg NR12 $00
        delay $69
    dec b
    jr nz,-

    pop bc
    ret

    
unknown____:    
        push bc
        
    ld c, $30
-  ld ($FF00 + c), a
    inc c
    bit 6, c
    jr z, -

    pop bc
        ret


 
unknown_123: 

    push bc
    ld c, a
    ld b, $00
   
             
-   lda NR52
    and c
    jr z, +

    delay $ff6 
    inc b
    jr nz, -
+   ld a, b
    pop bc
        ret
  
; Synchronizes to APU length counter within
; 5 cycles. Uses square 2 channel.
; Preserved: AF, BC, DE, HL
sync_apu_fast:                  
	push	af
	push	hl
	ld hl, $ff26        
	wreg	NR22,$08	; silent without disabling channel
        wreg    NR24,$40
	wreg	NR21,-2	; length = 3, to avoid early expiration
	wreg	NR24,$C0	; start length
	
	ld	a,$02
-	and	(hl)		; wait for length to expire
	jr	nz,-
-      delay $FED
        wreg NR21, $ff
        wreg NR24, $c0
        lda NR52
    nop
    nop
    and $02
    jr nz, -
	pop	hl
	pop	af
	ret

;; ; Gets current length counter value for
;; ; channel with mask A into A. Length counter
;; ; must be enabled for that channel.
;; ; Preserved: BC, DE, HL
;; get_len_a:
;; 	push	bc
;; 	ld	c,a
;; 	ld	b,0
;; -	lda	NR52		; 3
;; 	and	c		; 1
;; 	jr	z,+		; 2
;; 	delay 4096-10
;; 	inc	b		; 1
;; 	jr	nz,-		; 3
;; +	ld	a,b
;; 	pop	bc
;; 	ret
            
;; ; Fills wave RAM with A
;; ; Preserved: A, BC, DE, HL
;; fill_wave:
;; 	push	bc
;; 	ld	bc,$1030
;; -	ld	($FF00+c),a
;; 	inc	c
;; 	dec	b
;; 	jr	nz,-
;; 	pop	bc
;; 	ret

; Synchronizes exactly to length clock. Next length clock
; occurs by 4075 clocks after this returns. Uses NR2x.
; Preserved: AF, BC, DE, HL

;; 	call	sync_apu_fast
	
;; 	push	af
;; 	push	hl
	
;; 	wreg	NR21,-1
;; 	wreg	NR24,$C0
;; 	delay 4074-17
;; 	ld	hl,NR52
;; 	ld	a,(hl)
;; 	ld	h,(hl)
;; 	bit	1,a
;; 	jr	nz,+
;; +	ld	a,h
;; 	rra
;; 	rra
	
;; 	wreg	NR21,-1	; length = 1
;; 	wreg	NR24,$C0	; start length
;; 	delay 4072
;; 	ld	hl,NR52
;; 	ld	a,(hl)
;; 	ld	h,(hl)
;; 	jr	c,+
;; +	bit	1,h
;; 	jr	nz,+
;; +	rra
;; 	rra
;; 	jr	c,+
;; +	
;; 	pop	hl
;; 	pop	af
;; 	ret





;; ; Fills all APU registers ($FF10-$FF2F), except NR52
;; ; A <- Byte to write
;; ; Preserved: A, BC, DE, HL
;; fill_apu_regs:
;; 	push	bc
;; 	ld	bc,$2000+(<NR10)
;; -	ld	($FF00+c),a
;; 	inc	c
;; 	dec	b
;; 	jr	nz,-
;; 	pop	bc
;; 	ret
	


; Delays n*16384 clocks
; Preserved: AF, BC, DE, HL
.macro delay_apu ARGS n
	delay_clocks n*16384
.endm


; Delays A*16384 clocks + overhead
; Preserved: BC, DE, HL
; Time: A*16384+48 clocks (including CALL)
delay_apu_cycles:
    ;;  This method is really some delay macro, expanded
    or a
    jr nz, jr_001_6445
    ret

    push af
    ld a, $d3
    jr jr_001_6448
jr_001_6445:
    push af
    ld a, $df
jr_001_6448:
    call  delay_a_20_cycles
    delay $f00
    pop af
    dec a
    jr nz, jr_001_6445

    ret

;; ; Gets length of channel without delays
;; ; A -> Channel index (0 to 3)
;; ; A <- Length counter's contents
;; ; carry <- Clear if channel was already off
;; ; Preserved: BC, DE, HL
;; get_len_fast:
;; 	push	bc
;; 	push	hl
	
;; 	; Generate appropriate address and mask for
;; 	; channel
;; 	ld	h,a
;; 	ld	a,(<NR14)-5
;; 	ld	c,$80
;; 	inc	h
;; -	add	5
;; 	rlc	c
;; 	dec	h
;; 	jr	nz,-
;; 	ld	l,a		; HL = NRx4
;; 	ld	h,$FF
;; 	ld	b,0		; B = length count
	
;; 	; Disable length only if enabled
;; 	; (avoids extra clocking on CGB-02)
;; 	bit	6,(hl)
;; 	jr	z,+
;; 	ld	(hl),0
;; +
;; 	; End early if channel already off
;; 	lda	NR52
;; 	and	c
;; 	jr	z,@off
	
;; 	; Handle wave channel separately
;; 	cp	$04
;; 	jp	z,@wave
	
;; 	; Setup other channel
;; 	wreg	NR30,$80
;; 	wreg	NR31,-4
;; 	wreg	NR34,$C0
;; 	wreg	NR31,-1
	
;; 	; Wait for other's length to decrement
;; -	lda	NR52
;; 	and	$04
;; 	jr	nz,-
	
;; 	; Decrement length until it expires. Plenty of
;; 	; time to decrement 64 times if necessary.
;; -	ld	(hl),$40
;; 	ld	(hl),0
;; 	inc	b
;; 	lda	NR52
;; 	and	c
;; 	jr	nz,-
;; @done:
;; 	scf
	
;; @off:
;; 	ld	a,b
;; 	pop	hl
;; 	pop	bc
;; 	ret

;; @wave:
;; 	; Setup other channel
;; 	wreg	NR22,$08
;; 	wreg	NR21,-4
;; 	wreg	NR24,$C0
;; 	wreg	NR21,-1
	
;; 	; Wait for other's length to decrement
;; -	lda	NR52
;; 	and	$02
;; 	jr	nz,-
	
;; 	; Decrement length until it expires or
;; 	; too much time passes
;; 	ld	c,64
;; -	dec	c
;; 	jr	z,@wave
;; 	ld	(hl),$40
;; 	ld	(hl),0
;; 	inc	b
;; 	lda	NR52
;; 	and	$04
;; 	jr	nz,-
;; 	jr	@done
