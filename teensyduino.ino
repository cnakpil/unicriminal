// Intended for use with a Teensy LC 
// Should be compatible with any microcontroller w/ digital read.

#include <Bounce2.h>

// Setup Bounce objects to debounce signal for a 15ms interval
int ms = 15;
Bounce left1 = Bounce(15, ms);
Bounce left2 = Bounce(16, ms);
Bounce right1 = Bounce(17, ms);
Bounce right2 = Bounce(18, ms);
Bounce x = Bounce(19, ms);

void setup() {
  // Start serial
  Serial.begin(9600);

  // Set pinmodes
  // HIGH=1, LOW=0
  pinMode(15, INPUT_PULLUP);
  pinMode(16, INPUT_PULLUP);
  pinMode(17, INPUT_PULLUP);
  pinMode(18, INPUT_PULLUP);
  pinMode(19, INPUT_PULLUP);
}

void loop() {
  // Check for debounce status
  left1.update();
  left2.update();
  right1.update();
  right2.update();
  x.update();

  // If state of input has changed, press correct button
  if(left1.changed()){
    int left1_db = left1.read();
    if(left1_db==0)
      Serial.println("left1");
  }
  if(left2.changed()){
    int left2_db = left2.read();
    if(left2_db==0)
      Serial.println("left2");
  }
  if(right1.changed()){
    int right1_db = right1.read();
    if(right1_db==0)
      Serial.println("right1");
  }
  if(right2.changed()){
    int right2_db = right2.read();
    if(right2_db==0)
      Serial.println("right2");
  }
  if(x.changed()){
    int x_db = x.read();
    if(x_db==0)
      Serial.println("x");
  }
}

