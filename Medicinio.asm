.MODEL SMALL
.STACK 100h

.DATA
  msg DB "Medicinio starting...$"


.CODE
start:
  mov ax, @data
  mov ds, ax

  mov ah, 09h
  lea dx, msg
  int 21h

  mov ax, 4C00h
  int 21h

END start
