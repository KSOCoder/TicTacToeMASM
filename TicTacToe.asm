section .data
board     db '1','2','3','4','5','6','7','8','9', 10
turn      db 'X'
newline   db 10

xWinMsg   db "X wins!", 10
oWinMsg   db "O wins!", 10

xQueue    db 0FFh,0FFh,0FFh
oQueue    db 0FFh,0FFh,0FFh
xHead     db 0
oHead     db 0
xCount    db 0
oCount    db 0

lines      db 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6

section .bss
input resb 2

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
   call placeMark
   call checkWin
   jc .winner
   jmp .loopStart

 .winner:
   call printBoard
   mov al, [turn]
   cmp al, 'X'
   lea ecx, [xWinMsg]
   mov edx, 7
   lea ecx, [oWinMsg]
   mov edx, 7
   mov eax, 4
   mov ebx, 1
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
  je .readKey

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

placeMark:
  movzx ebx, byte [input]
  mov al, [turn]
  mov [board + ebx], al
  
  call loadQueuePtrs

  cmp cl, 3
  jl .skipDequeue
  mov al, [edi]
  movzx eax, al
  mov al, [esi + eax]
  add al, '1'
  mov [board + eax], al
  inc byte [edi]
  cmp byte [edi], 3
  jl .afterDeq
  mov byte [edi], 0
 .afterDeq:
  
 .skipDequeue:
  mov al, [edi]
  movzx eax, al
  mov [esi + eax], bl
  inc byte [edi]
  cmp byte [edi], 3
  jl .afterEnq
  mov byte [edi], 0
 .afterEnq:

  cmp cl, 3
  jl .incCount
  jmp .switchTurn
 .incCount:
  cmp byte [turn], 'X'
  jne .incO
  inc byte [xCount]
  jmp .switchTurn
 .incO:
  inc byte [oCount]

 .switchTurn:
  cmp byte [turn], 'X'
  jne .setX
  mov byte [turn], 'O'
  ret
 .setX:
  mov byte [turn], 'X'
  ret

checkWin:
  mov al, [turn]
  lea esi, [lines]
  mov ecx, 8
 .checkLines:
  mov bl, [board + esi + 0]
  cmp bl, al
  jne .nextLine
  cmp [board + esi + 1], al
  jne .nextLine
  cmp [board + esi + 2], al
  jne .nextLine
  stc
  ret
 .nextLine:
  add esi, 3
  loop .checkLines
  clc
  ret
