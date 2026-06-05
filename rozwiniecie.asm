         [bits 32]

;        esp -> [ret]  ; ret - adres powrotu do asmloader

licznik   equ 1
mianownik equ 17
n         equ 15

         push mianownik  ; mianownik -> stack
         push licznik    ; licznik -> stack

;        esp -> [licznik][mianownik][n][ret]

         call getaddr_x  ; push on the stack the run-time address of format and jump to getaddr
format_x:
         db "x = %d/%d", 0xA, 0
getaddr_x:

         call [ebx+3*4]
         add esp, 3*4
         
         push n
         
         call getaddr_n
format_n:
         db "n = %d", 0xA, 0
getaddr_n:

         call [ebx+3*4]  ; printf(format, licznik, mianownik, n);
         add esp, 2*4    ; esp = esp + 8

;        esp -> [ret]

         push 0          ; esp -> [00 00 00 00][ret]
         call [ebx+0*4]  ; exit(0);

; asmloader API
;
; ESP wskazuje na prawidlowy stos
; argumenty funkcji wrzucamy na stos
; EBX zawiera pointer na tablice API
;
; call [ebx + NR_FUNKCJI*4] ; wywolanie funkcji API
;
; NR_FUNKCJI:
;
; 0 - exit
; 1 - putchar
; 2 - getchar
; 3 - printf
; 4 - scanf
;
; To co funkcja zwróci jest w EAX.
; Po wywolaniu funkcji sciagamy argumenty ze stosu.
;
; https://gynvael.coldwind.pl/?id=387

%ifdef COMMENT

ebx    -> [ ][ ][ ][ ] -> exit
ebx+4  -> [ ][ ][ ][ ] -> putchar
ebx+8  -> [ ][ ][ ][ ] -> getchar
ebx+12 -> [ ][ ][ ][ ] -> printf
ebx+16 -> [ ][ ][ ][ ] -> scanf

%endif
