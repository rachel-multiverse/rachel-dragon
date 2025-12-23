; =============================================================================
; DRAGON 32/COCO DISPLAY MODULE
; 6809 Assembly - VDG 32x16 text
; =============================================================================

; -----------------------------------------------------------------------------
; Initialize display
; -----------------------------------------------------------------------------
display_init
        jsr     clear_screen
        rts

; -----------------------------------------------------------------------------
; Clear display (alias)
; -----------------------------------------------------------------------------
display_clear
        jsr     clear_screen
        rts

; -----------------------------------------------------------------------------
; Display title screen
; -----------------------------------------------------------------------------
display_title
        jsr     clear_screen
        lda     #6
        ldb     #4
        jsr     set_cursor
        leax    dt_title,pcr
        jsr     print_string
        rts
dt_title
        fcc     /===== RACHEL =====/
        fcb     0

; -----------------------------------------------------------------------------
; Render game (full redraw)
; -----------------------------------------------------------------------------
render_game
        jsr     draw_game_screen
        jsr     redraw_game
        rts

; -----------------------------------------------------------------------------
; Render hand only
; -----------------------------------------------------------------------------
render_hand
        jsr     draw_hand
        rts

; -----------------------------------------------------------------------------
; Clear screen
; -----------------------------------------------------------------------------
clear_screen
        ldx     #SCREEN_BASE
        lda     #$60            ; Green space in VDG
        ldb     #0              ; 256 iterations
cls_loop
        sta     ,x+
        sta     ,x+
        decb
        bne     cls_loop
        rts

; -----------------------------------------------------------------------------
; Set cursor position
; Input: A = column (0-31), B = row (0-15)
; -----------------------------------------------------------------------------
set_cursor
        pshs    a,b

        ; Calculate address: SCREEN_BASE + row * 32 + column
        lda     #0
        tfr     b,a             ; Row to A
        ldb     #32
        mul                     ; D = row * 32

        addd    #SCREEN_BASE
        addb    ,s              ; Add column
        adca    #0
        std     cursor_addr

        puls    a,b,pc

cursor_addr
        fdb     SCREEN_BASE

; -----------------------------------------------------------------------------
; Print character
; Input: A = ASCII character
; -----------------------------------------------------------------------------
print_char
        pshs    x

        ; Convert ASCII to VDG screen code
        jsr     ascii_to_vdg

        ldx     cursor_addr
        sta     ,x+
        stx     cursor_addr

        puls    x,pc

; -----------------------------------------------------------------------------
; Convert ASCII to VDG code
; Input/Output: A
; -----------------------------------------------------------------------------
ascii_to_vdg
        cmpa    #$40            ; @ or above?
        blt     atv_low
        cmpa    #$60
        blt     atv_upper
        ; Lowercase - convert to uppercase screen code
        suba    #$20
atv_upper
        anda    #$3F            ; Mask to 0-63
        rts
atv_low
        cmpa    #$20
        blt     atv_ctrl
        ; Space to ?
        ora     #$40            ; Add $40 for VDG code
        rts
atv_ctrl
        lda     #$60            ; Control chars become space
        rts

; -----------------------------------------------------------------------------
; Print null-terminated string
; Input: X = string address
; -----------------------------------------------------------------------------
print_string
ps_loop
        lda     ,x+
        beq     ps_done
        jsr     print_char
        bra     ps_loop
ps_done
        rts

; -----------------------------------------------------------------------------
; Clear a row
; Input: B = row number
; -----------------------------------------------------------------------------
clear_row
        lda     #0
        jsr     set_cursor
        ldb     #SCREEN_WIDTH
        lda     #$60            ; Space
cr_loop
        jsr     print_char
        decb
        bne     cr_loop
        rts

; -----------------------------------------------------------------------------
; Draw horizontal border
; Input: B = row number
; -----------------------------------------------------------------------------
draw_border
        lda     #0
        jsr     set_cursor
        ldb     #SCREEN_WIDTH
        lda     #'-'
db_loop
        jsr     print_char
        decb
        bne     db_loop
        rts

; -----------------------------------------------------------------------------
; Print a card
; Input: A = card byte
; -----------------------------------------------------------------------------
print_card
        pshs    a

        anda    #$0F            ; Rank
        leax    rank_chars,pcr
        lda     a,x
        jsr     print_char

        puls    a
        lsra
        lsra
        lsra
        lsra
        anda    #$03            ; Suit
        leax    suit_chars,pcr
        lda     a,x
        jsr     print_char

        rts

rank_chars
        fcc     "?A23456789TJQK"

suit_chars
        fcc     "HDCS"

; -----------------------------------------------------------------------------
; Print 2-digit number
; Input: A = number (0-99)
; -----------------------------------------------------------------------------
print_number_2d
        pshs    b
        ldb     #0
pn2d_tens
        cmpa    #10
        blt     pn2d_print
        suba    #10
        incb
        bra     pn2d_tens
pn2d_print
        pshs    a
        tfr     b,a
        adda    #'0'
        jsr     print_char
        puls    a
        adda    #'0'
        jsr     print_char
        puls    b,pc
