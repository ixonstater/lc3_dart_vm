.ORIG x3000
    JSR	mainLoop
HALT

; Main subroutine, here the program loops until the letter "q" is entered
mainLoop:
    LEA R0, BASIC_PROG_INFORMATION
    PUTS
    JMP	R3
    RET

    MAINLOOPLOOP 
    LEA R0, CYCLIC_PROMPT
    PUTS
    JSR readInput ; Input value memory location is returned in R1
    LD R3, QUIT_NEG
    LDR	R4,	R1,	X0
    ADD R3, R3, R4
    BRz MAINLOOPEXIT

    JSR validateInput ; If value of register 3 is not 1 then start the loop over
    ADD R3, R3, -1
    BRnp MAINLOOPLOOP
    JSR isPrime
    BRnzp MAINLOOPLOOP

MAINLOOPEXIT

QUIT_NEG .FILL XFF8F

; Prompts for main loop
BASIC_PROG_INFORMATION .STRINGZ	"T        df"
CYCLIC_PROMPT .STRINGZ "Tet\n"