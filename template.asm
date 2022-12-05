; multi-segment executable file template. 

.MODEL SMALL
.STACK 100H
.DATA
    W DW 1,2,3,4,5
    
    VAL DW 1234
.CODE
MAIN PROC           
    MOV AX, @DATA
    MOV DS, AX
    
    CALL INDEC
    CALL NEXT_LINE
    CALL DEC_OUTPUT      
    
    JMP EXIT    
    
; while loop          
WHILE_:
    
    JMP WHILE_
    
END_WHILE:    

; FOR loop    
TOP:           
    
    LOOP TOP  

; EXIT CODE    
EXIT:
    MOV AH,4CH
    INT 21H
MAIN ENDP  
             
; procedure             
; SI base pointer
; BX num of element
REVERSE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
          
    MOV DI, SI
    MOV CX, BX
    DEC BX
    SHL BX, 1
    ADD DI, BX      
    SHR CX, 1
    
XCHG_LOOP:
    MOV AX, [SI]
    XCHG AX, [DI]
    MOV [SI], AX
    
    ADD SI, 2
    SUB DI, 2
    LOOP XCHG_LOOP
          
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX    
    RET
REVERSE ENDP    

NEXT_LINE PROC
    PUSH AX
    PUSH DX
    
    MOV AH, 2       ; output a char
    MOV DL, 0DH     
    INT 21H         ; print CR
    MOV DL, 0AH     
    INT 21H         ; print LF
    
    POP DX                    
    POP AX                    
    RET
NEXT_LINE ENDP    

DEC_OUTPUT PROC
    PUSH AX
    PUSH BX  
    PUSH CX
    PUSH DX
                     
    ; if AX < 0
    OR AX, AX
    JGE @END_IF1
    
    ; then
    PUSH AX         ; save number
    MOV DL, '-'     ; get '-'
    MOV AH, 2       ; print char function
    INT 21H         
    POP AX          ; get AX back
    NEG AX          ; AX = - AX
@END_IF1:
    
    ; get decimal digits                      
    XOR CX, CX      ; CX counts digits
    MOV BX, 10D     ; BX has divisor
                                 
DEC_OUTPUT_WHILE:
    XOR DX, DX      ; prepare high word of dividend
    DIV BX          ; AX = quotient, DX = remainder
    PUSH DX         ; save remainder on stack
    INC CX          ; count = count + 1
    
    ; until
    OR AX,  AX      ; quotient = 0?
    JNE DEC_OUTPUT_WHILE      
    
    ; convert digit to char and print
    MOV AH, 2       ; print char function
DEC_PRINT_LOOP:
    POP DX          ; digit in DL
    OR DL, 30H      ; convert to char
    INT 21H         ; print digit
    LOOP DEC_PRINT_LOOP
    
    ; end for
    
    POP DX  
    POP CX     
    POP BX
    POP AX       
    RET
DEC_OUTPUT ENDP

INDEC PROC            
    ; pushing register
    PUSH BX
    PUSH CX
    PUSH DX           
    
@BEGIN:
    MOV AH, 2
    MOV DL, '?'
    INT 21H
    
    XOR BX, BX      ; BX holds total = 0
    XOR CX, CX      ; CX holds sign, negative = false
           
    ; read a character       
    MOV AH,1
    INT 21H           
    
    ; case char of
    CMP AL, '-'     ; minus sign?
    JE @MINUS       ; yes set sign
    CMP AL, '+'     ; plus sign
    JE @PLUS        ; yes, get another char
    JMP @REPEAT2    ; start processing char
    
@MINUS:
    MOV CX, 1       ; set cx to true , negative = true
@PLUS:
    INT 21H
    
@REPEAT2:
    ; if char is between '0' and '9'
    CMP AL, '0'     ; char >= '0'
    JNGE @NOT_DIGIT ; illegal char
    CMP AL, '9'     ; char <= '9'
    JNLE @NOT_DIGIT ; illegal char
    
    ; convert char to digit
    AND AX, 000FH   ; convert to digit
    PUSH AX         ; save on stack 
    
    ; total = total * 10 + digit
    MOV AX, 10      ; get 10
    MUL BX          ; AX = total * 10
    POP BX          ; retrieve digit
    ADD BX, AX      ; total = total * 10 + digit
    
    ; read a char
    MOV AH, 1
    INT 21H
    CMP AL, 0DH     ; carriage return?
    JNE @REPEAT2    ; no, keep going
    
    ; until CR
    MOV AX, BX      ; store num in AX
    ; if negative
    OR CX, CX       ; negative num
    JE @EXIT        ; no, exit
    ; then
    NEG AX          ; yes negative
    ; end if
       
@EXIT:       
    ; popping register
    POP DX
    POP CX
    POP BX
    RET
    
@NOT_DIGIT:
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    JMP @BEGIN      ; go to beginning 
INDEC ENDP    


DEC_INPUT PROC
    ; pushing to stack  
    PUSH AX
           
    XOR DX, DX
    ; taking input
DEC_INPUT_WHILE_:
    ; take a char input
    MOV AH, 1
    INT 21H            
    
    ; if al is CR then break
    CMP AL, 0DH
    JE DEC_INPUT_END_WHILE
             
    ; keeping back of AH         
    MOV AH, 0     
    SUB AL, '0'  
    PUSH AX
    
    ; BX * 10 + input
    MOV AX, 10
    MUL DX
    POP DX
    ADD AX, DX
    MOV DX, AX
                 
    JMP DEC_INPUT_WHILE_             
DEC_INPUT_END_WHILE:
    
    ; popping from stack
    POP AX    
    RET
DEC_INPUT ENDP    


END MAIN        

