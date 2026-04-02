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
   call printBoard
   call getInput
   ;call placeMark
   ;call checkWin
   jc .winner
   jmp .loopStart

 .winner:
  call printBoard
  mov eax, 4
  mov ebx, 1
  mov ecx, board
  mov edx, 10
  int 0x80
  ret

printBoard:
  mov eax, 4
  mov ebx, 1
  mov ecx, board
  mov edx, 10
  int 0x80
  ret

getInput:
 .readKey:
  mov eax, 3
  mov ebx, 0
  mov ecx, input
  mov edx, 2
  int 0x80

  ;convert '1' - '9' to 0-8 (board positions)
  movzx eax, byte [input]
  sub al, '1'
  cmp al, 0
  jl .readKey
  cmp al, 8
  jg .readKey
  movzx ebx, al

  ;check if cell is occupied (prevention of move errors)
  mov al, [board + ebx]
  cmp al, 'X'
  je .readKey
  cmp al, 'O'
  je. readKey

  ;check if current player's queue is full (all 3 of their pieces on board?) and cell is oldest
  call loadQueuePtrs
  cmp cl, 3
  jl .inputOk
  mov al, [edi]
  movzx eax, al
  cmp bl, al
  je .readKey

 .inputOk:
  mov [input], bl
  ret

loadQueuePtrs:
  cmp byte [turn], 'X'
  jne .useO
  lea esi, [xQueue]
  lea edi, [xHead]
  mov cl, [xCount]
  ret
 .useO:
  lea esi, [oQueue]
  lea edi, [oHead]
  mov cl, [oCount]
  ret
