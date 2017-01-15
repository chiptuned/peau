/* 
 *  - Projet Appareil Médical Pour la Peau
 *  15 janvier 2017
 *  
 *  Le système est occupé lorsque la LED est allumée
 *  On peut modifier les valeurs d'échantillonage/balayage comme demandé
 *  Il existe des limitations (hardware, capacité du moteur) minimales de temps
 *  pour faire tourner le moteur. 
 *  On prend au minimum 1 seconde par quart de tour environ
 *  On communique à 115200 bauds.
 *  
 *  Pour calibrer, il faut rester avec le bouton appuyé lors du reset/démarrage.
 *  Le calibrage fait un demi tour en arrière du moteur
 */
 
// Ici on définit les pins
#define IN1  7
#define IN2  6
#define IN3  5
#define IN4  4
#define IN_VOLTAGE A0
#define IN_BUTTON 3
#define LED 13

// Ici on définit les variables d'échantillonage/balayage
int angle = 110;
uint32_t time_scanning_millis = 1500;
uint32_t pause_scanning_millis = 400;
double angular_resolution = 0.5;
int analog_res = 10;
int nb_scans = 1;

// Initialisation des valeurs
short curr_step_motor;
int position_motor;
boolean direction_motor;
int steps_scan;
int time_each_step;
int step_res_measure;

// Démarrage de l'application
void setup(){
  pinMode(LED, OUTPUT);
  digitalWrite(LED, HIGH);
  Serial.begin(115200);
  pinMode(IN_BUTTON, INPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  //analogReadResolution(analog_res) // IF TEENSY
  delay(100);
  steps_scan = double(angle)*4096/360;
  time_each_step = time_scanning_millis*1000/steps_scan;
  step_res_measure = steps_scan/(angular_resolution*angle);
  if(digitalRead(IN_BUTTON)){
    calibrate();
  }
  curr_step_motor = 0;
  position_motor = 0;
  direction_motor = 1;
  digitalWrite(LED, LOW);
}

// Boucle
void loop()
{
  if(digitalRead(IN_BUTTON)){
    digitalWrite(LED, HIGH);
    stepper(steps_scan);
    digitalWrite(LED, LOW);
  }
}

// Fonction effectuant le balayage demandé
void stepper(int xw){
  int nb_mesures;
  int cpt_demi_scan = 0;
  send_format_info();
  delay(pause_scanning_millis);
  while(cpt_demi_scan < 2*nb_scans){
    nb_mesures = 0;
    cpt_demi_scan++;
    for (int x=0;x<xw;x++){
      set_output();
      if(position_motor%step_res_measure==0 && nb_mesures<(angle*angular_resolution)){
        nb_mesures ++;
        Serial.print(micros());
        Serial.print(' ');
        Serial.print(position_motor);
        Serial.print(' ');
        Serial.println(analogRead(IN_VOLTAGE));
      }
    }
    delay(pause_scanning_millis);
    direction_motor=!direction_motor;
  }
}

// Fonction effectuant un step du moteur
void set_output(){
  uint32_t t_start;
  t_start = micros();
  switch(curr_step_motor){
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
  if(direction_motor==1){
    curr_step_motor++;
    position_motor++;
  }
  if(direction_motor==0){
    curr_step_motor--;
    position_motor--;
  }
  if(curr_step_motor>7){curr_step_motor=0;}
  if(curr_step_motor<0){curr_step_motor=7;}
  delayMicroseconds(time_each_step-micros()+t_start);
}

// Fonction envoyant les variables d'échantillonage/balayage dans le port série
void send_format_info(){
  Serial.print(angle);
  Serial.print(' ');
  Serial.print(time_scanning_millis);
  Serial.print(' ');
  Serial.print(pause_scanning_millis);
  Serial.print(' ');
  Serial.print(angular_resolution);
  Serial.print(' ');
  Serial.print(analog_res);
  Serial.print(' ');
  Serial.println(nb_scans);
}

// Fonction pour calibrer
void calibrate(){
  direction_motor = 0;
  for (int x=0;x<2000;x++){
    set_output();
  }
}
