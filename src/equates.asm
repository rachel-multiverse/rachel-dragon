; =============================================================================
; DRAGON 32/TANDY COCO EQUATES
; Motorola 6809 Assembly
; =============================================================================

; VDG (Video Display Generator)
SCREEN_BASE     equ     $0400           ; 32x16 text screen
SCREEN_WIDTH    equ     32
SCREEN_HEIGHT   equ     16

; PIA (Peripheral Interface Adapter)
PIA0_DA         equ     $FF00           ; PIA 0 Data A (keyboard rows)
PIA0_CA         equ     $FF01           ; PIA 0 Control A
PIA0_DB         equ     $FF02           ; PIA 0 Data B (keyboard cols)
PIA0_CB         equ     $FF03           ; PIA 0 Control B

PIA1_DA         equ     $FF20           ; PIA 1 Data A
PIA1_CA         equ     $FF21           ; PIA 1 Control A
PIA1_DB         equ     $FF22           ; PIA 1 Data B
PIA1_CB         equ     $FF23           ; PIA 1 Control B

; DragonWiFi / Serial
ACIA_CTRL       equ     $FF04           ; ACIA Control
ACIA_STATUS     equ     $FF04           ; ACIA Status (same address)
ACIA_DATA       equ     $FF05           ; ACIA Data

; ACIA Status bits
ACIA_RDRF       equ     %00000001       ; Receive Data Register Full
ACIA_TDRE       equ     %00000010       ; Transmit Data Register Empty

; Key codes (Dragon keyboard matrix)
KEY_LEFT        equ     $08             ; Left arrow
KEY_RIGHT       equ     $09             ; Right arrow
KEY_UP          equ     $0C             ; Up arrow
KEY_DOWN        equ     $0A             ; Down arrow
KEY_RETURN      equ     $0D             ; Enter
KEY_SPACE       equ     $20             ; Space
KEY_BREAK       equ     $03             ; Break
KEY_D           equ     'D'
KEY_d           equ     'd'

; BASIC ROM entry points
POLCAT          equ     $A000           ; Poll keyboard
CHROUT          equ     $A002           ; Output character
CLS             equ     $A004           ; Clear screen

; RUBP Protocol Constants
MAGIC_0         equ     'R'
MAGIC_1         equ     'A'
MAGIC_2         equ     'C'
MAGIC_3         equ     'H'
PROTOCOL_VER    equ     1

; Header offsets
HDR_MAGIC       equ     0
HDR_VERSION     equ     4
HDR_TYPE        equ     5
HDR_FLAGS       equ     6
HDR_RESERVED    equ     7
HDR_SEQ         equ     8
HDR_PLAYER_ID   equ     10
HDR_GAME_ID     equ     12
HDR_CHECKSUM    equ     14
PAYLOAD_START   equ     16
PAYLOAD_SIZE    equ     48

; Message types
MSG_JOIN        equ     $01
MSG_LEAVE       equ     $02
MSG_READY       equ     $03
MSG_GAME_START  equ     $10
MSG_GAME_STATE  equ     $11
MSG_GAME_END    equ     $12
MSG_PLAY_CARDS  equ     $20
MSG_DRAW_CARD   equ     $21
MSG_NOMINATE    equ     $22
MSG_ACK         equ     $F0
MSG_NAK         equ     $F1

; Connection states
CONN_DISCONNECTED equ   0
CONN_HANDSHAKE    equ   1
CONN_WAITING      equ   2
CONN_PLAYING      equ   3

; Card constants
SUIT_HEARTS     equ     0
SUIT_DIAMONDS   equ     1
SUIT_CLUBS      equ     2
SUIT_SPADES     equ     3

RANK_ACE        equ     1
RANK_JACK       equ     11
RANK_QUEEN      equ     12
RANK_KING       equ     13

; Game state variables (RAM)
CURRENT_TURN    equ     $0100
DIRECTION       equ     $0101
DISCARD_TOP     equ     $0102
NOMINATED_SUIT  equ     $0103
PENDING_DRAWS   equ     $0104
PENDING_SKIPS   equ     $0105
MY_INDEX        equ     $0106
HAND_COUNT      equ     $0107
PLAYER_COUNTS   equ     $0108           ; 8 bytes
MY_HAND         equ     $0110           ; 16 bytes
CURSOR_POS      equ     $0120
SELECTED_LO     equ     $0121
SELECTED_HI     equ     $0122

; Key aliases for game controls
KEY_QUIT        equ     KEY_BREAK
KEY_SELECT      equ     KEY_SPACE
KEY_PLAY        equ     KEY_RETURN
KEY_DRAW        equ     KEY_D
