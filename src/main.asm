; =============================================================================
; RACHEL - DRAGON 32/COCO MAIN MODULE
; 6809 Assembly - Entry point and main loop
; =============================================================================

        org     $3000

start
        orcc    #$50            ; Disable interrupts
        jsr     init_system
        jsr     display_init
        jsr     display_title

        ; Get server address
        jsr     input_ip_address

        ; Connect to server
        jsr     do_connect
        bcs     conn_failed

        ; Initialize RUBP
        jsr     rubp_init

        ; Send HELLO with player name and platform ID
        jsr     send_hello

        ; Wait for game to start
        jsr     wait_for_game

        ; Main game loop
main_loop
        jsr     net_recv
        bcs     ml_no_msg

        jsr     rubp_validate
        bcs     ml_no_msg

        lda     rx_buffer+6     ; Message type
        cmpa    #MSG_GAME_STATE
        bne     ml_check_end

        jsr     process_game_state
        jsr     render_game
        bra     ml_input

ml_check_end
        cmpa    #MSG_GAME_END
        bne     ml_no_msg
        jmp     game_over

ml_no_msg
ml_input
        ; Check if it's our turn
        lda     CURRENT_TURN
        cmpa    MY_INDEX
        bne     main_loop

        ; Handle input
        jsr     get_input
        cmpa    #KEY_QUIT
        beq     quit_game
        cmpa    #KEY_LEFT
        beq     ml_left
        cmpa    #KEY_RIGHT
        beq     ml_right
        cmpa    #KEY_SELECT
        beq     ml_select
        cmpa    #KEY_PLAY
        beq     ml_play
        cmpa    #KEY_DRAW
        beq     ml_draw
        bra     main_loop

ml_left
        jsr     cursor_left
        jsr     render_hand
        bra     main_loop

ml_right
        jsr     cursor_right
        jsr     render_hand
        bra     main_loop

ml_select
        jsr     toggle_select
        jsr     render_hand
        bra     main_loop

ml_play
        jsr     count_selected
        beq     main_loop       ; Nothing selected
        jsr     build_play_msg
        jsr     net_send
        bra     main_loop

ml_draw
        jsr     send_draw
        bra     main_loop

conn_failed
        jsr     display_clear
        leax    msg_conn_fail,pcr
        jsr     print_string
        jmp     wait_key

game_over
        jsr     display_clear
        leax    msg_game_over,pcr
        jsr     print_string
        jsr     wait_key

quit_game
        jsr     net_close
        rts

; -----------------------------------------------------------------------------
; Helper routines
; -----------------------------------------------------------------------------
init_system
        jsr     net_init
        rts

input_ip_address
        jsr     display_clear
        leax    msg_enter_ip,pcr
        jsr     print_string
        jsr     input_line
        rts

do_connect
        jsr     display_clear
        leax    msg_connecting,pcr
        jsr     print_string
        jsr     net_connect
        rts

wait_for_game
        jsr     display_clear
        leax    msg_waiting,pcr
        jsr     print_string
wfg_loop
        jsr     net_recv
        bcs     wfg_loop
        jsr     rubp_validate
        bcs     wfg_loop
        lda     rx_buffer+6
        cmpa    #MSG_GAME_STATE
        bne     wfg_loop
        jsr     process_game_state
        rts

rubp_validate
        lda     rx_buffer
        cmpa    #'R'
        bne     rv_fail
        lda     rx_buffer+1
        cmpa    #'A'
        bne     rv_fail
        lda     rx_buffer+2
        cmpa    #'C'
        bne     rv_fail
        lda     rx_buffer+3
        cmpa    #'H'
        bne     rv_fail
        andcc   #$FE            ; Clear carry
        rts
rv_fail
        orcc    #$01            ; Set carry
        rts

count_selected
        ldx     #selected_flags
        ldb     #0
        lda     HAND_COUNT
        sta     zp_temp1
cs_loop
        tst     ,x+
        beq     cs_next
        incb
cs_next
        dec     zp_temp1
        bne     cs_loop
        tfr     b,a
        rts

build_play_msg
        lda     #MSG_PLAY_CARDS
        jsr     build_header
        jsr     count_selected
        sta     tx_buffer+16
        lda     nominated_suit
        sta     tx_buffer+17
        ldx     #selected_flags
        ldy     #MY_HAND
        ldu     #tx_buffer+18
        ldb     HAND_COUNT
bpm_loop
        tst     ,x+
        beq     bpm_next
        lda     ,y
        sta     ,u+
bpm_next
        leay    1,y
        decb
        bne     bpm_loop
        ; Clear selection
        ldx     #selected_flags
        ldb     #16
        clra
bpm_clr
        sta     ,x+
        decb
        bne     bpm_clr
        rts

; wait_key is defined in input.asm

; -----------------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------------
msg_enter_ip    fcc     /ENTER SERVER IP:/
                fcb     13
                fcb     0
msg_connecting  fcc     /CONNECTING.../
                fcb     13
                fcb     0
msg_waiting     fcc     /WAITING FOR GAME.../
                fcb     13
                fcb     0
msg_conn_fail   fcc     /CONNECTION FAILED/
                fcb     13
                fcb     0
msg_game_over   fcc     /GAME OVER!/
                fcb     13
                fcb     0

selected_flags  rmb     16
zp_temp1        rmb     1

; -----------------------------------------------------------------------------
; Includes
; -----------------------------------------------------------------------------
        include "equates.asm"
        include "display.asm"
        include "input.asm"
        include "game.asm"
        include "connect.asm"
        include "rubp.asm"
        include "net/wifi.asm"

        end     start
