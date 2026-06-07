         [bits 32]

global _main

extern _printf
extern _scanf
extern _getchar

max_digit equ 63  ; ile cyfr maksymalnie po przecinku (nie rozmiar bufora)

section .data

format_px    db "x = ", 0
format_sx    db "%d/%d", 0
format_pn    db "n = ", 0
format_sn    db "%d", 0
format_wynik db 0xA, "x = %s", 0xA, 0

msg_danych   db 0xA, "Blad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)", 0xA, 0
msg_zero     db 0xA, "Blad mianownik rowny zero", 0xA, 0
msg_n        db 0xA, "Blad: n musi byc z przedzialu 1-63", 0xA, 0

section .bss

bufor        resb 66  ; miejsce na tekst wyniku, wyjasnienie czemu max n=63 na poczatku

section .text

_main:
;        esp -> [ret]  ; ret - adres powrotu programu

         sub esp, 16   ; esp = esp - 16  ; rezerwacja 4 pola po 4 bajty
         mov ebp, esp  ; ebp = adres bloku danych

;        SCIAGA (zeby tez wiadomo gdzie co)
;        Wszystko po 4 bajty oczywiscie
;        [ebp+0] = licznik
;        [ebp+4] = mianownik
;        [ebp+8] = n
;        [ebp+12] = abs_p  ; wartosc bezwzgledna licznika bedzie
;        esp -> [licznik][mianownik][n][abs_p][ret]

;        ODCZYT X (ulamek licznik/mianownik)

poczatek:
         push format_px  ; esp -> [format_px][licznik][mianownik][n][abs_p][ret]

         call _printf  ; printf(format_px);

         add esp, 1*4  ; esp = esp + 4

;        esp -> [licznik][mianownik][n][abs_p][ret]

         lea eax, [ebp+4]  ; eax = adres mianownika (&mianownik)
         push eax          ; eax -> stack

;        esp -> [addr_mianownik][licznik][mianownik][n][abs_p][ret]

         lea eax, [ebp+0]  ; eax = adres licznika (&licznik)  ; ladujemy adres zmiennej nie wartosc
         push eax          ; eax -> stack

;        esp -> [addr_licznik][addr_mianownik][licznik][mianownik][n][abs_p][ret]

         push format_sx  ; esp -> [format_sx][addr_licznik][addr_mianownik][licznik][mianownik][n][abs_p][ret]

         call _scanf  ; scanf(format_sx, &licznik, &mianownik);
         add esp, 3*4    ; esp = esp + 12
        
;        esp -> [licznik][mianownik][n][abs_p][ret]

         cmp eax, 2  ; eax - 2
         jne blad_danych_l  ; jump if not equal  ; jump if ZF = 0

         call _getchar  ; eax = getchar();
         cmp eax, 10      ; eax - 10 (\n)
         je sprawdz_zero  ; jump if equal  ; jump if ZF = 1
         cmp eax, -1      ; eax - (-1) (EOF)
         je sprawdz_zero  ; jump if equal  ; jump if ZF = 1
         jmp blad_danych_l

;        MIANOWNIK != 0

sprawdz_zero:
         cmp dword [ebp+4], 0  ; *(int*)(ebp+4) - 0  ; mianownik - 0
         je blad_zero          ; jump if equal  ; jump if ZF = 1  ; mianownik == 0 -> blad
        
;        ODCZYT N

poczatek_n:
         push format_pn  ; esp -> [format_pn][licznik][mianownik][n][abs_p][ret]

         call _printf  ; printf(format_pn);

         add esp, 1*4  ; esp = esp + 4

;        esp -> [licznik][mianownik][n][abs_p][ret]

         lea eax, [ebp+8]  ; eax = adres n (&n)
         push eax          ; eax -> stack

;        esp -> [addr_n][licznik][mianownik][n][abs_p][ret]

         push format_sn  ; esp -> [format_sn][addr_n][licznik][mianownik][n][abs_p][ret]
     
         call _scanf  ; eax = scanf(format_sn, &n);
         add esp, 2*4    ; esp = esp + 8
        
;        esp -> [licznik][mianownik][n][abs_p][ret]

         cmp eax, 1         ; eax - 1
         jne blad_danych_n  ; jump if not equal  ; jump if ZF = 0

         call _getchar  ; eax = getchar();
         cmp eax, 10      ; eax - 10 (\n)
         je sprawdz_n     ; jump if equal  ; jump if ZF = 1
         cmp eax, -1      ; eax - (-1) (EOF)
         je sprawdz_n     ; jump if equal  ; jump if ZF = 1
         jmp blad_danych_n

;        1 <= n <= max_digit

sprawdz_n:
         cmp dword [ebp+8], 1  ; *(int*)(ebp+8) - 1  ; n - 1
         jl blad_n             ; jump if less  ; jump if SF != OF  ; n < 1 -> blad

         cmp dword [ebp+8], max_digit  ; *(int*)(ebp+8) - max_digit
         jg blad_n                     ; jump if greater  ; jump if SF != OF  ; n > 63 -> blad
         
;        UJEMNY ZNAK DLA MIANOWNIKA LUB LICZNIKA

         xor ecx, ecx  ; ecx = 0

         mov eax, [ebp+0]  ; eax = *(int*)(ebp+0) = licznik
         test eax, eax     ; eax & eax  ; OF=0 SF ZF PF CF=0 affected
         jns zn_p          ; jump if not sign  ; jump if SF = 0  ; licznik >= 0 -> bez zmiany ecx

         xor ecx, 1  ; licznik < 0 (bit znaku przelaczyc 0->1)

;        licznik sprawdzony i lecimy do mianownika
zn_p:
         mov eax, [ebp+4]  ; eax = *(int*)(ebp+4) = mianownik
         test eax, eax     ; eax & eax  ; OF=0 SF ZF PF CF=0 affected
         jns zn_q          ; jump if not sign  ; jump if SF = 0  ; mianownik >= 0 -> bez zmoany ecx

         xor ecx, 1  ; gdy mianownik < 0 -> przelacz bit (oba ujemne = wynik dodatni dwa minusy -> +)

;        koniec ustalenia znaku wyniku
zn_q:

;        koniec ustalania znaku podsumowanie
;        ecx = 0 -> wynik dodatni, ecx = 1 -> wynik ujemny

;        |l| -> [ebp+12], |m| -> esi
;        gdzie |l| wartosc bezwz. licznik i |m| mianownik
;        bede uzywac naprzemiennie w komentarzach |licznik|/|mianownik| zeby bylo wiadomo

         mov eax, [ebp+0]  ; eax = *(int*)(ebp+0) = licznik
         test eax, eax     ; eax & eax  ; OF=0 SF ZF PF CF=0 affected
         jns p_abs         ; jump if not sign  ; jump if SF = 0  ; licznik >= 0 -> juz |l|

         neg eax  ; licznik < 0 -> eax = -eax = |licznik| = |l|

;        licznik nieujemny to zapisujemy |licznik| do abs_p
p_abs:
         mov [ebp+12], eax  ; *(int*)(ebp+12) = eax  ; abs_p = |licznik|

         mov eax, [ebp+4]  ; eax = *(int*)(ebp+4) = mianownik
         test eax, eax     ; eax & eax  ; OF=0 SF ZF PF CF=0 affected
         jns q_abs         ; jump if not sign  ; jump if SF = 0  ; mianownik >= 0

         neg eax  ; mianownik < 0 -> |mianownik|

;        mianownik nieujemny, esi = |mianownik| jako dzielnik
q_abs:
         mov esi, eax  ; esi = |mianownik|  ; dzielnik w div

;        bufor wyniku

;        BUFOR!!! NAJWAZNIEJSZA CZESC CHYBA
;        USTALIC ZAKRES GORNY JUZ NA ILOSC MIEJSC

         mov edi, bufor  ; edi = wskaznik zapisu

         cmp ecx, 0     ; ecx - 0
         je bez_minusa  ; jump if equal  ; jump if ZF = 1  ; wynik dodatni

;        znak '-' (ecx z XOR gdzie 0 = dodatni, 1 = ujemny)

         mov byte [edi], '-'  ; *(char*)edi = '-'
         inc edi  ; edi = edi + 1
 
;        wynik dodatni, pomijamy zapis '-' i idziemy do div od razu
bez_minusa:

         mov eax, [ebp+12]  ; eax = *(int*)(ebp+12) = abs_p (|licznik|)
         mov edx, 0         ; edx = 0

         div esi  ; eax = eax/esi  ; iloraz
                  ; edx = eax%esi  ; reszta

         push edx  ; edx -> stack

;        esp -> [reszta][licznik][mianownik][n][abs_p][ret]

         cmp eax, 0     ; eax - 0
         je czesc_zero  ; jump if equal  ; jump if ZF = 1  ; czesc calkowita = 0
         
         push esi  ; esi -> stack

;        esp -> [|m|][reszta][licznik][mianownik][n][abs_p][ret]

         mov esi, esp  ; esi = esp
 
;        dzielimy czesc calkwoita przez 10 i cyfry potem na stos leca
czesc_push:

         cmp eax, 0    ; eax - 0
         je czesc_pop  ; jump if equal  ; jump if ZF = 1  ; eax == 0

         mov edx, 0   ; edx = 0
         mov ecx, 10  ; ecx = 10

         div ecx  ; eax = eax/10  ; iloraz
                  ; edx = eax%10  ; ostatnia cyfra 0-9

         add dl, '0'  ; dl = dl + 48  ; dl = cyfra jako ascii
         push edx     ; edx -> stack (cyfra)

         jmp czesc_push
 
;        zdjac cyfry ze stosu i zapisac do bufora w odpowiedniej kolejnosci
czesc_pop:

         cmp esp, esi  ; esp - esi
         je po_czesci  ; jump if equal  ; jump if ZF = 1
         
         pop eax        ; eax <- stack
         mov [edi], al  ; *(char*)edi = al
         inc edi        ; edi++

         jmp czesc_pop

;        czesc calkowita = 0, wpisujemy '0' i przygotowujemy stos tak jak przy |licznik| > |mianownik|
czesc_zero:
         mov byte [edi], '0'  ; *(char*)edi = '0'
         inc edi              ; edi++

         push esi  ; esi -> stack

;        esp -> [|mianownik|][reszta][licznik][mianownik][n][abs_p][ret]

;        wpisujemy '.' i przywracamy |m| i reszte ladoujemy n do petli cyfr
po_czesci:
         mov byte [edi], '.'  ; *(char*)edi = '.'
         inc edi              ; edi++
         
         pop eax       ; eax <- stack
         mov esi, eax  ; esi = eax  ; esi = |mianownik|
         
         pop eax  ; eax <- stack  ; eax = reszta

         mov ecx, [ebp+8]  ; ecx = *(int*)(ebp+8) = n

;        n razy reszta * 10, div przez |m| i zpais jednej cyfry po przecinku
cyfra_petla:
         mov edx, 0  ; edx = 0
         
         lea eax, [eax + eax*4]  ; eax = eax + eax * 4  ; eax = reszta * 5
         add eax, eax            ; eax = eax + eax  ; eax = reszta * 10

         div esi  ; eax = edx:eax / esi  ; cyfra
                  ; edx = edx:eax % esi  ; reszta

         add al, '0'    ; al = al + 48 (ASCII 48 co nie)
         mov [edi], al  ; *(char*)edi = al
         inc edi        ; edi++

         mov eax, edx  ; eax = edx  ; eax = reszta

         loop cyfra_petla

         mov byte [edi], 0  ; *(char*)edi = 0
         
;        X = WYNIK

         push bufor  ; esp -> [bufor][licznik][mianownik][n][abs_p][ret]
         
         push format_wynik  ; esp -> [format_wynik][bufor][licznik][mianownik][n][abs_p][ret]

         call _printf  ; printf(format_wynik, bufor);
         add esp, 2*4    ; esp = esp + 8

         add esp, 16   ; esp = esp + 16

;        esp -> [ret]

         xor eax, eax  ; eax = 0  ; kod wyjscia 0
         ret

;        OBSLUGI BLEDOW !!!!

;        scanf nie wczytal liczby np litera lub inny smiec
blad_danych_l:
         mov dword [ebp+12], 0  ; *(int*)(ebp+12) = 0  ; 0 = ponow od "x = "
         jmp blad_danych

blad_danych_n:
         mov dword [ebp+12], 1  ; *(int*)(ebp+12) = 1  ; 1 = ponow od "n = "
         jmp blad_danych

blad_danych:
         push msg_danych  ; esp -> [msg_danych][licznik][mianownik][n][abs_p][ret]

         call _printf  ; printf(msg_danych);
         add esp, 1*4    ; esp = esp + 4

flush_bd:
         call _getchar  ; eax = getchar();
         cmp eax, 10     ; eax - 10 (\n)
         je retry_bd     ; jump if equal  ; jump if ZF = 1  ; koniec linii
         cmp eax, -1     ; eax - (-1) (EOF)
         je retry_bd     ; jump if equal  ; jump if ZF = 1  ; koniec wejscia
         jmp flush_bd    ; zjadamy znaki az \n lub EOF

retry_bd:
         cmp dword [ebp+12], 0  ; *(int*)(ebp+12) - 0
         je poczatek            ; jump if equal  ; jump if ZF = 1  ; zly x wtedy -> "x = "
         jmp poczatek_n         ; zly n -> "n = "

;        jak mianownik = 0 to wypisz komunikat i koncz program!!
blad_zero:
         push msg_zero  ; esp -> [msg_zero][licznik][mianownik][n][abs_p][ret]

         call _printf  ; printf(msg_zero);
         add esp, 1*4     ; esp = esp + 4
         jmp poczatek    ; koniec_blad konczy program

;        n poza zakresem 1-63, komunikat i ponowienie odczytu n
blad_n:
         push msg_n  ; esp -> [msg_n][licznik][mianownik][n][abs_p][ret]

         call _printf  ; printf(msg_n);
         add esp, 4      ; esp = esp + 4
         jmp poczatek_n

;        wspolne zakonczenie po bledzie zwalnamy caly stos i exit(0) pierwsza funkcja w API asmloadera 0. exit
koniec_blad:
         add esp, 16  ; esp = esp + 16
         
;        esp -> [ret]

         xor eax, eax  ; eax = 0
         ret
