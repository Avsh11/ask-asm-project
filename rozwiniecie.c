#include <stdio.h>

#define MAX_N 63

static void flush_linia(void)
{
    int c;

    while ((c = getchar()) != '\n' && c != EOF)
        ;
}

static int wczytaj_ulamek(int *licznik, int *mianownik)
{
    int c;

    printf("x = ");
    if (scanf("%d/%d", licznik, mianownik) != 2) {
        printf("\nBlad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)\n");
        flush_linia();
        return 0;
    }

    c = getchar();
    if (c != '\n' && c != EOF) {
        printf("\nBlad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)\n");
        flush_linia();
        return 0;
    }

    return 1;
}

static int wczytaj_n(int *n)
{
    printf("n = ");
    if (scanf("%d", n) != 1) {
        printf("\nBlad: oczekiwano liczby calkowitej (wpisales litere lub cos innego)\n");
        flush_linia();
        return 0;
    }

    return 1;
}

static unsigned wartosc_bezwzgledna(int x)
{
    if (x < 0)
        return (unsigned)(-(long long)x);
    return (unsigned)x;
}

int main(void)
{
    int licznik, mianownik, n;
    unsigned modul_p, modul_q;
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
        if (n < 0 || n > MAX_N) {
            printf("\nBlad: n musi byc z przedzialy 0-63\n");
            continue;
        }
        break;
    }

    modul_p = wartosc_bezwzgledna(licznik);
    modul_q = wartosc_bezwzgledna(mianownik);

    czesc = modul_p / modul_q;
    reszta = modul_p % modul_q;

    printf("\nx = ");
    if ((licznik < 0) ^ (mianownik < 0))
        putchar('-');
    printf("%u.", czesc);

    for (i = 0; i < n; i++) {
        reszta *= 10;
        printf("%u", reszta / modul_q);
        reszta %= modul_q;
    }
    putchar('\n');

    return 0;
}
