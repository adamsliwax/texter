TXD	EQU 	0014H
RXD	EQU	001FH
                  ORG 8000H
;----------- HEADER ---------------
                  LD HL,LOGO1
                  CALL PRINT 
                  LD HL,LOGO2
                  CALL PRINT
                  LD HL,LOGO3
                  CALL PRINT           
                  CALL CRLF
;---------  MAIN  ------------------ 
MAIN:             LD HL,HELP1
                  CALL PRINT
                  LD HL,HELP2
                  CALL PRINT
                  LD HL,HELP3
                  CALL PRINT
LOOP:             NOP                  
                  CALL PROMPT       
                  CALL RXD         
                  CALL BIGCHARS
                  PUSH AF
                  CALL TXD
                  CALL CRLF
                  POP AF
                  CP 'I'
                  JR Z,INPUTADR
                  CP 'S'
                  JR Z,OUTPUTADR
                  CP 'T'
                  JR Z,INPUTTX
                  CP 'D'
                  JR Z,OUTPUTTX
                  CP 'H'
                  JR Z,MAIN
                  CP 'Q'
                  JR NZ,LOOP
                  RET                  
;----------- END MAIN --------------
INPUTADR:         LD HL,INPUT_ADR
                  CALL PRINT
                  LD A,00H
                  LD HL,ADDRESS
                  LD B,5
INPUTADR2:        LD (ADDRESS),A
                  INC HL
                  DJNZ INPUTADR2
                  LD HL,ADDRESS
                  LD B,4
INPUTADR1:        PUSH BC
                  PUSH HL
                  CALL RXD
                  POP HL
                  POP BC
                  CP ESC
                  JR Z,INPUTADREND
                  CALL BIGCHARS
                  CALL CHECHEX
                  LD (HL),A
                  INC HL
                  CALL TXD
                  DJNZ INPUTADR1                  
INPUTADREND:      CALL CRLF
                  JP LOOP
;-----------------------------------      ; Check leter of set 0-9 and A-F
CHECHEX:          ;PUSH AF
                  PUSH HL
                  PUSH BC
                  LD HL,TABLEX
                  LD B,16
DONHEX:           CP (HL)
                  JP Z,OKHEX
                  INC HL
                  DJNZ DONHEX
NOTHEX:           POP BC
                  POP HL
                  ;POP AF
                  JP INPUTADR1
OKHEX:            POP BC
                  POP HL
                  ;POP AF
                  RET
;---------------------------------
OUTPUTADR:        LD HL,OUTPUT_ADR
                  CALL PRINT
                  LD HL,ADDRESS
                  CALL PRINT
                  CALL CRLF
                  JP LOOP
;-----------------------------------
OUTPUTTX:         LD HL,OUTPUT_TX
                  CALL PRINT
                  LD HL,BUFFOR
                  CALL PRINT
                  CALL CRLF
                  JP LOOP           
;-----------------------------------
INPUTTX:          LD HL,INPUT_TX
                  CALL PRINT
                  LD HL,BUFFOR
INPUTTX_LOOP:     PUSH HL
                  CALL RXD
                  CP 0DH
                  POP HL
                  CALL TXD
                  JP Z,INPUTTX_END
                  LD (HL),A
                  INC HL
                  JR INPUTTX_LOOP
INPUTTX_END:      INC HL
                  LD A,00H
                  LD (HL),A
                  CALL CRLF
                  JP LOOP              
;-----------------------------------
PRINT_NUMBER:                             ; Print nuber of reg.A
;100
                  LD B,100
                  CALL DIVIDE
                  CALL PRINT_DIGIT
;10
                  LD B,10
                  CALL DIVIDE
                  CALL PRINT_DIGIT
;1
                  ADD A,1
                  LD E,A
                  CALL PRINT_DIGIT
                  RET
;-------------------------------            
DIVIDE:           LD C,0            ;Divide byte in  reg.A by reg.B
DIVIDE_LOOP:      SBC B
                  JR C,DIVIDE_DONE
                  INC C
                  JR DIVIDE_LOOP
DIVIDE_DONE:      ADD A,B
                  LD E,C
                  RET
;--------------------------------            
PRINT_DIGIT:      PUSH AF           ;Print digit in reg.A
                  LD A,E
                  ADD A,'0'
                  LD E,A
                  CALL TXD
                  POP AF
                  RET
;-------------------------------    ;Conwer integer to hex
HEX2:             LD A,B
                  CALL HEX1
                  LD A,C
HEX1:             PUSH AF           ;Conver byte to hex           
                  RRCA
                  RRCA
                  RRCA
                  RRCA
                  CALL TETRAD
                  POP AF
TETRAD:           AND 0FH
                  ADD A,30H
                  CP 3AH
                  JR C,DIGIT
                  ADD A,07H
DIGIT:            CALL TXD
                  RET
;-------------------------------    ; Convert hex tu word from memory
                                    ; pointed in reg.HL to reg.BC
HEX2WORD:         NOP
                  CALL HEX2BYTE
                  LD B,A
                  INC HL
                  CALL HEX2BYTE 
                  LD C,B
                  RET
;-------------------------------    ; Convert hex tu byte from memory
                                    ; pointed in reg.HL
HEX2BYTE:         NOP
                  LD A,(HL)
                  CALL HEX2NUM
                  RLC A
                  RLC A
                  RLC A
                  RLC A
                  LD B,A
                  INC HL
                  LD A,(HL)
                  CALL HEX2NUM
                  OR B
                  RET
;-------------------------------    ; Convert hex digit to value
HEX2NUM:          NOP
                  CP '9'+1
                  JR C,H2N
                  SUB 7
H2N:              SUB '0'
                  AND 0FH
                  RET      
;-------------------------------
CRLF:             NOP               ; Print end of line
                  LD A,CR
                  CALL TXD
                  LD A,LF
                  CALL TXD
                  RET
;-------------------------------    ;Print prompt            
PROMPT:           LD A,'0'
                  CALL TXD
                  LD A,'>'
                  CALL TXD
                  RET
;-------------------------------    ;Change small leter to big
BIGCHARS:         NOP
                  CP 'a'
                  JR C,OUT1
                  CP 'z'
                  JR NC,OUT1
                  SUB 32
OUT1:             NOP
                  RET           
;-------------------------------
            
PRINT:            NOP                     ; Print text from reg.HL
                  PUSH AF
                  PUSH HL
PRINTLOOP:        NOP
                  LD A,(HL)
                  CP 00H
                  JR Z,PRINTEND
                  CALL TXD
                  INC HL
                  JR PRINTLOOP
PRINTEND:         NOP
                  POP HL
                  POP AF
                  RET
;-------------------------------
; tablice i zmienne
CR          EQU 0DH
LF          EQU 0AH
EOL         EQU 00H
BS          EQU 10H
ESC         EQU 1BH
LOGO1:      DB '>> Z-80 PLUMKO <<',CR,LF,EOL
LOGO2:      DB '=================',CR,LF,EOL
LOGO3:      DB 'PLUM CO. (C) 2024',CR,LF,EOL
HELP1:      DB 'SELECT OPTION:',CR,LF,EOL
HELP2:      DB '  [I] Inp adr.    [S] Show adr.    [H] Help',CR,LF,EOL
HELP3:      DB '  [T] Inp text    [D] Disp tekst   [Q] Exit',CR,LF,EOL
INPUT_ADR:  DB ' - INPUT ADDRESS :',EOL
OUTPUT_ADR: DB ' - ADDRESS : ',EOL
INPUT_TX:   DB ' - INPUT TEXT :',EOL
OUTPUT_TX:  DB ' - TEXT : ',EOL
TABLEX:     DB '0','1','2','3','4','5','6','7','8','9'
            DB 'A','B','C','D','E','F'
BUFFOR      DEFS 80
ADDRESS     DEFS 5
            END

