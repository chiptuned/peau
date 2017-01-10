void setup() {
  // open a serial connection
  Serial.begin(9600); 
  analogReadResolution(16);
}

void loop() {
  // and send it out the serial connection 
  Serial.println(analogRead(A0));
  delay(8);
}
