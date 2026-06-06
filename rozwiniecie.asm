         [bits 32]

;        esp -> [ret]  ; ret - adres powrotu do asmloader

%ifdef   COMMENT
na razie bez analiz stosu i kom do getaddr
(nie mam home na klawiaturze nie chce mi sie kopiowac)
+ maly ekran
%endif

max_digit equ 63

         sub esp, 16  ; esp = esp - 16
         
         mov ebp, esp  ; ebp = adres licznika
         
         call getaddr_pl  ; (pl) prompt licznik
format_pl:
         db "licznik = ", 0
getaddr_pl:

         call [ebx+3*4]  ; printf(format_pl)
         
         lea eax, [ebp+0]  ; eax - adres licznika
         
         push eax  ; eax -> stack
         
         call getaddr_sl  ; scanf licznik
format_sl:
         db "%d", 0
getaddr_sl:

         call [ebx+4*4]
         add esp, 2*4

         call getaddr_pm  ; prompt mianownik
format_pm:
         db "mianownik = ", 0
getaddr_pm:

         call [ebx+3*4]
         
         lea eax, [ebp+4]  ; eax = adres mianownika

         push eax  ; eax -> stack
         
         call getaddr_sm
format_sm:
         db "%d", 0
getaddr_sm:

         call [ebx+4*4]
         add esp, 2*4
         
         call getaddr_pn
format_pn:
          db "n = ", 0
getaddr_pn:

           call [ebx+3*4]
           
           lea eax, [ebp+8]
           
           push eax
           
           call getaddr_sn
format_sn:
          db "%d", 0
getaddr_sn:

           call [ebx+4*4]
           add esp, 2*4

           push dword [ebp+8]  ; n -> stack
           push dword [ebp+4]   ; mianownik -> stack
           push dword [ebp+0]   ; licznik -> stack

           call getaddr
format:
       db "wczytano: %d / %d, n = %d", 0xA, 0
getaddr:

         call [ebx+3*4]  ; printf(format, licznik, mianownik, n);
         add esp, 4*4    ; esp = esp + 8

;        esp -> [ret]
         add esp, 16  ; zwolnic blok danych
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
