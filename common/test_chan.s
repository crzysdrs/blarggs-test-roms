; Runs test on all four channels

.include "apu.s"

.define chan_index	dp+0
.define chan_base	dp+1
.define chan_mask	dp+2
.define chan_maxlen	dp+3
.redefine dp		dp+4

; Writes data to NRxN, where x is current channel being tested
; Preserved: B, DE, HL
; Time: 11 cycles
.macro wchn ARGS N,data
	lda	chan_base
	add	N
	ld	c,a
	ld	a,data
	ld	($FF00+c),a
.endm

.macro wchnb ARGS N
	lda	chan_base
	add	N
	ld	c,a
	ld	a,b
	ld	($FF00+c),a
.endm

.macro test_chan_common ; chan
	ld	a,\1
	sta	chan_index
	call	print_dec
	call	print_space
	
	; Set variables
	ld	a,\1*5+(NR10-$FF00)
	sta	chan_base
	ld	a,1<<\1
	sta	chan_mask
	.if \1 == 2
		ld	a,0
	.else
		ld	a,64
	.endif
	sta	chan_maxlen
.endm

.macro test_chan_begin ; chan
	; Enable channel's DAC
	.if \1 == 2
		wreg \1*5+NR10,$80
	.else
		wreg \1*5+NR12,$08
	.endif
.endm

.macro test_one_chan ; chan
	test_chan_common \1
	call	console_flush
	test_chan_begin \1
	call	test_chan
.endm

.macro test_all_chans
	test_one_chan 0
	test_one_chan 1
	test_one_chan 2
	test_one_chan 3
.endm

.macro test_chan_timing ; chan, iter
	test_chan_common \1
	
	ld	a,\2
test_chan_timing\@:
	; Enable channel's DAC
	push	af
	test_chan_begin \1
	pop	af
	
	push	af
	test_chan 1<<\1, \1*5+NR10
	call	console_flush
	pop	af
	
	dec	a
	jp	nz,test_chan_timing\@
	
	call	print_newline
.endm

.macro test_chans_timing ARGS iter
	test_chan_timing 0,iter
	test_chan_timing 1,iter
	test_chan_timing 2,iter
	test_chan_timing 3,iter
.endm
