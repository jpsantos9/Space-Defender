
.model large
.data

exit db 0
ship_pos dw 1760d                        

missile_pos dw 0d                            
missile_status db 0d                          
missile_limit dw  30d     

nuk_pos dw 180d       
nuk_status db 0d
         
                                            
                                            
direction db 0d

state_buf db '00:0:0:0:0:0:00:00$'          
score dw 0d
health dw 5d

game_over_str dw '  ',0ah,0dh
dw '                  |---------------|',0ah,0dh
dw '                  | ^   Score   ^ |',0ah,0dh
dw '                  |_______________|',0ah,0dh
dw '   _                      _______                      _           ',0ah,0dh
dw '  _dMMMb._              .adOOOOOOOOOba.              _,dMMMb_      ',0ah,0dh
dw ' dP`  ~YMMb            dOOOOOOOOOOOOOOOb            aMMP~  `Yb     ',0ah,0dh
dw ' V      ~"Mb          dOOOOOOOOOOOOOOOOOb          dM"~      V     ',0ah,0dh
dw '          `Mb.       dOOOOOOOOOOOOOOOOOOOb       ,dM`              ',0ah,0dh
dw '           `YMb._   |OOOOOOOOOOOOOOOOOOOOO|   _,dMP`               ',0ah,0dh
dw '      __     `YMMM| OP`~"YOOOOOOOOOOOP"~`YO |MMMP`     __          ',0ah,0dh
dw '    ,dMMMb.     ~~` OO     `YOOOOOP`     OO `~~     ,dMMMb.        ',0ah,0dh
dw ' _,dP~  `YMba_      OOb      `OOO`      dOO      _aMMP`  ~Yb._     ',0ah,0dh
dw '             `YMMMM\`OOOo     OOO     oOOO`/MMMMP`                 ',0ah,0dh
dw '     ,aa.     `~YMMb `OOOb._,dOOOb._,dOOO`dMMP~`       ,aa.        ',0ah,0dh
dw '   ,dMYYMba._         `OOOOOOOOOOOOOOOOO`          _,adMYYMb.      ',0ah,0dh
dw '  ,MP`   `YMMba._      OOOOOOOOOOOOOOOOO       _,adMMP`   `YM.     ',0ah,0dh
dw '  MP`        ~YMMMba._ YOOOOPVVVVVYOOOOP  _,adMMMMP~       `YM     ',0ah,0dh
dw '  YMb           ~YMMMM\`OOOOI`````IOOOOO`/MMMMP~           dMP     ',0ah,0dh
dw '   `Mb.           `YMMMb`OOOI,,,,,IOOOO`dMMMP`           ,dM`      ',0ah,0dh
dw '     ``                  `OObNNNNNdOO`                   ``        ',0ah,0dh
dw '                           `~OOOOO~`                               ',0ah,0dh
dw '                           Game Over',0ah,0dh
dw '                   Press Enter to start again$',0ah,0dh 


game_start_str dw '  ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh        
dw '      *        .--.     ========================================   ',0ah,0dh
dw '              / /  `   ||  ######   ##   #####  ##### #    #   ||  *',0ah,0dh                                        
dw '   +  *  +   | |       ||  #       #  #  #    #   #   #    #   ||   ',0ah,0dh
dw '              \ \__,   ||  #####  #    # #    #   #   ######   ||+  ',0ah,0dh
dw '  *        +   "--"  * ||  #      ###### #####    #   #    #   ||   ',0ah,0dh
dw '     +   /\            ||  #      #    # #   #    #   #    #   ||  *',0ah,0dh
dw ' +     .'  '.   *      ||  ###### #    # #    #   #   #    #   ||   ',0ah,0dh
dw '  *   /======\      +  ||       --- D E F E N D E R ---        || + ',0ah,0dh          
dw '     ;:.  _   ;        ||                                      ||*   ',0ah,0dh
dw '   + |:. (_)  |        ||          JOSE PAOLO SANTOS           || + ',0ah,0dh
dw '     |:.  _   |        ||             BEA MARIANO              ||  *',0ah,0dh
dw '     |:. (_)  |      * ||         CRISSA ROCHEL CRUZ           ||   ',0ah,0dh 
dw '     ;:.      ;        ||                                      ||   ',0ah,0dh
dw '   ." \:.    / ".      ||--------------------------------------||+  ',0ah,0dh
dw '  / .-"":._.""-. \     ||  Use up and down key to move player  ||   ',0ah,0dh
dw '  |/    /||\    \|     ||      and space button to shoot       || * ',0ah,0dh
dw ' _..--"""````"""--.._  ||                                      ||  +',0ah,0dh
dw '-'``                  '||        Press Enter to start          ||   ',0ah,0dh
dw '                        ========================================   ',0ah,0dh
dw '$',0ah,0dh




.code
main proc
mov ax,@data
mov ds,ax

mov ax, 0B800h
mov es,ax 



jmp game_menu                              

                                                                   
main_loop:                                 
                                           
    mov ah,1h
    int 16h                                
    jnz key_pressed
    jmp inside_loop                        
    
    inside_loop:                           
        
        cmp health, 0                               ;check if health is 0                
        jle game_over
        
        mov dx,missile_pos                          ;check if missile hit nuk
        cmp dx, nuk_pos
        je hit
        
        cmp direction,8d                            ;check if player pressed up
        je ship_up
        cmp direction,2d                            ;check if player pressed down
        je ship_down
        
        mov dx,missile_limit                        ;check if missile is out of range
        cmp missile_pos, dx
        jge hide_missile
        
        cmp nuk_pos, 3870d                          ;check if the nuk reach the bottom
        jge miss_nuk
        jne render_nuk
    
        hit:                                        ;if hit
            mov ah,2                                    ;play sound
            mov dx, 7d
            int 21h 
            
            inc score                                   ;increase score
            
            lea bx,state_buf                            ;display score/health
            call show_score 
            lea dx,state_buf
            mov ah,09h
            int 21h
            
            mov ah,2                                    ;print new line             
            mov dl, 0dh
            int 21h    
            
            jmp random_num                                ;fire new nuk from random side
    
        render_nuk:                                 ;move the nuk down
            mov cl, ' '                                 ;hide old nuk (save ' ')
            mov ch, 1111b
        
            mov bx,nuk_pos                              ;replace old position with ' '
            mov es:[bx], cx
                
            add nuk_pos,160d                            ;increment nuk position
            mov cl, 25d                                 ;place nuk (save 'nuk char')
            mov ch, 1101b
        
            mov bx,nuk_pos                              ;place nuk to new position
            mov es:[bx], cx
            
            cmp missile_status,1d                       ;check if missile is active
            je render_missile                             
            jne inside_loop2 
        
        render_missile:                             ;movement of missile
            mov cl, ' '                                 ;hide old missile (save ' ')
            mov ch, 1111b
        
            mov bx,missile_pos                          ;replace old missile
            mov es:[bx], cx
                
            add missile_pos,4d                          ;place new missile (save 'char')
            mov cl, 26d
            mov ch, 1001b
        
            mov bx,missile_pos                          ;place missile
            mov es:[bx], cx
        
        inside_loop2:
            
            mov cl, 125d                                ;draw the ship (save 'char')
            mov ch, 1100b                               
            
            mov bx,ship_pos                             ;place ship in screen
            mov es:[bx], cx
            
             
                       
    cmp exit,0                                      ;check if exit
    je main_loop                                       ;loop
    jmp exit_game
 
jmp inside_loop2
    
ship_up:                                            ;move ship up
    mov cl, ' '                                         ;replace old ship
    mov ch, 1111b
        
    mov bx,ship_pos 
    mov es:[bx], cx
    
    sub ship_pos, 160d                                  ;place new ship
    mov direction, 0    

    jmp inside_loop2                      
    
ship_down:                                          ;move ship down
    mov cl, ' '                                         ;replace old ship
    mov ch, 1111b                         
                                          
    mov bx,ship_pos 
    mov es:[bx], cx
    
    add ship_pos,160d                                   ;place new ship
    mov direction, 0
    
    jmp inside_loop2

key_pressed:                                        ;check if key is pressed
    mov ah,0                                            ;get input
    int 16h

    cmp ah,48h                                          ;if up
    je upKey
    cmp ah, 50h                                         ;if down
    je downKey
    
    cmp ah,39h                                          ;if space
    je spaceKey
                                          
    jmp inside_loop
    
upKey:                                              ;change direction up
    mov direction, 8d                                   
    jmp inside_loop

downKey:                                            ;change direction down
    mov direction, 2d                     
    jmp inside_loop
    
spaceKey:                                           ;change direction space
    cmp missile_status,0
    je  fire_missile
    jmp inside_loop

fire_missile:                                       ;fire missile         
    mov dx, ship_pos                                    ;get ship position
    mov missile_pos, dx                                 ;initialize missile position
    
    mov dx,ship_pos                                     
    mov missile_limit, dx                               ;initialize missile limit
    add missile_limit, 30d  
    
    mov missile_status, 1d                              ;change status to true
    jmp inside_loop                       

miss_nuk:                                           ;if nuk reach floor                        
    sub health,1                                        ;minus health

    lea bx,state_buf                                    ;print score
    call show_score 
    lea dx,state_buf
    mov ah,09h
    int 21h
                                          
    mov ah,2                                            ;print new line
    mov dl, 0dh
    int 21h
jmp random_num                                      ;shoot new nuk from random side
    
fire_nuk:                                           ;fire new nuk   
    jmp render_nuk
    
hide_missile:                                       ;if missile reach limit
    mov missile_status, 0                               ;set status to false
    
    mov cl, ' '                                         ;replace old missile
    mov ch, 1111b
    
    mov bx,missile_pos 
    mov es:[bx], cx
    
    cmp nuk_pos, 3870d                                  ;check if nuk reach floor
    jge miss_nuk
    jne render_nuk 
    
    jmp inside_loop2
                                          
random_num:
    mov ax, score
    add ax, health
    test ax, 1
    jnz right_canon
    jz left_canon

right_canon:
    mov nuk_status, 1d 
    mov nuk_pos, 184d  
    jmp fire_nuk

left_canon:
    mov nuk_status, 1d 
    mov nuk_pos, 180d  
    jmp fire_nuk

;-------------------- Display Game Over --------------------;
game_over:
    mov ah,09h
    mov dx, offset game_over_str
    int 21h
    

    mov cl, ' '                                     ;remove missile           
    mov ch, 1111b 
    mov bx,missile_pos                      
    
    mov cl, ' '                                     ;remove ship
    mov ch, 1111b 
    mov bx,ship_pos  
 
    
    ;reset values                          
    mov health, 6d
    mov score,0d
    
    mov ship_pos, 1760d

    mov missile_pos, 0d
    mov missile_status, 0d 
    mov missile_limit, 22d     

    mov nuk_pos, 3860d       
    mov nuk_status, 0d
         
    mov direction, 0d
                                           
    input:                                          ;if enter pressed rest game
        mov ah,1
        int 21h
        cmp al,13d
        jne input
        call clear_screen
        jmp main_loop
    
;-------------------- Display Menu --------------------;
game_menu:
                                           
    mov ah,09h
    mov dh,0
    mov dx, offset game_start_str
    int 21h
                                           
    input2:
        mov ah,1
        int 21h
        cmp al,13d
        jne input2
        call clear_screen
        
        lea bx,state_buf                   
        call show_score 
        lea dx,state_buf
        mov ah,09h
        int 21h
    
        mov ah,2
        mov dl, 0dh
        int 21h
        
        jmp main_loop

exit_game:                                  
mov exit,10d

main endp




;-------------------- Display Score --------------------;
proc show_score
    lea bx,state_buf
    
    mov dx, score
    add dx,48d 
    
    mov [bx], 9d
    mov [bx+1], '<'
    mov [bx+2], '('
    mov [bx+3], 'o'
    mov [bx+4], 'O'
    mov [bx+5], 'o'                                        
    mov [bx+6], ')'
    mov [bx+7], '>'
    mov [bx+8], 9d
    mov [bx+9], 9d
    mov [bx+10], 'S'
    mov [bx+11], ':'
    mov [bx+12], dx

    mov dx, health
    add dx,48d

    mov [bx+13], ' '
    mov [bx+14], 'H'
    mov [bx+15], ':'
    mov [bx+16], dx
ret    
show_score endp 


;-------------------- Clear the Screen --------------------;
clear_screen proc near
        mov ah,0
        mov al,3
        int 10h        
        ret
clear_screen endp

end main
