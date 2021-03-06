;
;
;  Snake.asm
;  Snake
;
;  Created by Asaf Fisher on  6/5/2015.
;  Copyright © 2015 Asaf Fisher. All rights reserved.
;
;
;
;
;========MACROS======= 
random macro range
    mov ah,00h
    int 1Ah
    mov ax,dx
    xor dx,dx
    mov bx, range
    div bx
    inc dx   
endm
;========================================================================








org 100h
MainMenu:
call ClearAllRegAndVars
call DrawMainMenu
call FunctionalMainMenu
pop ax
cmp ax,1
je StartTheGame
cmp ax,2
je MoreOptions
cmp ax,3
je Exit 

jmp MainMenu

Exit:
MOV AX, 4C00h
int 21h


MoreOptions:




StartTheGame:
call ClearAllRegAndVars
call SetUpSnake
Step:
call Sleep
;call CheckDirectionChange 
call SnakeMove
pop ax
cmp ax,1
je MainMenu
call CheckDirectionChange



;call CheckWin
jmp Step

hlt
;=================================================================================================
proc FunctionalMainMenu
    
    Options:
     mov ah,1h ;Check if any key was pressed in the keyboard!
    int 16h
    jnz UpOrDown;key was pressed!
    jmp Options ;key wasent pressed!
    
    UpOrDown:
    mov ah,0h;Get the key that was pressed!
    int 16h
    
    cmp ah,48h ;up key
    je UpKey
    cmp ah,50h ;down key
    je DownKey
    cmp al,13
    je OptionClicked
    jmp Options
    
    UpKey:
    cmp OptionsPosition,1
    je Buttom
    mov dh,OptionsPosition
    mov dl,0
    push dx
    call ChangeManuPosition
    
    dec OptionsPosition
    
    mov dh,OptionsPosition
    mov dl,1
    push dx
    call ChangeManuPosition
    jmp Options
    
    ;upper then 1?
    Buttom:
    
    mov dh,OptionsPosition  ;unmark befor
    mov dl,0
    push dx
    call ChangeManuPosition
    
    mov OptionsPosition,3
     
    mov dh,OptionsPosition    ;mark after
    mov dl,1
    push dx
    call ChangeManuPosition
    
    
    
    
    jmp Options
    
    DownKey:
    
    cmp OptionsPosition,3
    je Top
    mov dh,OptionsPosition
    mov dl,0
    push dx
    call ChangeManuPosition
    
    inc OptionsPosition
    
    mov dh,OptionsPosition
    mov dl,1 
    push dx
    call ChangeManuPosition
    jmp Options
    
    ;lower then 3?
    Top:
    
    mov dh,OptionsPosition  ;unmark befor
    mov dl,0
    push dx
    call ChangeManuPosition
    
    mov OptionsPosition,1
     
    mov dh,OptionsPosition    ;mark after
    mov dl,1
    push dx
    call ChangeManuPosition
    

    jmp Options
    
    
    OptionClicked: 
    xor ax,ax
    pop [150]
    mov al, OptionsPosition
    push ax
    push [150] 

    ret
endp FunctionalMainMenu    

;chnage the selected menu item...
;get param in stack High- Option kind. Low- 0=true 1=false
proc ChangeManuPosition
    pop [150]
    pop dx
    cmp dh,1
    je SC
    cmp dh,2
    je MOC
    cmp dh,3
    
    ;Exit Unmark/mark
    EC:
    cmp dl,1
    je ECmark
    ECunmark:;unmark
    mov dx,ELLocation 
    mov bp,offset ExitLabelFalse 
    
    jmp doneMarking
    
    
    ECmark:;mark
    mov dx,ELLocation 
    mov bp,offset ExitLabelTrue
    
    jmp doneMarking
    
    ;Start unmark/mark
    SC:
    cmp dl,1
    je SCmark
    SCunmark:;unmark
    mov dx,SLLocation 
    mov bp,offset StartLabelFalse
    jmp doneMarking
    
    
    SCmark:;mark
    
    mov dx,SLLocation 
    mov bp,offset StartLabelTrue
    
    jmp doneMarking
    
    ;More Options mark/unmark
    MOC:
    cmp dl,1
    je MOCmark
    MOCunmark:;unmark
    mov dx,OLLocation 
    mov bp,offset OptionsLabelFalse
    jmp doneMarking
    
    
    MOCmark:;mark
    mov dx,OLLocation 
    mov bp,offset OptionsLabelTrue
    
    doneMarking:
    
    mov bh,0
    mov ah,13h
    mov al,0 
    mov bl,10
    mov cx,16d
    int 10h
    push [150]
    ret    
endp ChangeManuPosition
proc DrawMainMenu
    call ClearScreen
    TitleMsg:
    mov bh,0
    mov ah,13h
    mov al,0
    mov dh,1
    mov dl,13 
    mov bl,10
    mov cx,52d
    mov bp,offset T1 
    int 10h 
    inc dh
    mov bp,offset T2 
    int 10h
    inc dh
    mov bp,offset T3 
    int 10h
    inc dh
    mov bp,offset T4 
    int 10h 
    inc dh
    mov bp,offset T5 
    int 10h
    inc dh
    mov bp,offset T6 
    int 10h
    inc dh
    mov bp,offset T7 
    int 10h
    inc dh
    mov bp,offset T8 
    int 10h
    inc dh
    mov bp,offset T9 
    int 10h
    inc dh
    mov bp,offset T10 
    int 10h
    inc dh
    mov bp,offset T11 
    int 10h
            
            
    mov cx,10
    waitsec2: 
    call Sleep
    loop waitsec2
     
    mov bh,0
    mov ah,13h
    mov al,0
    mov dl,32d
    add dh,3d
    mov bl,10
    mov cx,16d
    mov bp,offset StartLabelTrue
    int 10h
    mov SLLocation,dx
    
    add dh,3
    mov bp,offset OptionsLabelFalse
    int 10h
    mov OLLocation,dx
    add dh,3
    mov bp,offset ExitLabelFalse
    int 10h
    mov ELLocation,dx 
    
    
    
    
          
    
    ;call SetPoint
    
    
    ret
endp DrawMainMenu





















proc SetUpSnake
    
    call ClearScreen
    
    mov dl,0 ;set cursor to 0,0
    mov dh,0
    
    BuildField:
    
    ;Drow the top border
    T_draw:
    mov bh, 0
    mov ah, 0x2
    int 0x10 ;set mod 
    
    ; dh = y
;     dl = x 
    mov dl,0
    mov dh,0  
    
    mov cx, 80 ; print chars
    mov bh, 0
    mov bl, 20d ; green bg/blue fg
    mov al, ' ';'*';0x20 ; blank char
    mov ah, 0x9
    int 0x10
     
    L_draw: ;draw the left border   
    inc dh
    mov cl,' '
    mov ch,20d
    push dx
    push cx
    push dx
    call SetPoint
    pop dx
    cmp dh,25d               
     
    jne L_draw 
          
    
    mov dl,79
    mov dh,0
     
    R_draw: ;draw the right border
    inc dh
    mov cl,' '
    mov ch,20d
    push dx
    push cx
    push dx
    call SetPoint
    pop dx
    cmp dh,25d
    jne R_draw
    
     
    
    B_draw: ;draw the buttom border
    mov bh, 0
    mov ah, 0x2
    int 0x10
    
    mov dl,0
    mov dh,24
    
    mov ah, 0x2
    int 0x10
    
    mov cx, 80 ; print chars
    mov bh, 0
    mov bl, 20d ; green bg/blue fg
    mov al, ' ';'*';0x20 ; blank char
    mov ah, 0x9
    int 0x10
    
    
    
    
    
    ;place the snake...
       
       
    mov cl,Snake_Shape
    mov ch,Snake_Color
    push cx
       
    mov dh,Head_Y
    mov dl,Head_X  
    push dx
    
    call SetPoint
    
    ;place the snake food...
    call GenerateNewFood
     
    ret
endp SetUpSnake

proc ClearScreen
ClearField:
    mov dl,0 ;set cursor to 0,0
    mov dh,0  
    clear: ;clear the console...
    mov bh, 0
    mov ah, 0x2
    int 0x10
    mov cx, 80 ; print chars
    mov bh, 0
    mov bl, 00d ; green bg/blue fg
    mov al, 0;'*';0x20 ; blank char
    mov ah, 0x9
    int 0x10
    inc dh
    cmp dh,25d
    jne clear
    ret
    
endp ClearScreen





;===========================TESTS============================                      
;proc SetPoint;Use stack to cx ch=Colors cl= Letters Ascii  
;    pop [160]
;    pop bx ; Place
;    mov al,80d
;    mul bl
;    add al,bh
;    mov bx,ax 
;    
;    mov ch,0ah
;    mov cl,'*'
;    mov ax,0B800h     ;   Letter Color
;    mov es,ax         ;  B|ack ground
;                      ;  ||
;    mov es:bx,cx;        ||
;    push [160]  ;        0c31h
;    ret               ;    || 
;endp SetPoint         ;    Letter   

;proc SetPoint
;    pop [150]
;    pop dx;place
;    ; dh = y
;    ; dl = x  Set cursor to top left-most corner of screen
;    mov bh, 0
;    mov ah, 0x2
;    int 0x10 
;    
;    mov cx, 1 ; print chars
;    mov bh, 0
;    mov bl, Snake_Color ; green bg/blue fg
;    mov al, Snake_Shape;'*';0x20 ; blank char
;    mov ah, 0x9
;    int 0x10
;    push [150]
;    ret
;endp SetPoint
;===========================TESTS==============================




proc SetPoint
    ; Get params to stack, first parameter that you need to push
    ; is the shape and the second one is the location...
    
    pop [150]
    pop dx;place dh = y; dl = x
    
    pop cx ;cl Shape, ch Color
    ;change the dh and dl to one number algorithem...
    mov al,dh;mov al y value
    mov bl,80d
    mul bl
    add ax,ax
    add dl,dl
    mov dh,0
    add ax,dx
    mov bx,ax        
     
    push ds ;move data seg to 0b800h
    
    ;mov cl,Snake_Shape;shape 
    ;mov ch,Snake_Color ;color
    mov ax, 0b800h
    mov ds,ax
    ;mov bx,1
    mov [bx],cx 
    pop ds
    push [150]
    ret
endp SetPoint
proc Sleep
    pusha
    MOV CX, 02H;0fh
    MOV DX, 4240H
    MOV AH, 86H
    INT 15H
    popa
    ret
endp Sleep

proc GetPoint;Return the char in certain place get value from stack and return to stack high-Color Low-Shape
    pop [150]
    pop dx;place dh = y; dl = x
    push [150]
    
    mov al,dh;mov al y value
    mov bl,80d
    mul bl
    add ax,ax
    add dl,dl
    mov dh,0
    add ax,dx
    mov bx,ax
    
    
    push ds
    mov ax, 0b800h
    mov ds,ax
    ;mov bx,1
    mov cx,[bx] 
    pop ds
    pop [150]
    push cx
    push [150] 
    
    
    
    ret
endp GetPoint


;WORNING- May be a problem with Turns array problem and his word size [si+2]
proc CheckDirectionChange 
    ;check if keyboard clicked
    
    mov ah,1h ;Check if any key was pressed in the keyboard!
    int 16h
    jnz getKey;key was pressed!
    jmp Knone;key wasent pressed!
    
    getKey:
    mov ah,0h;Get the key that was pressed!
    int 16h
    
    ;compiration with al and the key that you need
    cmp al,'w'
    je Kup  
    cmp al,'a'
    je Kleft
    cmp al,'d'
    je Kright
    cmp al,'s'
    je Kdown
    cmp al,20h
    jne Knone
    pop dx
    jmp MainMenu
    
    Kup:
    cmp HeadDirection,1
    je Knone
    mov HeadDirection,1
    
    jmp performDataTurn
    
    Kright:
    cmp HeadDirection,2
    je Knone
    mov HeadDirection,2

    
    jmp performDataTurn
          
    Kdown:
    cmp HeadDirection,3
    je Knone
    mov HeadDirection,3
    
  
    jmp performDataTurn
    
    Kleft:
    cmp HeadDirection,4
    je Knone
    mov HeadDirection,4
    
    
    performDataTurn:
     
     ;========Turns Alg=========
    mov si,[Turns_Length]
    mov al,HeadDirection
    mov Turns[si],al
    add si,si
    mov al,Head_X
    mov ah,Head_Y
    mov Locations[si],ax
    inc Turns_Length
    ;===========================
    Knone: 
    ret
    
endp CheckDirectionChange 
   
 ;working Snake eatten might be an error with labels location....  
proc SnakeMove
    ;============ 
    
    ;mov al,Snake_Shape
;    mov Blank, al
;    mov Snake_Shape,' '
;     
;    mov bl,00
;    
    cmp IsSnakeEatten,1;check is snake eatten
    je skip
           
    cmp Turns_Length,0
    je RemoveTail
    mov si,0;Current Turn...
    mov ax,Locations[si]
    cmp Tail_X,al
    jne RemoveTail
    cmp Tail_Y,ah
    jne RemoveTail
    
     
    ChangeTailDirection:
    ;up 
    mov al,Turns[si]
    mov TailDirection,al
    
    RemoveTurnFromArray:
    mov si,0
    cmp Turns_Length,1
    ja conti 
    
    mov Turns[si],00h
    mov Locations[si],0000h
    dec Turns_Length
    jmp RemoveTail
    
    conti:
    
    mov cx,Turns_Length
    dec cx 
    SortLocationsArray:
    mov ax,Locations[si+2]
    mov Locations[si],ax
    add si,2
    loop SortLocationsArray
    
    mov si,0
    mov cx,Turns_Length
    dec cx 
    SortTurnsArray:
    mov al,Turns[si+1]
    mov Turns[si],al
    inc si
    loop SortTurnsArray
    
    dec Turns_Length 
    
    
    
     
    
    
    
    RemoveTail:
    
    mov cl,0
    mov ch,0
    push cx
    
    mov dh,Tail_Y
    mov dl,Tail_X 
    push dx
    call SetPoint
    
    mov IsSnakeEatten,0
    
    cmp TailDirection,1
    je MoveTailUp
    cmp TailDirection,2
    je MoveTailRight
    cmp TailDirection,3
    je MoveTailDown
    cmp TailDirection,4
    je MoveTailLeft
    
    
    MoveTailUp:
    dec Tail_Y
    jmp skip 
    MoveTailRight:
    inc Tail_X
    jmp skip
    MoveTailDown:
    inc Tail_Y
    jmp skip
    MoveTailLeft:
    dec Tail_X
    
    skip:
    cmp IsSnakeEatten,1
    je IncSnake
    jmp next
    
    
    IncSnake:
    mov IsSnakeEatten,0
    inc Snake_Size
    
    next:
    
    
    
    
    
    
   
    
;    
;    push bx  
;    push dx
;    call SetPoint
;    
;    mov al,Blank
;    mov Snake_Shape,al 
    
    ;============
    
    cmp HeadDirection,1
    je up
    
    cmp HeadDirection,2
    je right
    
    cmp HeadDirection,3
    je down
    
    cmp HeadDirection,4
    je left 
    
    
    
    up:;UP
    dec Head_Y
    jmp move 
    right:;RIGHT
    inc Head_X
    jmp move
    down:;DOWN
    inc Head_Y
    jmp move
    left:;LEFT
    dec Head_X
    
    
    move:
    
    ;Check if snake eaten...
    call IsSnakeEaten
    
    ;Check if game lost...
    call CheckLose
    pop ax
    cmp ax,1
    je GameLost
    mov cl,Snake_Shape
    mov ch,Snake_Color
    push cx
    
    mov dh,Head_Y
    mov dl,Head_X 
    push dx
    call SetPoint
    jmp PointDone
    GameLost:
    call GameOver
    pop [150]
    push 1
    push [150] 
    ret
    
    PointDone:
    pop [150]
    push 0
    push [150]
    ret
endp SnakeMove


proc IsSnakeEaten
    xor ax,ax
    
    mov dh,Head_Y
    mov dl,Head_X
              
    push dx
    call GetPoint
    pop cx
    cmp cl,S_Berry
    je berry
    cmp cl,S_Apple
    je apple
    cmp cl,S_Waffels
    je waffels
    jmp none
    
    berry:
    mov al,P_Berry
    add Points,ax
    jmp eated
    apple:
    mov al,P_Apple
    add Points,ax
    jmp eated        
            
    waffels:
    mov al,P_Waffels
    add Points,ax
    
    
    eated:
    mov IsSnakeEatten,1
    
    call GenerateNewFood
    
    
    none:
    
    
    ret
endp IsSnakeEaten

proc GenerateNewFood
    getY: 
    random Field_Y
    mov T_F_Y,dl
    cmp T_F_Y,0
    je getY
    cmp T_F_Y,24d
    jae getY
    getX:
    random Field_X
    mov T_F_X,dl
    cmp T_F_X,80d
    je getX
    
    random 3d
    cmp dl,1
    je PlaceBerry
    cmp dl,2
    je PlaceApple
    cmp dl,3
    je PlaceWaffels
    
    PlaceBerry:
    mov ch,C_Berry;mov food color
    mov cl,S_Berry;mov food shape
    jmp place 
    
    PlaceApple:
    mov ch,C_Apple
    mov cl,S_Apple
    jmp place 
    
    PlaceWaffels:
    mov ch,C_Waffels
    mov cl,S_Waffels
    
    place:
    
    mov dh,T_F_Y
    mov dl,T_F_X
    
    
    push cx;shape,color
    push dx;x,y
    call SetPoint
    
    
    
    
    
    
    
    
    
    ret
endp


proc CheckLose
    
    mov dh,Head_Y
    mov dl,Head_X
              
    push dx
    call GetPoint
    pop cx
    cmp cl,20h
    je Lost
    cmp cl,2ah
    je Lost
    jmp Continue
    
    
    
    Lost:
    pop [150]
    push 1
    push [150]
    ret
    Continue:
    pop [150]
    push 0
    push [150]
    ret
endp CheckLose

proc GameOver
    mov bh,0
    mov ah,13h
    mov al,0
    mov dh,10
    mov dl,10 
    mov bl,10
    mov cx,50d
    mov bp,offset MSG_GameOver1 
    int 10h 
    inc dh
    mov bp,offset MSG_GameOver2 
    int 10h
    inc dh
    mov bp,offset MSG_GameOver3 
    int 10h
    inc dh
    mov bp,offset MSG_GameOver4 
    int 10h
            
            
    mov cx,5
    waitsec: 
    call Sleep
    loop waitsec
                        
    
    
    ret
endp GameOver 



;clear all the registries
proc ClearAllRegAndVars
    xor ax,ax
    xor bx,bx
    xor dx,dx
    xor cx,cx
    mov Head_X,1
    mov Head_Y,1
    mov Tail_X,1
    mov Tail_Y,1
    mov HeadDirection,2
    mov TailDirection,2
    mov Points,0d 
    mov Snake_Size,1
    mov cx,Turns_Length
    add cx,cx
    cmp cx,0
    je noneValues 
    resetArray:
    mov si,cx
    mov Turns[si],0         
    loop resetArray;
    mov Turns_Length,0                   
    noneValues:
    
    ret 
endp ClearAllReg
;====================



ret



  

;========VARS========
;Cords
Head_X db 1  

Head_Y db 1

Tail_X db 1

Tail_Y db 1


HeadDirection db 2
TailDirection db 2

 


;Blank db ''
Turns db 2000 dup(?)
Locations dw 2000 dup(?)
Turns_Length dw 0

Snake_Size db 1

IsSnakeEatten db 0
                
              
 
 
;Values 
Points dw 0d

;MainMenu

OptionsPosition db 1



;===============SETTINGS================

;SNAKE PROPERTIES:

Snake_Color db 11
Snake_Shape db '*'

;FOOD VALUE:

P_Berry db 10d;*
P_Apple db 20d;@
P_Waffels db 30d;#

;FOOD SHAPE:

S_Berry db 0ebh
S_Apple db '@'
S_Waffels db '#'
;FOOD COLOR:
C_Berry db 05h
C_Apple db 04h
C_Waffels db 06h



;Temp food location:
T_F_Y db ?
T_F_X db ?

;Size of the field..
Field_Chars dw 2000d
Field_X dw 80d
Field_Y dw 25d

 
 
;===============STRINGS=============== 

;GAME OVER MSG:

MSG_GameOver1 db "  ___   __   _  _  ____     __   _  _  ____  ____ " 
MSG_GameOver2 db " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \"
MSG_GameOver3 db "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /"
MSG_GameOver4 db " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)" 

;GO_Len equ $ - MSG_GameOver 

;WELCOME TITLE:


          

T1 db  "  _______ _             _____             _         "
T2 db  " |__   __| |           / ____|           | |        "
T3 db  "    | |  | |__   ___  | (___  _ __   __ _| | _____  "
T4 db  "    | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ "
T5 db  "    | |  | | | |  __/  ____) | | | | (_| |   <  __/ "
T6 db  "   _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| "
T7 db  "  / ____|                    | |                    "
T8 db  " | |  __  __ _ _ __ ___   ___| |                    "
T9 db  " | | |_ |/ _` | '_ ` _ \ / _ \ |                    "
T10 db " | |__| | (_| | | | | | |  __/_|                    "
T11 db "  \_____|\__,_|_| |_| |_|\___(_)                    "
T_Len equ $ - T1




;MainMenu Options:

StartLabelFalse db   " Start The Game "
StartLabelTrue db    ">Start The Game<"
;Var
SLLocation dw ?

OptionsLabelFalse db "  More Options  "
OptionsLabelTrue db  " >More Options< " 
;Var
OLLocation dw ?

ExitLabelFalse db    "     Exit       "
ExitLabelTrue db     "    >Exit<      "
;Var
ELLocation dw ?                                                                                   
