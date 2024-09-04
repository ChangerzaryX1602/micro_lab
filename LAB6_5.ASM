    CPU "Z80.TBL"
    HOF "INT8"

PORT_DAC: EQU 20H ; Port A 8255 = DAC
PORT_MTR: EQU 21H ; Port B 8255 = DC Motor
PORT_ADC: EQU 22H ; Port C 8255 = ADC
PORT_PCC: EQU 23H ; PC Control
CS_ADC: EQU 3 ; CS ADC = PX.1
SK_ADC: EQU 2 ; Clock Synchronous
DI_ADC: EQU 0 ; Data Input
DO_ADC: EQU 4 ; Data Output
SPEED: EQU 0FFH

    ORG 9000H
LCD_BUFF: DFS 1 ; LCD Signal Buffer
ADC_BUFF: DFS 1 ; ADC Signal Buffer
ADC_CODE: DFS 1 ; ADC Ch Code


    ORG 8000H
MAIN:
    LD A, 88H
    OUT (PORT_PCC), A
    LD L, 11111101B ; Direction
LOOP:
    LD A, L ; Direction Motor
    OUT (PORT_MTR), A
    CALL READ_ADC
    LD A, (ADC_CODE); On Motor
    
    LD A, 06H
    OUT (00H), A
    LD A, (ADC_CODE)
    OUT (01H), A

    OUT (PORT_DAC), A
    JR LOOP

DELAY:
    LD DE, 01FFFH
DELAY1:
    DEC DE
    LD A, D
    OR E
    JR NZ, DELAY1
    RET

    


    ;/**********************/;
    ;/* Read Data From ADC */;
    ;/* ADC0832 (8Bit A/D) */;
    ;/* Input : ACC */;
    ;/* Output : ACC */;
    ;/**********************/;
    ; START,SGL,ODD = ADC
    ; 1 1 0 = Ch0
    ; 1 1 1 = Ch1
    ; A = 110X XXXX = Ch0(DF)
    ; A = 111X XXXX = Ch1(FF)
    ;

READ_ADC: 
    LD A, 0DFH ; Read ADC Ch0
    LD (ADC_CODE),A ; Save Channel Control
    PUSH BC
    ;
    LD A,(ADC_BUFF) ; Get ADC Signal
    SET SK_ADC,A ; Makesure Start Clock
    OUT (PORT_ADC),A
    SET DI_ADC,A ; Start Bit
    OUT (PORT_ADC),A
    SET CS_ADC,A ; Makesure CS=High
    OUT (PORT_ADC),A
    RES CS_ADC,A ; Start Operation
    OUT (PORT_ADC),A
    LD (ADC_BUFF),A ; Save ADC Signal
    ;
    LD B,4 ; Counter (START/SGL/ODD/NULL)
READ_AD1: LD A,(ADC_CODE) ; Get ADC Code Control
    RL A ; Rotate Din to Carry
    LD (ADC_CODE),A ; Save ADC Code Control
    ;
    LD A,(ADC_BUFF) ; Get ADC Signal
    RES SK_ADC,A ; Clock Low
    OUT (PORT_ADC),A
    ;
    JR C,READ_AD2
    RES DI_ADC,A
    JR READ_AD3
    ;
READ_AD2: SET DI_ADC,A
READ_AD3: OUT (PORT_ADC),A
    ;
    OUT (PORT_ADC),A
    SET SK_ADC,A ; Clock High (ADC Receive Data)
    OUT (PORT_ADC),A
    LD (ADC_BUFF),A ; Save ADC SIgnal
    DJNZ READ_AD1 ; Loop Send Data Word 4 Bit
    ;
    LD A,(ADC_BUFF) ; Get ADC SIgnal
    RES SK_ADC,A ; Clock Low
    OUT (PORT_ADC),A
    LD (ADC_BUFF),A ; Save ADC Signal
    ;
    LD A,0
    LD (ADC_CODE),A ; Clear Result
    LD B,8 ; Counter MSB 8-Bit Data
READ_AD4: IN A,(PORT_ADC) ; Read ADC DOut
    RL A ; Shift DOUT to CY
    RL A
    RL A
    RL A
    ;
    LD A,(ADC_CODE)
    RL A ; Rotate Carry to Data
    LD (ADC_CODE),A
    ;
    LD A,(ADC_BUFF) ; Get ADC Signal
    SET SK_ADC,A ; Clock High
    OUT (PORT_ADC),A
    RES SK_ADC,A ; Clock Low
    OUT (PORT_ADC),A
    LD (LCD_BUFF),A ; Save ADC Signal
    DJNZ READ_AD4 ; Next bit
    ;
    LD A,(ADC_BUFF) ; Get ADC Signal
    SET CS_ADC,A ; Stop Operation
    OUT (PORT_ADC),A
    LD (ADC_BUFF),A ; Save ADC Signal
    ;
    POP BC ; Restore Register
    LD A,(ADC_CODE) ; ACC = Result
    RET

