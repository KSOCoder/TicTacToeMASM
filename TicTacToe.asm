section .data
board     db '1','2','3','4','5','6','7','8','9', 10
turn      db 'X'
newline   db 10

xQueue    db 0FFh,0FFh,0FFh
oQueue    db 0FFh,0FFh,0FFh
xHead     db 0
oHead     db 0
xCount    db 0
oCount    db 0

rows      db 0,1,2, 3,4,5, 6,7,8
cols      db 0,3,6, 1,4,7, 2,5,8
diags     db 0,4,8, 2,4,6

section .text
global _start
_start:
  call gameLoop

  mov eax, 1
  xor ebx, ebx
  int 0x80

printNewLine:
  mov eax, 4
  mov ebx, 1
  mov ecx, newline
  mov edx, 1
  int 0x80
  ret

gameLoop:
 .loopStart:
   ;call printBoard
   ;call getInput
   ;call placeMark
   ;call checkWin
   ;jc .winner
   ;jmp .loopStart
