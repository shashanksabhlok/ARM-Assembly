; ECE-222 Lab ... Winter 2013 term 
; Lab 3 sample code 
				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				ENTRY  
__MAIN

; The following lines are similar to Lab-1 but use a defined address to make it easier.
; They just turn off all LEDs 
				LDR			R10, =LED_BASE_ADR		; R10 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports

				MOV 		R3, #0xF0000000		; Turn off three LEDs on port 1  
				STR 		R3, [R10, #0x20]	
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 	; Turn off five LEDs on port 2 


				MOV R6, #0x00  
				STRB R6, [R10, #0x41] ; P2.10 = 0 initiates it for input
				LDR R8, =FIO2PIN  ;FIO2PIN is used to read P2[31:0]
				LDR R6, [R8]  ;R6[10] contains the input

				; This line is very important in your main program
				; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
				MOV			R11, #0xABCD		; Init the random number generator with a non-zero number

				
				BL 	RandomNum  ; Branch to RandomNum to generate a random number
				MOV R2, #0x2710  ; Move 10000 to R2
				MUL R4, R4, R2	; Multiply the delay by 10000 to create the appropriate delay
				BL DELAY
				MOV R1, #0xD0000000	
				STR R1, [R10, #0x20] ; Turn on Led 29
				BL POLL  ; Branch to Poll subroutine
Show_Again		MOV R12, R9		; Display the first 8-bit of the reflex time
				BL DISPLAY_NUM
				LSR R12, #8
				MOV R4, #0x4E20
				BL DELAY	; Delay for 2 seconds
				BL DISPLAY_NUM ; Display the next 8 bits
				LSR R12, #8
				MOV R4, #0x4E20
				BL DELAY	; Delay for 2 seconds
				BL DISPLAY_NUM  ; Display the next 8 bits
				LSR R12, #8
				MOV R4, #0x4E20
				BL DELAY	; Delay for 2 seconds
				BL DISPLAY_NUM  ; Display the final 8 bits
				MOV R4, #0xC350
				BL DELAY	; Delay for 5 seconds before repeating the display of the 32 bit number
				B Show_Again
				
				;BL Simple_Counter	; Branch to led simple_counter subroutine

Simple_Counter	STMFD		R13!,{R1, R2, R4, R8, R14}
				MOV R1, #0x0
NextNumber		MOV	R4, #0x3E8 ;Move 1000 to create a 0.1 second delay
MultipleLoop3	MOV	R2, #0x0000007D
loopMore3		SUBS	R2, #1		
				BNE	loopMore3
				SUBS R4, #1;
				BNE MultipleLoop3
				ADD R1, R1, #1	;Add 1 to R1 to display the next number 
				MOV R12, R1
				BL DISPLAY_NUM
				B NextNumber
				LDMFD		R13!,{R1, R2, R4, R8, R15}
;
; Display the number in R3 onto the 8 LEDs
DISPLAY_NUM		STMFD		R13!,{R1, R2, R4, R8, R14}

; Usefull commaands:  RBIT (reverse bits), BFC (bit field clear), LSR & LSL to shift bits left and right, ORR & AND and EOR for bitwise operations
				
				MOV 		R1, R12		
				MVN 		R1, R1		; complement the number that is passed in
				MOV 		R2, #0x80   ; generate a bit number that has a leading 1
				AND 		R4, R1, R2	; Store the one bit by ANDing
				LSR			R7, R4, #3	; Shift R4 by 3 so that it controls LED 28
				LSL 		R1, R1, #1	; Shift the number left by 1 
				AND 		R4, R1, R2
				LSR			R8, R4, #2	; Shift R4 by 2 so that it controls LED 29 
				ADD			R7, R7, R8	; Adds both the number for LED 28 and LED 29 so that both are controlled by the same number
				LSL			R1, R1, #1	
				AND 		R4, R1, R2
				ADD			R7, R7, R4	;Adds number for LED 28, 29 and 31 so that all are controlled by the same number
				LSL			R7, R7, #24  ; Shift by 24 so that it goes to the most significant byte 
				STR 		R7, [R10, #0x20]  ; finally store in the memory address for port 1
				
				MOV 		R7, #0x0	
				LSL 		R1, R1, #1	
				AND 		R4, R1, R2
				LSR			R8, R4, #4  ; Shift by 4 so that it goes to the third bit 
				ADD			R7, R7, R8	; Adds both the number for LED 28 and LED 29 so that both are controlled by the same number
				LSL 		R1, R1, #1
				AND 		R4, R1, R2
				LSR			R8, R4, #3
				ADD			R7, R7, R8	; Adds both the number for LED 2 and LED 3 so that both are controlled by the same number
				LSL 		R1, R1, #1
				AND 		R4, R1, R2
				LSR			R8, R4, #2
				ADD			R7, R7, R8	;Adds number for LED 2, 3 and 4 so that all are controlled by the same number
				LSL 		R1, R1, #1
				AND 		R4, R1, R2
				LSR			R8, R4, #1	
				ADD			R7, R7, R8	;Adds number for LED 2, 3, 4 and 5 so that all are controlled by the same number
				LSL 		R1, R1, #1	
				AND 		R4, R1, R2
				ADD			R7, R7, R4	;Adds number for LED 2, 3, 4, 5 and 6 so that all are controlled by the same number
				LSR			R7, R7, #1
				STR 		R7, [R10, #0x40] ;finally store in the memory address for port 2
				
				
				LDMFD		R13!,{R1, R2, R4, R8, R15}

POLL			STMFD		R13!,{R1, R2, R3, R14}
		;
		; code to generate a delay of 0.1mS * R0 times
		;
				MOV R9, #0x0
				MOV R1, #0x400 		; stores a number that has 0s except at the 11bit that has 1 into R1						
MultipleLoop2	MOV	R2, #0x0000007D
loopMore2		SUBS	R2, #1			
				BNE	loopMore2
				ADD R9, R9, #1	; increments one every 0.1 millisecond
				LDR R6, [R8]  ; reading form the contents of the memory address that reads the input button
				ANDS R3, R1, R6	; check to see if it is pressed, if its 0, then it is pressed.
				BNE MultipleLoop2
			
exitDelay		LDMFD		R13!,{R1, R2, R3, R15}
;
; R11 holds a 16-bit random number via a pseudo-random sequence as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 holds a non-zero 16-bit number.  If a zero is fed in the pseudo-random sequence will stay stuck at 0
; Take as many bits of R11 as you need.  If you take the lowest 4 bits then you get a number between 1 and 15.
;   If you take bits 5..1 you'll get a number between bbassuming you right shift by 1 bit).
;
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program OR ELSE!
; R11 can be read anywhere in the code but must only be written to by this subroutine
RandomNum		STMFD		R13!,{R1, R2, R3, R14}

				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1		; the new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				
				MOV 		R1, #0x0001
				AND 		R3, R1, R11
				LSL			R1, #1
				AND 		R4, R1, R11
				ADD 		R3, R3, R4
				LSL			R1, #1
				AND 		R4, R1, R11
				ADD 		R3, R3, R4
				ADD 		R4, R3, #0x2
				
				LDMFD		R13!,{R1, R2, R3, R15}


;
;		Delay 0.1ms (100us) * R0 times
; 		aim for better than 10% accuracy
DELAY			STMFD		R13!,{R2, R14}
		;
		; code to generate a delay of 0.1mS * R0 times
		;
				
				MOV R0, R4				
MultipleLoop	MOV	R2, #0x0000007D
loopMore		SUBS	R2, #1			
				BNE	loopMore
				SUBS R0, #1;
				BNE MultipleLoop
			
				LDMFD		R13!,{R2, R15}
				

LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002c00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002c010 		; Address of Pin Select Register 4 for P2[15:0]
FIO2PIN 		EQU 	0x2009c054
;	Usefull GPIO Registers
;	FIODIR  - register to set individual pins as input or output
;	FIOPIN  - register to read and write pins
;	FIOSET  - register to set I/O pins to 1 by writing a 1
;	FIOCLR  - register to clr I/O pins to 0 by writing a 1

				ALIGN 

				END 

;LAB Report Answers

;1) The maximum amount of time that can be encoded in 8-bits is 25.5 ms.
;	The maximum amount of time that can be encoded in 16-bits is 6.5535 s.
;	The maximum amount of time that can be encoded in 24-bits is 1677.7215 s.
;	The maximum amount of time that can be encoded in 32-bits is 429496.7295 s.

;2) Considering typical human reaction time, I think 16 bits would be the best size for this task. 