; =============================================================================
; DRAGON 32/COCO RUBP PROTOCOL MODULE
; 6809 Assembly - Message types in equates.asm
; =============================================================================

rubp_init
        clra
        sta     rubp_seq
        sta     last_recv_seq
        rts

rubp_seq        fcb     0
last_recv_seq   fcb     0

build_header
        sta     msg_type_temp
        ldx     #tx_buffer
        lda     #'R'
        sta     ,x+
        lda     #'A'
        sta     ,x+
        lda     #'C'
        sta     ,x+
        lda     #'H'
        sta     ,x+
        lda     #$01
        sta     ,x+
        clra
        sta     ,x+
        lda     msg_type_temp
        sta     ,x+
        clra
        sta     ,x+
        sta     ,x+
        lda     rubp_seq
        sta     ,x+
        inc     rubp_seq
        lda     player_id
        sta     ,x+
        lda     player_id+1
        sta     ,x+
        lda     game_id
        sta     ,x+
        lda     game_id+1
        sta     ,x+
        clra
        sta     ,x+
        sta     ,x+
        rts

msg_type_temp   fcb     0
player_id       fdb     0
game_id         fdb     0

send_join
        lda     #MSG_JOIN
        jsr     build_header
        ldx     #tx_buffer+16
        ldb     #48
        clra
sj_clear
        sta     ,x+
        decb
        bne     sj_clear
        jsr     net_send
        rts

send_ready
        lda     #MSG_READY
        jsr     build_header
        ldx     #tx_buffer+16
        ldb     #48
        clra
sr_clear
        sta     ,x+
        decb
        bne     sr_clear
        jsr     net_send
        rts

send_play_cards
        stb     card_count_temp
        lda     #MSG_PLAY_CARDS
        jsr     build_header
        lda     card_count_temp
        sta     tx_buffer+16
        lda     nominated_suit
        sta     tx_buffer+17
        clrb
spc_copy
        cmpb    card_count_temp
        bhs     spc_pad
        ldx     #card_play_buf
        lda     b,x
        ldx     #tx_buffer+18
        sta     b,x
        incb
        bra     spc_copy
spc_pad
        cmpb    #8
        bhs     spc_done
        ldx     #tx_buffer+18
        clra
        sta     b,x
        incb
        bra     spc_pad
spc_done
        ldx     #tx_buffer+26
        ldb     #38
        clra
spc_clear
        sta     ,x+
        decb
        bne     spc_clear
        jsr     net_send
        rts

card_count_temp fcb     0
nominated_suit  fcb     $FF
card_play_buf   rmb     8

send_draw
        lda     #MSG_DRAW_CARD
        jsr     build_header
        ldx     #tx_buffer+16
        ldb     #48
        clra
sd_clear
        sta     ,x+
        decb
        bne     sd_clear
        jsr     net_send
        rts

receive_message
        jsr     net_recv
        bcs     rm_none
        lda     rx_buffer
        cmpa    #'R'
        bne     rm_invalid
        lda     rx_buffer+1
        cmpa    #'A'
        bne     rm_invalid
        lda     rx_buffer+2
        cmpa    #'C'
        bne     rm_invalid
        lda     rx_buffer+3
        cmpa    #'H'
        bne     rm_invalid
        lda     rx_buffer+9
        sta     last_recv_seq
        lda     rx_buffer+6
        andcc   #$FE
        rts
rm_invalid
rm_none
        clra
        orcc    #$01
        rts

process_game_state
        lda     rx_buffer+16
        sta     CURRENT_TURN
        lda     rx_buffer+17
        sta     DIRECTION
        lda     rx_buffer+18
        sta     DISCARD_TOP
        lda     rx_buffer+19
        sta     NOMINATED_SUIT
        lda     rx_buffer+20
        sta     PENDING_DRAWS
        lda     rx_buffer+21
        sta     PENDING_SKIPS
        ldx     #rx_buffer+22
        ldy     #PLAYER_COUNTS
        ldb     #8
pgs_counts
        lda     ,x+
        sta     ,y+
        decb
        bne     pgs_counts
        lda     rx_buffer+30
        sta     MY_INDEX
        lda     rx_buffer+31
        sta     HAND_COUNT
        ldx     #rx_buffer+32
        ldy     #MY_HAND
        ldb     #16
pgs_hand
        lda     ,x+
        sta     ,y+
        decb
        bne     pgs_hand
        rts

tx_buffer   rmb     64
rx_buffer   rmb     64
