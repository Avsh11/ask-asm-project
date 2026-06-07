/*
Ten sam algorytm co rozwiniecie.asm; wynik wypisujemy printfem (bez recznego bufora).
Warunki brzegowe (jak w asm):
litera / zly scanf  -> komunikat, ponowienie odczytu
mianownik = 0       -> komunikat, ponowienie odczytu x
n < 1 lub n > MAX_N (63) -> komunikat, ponowienie odczytu n
ujemny licznik lub mianownik -> znak '-' (XOR), obliczenia na modulach
Przyklad: x = 1/17, n = 15 -> x = 0.058823529411765
 */

#include <stdio.h>

#define MAX_N 63

// flush_linia nam wyrzuca reszte linii ze stdin po blednym scanf */
static void flush_linia(void)
{
    int c;

    while ((c = getchar()) != '\n' && c != EOF)  //EOF = koniec wejscia (-1)
        ;
}

// wczytaj_ulamek - "x = " + scanf "%d/%d"; 1 = OK, 0 = blad danych
static int wczytaj_ulamek(int *licznik, int *mianownik)
{
    int c;

    printf("x = ");
    if (scanf("%d/%d", licznik, mianownik) != 2) {  // musza byc 2 liczby i '/'
        printf("\nBlad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)\n");
        flush_linia();
        return 0;
    }

    c = getchar();
    if (c != '\n' && c != EOF) {  // np "1/3abc" cos zostalo po ulamku np litera
        printf("\nBlad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)\n");
        flush_linia();
        return 0;
    }

    return 1;
}

// wczytaj_n - "n = " + scanf "%d"; 1 = OK, 0 = blad danych 
static int wczytaj_n(int *n)
{
    int c;

    printf("n = ");
    if (scanf("%d", n) != 1) {
        printf("\nBlad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)\n");
        flush_linia();
        return 0;
    }

    c = getchar();
    if (c != '\n' && c != EOF) {  // np. "2b" - scanf wczytal 2, litera zostala 
        printf("\nBlad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)\n");
        flush_linia();
        return 0;
    }

    return 1;
}

// wartosc_bezwzgledna |x| dla int (long long przy INT_MIN) 
static unsigned wartosc_bezwzgledna(int x)
{
    if (x < 0)
        return (unsigned)(-(long long)x);
    return (unsigned)x;
}

int main(void)
{
    int licznik, mianownik, n;
    unsigned modul_l, modul_m;
    unsigned czesc, reszta;
    int i;

    while (1) {
        if (!wczytaj_ulamek(&licznik, &mianownik))
            continue;
        if (mianownik == 0) {
            printf("\nBlad mianownik rowny zero\n");
            continue;
        }
        break;
    }

    while (1) {
        if (!wczytaj_n(&n))
            continue;
        if (n < 1 || n > MAX_N) {
            printf("\nBlad: n musi byc z przedzialu 1-63\n");
            continue;
        }
        break;
    }

    modul_l = wartosc_bezwzgledna(licznik);
    modul_m = wartosc_bezwzgledna(mianownik);

    czesc = modul_l / modul_m;
    reszta = modul_l % modul_m;

    // wypis wyniku opcjonalny '-', czesc calkowita, '.', n cyfr po przecinku 
    printf("\nx = ");
    if ((licznik < 0) ^ (mianownik < 0))  // XOR minus gdy tylko jeden ujemny
        putchar('-');
    printf("%u.", czesc);

    for (i = 0; i < n; i++) {
        reszta *= 10;
        printf("%u", reszta / modul_m);
        reszta %= modul_m;
    }
    putchar('\n');

    return 0;
}
