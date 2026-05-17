.MODEL SMALL
.STACK 100h

; ==========================================
; MACRO DEFINITIONS 
; ==========================================
PRINT_STRING MACRO str
    PUSH AX
    PUSH DX
    LEA DX, str
    MOV AH, 09h
    INT 21h
    POP DX
    POP AX
ENDM

.DATA
    ; Core Variables
    board DB 9 DUP(' ')  
    player DB 'X'
    gameMode DB 0        
    difficulty DB 0      
    turns DB 0           
    
    ; The 8 winning combinations
    win_lines DB 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6

    ; UI Messages
    msgBanner DB "=================================", 0Dh,0Ah
              DB "    COAL PROJECT: TIC-TAC-TOE    ", 0Dh,0Ah
              DB "=================================", 0Dh,0Ah, "$"
    
    msgMenu DB 0Dh,0Ah,"Choose Mode:", 0Dh,0Ah,"1. Multiplayer", 0Dh,0Ah,"2. vs Computer", 0Dh,0Ah,"Select (1-2): $"
    msgDiff DB 0Dh,0Ah,"Level:", 0Dh,0Ah,"1. Easy", 0Dh,0Ah,"2. Medium", 0Dh,0Ah,"3. Unbeatable", 0Dh,0Ah,"Select (1-3): $"
    msgTurn DB 0Dh,0Ah,"Player: $"
    msgInput DB " Enter pos (1-9): $" 
    msgWin DB 0Dh,0Ah,"*** WINNER: $"
    msgDraw DB 0Dh,0Ah,"*** IT'S A DRAW! ***$" 
    msgThink DB 0Dh,0Ah,"Computer is thinking...$"
    newline DB 0Dh,0Ah,"$"

.CODE
MAIN PROC
    MOV AX, @DATA        
    MOV DS, AX

    CALL CLEAR_SCREEN
    PRINT_STRING msgBanner

    ; --- MENU SYSTEM ---
    PRINT_STRING msgMenu
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV gameMode, AL

    CMP AL, 2
    JNE GAME_LOOP

    PRINT_STRING msgDiff
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV difficulty, AL

    CMP gameMode, 2
    JNE GAME_LOOP
    MOV player, 'O'

GAME_LOOP:
    CALL CLEAR_SCREEN
    PRINT_STRING msgBanner
    CALL DRAW_BOARD
    
    CMP gameMode, 2
    JNE HUMAN_INPUT
    CMP player, 'O'
    JE COMPUTER_MOVE

HUMAN_INPUT:
    PRINT_STRING msgTurn
    MOV DL, player
    MOV AH, 02h
    INT 21h
    
    PRINT_STRING msgInput
    MOV AH, 01h
    INT 21h
    SUB AL, '1'          
    
    CMP AL, 0
    JL GAME_LOOP         
    CMP AL, 8
    JA GAME_LOOP         
    
    MOV BL, AL
    XOR BH, BH
    LEA SI, board
    
    CMP [SI+BX], ' '     
    JNE GAME_LOOP
    
    MOV AL, player
    MOV [SI+BX], AL
    JMP AFTER_MOVE

AFTER_MOVE:
    INC turns            
    CALL CHECK_WIN
    CMP AL, 1
    JE WINNER_FOUND
    CMP turns, 9         
    JE DRAW_FOUND

    CMP player, 'X'
    JE SET_O
    MOV player, 'X'
    JMP GAME_LOOP
    
SET_O:
    MOV player, 'O'
    JMP GAME_LOOP

WINNER_FOUND:
    CALL CLEAR_SCREEN
    PRINT_STRING msgBanner
    CALL DRAW_BOARD
    PRINT_STRING msgWin
    MOV DL, player
    MOV AH, 02h
    INT 21h
    JMP END_GAME

DRAW_FOUND:
    CALL CLEAR_SCREEN
    PRINT_STRING msgBanner
    CALL DRAW_BOARD
    PRINT_STRING msgDraw

END_GAME:
    MOV AH, 4Ch          
    INT 21h
MAIN ENDP

; ==========================================
; UI & RENDERING MODULE (AHMED)
; ==========================================
CLEAR_SCREEN PROC
    MOV AX, 0600h
    MOV BH, 07h
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h
    MOV AH, 02h
    MOV BH, 00h
    MOV DX, 0000h
    INT 10h
    RET
CLEAR_SCREEN ENDP

DRAW_BOARD PROC
    XOR SI, SI
    MOV CX, 3
D_R1: PUSH CX
    MOV CX, 3
D_C1: 
    MOV DL, '['
    MOV AH, 02h
    INT 21h
    
    MOV AL, board[SI]
    CMP AL, 'X'
    JE COLOR_X
    CMP AL, 'O'
    JE COLOR_O
    MOV BL, 0Fh
    JMP PRINT_COLORED

COLOR_X:
    MOV BL, 0Ch
    JMP PRINT_COLORED

COLOR_O:
    MOV BL, 0Ah

PRINT_COLORED:
    MOV AH, 09h
    MOV BH, 00h
    PUSH CX
    MOV CX, 1
    INT 10h
    POP CX
    
    MOV DL, board[SI]
    MOV AH, 02h
    INT 21h
    MOV DL, ']'
    MOV AH, 02h
    INT 21h
    
    INC SI
    LOOP D_C1
    PRINT_STRING newline
    POP CX
    LOOP D_R1
    RET
DRAW_BOARD ENDP

THINKING_DELAY PROC
    PUSH CX              
    PUSH DX              
    MOV CX, 0001h        
DELAY_OUTER:
    MOV DX, 00FFh        
DELAY_INNER:
    DEC DX
    JNZ DELAY_INNER      
    LOOP DELAY_OUTER     
    POP DX               
    POP CX
    RET
THINKING_DELAY ENDP

; ==========================================
; WIN VALIDATION MODULE (UMAMA)
; ==========================================
CHECK_WIN PROC
    LEA SI, board
    MOV AL, [SI]
    CMP AL, [SI+1]
    JNE WR2
    CMP AL, [SI+2]
    JNE WR2
    CMP AL, ' '
    JE WR2
    JMP IS_WIN
WR2: 
    MOV AL, [SI+3]
    CMP AL, [SI+4]
    JNE WR3
    CMP AL, [SI+5]
    JNE WR3
    CMP AL, ' '
    JE WR3
    JMP IS_WIN
WR3: 
    MOV AL, [SI+6]
    CMP AL, [SI+7]
    JNE WC1
    CMP AL, [SI+8]
    JNE WC1
    CMP AL, ' '
    JE WC1
    JMP IS_WIN
WC1: 
    MOV AL, [SI]
    CMP AL, [SI+3]
    JNE WC2
    CMP AL, [SI+6]
    JNE WC2
    CMP AL, ' '
    JE WC2
    JMP IS_WIN
WC2: 
    MOV AL, [SI+1]
    CMP AL, [SI+4]
    JNE WC3
    CMP AL, [SI+7]
    JNE WC3
    CMP AL, ' '
    JE WC3
    JMP IS_WIN
WC3: 
    MOV AL, [SI+2]
    CMP AL, [SI+5]
    JNE WDIAG
    CMP AL, [SI+8]
    JNE WDIAG
    CMP AL, ' '
    JE WDIAG
    JMP IS_WIN
WDIAG: 
    MOV AL, [SI]
    CMP AL, [SI+4]
    JNE WD2
    CMP AL, [SI+8]
    JNE WD2
    CMP AL, ' '
    JE WD2
    JMP IS_WIN
WD2: 
    MOV AL, [SI+2]
    CMP AL, [SI+4]
    JNE IS_NO_WIN
    CMP AL, [SI+6]
    JNE IS_NO_WIN
    CMP AL, ' '
    JE IS_NO_WIN
    JMP IS_WIN
IS_NO_WIN: 
    MOV AL, 0
    RET
IS_WIN: 
    MOV AL, 1
    RET
CHECK_WIN ENDP

; ==========================================
; AI MASTER LOGIC CONTROLLER (HAMZA)
; ==========================================
COMPUTER_MOVE:
    PRINT_STRING msgThink
    CALL THINKING_DELAY  

    CMP difficulty, 3
    JE COMP_HARD
    CMP difficulty, 2
    JE COMP_MED
    JMP COMP_EASY

COMP_HARD:
    CALL AI_TRY_WIN
    CMP AL, 1
    JE AFTER_MOVE
    CALL AI_TRY_BLOCK
    CMP AL, 1
    JE AFTER_MOVE
    MOV BX, 4
    CMP board[BX], ' '
    JNE CH_TRAPS
    MOV board[BX], 'O'
    JMP AFTER_MOVE
CH_TRAPS:
    CALL AI_TRAP_DEFENSE
    CMP AL, 1
    JE AFTER_MOVE

COMP_MED:
    CALL AI_TAKE_CORNER
    CMP AL, 1
    JE AFTER_MOVE

COMP_EASY:
    CALL AI_TAKE_EDGE
    JMP AFTER_MOVE

; ==========================================
; AI BRAIN SUBROUTINES (HAMZA)
; ==========================================
AI_TRY_WIN PROC
    LEA SI, win_lines
    MOV CX, 8
CW_LOOP:
    PUSH CX
    PUSH SI
    XOR BX, BX
    MOV BL, [SI]
    MOV AL, board[BX]
    MOV BL, [SI+1]
    MOV AH, board[BX]
    MOV BL, [SI+2]
    MOV DH, board[BX]

    CMP AL, 'O'
    JNE CW_C2
    CMP AH, 'O'
    JNE CW_C2
    CMP DH, ' '
    JNE CW_C2
    MOV BL, [SI+2]
    JMP CW_EXEC
CW_C2:
    CMP AL, 'O'
    JNE CW_C3
    CMP AH, ' '
    JNE CW_C3
    CMP DH, 'O'
    JNE CW_C3
    MOV BL, [SI+1]
    JMP CW_EXEC
CW_C3:
    CMP AL, ' '
    JNE CW_NEXT
    CMP AH, 'O'
    JNE CW_NEXT
    CMP DH, 'O'
    JNE CW_NEXT
    MOV BL, [SI]
CW_EXEC:
    MOV board[BX], 'O'
    POP SI
    POP CX
    MOV AL, 1
    RET
CW_NEXT:
    POP SI
    ADD SI, 3
    POP CX
    DEC CX
    JNZ CW_LOOP
    MOV AL, 0
    RET
AI_TRY_WIN ENDP

AI_TRY_BLOCK PROC
    LEA SI, win_lines
    MOV CX, 8
CB_LOOP:
    PUSH CX
    PUSH SI
    XOR BX, BX
    MOV BL, [SI]
    MOV AL, board[BX]
    MOV BL, [SI+1]
    MOV AH, board[BX]
    MOV BL, [SI+2]
    MOV DH, board[BX]

    CMP AL, 'X'
    JNE CB_C2
    CMP AH, 'X'
    JNE CB_C2
    CMP DH, ' '
    JNE CB_C2
    MOV BL, [SI+2]
    JMP CB_EXEC
CB_C2:
    CMP AL, 'X'
    JNE CB_C3
    CMP AH, ' '
    JNE CB_C3
    CMP DH, 'X'
    JNE CB_C3
    MOV BL, [SI+1]
    JMP CB_EXEC
CB_C3:
    CMP AL, ' '
    JNE CB_NEXT
    CMP AH, 'X'
    JNE CB_NEXT
    CMP DH, 'X'
    JNE CB_NEXT
    MOV BL, [SI]
CB_EXEC:
    MOV board[BX], 'O'
    POP SI
    POP CX
    MOV AL, 1
    RET
CB_NEXT:
    POP SI
    ADD SI, 3
    POP CX
    DEC CX
    JNZ CB_LOOP
    MOV AL, 0
    RET
AI_TRY_BLOCK ENDP

AI_TRAP_DEFENSE PROC
    MOV AL, 0
    MOV BX, 0
    CMP board[BX], 'X'
    JNE ATD_2
    MOV BX, 8
    CMP board[BX], 'X'
    JNE ATD_2
    MOV BX, 1
    CMP board[BX], ' '
    JNE ATD_2
    MOV board[BX], 'O'
    MOV AL, 1
    RET
ATD_2:
    MOV BX, 2
    CMP board[BX], 'X'
    JNE ATD_3
    MOV BX, 6
    CMP board[BX], 'X'
    JNE ATD_3
    MOV BX, 1
    CMP board[BX], ' '
    JNE ATD_3
    MOV board[BX], 'O'
    MOV AL, 1
    RET
ATD_3:
    MOV BX, 0
    CMP board[BX], 'X'
    JNE ATD_4
    MOV BX, 7
    CMP board[BX], 'X'
    JNE ATD_4
    MOV BX, 6
    CMP board[BX], ' '
    JNE ATD_4
    MOV board[BX], 'O'
    MOV AL, 1
    RET
ATD_4:
    RET
AI_TRAP_DEFENSE ENDP

AI_TAKE_CORNER PROC
    MOV BX, 0
    CMP board[BX], ' '
    JE ATC_FOUND
    MOV BX, 2
    CMP board[BX], ' '
    JE ATC_FOUND
    MOV BX, 6
    CMP board[BX], ' '
    JE ATC_FOUND
    MOV BX, 8
    CMP board[BX], ' '
    JE ATC_FOUND
    MOV AL, 0
    RET
ATC_FOUND:
    MOV board[BX], 'O'
    MOV AL, 1
    RET
AI_TAKE_CORNER ENDP

AI_TAKE_EDGE PROC
    MOV BX, 1
    CMP board[BX], ' '
    JE ATE_FOUND
    MOV BX, 3
    CMP board[BX], ' '
    JE ATE_FOUND
    MOV BX, 5
    CMP board[BX], ' '
    JE ATE_FOUND
    MOV BX, 7
    CMP board[BX], ' '
    JE ATE_FOUND
    MOV BX, 0
ATE_LOOP:
    CMP board[BX], ' '
    JE ATE_FOUND
    INC BX
    CMP BX, 9
    JL ATE_LOOP
    MOV AL, 0
    RET
ATE_FOUND:
    MOV board[BX], 'O'
    MOV AL, 1
    RET
AI_TAKE_EDGE ENDP
