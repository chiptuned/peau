#define IN1  7
#define IN2  6
#define IN3  5
#define IN4  4
float angle(0);
int Steps = 0;
boolean Direction = true;// gre
unsigned long last_time;
unsigned long currentMillis;
int angle_calc;
int steps_left=4095;
long time;
void setup()
{
Serial.begin(115200);
pinMode(IN1, OUTPUT);
pinMode(IN2, OUTPUT);
pinMode(IN3, OUTPUT);
pinMode(IN4, OUTPUT);
delay(1000);

}
void loop()
{
  Serial.print(steps_left);
  Serial.println("....");
  while(steps_left>0){
  currentMillis = micros();
  if(currentMillis-last_time>=1000){
  stepper(1);
  time=time+micros()-last_time;
  last_time=micros();
  steps_left--;
  if (Direction){
    angle_calc = 4095-steps_left;
  }else{
    angle_calc = steps_left;
  }
  angle=(float(angle_calc)/64)*5.625;
  Serial.println(angle);
  }
  }
   //Serial.println(time);
  //Serial.println("Wait...!");
  delay(1000);
  Direction=!Direction;
  steps_left=4095;

}

void stepper(int xw){
  for (int x=0;x<xw;x++){
switch(Steps){
   case 0:
     digitalWrite(IN1, LOW);
     digitalWrite(IN2, LOW);
     digitalWrite(IN3, LOW);
     digitalWrite(IN4, HIGH);
   break;
   case 1:
     digitalWrite(IN1, LOW);
     digitalWrite(IN2, LOW);
     digitalWrite(IN3, HIGH);
     digitalWrite(IN4, HIGH);
   break;
   case 2:
     digitalWrite(IN1, LOW);
     digitalWrite(IN2, LOW);
     digitalWrite(IN3, HIGH);
     digitalWrite(IN4, LOW);
   break;
   case 3:
     digitalWrite(IN1, LOW);
     digitalWrite(IN2, HIGH);
     digitalWrite(IN3, HIGH);
     digitalWrite(IN4, LOW);
   break;
   case 4:
     digitalWrite(IN1, LOW);
     digitalWrite(IN2, HIGH);
     digitalWrite(IN3, LOW);
     digitalWrite(IN4, LOW);
   break;
   case 5:
     digitalWrite(IN1, HIGH);
     digitalWrite(IN2, HIGH);
     digitalWrite(IN3, LOW);
     digitalWrite(IN4, LOW);
   break;
     case 6:
     digitalWrite(IN1, HIGH);
     digitalWrite(IN2, LOW);
     digitalWrite(IN3, LOW);
     digitalWrite(IN4, LOW);
   break;
   case 7:
     digitalWrite(IN1, HIGH);
     digitalWrite(IN2, LOW);
     digitalWrite(IN3, LOW);
     digitalWrite(IN4, HIGH);
   break;
   default:
     digitalWrite(IN1, LOW);
     digitalWrite(IN2, LOW);
     digitalWrite(IN3, LOW);
     digitalWrite(IN4, LOW);
   break;
}
SetDirection();
}
}
void SetDirection(){
if(Direction==1){ Steps++;}
if(Direction==0){ Steps--; }
if(Steps>7){Steps=0;}
if(Steps<0){Steps=7; }
}
