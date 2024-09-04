    CPU "Z80.TBL"
    HOF "INT8"

PORT_DAC: EQU 20H ; Port A 8255 = DAC
PORT_MTR: EQU 21H ; Port B 8255 = DC Motor
PORT_ADC: EQU 22H ; Port C 8255 = ADC
PORT_PCC: EQU 23H ; PC Control
; SPEED: EQU 0FFH
    ORG 8000H
MAIN:
    LD A, 88H
    OUT (PORT_PCC), A
    LD H, 11111101B ; Direction

START: 
    LD A, H ; Direction Motor
    OUT (PORT_MTR), A
    LD C, 0

LOOP1:
    LD A, C  ; On Motor
    OUT (PORT_DAC), A
    CALL DELAY
    INC C
    LD L, 0FFH
    LD A, L
    CP C
    LD A, 06H
    OUT (00H), A
    LD A, C
    OUT (01H), A
    JR Z, SLOWMOTOR
    JR LOOP1

SLOWMOTOR:
    LD C , 0FFH
LOOP2:
    LD A, C  ; On Motor
    OUT (PORT_DAC), A
    CALL DELAY
    DEC C
    LD L, 0
    LD A, L
    CP C
    LD A, 06H
    OUT (00H), A
    LD A, C
    OUT (01H), A
    JR Z, RETMOTOR
    JR LOOP2


RETMOTOR:
    LD A, H
    XOR 00000011B ; Flip direction
    LD C, A
    LD A, 06H
    OUT (00H), A
    LD A, C
    OUT (01H), A
    CALL DELAY
    LD A, C
    LD H, A
    JR START

DELAY:
    LD DE, 01FFFH
DELAY1:
    DEC DE
    LD A, D
    OR E
    JR NZ, DELAY1
    RET

    

STOP:
    LD A, 0
    OUT (PORT_DAC), A ; Off Motor
    END