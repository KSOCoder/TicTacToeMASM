section .data
board     db '1','2','3','4','5','6','7','8','9', 10
turn      db 'X'
newline   db 10
sepRow    db "-+-+-", 10

xWinMsg   db "X wins!", 10
oWinMsg   db "O wins!", 10
xTurnMsg  db "X's turn", 10
oTurnMsg  db "O's turn", 10

xQueue    db -1,-1,-1
oQueue    db -1,-1,-1
xHead     db 0
oHead     db 0
xCount    db 0
oCount    db 0

lines     db 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6
three     dd 3

section .bss
input resb 2
cellIdx resd 1

section .text
global _start
_start:
  call gameLoop

  mov eax, 1
  xor ebx, ebx
  int 0x80

gameLoop:
 .loopStart:
   call printBoard
   mov al, [turn]
   cmp al, 'X'
   je .printXTurn
   lea ecx, [oTurnMsg]
   mov edx, 9
   jmp .printTurn
  
 .printXTurn:
  lea ecx, [xTurnMsg]
  mov edx, 9

 .printTurn:
  mov eax, 4
  mov ebx, 1
  int 0x80

  call getInput
  call placeMark
  mov al, [turn]
  call checkWin
  jc .winner
  jmp .loopStart

 .winner:
   call printBoard
   mov al, [turn]
   cmp al, 'X'
   je .printXWin
   lea ecx, [oWinMsg]
   mov edx, 7
   jmp .printWin
 .printXWin:
   lea ecx, [xWinMsg]
   mov edx, 7
 .printWin:
  mov eax, 4
  mov ebx, 1
  int 0x80
  ret

printBoard:
  pushad
  mov dword [cellIdx], 0
 .printCell:
  mov ecx, [cellIdx]
  mov al, [board + ecx]
  call printChar

  mov eax, [cellIdx]
  inc eax
  xor edx, edx
  div dword [three]

  cmp edx, 0
  jne .printPipe

  mov al, 10
  call printChar

  mov eax, [cellIdx]
  cmp eax, 8
  je .doneBoard
  mov eax, 4
  mov ebx, 1
  lea ecx, [sepRow]
  mov edx, 6
  int 0x80
  jmp .nextCell
  
 .printPipe:
  mov al, '|'
  call printChar

 .nextCell:
  inc dword [cellIdx]
  mov eax, [cellIdx]
  cmp eax, 9
  jl .printCell
 .doneBoard:
  popad
  ret

printChar:
  pushad
  mov [esp+28], al
  mov eax, 4
  mov ebx, 1
  lea ecx, [esp+28]
  mov edx, 1
  int 0x80
  popad
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
  movzx eax, byte [edi]
  mov al, [esi + eax]
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
  pushad
  movzx ebx, byte [input]
  mov al, [turn]
  mov [board + ebx], al
  
  call loadQueuePtrs

  cmp cl, 3
  jl .skipDequeue
  movzx eax, byte [edi]
  movzx eax, byte [esi + eax]
  mov edx, eax
  add dl, '1'
  mov [board + eax], dl
  inc byte [edi]
  cmp byte [edi], 3
  jl .skipDequeue
  mov byte [edi], 0
  
 .skipDequeue:
  movzx eax, byte [edi]
  movzx edx, cl
  cmp cl, 3
  jl .computeTail
  xor edx, edx
 .computeTail:
  add eax, edx
  xor edx, edx
  div dword [three]
  mov [esi + edx], bl

  cmp cl, 3
  jge .switchTurn
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
  jmp .done
 .setX:
  mov byte [turn], 'X'
 .done:
  popad
  ret

checkWin:
  push esi
  push ecx
  push eax
  push ebx
  push edx

  lea esi, [lines]
  mov ecx, 8
  mov al, [turn]
 .checkLines:
  mov bl, [esi + 0]
  mov bh, [esi + 1]
  mov dl, [esi + 2]

  movzx ebx, bl
  movzx edx, bh
  movzx edi, dl

  mov bl, [board + ebx]
  cmp bl, al
  jne .nextLine
  mov bh, [board + edx]
  cmp bh, al
  jne .nextLine
  mov dl, [board + edi]
  cmp dl, al
  jne .nextLine
  stc
  pop edx
  pop ebx
  pop eax
  pop ecx
  pop esi
  ret
 .nextLine:
  add esi, 3
  loop .checkLines
  clc
  pop edx
  pop ebx
  pop eax
  pop ecx
  pop esi
  ret
