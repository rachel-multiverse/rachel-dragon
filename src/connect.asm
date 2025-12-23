; =============================================================================
; DRAGON 32/COCO CONNECTION MODULE
; 6809 Assembly
; =============================================================================

connect_server
        jsr     net_init
        bcs     conn_fail
        jsr     net_connect
        bcs     conn_fail
        lda     #1
        sta     connected
        andcc   #$FE            ; Clear carry
        rts
conn_fail
        clra
        sta     connected
        orcc    #$01            ; Set carry
        rts

conn_port   fdb     0
connected   fcb     0
server_ip   rmb     4

disconnect
        lda     connected
        beq     disc_done
        jsr     net_close
        clra
        sta     connected
disc_done
        rts

show_connect_screen
        jsr     display_init
        lda     #6
        ldb     #4
        jsr     set_cursor
        leax    cs_title,pcr
        jsr     print_string
        lda     #4
        ldb     #6
        jsr     set_cursor
        leax    cs_prompt,pcr
        jsr     print_string
        lda     #4
        ldb     #8
        jsr     set_cursor
        rts

cs_title    fcc     "CONNECT TO RACHEL"
            fcb     0
cs_prompt   fcc     "SERVER IP: "
            fcb     0

get_server_address
        jsr     show_connect_screen
        ldx     #input_buffer
        ldb     #15
        jsr     input_line
        tsta
        beq     gsa_cancel
        ldx     #input_buffer
        jsr     parse_ip
        bcs     gsa_cancel
        andcc   #$FE
        rts
gsa_cancel
        orcc    #$01
        rts

parse_ip
        ldy     #0
        clrb
pi_byte
        clra
        sta     pi_accum
pi_digit
        lda     ,x+
        beq     pi_end_byte
        cmpa    #'.'
        beq     pi_next
        cmpa    #'0'
        blt     pi_error
        cmpa    #':'
        bge     pi_end_byte
        suba    #'0'
        pshs    a
        lda     pi_accum
        lsla
        lsla
        adda    pi_accum
        lsla
        adda    ,s+
        sta     pi_accum
        bra     pi_digit
pi_next
        lda     pi_accum
        sta     server_ip,y
        leay    1,y
        cmpy    #4
        blt     pi_byte
pi_error
        orcc    #$01
        rts
pi_end_byte
        lda     pi_accum
        sta     server_ip,y
        andcc   #$FE
        rts

pi_accum    fcb     0
input_buffer    rmb     16

show_connecting
        lda     #8
        ldb     #10
        jsr     set_cursor
        leax    sc_msg,pcr
        jsr     print_string
        rts
sc_msg  fcc     "CONNECTING..."
        fcb     0

show_connect_error
        lda     #4
        ldb     #10
        jsr     set_cursor
        leax    sce_msg,pcr
        jsr     print_string
        jsr     wait_key
        rts
sce_msg fcc     "CONNECTION FAILED!"
        fcb     0
