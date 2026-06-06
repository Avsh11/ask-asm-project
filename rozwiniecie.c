#include <stdio.h>

#define MAX_N 63 // limit miejsc po przecinku taki sam jak w wersji z .asm wzialem

// metoda pobiera wpisany tekst i przerabia na liczbe
// majac wejscie jako tekst mozna odrzucic bledu
// zwraca 1 jak sie udalo a 0 jak nie i jest blad
int wczytaj_liczbe(long long *wynik) {
    char bufor[100];  // 99 znakow z klawiatury    
    
    // wczytujemy ciag jako tekst, max 99 znakow bez spacji a ja ksie nie uda zwraca 0
    if (scanf("%99s", bufor) != 1) {
        return 0;
    }

	// tutaj budujemy liczbe z cyfr
    long long wartosc = 0;
    // zakladamy na start ze liczba dodatnia
    int znak = 1;
    // tutaj counter ktory bedzie mowic na ktoryzm naku tekstu jestesmy
    int i = 0;

    // sprawdzamy czy znak jest ujmeny
    if (bufor[0] == '-') {
        znak = -1;  // wynik koncowy bedzie na minusie
        i++;		// przesuwamy sie nak olejny znak
        if (bufor[i] == '\0') return 0; // jak wpisano sam znak - a nie ma po nim cufr to koniec tekstu zabezpieczenie takie
    }

    // przegladamy wpisany tekst znak po znaku w petli
    for (; bufor[i] != '\0'; i++) {
        // jesli znak sie nie miesci w przeziale od 0 do 9 to znaczy ze
        // mamy kropke litere przecinek i przerywamy i blad
        if (bufor[i] < '0' || bufor[i] > '9') {
            return 0; 
        }

        // mamy limit 63 ale to dla cyfr po przecinku tutaj dalem tak na szybko zabezpieczenie przed
        // przekreceniem sie licznika, jak liczba rosnie bardzo to przerywamy
        if (wartosc > 900000000000000000LL) {
            return 0; 
        }

        // zamieniamy znak np litere '5' na cyfre 5 robimy to odejmujac od niej znak '0', bo tak dziala tabela
        // znakow ascii w C
        int cyfra = bufor[i] - '0';
        wartosc = wartosc * 10 + cyfra;
    }

	// zapisujemy gotowa liczbe we wskazanym miejscu pamietajac o przemnozeniu przez jej znak
	// i zwracamy 1 czyli komunikat ze wszystko poszlo ok
    *wynik = wartosc * znak;
    return 1; 
}

int main() {
    long long licznik, mianownik, n;

    // pobieramy
    printf("licznik:\n");
    // wywolanie funcji jak zworci 0 to blad i wylaczmay program
    if (wczytaj_liczbe(&licznik) == 0) {
        printf("Blad: Wprowadzono litery, znaki lub zbyt duza liczbe.\n");
        return 1;
    }

    // pobieramy mianownik plus walidacja
    printf("mianownik:\n");
    if (wczytaj_liczbe(&mianownik) == 0) {
        printf("Blad: Wprowadzono litery, znaki lub zbyt duza liczbe.\n");
        return 1;
    }

    // warunek dzielenie przez zero
    if (mianownik == 0) {
        printf("Blad: Dzielenie przez zero!\n");
        return 1;
    }

    // pobieramy n czyli n cyfr pop rzecinku
    printf("n:\n");
    if (wczytaj_liczbe(&n) == 0) {
        printf("Blad: Wprowadzono nieprawidlowe n.\n");
        return 1;
    }

    // zabezpieczenie by n nie bylo ujemny ani nie przekroczylo limitu co na poczatku dawalem
    if (n < 0 || n > MAX_N) {
        printf("Blad: Liczba n musi byc w przedziale od 0 do %d.\n", MAX_N);
        return 1;
    }

    // wyswietlamy userowi to co wpisal
    printf("x = %lld/%lld n = %lld\n", licznik, mianownik, n);

    // ustalamy czy wynik ma byc z minusem z przodu, wynik ujemny jak tylko jedna liczba mianownik lub licznik ujemna
    int wypisz_minus = 0;
    if ((licznik < 0 && mianownik > 0) || (licznik > 0 && mianownik < 0)) {
        wypisz_minus = 1;
    }

	// dzieki temu ze wynikowy znak mamy mozemy zamienic licznik i mianownik na zawsze dodatnie
    unsigned long long u_licznik = (licznik < 0) ? -licznik : licznik;
    unsigned long long u_mianownik = (mianownik < 0) ? -mianownik : mianownik;

    // calosc i reszta
    // wyliczamy ile pelnych calosci sie miesci w ulamku np mamy 17.5 czyli 3 
    unsigned long long czesc_calkowita = u_licznik / u_mianownik;
    // ile reszty zostalo 
    unsigned long long reszta = u_licznik % u_mianownik;

    // wypisywanie wyniku na konsoli juz
    printf("x = ");
    // doklejanie minusa jesli zapiamietalismy ze jest potrzebny
    if (wypisz_minus && u_licznik != 0) {
        printf("-");
    }
    // liczba calosci czyli to co przed kropka
    printf("%llu", czesc_calkowita);

    // jak n wieksze od zera to wykonujemy ta czesc
    if (n > 0) {
        printf(".");  // separator dziesietny
        
        // petla wykonuje sie tyle razy ile mamy cyfr po przecinku czyli n
        for (long long i = 0; i < n; i++) {
        	
        	// w sumie to jest symulacja dzielenia pisemnego, dopisujemy 0 do reszty czyli mnozymy ja przez 10
            reszta = reszta * 10;
            
            // ile razy sie mianownik miesci w powiekszonej reszcie i to daje na mejdna cyfre po przecinku
            unsigned long long cyfra = reszta / u_mianownik;
            
            // wypisujemy te wyliczona cyfre an ekran
            printf("%llu", cyfra);
            
            // ibkuczay biwa reszte z tego dzielenia i potwarzamy caly proces w petli
            reszta = reszta % u_mianownik;
        }
    }
    printf("\n");  // znak nowej linii zeby bylo estetyczne formatowanie

    return 0;
}