.include "apu.s"

init_timer:
	wreg	NR52,$80	; power on
	ret

start_timer:
	jp	sync_apu

stop_timer:
	push	bc
	
	nop
	nop
	nop
	nop
	
	ld	b,-10
	
	wreg	NR22,$08	; silent without disabling channel
	wreg	NR21,-3	; length = 3, to avoid early expiration
	wreg	NR24,$C0	; start length
	
	ld	hl,NR52
	wreg	NR21,-1	; length = 1
	ld	a,$02
-	dec	b
	and	(hl)		; wait for length to expire
	jr	nz,-
	
	push	de
	push	hl
	
	wreg	NR21,-1
	wreg	NR24,$C0
	delay 4066
	ld	hl,NR52
	ld	c,(hl)
	ld	d,(hl)
	ld	e,(hl)
	
	wreg	NR21,-1	; length = 1
	wreg	NR24,$C0	; start length
	delay 4081
	ld	a,(hl)
	ld	l,(hl)
	ld	h,a
	
	ld	a,b
	add	a
	add	a
	add	b
	add	b
	
	bit	1,c
	jr	nz,+
	inc	a
+	bit	1,h
	jr	nz,+
	inc	a
+	bit	1,d
	jr	nz,+
	inc	a
+	bit	1,l
	jr	nz,+
	inc	a
+	bit	1,e
	jr	nz,+
	inc	a
+	
	pop	hl
	pop	de
	pop	bc
	ret
