; =============================================================================
; DRAGON 32/COCO INPUT MODULE
; 6809 Assembly
; =============================================================================

; -----------------------------------------------------------------------------
; Wait for key (blocking)
; Returns: A = key code
; -----------------------------------------------------------------------------
wait_key
wk_loop
        jsr     scan_keyboard
        tsta
        beq     wk_loop
        rts

; -----------------------------------------------------------------------------
; Check for key (non-blocking)
; Returns: A = key if pressed, 0 if no key
; -----------------------------------------------------------------------------
check_key
        jsr     scan_keyboard
        rts

; -----------------------------------------------------------------------------
; Scan keyboard matrix
; Returns: A = key code or 0
; -----------------------------------------------------------------------------
scan_keyboard
        pshs    b,x

        ; Scan keyboard via PIA
        lda     #$FF
        sta     PIA0_DB         ; All columns high

        ldx     #0              ; Column counter
sk_col
        lda     col_bits,x
        coma                    ; Invert for output
        sta     PIA0_DB

        lda     PIA0_DA         ; Read rows
        coma                    ; Invert
        beq     sk_next_col

        ; Key pressed - find row
        ldb     #0
sk_row
        lsra
        bcs     sk_found
        incb
        cmpb    #8
        blt     sk_row
        bra     sk_next_col

sk_found
        ; Calculate key index: col * 8 + row
        tfr     x,a
        lsla
        lsla
        lsla
        sta     ,-s
        tfr     b,a
        adda    ,s+

        ; Look up in key table
        leax    key_table,pcr
        lda     a,x

        puls    b,x,pc

sk_next_col
        leax    1,x
        cmpx    #8
        blt     sk_col

        clra
        puls    b,x,pc

col_bits
        fcb     $01,$02,$04,$08,$10,$20,$40,$80

; Simplified key table
key_table
        fcb     '@','A','B','C','D','E','F','G'
        fcb     'H','I','J','K','L','M','N','O'
        fcb     'P','Q','R','S','T','U','V','W'
        fcb     'X','Y','Z',KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT,KEY_SPACE
        fcb     '0','1','2','3','4','5','6','7'
        fcb     '8','9',':',';',',','-','.',$2F
        fcb     KEY_RETURN,0,KEY_BREAK,0,0,0,0,0
        fcb     0,0,0,0,0,0,0,0

; -----------------------------------------------------------------------------
; Input line
; Input: X = buffer, B = max length
; Returns: A = length entered
; -----------------------------------------------------------------------------
input_line
        stb     il_max
        stx     il_buf
        clra
        sta     il_pos

il_loop
        jsr     wait_key

        cmpa    #KEY_RETURN
        beq     il_done

        cmpa    #KEY_LEFT
        beq     il_delete

        ldb     il_pos
        cmpb    il_max
        bhs     il_loop         ; At max

        cmpa    #32
        blt     il_loop         ; Non-printable
        cmpa    #127
        bhs     il_loop

        ldx     il_buf
        ldb     il_pos
        sta     b,x
        inc     il_pos
        jsr     print_char
        bra     il_loop

il_delete
        lda     il_pos
        beq     il_loop

        dec     il_pos
        lda     #KEY_LEFT
        jsr     print_char
        lda     #' '
        jsr     print_char
        lda     #KEY_LEFT
        jsr     print_char
        bra     il_loop

il_done
        ldx     il_buf
        ldb     il_pos
        clra
        sta     b,x
        lda     il_pos
        rts

il_max  fcb     0
il_pos  fcb     0
il_buf  fdb     0

; -----------------------------------------------------------------------------
; Get input for game (blocking)
; Returns: A = key code
; -----------------------------------------------------------------------------
get_input
        jsr     wait_key
        rts

; -----------------------------------------------------------------------------
; Cursor movement
; -----------------------------------------------------------------------------
cursor_left
        lda     CURSOR_POS
        beq     cl_done
        dec     CURSOR_POS
cl_done
        rts

cursor_right
        lda     CURSOR_POS
        inca
        cmpa    HAND_COUNT
        bhs     cr_done
        inc     CURSOR_POS
cr_done
        rts

toggle_select
        lda     CURSOR_POS
        cmpa    #8
        bhs     ts_high
        ; Low byte
        leax    SELECTED_LO,pcr
        ldb     #1
        tsta
        beq     ts_do_lo
ts_shift_lo
        lslb
        deca
        bne     ts_shift_lo
ts_do_lo
        eorb    ,x
        stb     ,x
        rts
ts_high
        suba    #8
        leax    SELECTED_HI,pcr
        ldb     #1
        tsta
        beq     ts_do_hi
ts_shift_hi
        lslb
        deca
        bne     ts_shift_hi
ts_do_hi
        eorb    ,x
        stb     ,x
        rts
