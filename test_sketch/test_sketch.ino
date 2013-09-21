
int pins[] = {0, 1, 2, 3, 4, 5, 6, 7, A0, A1, A2, A3};

void setup() {
  for (int i = 0; i < 12; i++) {
    pinMode(pins[i], INPUT);
    digitalWrite(pins[i], LOW);
  }
  // pinMode(0, OUTPUT);
  // pinMode(1, OUTPUT);
  // digitalWrite(0, HIGH);
  // on(3, 1);
}



void on(int high, int low) {
  digitalWrite(pins[high], LOW);
  digitalWrite(pins[low], LOW);
  pinMode(pins[high], OUTPUT);
  pinMode(pins[low], OUTPUT);
  digitalWrite(pins[high], HIGH);
}

void off(int high, int low) {
  digitalWrite(pins[high], LOW);
  digitalWrite(pins[low], LOW);
  pinMode(pins[high], INPUT);
  pinMode(pins[low], INPUT);
}


void loop() {
  for (int high = 0; high < 12; high++) {
    for (int low = high+1; low < 12; low++) {
      on(high, low);
      // delay(1);
      off(high, low);
      on(low, high);
      // delay(1);
      off(low, high);
    }
  }

}