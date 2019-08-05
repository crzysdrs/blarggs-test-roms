; Build as subtest of multi-test

.memoryMap
	defaultSlot 0
	slot 0 $0000 size $1000
	slot 1 $C000 size $1000
.endMe

.romBankSize	$1000
.romBanks		2
;.emptyfill	$FF

.org $70
	.ds $148-$70,0

.bank 1 slot 1
.org 0

;;;; Shell

.define CUSTOM_EXIT  1
        ;; .define CUSTOM_PRINT 1
.define CUSTOM_RESET 1
.define NO_COPY 1

        .include "runtime.s"
        .section "RETS" returnorg

        init_runtime:
 	ret

std_print:
        ret
post_exit:
	jp	$3FFD
internal_error:
                        ; shouldn't ever be called
        
forever:       jr  forever
reset:
        ret


;; init_text_out:
;; 	ret

        

;; print_char_nocrc:
;; 	ret ; ignore text output

;; play_byte:
;; 	ret


.ends                           
