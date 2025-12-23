; =============================================================================
; DRAGON 32/COCO GAME MODULE
; 6809 Assembly - 32x16 display
; =============================================================================

; -----------------------------------------------------------------------------
; Draw the complete game screen
; -----------------------------------------------------------------------------
draw_game_screen
        jsr     display_init

        lda     #10
        ldb     #0
        jsr     set_cursor
        leax    gm_title,pcr
        jsr     print_string

        ldb     #1
        jsr     draw_border
        ldb     #3
        jsr     draw_border
        ldb     #6
        jsr     draw_border
        ldb     #11
        jsr     draw_border
        ldb     #13
        jsr     draw_border

        lda     #0
        ldb     #7
        jsr     set_cursor
        leax    gm_hand,pcr
        jsr     print_string

        lda     #0
        ldb     #12
        jsr     set_cursor
        leax    gm_ctrl,pcr
        jsr     print_string

        rts

gm_title    fcc     "RACHEL V1.0"
            fcb     0
gm_hand     fcc     "YOUR HAND:"
            fcb     0
gm_ctrl     fcc     "L/R=MOVE SPC=SEL RET=PLAY"
            fcb     0

; -----------------------------------------------------------------------------
; Full game redraw
; -----------------------------------------------------------------------------
redraw_game
        jsr     draw_players
        jsr     draw_discard
        jsr     draw_hand
        jsr     draw_turn_indicator
        rts

; =============================================================================
; PLAYER LIST
; =============================================================================

draw_players
        lda     #0
        ldb     #2
        jsr     set_cursor

        clra
dp_loop1
        sta     dp_idx
        jsr     draw_one_player
        lda     dp_idx
        inca
        cmpa    #4
        blt     dp_loop1

        rts

dp_idx  fcb     0

draw_one_player
        lda     #'P'
        jsr     print_char
        lda     dp_idx
        adda    #'1'
        jsr     print_char
        lda     #':'
        jsr     print_char

        ldx     #PLAYER_COUNTS
        ldb     dp_idx
        lda     b,x
        jsr     print_number_2d

        lda     #' '
        jsr     print_char
        rts

; =============================================================================
; DISCARD PILE
; =============================================================================

draw_discard
        lda     #10
        ldb     #4
        jsr     set_cursor
        leax    dd_lbl,pcr
        jsr     print_string

        lda     #12
        ldb     #5
        jsr     set_cursor

        lda     DISCARD_TOP
        beq     dd_empty
        jsr     print_card
        bra     dd_suit

dd_empty
        leax    dd_mt,pcr
        jsr     print_string
        rts

dd_suit
        lda     NOMINATED_SUIT
        cmpa    #$FF
        beq     dd_done

        ; No room in 32-col for suit name
dd_done
        rts

dd_lbl      fcc     "DISCARD:"
            fcb     0
dd_mt       fcc     "[EMPTY]"
            fcb     0

; =============================================================================
; HAND DISPLAY
; =============================================================================

draw_hand
        lda     HAND_COUNT
        bne     dh_has_cards

        lda     #0
        ldb     #8
        jsr     set_cursor
        leax    dh_empty,pcr
        jsr     print_string
        rts

dh_has_cards
        lda     #0
        ldb     #8
        jsr     set_cursor

        clra
        sta     dh_pos
        sta     dh_col

dh_loop
        lda     dh_pos
        jsr     check_selected
        beq     dh_not_sel

        lda     #'['
        jsr     print_char
        bra     dh_card

dh_not_sel
        lda     dh_pos
        cmpa    CURSOR_POS
        bne     dh_not_cur

        lda     #'>'
        jsr     print_char
        bra     dh_card

dh_not_cur
        lda     #' '
        jsr     print_char

dh_card
        ldx     #MY_HAND
        ldb     dh_pos
        lda     b,x
        jsr     print_card

        lda     dh_pos
        jsr     check_selected
        beq     dh_no_close
        lda     #']'
        jsr     print_char
        bra     dh_space
dh_no_close
        lda     #' '
        jsr     print_char

dh_space
        inc     dh_pos
        inc     dh_col

        lda     dh_col
        cmpa    #5              ; 5 cards per row for 32-col
        bne     dh_no_newline

        clra
        sta     dh_col

        lda     dh_pos
        lsra
        lsra
        lsra
        adda    #8
        tfr     a,b
        lda     #0
        jsr     set_cursor

dh_no_newline
        lda     dh_pos
        cmpa    HAND_COUNT
        blt     dh_loop

        rts

dh_pos      fcb     0
dh_col      fcb     0
dh_empty    fcc     "(NO CARDS)"
            fcb     0

; -----------------------------------------------------------------------------
; Check if card selected
; -----------------------------------------------------------------------------
check_selected
        cmpa    #8
        bhs     cks_high

        tfr     a,b
        lda     SELECTED_LO
        bra     cks_shift

cks_high
        suba    #8
        tfr     a,b
        lda     SELECTED_HI

cks_shift
        tstb
        beq     cks_test
cks_sloop
        lsra
        decb
        bne     cks_sloop

cks_test
        anda    #1
        rts

; =============================================================================
; TURN INDICATOR
; =============================================================================

draw_turn_indicator
        ldb     #14
        jsr     clear_row

        lda     #6
        ldb     #14
        jsr     set_cursor

        lda     CURRENT_TURN
        cmpa    MY_INDEX
        bne     dti_other

        leax    dti_your,pcr
        jsr     print_string
        rts

dti_other
        leax    dti_player,pcr
        jsr     print_string

        lda     CURRENT_TURN
        adda    #'1'
        jsr     print_char

        leax    dti_turn,pcr
        jsr     print_string
        rts

dti_your    fcc     ">>> YOUR TURN <<<"
            fcb     0
dti_player  fcc     "PLAYER "
            fcb     0
dti_turn    fcc     "'S TURN"
            fcb     0
