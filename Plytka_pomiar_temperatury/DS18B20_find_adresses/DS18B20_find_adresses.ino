#include <OneWire.h>
/* 
Program do Arduino sluzacy do wykrywania adresow czujnikow DB18S20
Po wgraniu programu należy włączyć Monitor portu szeregowego aby
odczytac adressy. 
Potrzebana jest bibliotek OneWire.h
Można także użyc skryptu read_adresses.py aby zapisac adresy do pliku
Wyznaczone adresy należy uwzględnić w pliku do odczytu temperatury
 */


// Numer pinu cyfrowego do którego podłaczyłęś czujniki
const byte ONEWIRE_PIN = 10;

// Stworzenie obiektu onewire
OneWire onewire(ONEWIRE_PIN);

void setup()
{
  // Otwarcie portu szeregowego
  while(!Serial);
  Serial.begin(115200);
}

void loop()
{
  // tablica z adressem
  byte address[8];
  // Wyszukowanie adresów poprzez wywołanie funkcji reset_search()
  onewire.reset_search();
  while(onewire.search(address))
  {
    // Sprawdzenie czy to czujnik DB18S20
    if (address[0] != 0x28)
      continue;

    // Sprawdzenie poprawnosci przez sume kontrolna
    if (OneWire::crc8(address, 7) != address[7])
    {
      Serial.println(F("Błędny adres, sprawdz polaczenia"));
      break;
    }

    // Wypisanie adresu
    for (byte i=0; i<8; i++)
    {
      Serial.print(F("0x"));
      Serial.print(address[i], HEX);

      if (i < 7)
        Serial.print(F(", "));
    }
    Serial.println();
  }

  while(1);
}
