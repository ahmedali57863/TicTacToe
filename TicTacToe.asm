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

; --- UMAMA'S STUB ---
CHECK_WIN PROC
    MOV AL, 0
    RET
CHECK_WIN ENDP

; --- HAMZA'S STUBS ---
COMPUTER_MOVE:
    JMP AFTER_MOVE
AI_TRY_WIN PROC
    RET
AI_TRY_WIN ENDP
AI_TRY_BLOCK PROC
    RET
AI_TRY_BLOCK ENDP
AI_TRAP_DEFENSE PROC
    RET
AI_TRAP_DEFENSE ENDP
AI_TAKE_CORNER PROC
    RET
AI_TAKE_CORNER ENDP
AI_TAKE_EDGE PROC
    RET
AI_TAKE_EDGE ENDP

END MAIN
