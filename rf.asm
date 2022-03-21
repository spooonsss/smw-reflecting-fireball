;====================;
;Reflecting Fireball ;
;====================;

InitSpeeds: db $10,$F0		; Initial speeds (right, left)
!InitY = $F0			; Initial Y speed.
!Tile = $AC			; Tile of sprite (upper left 8x8)

print "INIT ",pc
	PHB			;\
	PHK			; |
	PLB			;/
	%SubHorzPos()
	LDA InitSpeeds,y	; |
	STA $B6,x		; |
	LDA #!InitY		; | Y Speed = A0 initially.	
	STA $AA,x		;/
	PLB		
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Spr
	PLB
	RTL

;=======;
; Main  ;
;=======;
Spr:
									JSR.w Graphics     	; Tilemaps code.    
			
			                      LDA.w $14C8,X  		; If sprite is dead, return.           
			                      CMP.b #$08                
			                      BNE Return038FF1          
			                      LDA $9D			;RAM_SpritesLocked     
			                      BNE Return038FF1          	; Return if sprites locked.
			                      JSL.l $01801A;		UpdateYPosNoGrvty   
			                      JSL.l $018022;		UpdateXPosNoGrvty   
			                      JSL.l $019138;		; some interaction routine?         
			                      LDA.w $1588,X  		; \ Branch if not touching object 
			                      AND.b #$03                	;  | 
			                      BEQ CODE_038FDC           	; / 
			                      LDA $B6,X    			;\
			                      EOR.b #$FF                	; | Invert speed if touching a wall.
			                      INC A                     	; |
			                      STA $B6,X    			;/
CODE_038FDC:                      LDA.w $1588,X  
			                      AND.b #$0C   			; C = 12 = 8+4 = 00001100          
			                      BEQ CODE_038FEA           	; If touching a ceiling ..
			                      LDA $AA,X    			;\
			                      EOR.b #$FF                	; |
			                      INC A                     	; | Invert y speed.
			                      STA $AA,X    			;/
CODE_038FEA:                      JSL.l $01A7DC			; default interaction with Mario.    
								LDA #$00
								%SubOffScreen()
Return038FF1:                     RTS                       ; Return 

;Graphics
;==========

Graphics:                      JSL.l $0190B2			;GenericSprGfxRt2    
			                      LDA $14     		
			                      LSR                       
			                      LSR                       
			                      LDA.b #$04                
			                      BCC CODE_038FFF           
			                      ASL                       
CODE_038FFF:                      LDY $B6,X    
			                      BPL CODE_039005		; If going right ..           
			                      EOR.b #$40                	;\
CODE_039005:                      LDY $AA,X    			; | X flip sprite.
			                      BMI CODE_03900B           	; | Y flip if falling
			                      EOR.b #$80                	; |
CODE_03900B:                      STA $00                   	;/ Store into $00
			                      LDY.w $15EA,X   	; Y = Index into sprite OAM 
			                      LDA.b #!Tile           	; Store tile.     
			                      STA.w $0302,Y
			                      LDA.w $0303,Y          
								  AND.b #$31   			; Filter  00110001           
			                      ORA $00                  	;	  YXPPCCCT
			                      STA.w $0303,Y         	; Store $00 into $0303,y. 
Return03901F:                     RTS
