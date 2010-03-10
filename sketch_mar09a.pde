/*
/////////////////////////////////
Htachi H48C3 Axis Accelerometer
parallax (#28026)

AUTHOR:   kiilo ki...@kiilo.org
License:  http://creativecommons.org/licenses/by-nc-sa/2.5/ch/

http://parallax.com/Store/Microcontrollers/BASICStampModules/tabid/13...
http://sage.medienkunst.ch/tiki-index.php?page=HowTo_Arduino_Parallax...
http://arduino.cc

/////////////////////////////////
*/

#include <Servo.h>

//// VARS
int CS_pin = 7;
int CLK_pin = 6;
int DIO_pin = 5;

int aX  = 0;
int aY  = 0;
int aZ  = 0;
int aX_old = 0;
int aY_old = 0;

long mXVal = 90;
long mYVal = 90;
Servo motorX;
Servo motorY;

float Kp = 0.1;
float Kd = 0.01;

//// FUNCTIONS
void StartBit() {
  pinMode(DIO_pin, OUTPUT);
  digitalWrite(CS_pin, LOW);
  digitalWrite(CLK_pin, LOW);
  delayMicroseconds(1);
  digitalWrite(DIO_pin, HIGH);
  digitalWrite(CLK_pin, HIGH);
  delayMicroseconds(1);

  }

void ShiftOutNibble(byte DataOutNibble) {
  for(int i = 3; i >= 0; i--) { // i = 3 ... 2 ... 1 ... 0
    digitalWrite(CLK_pin, LOW);
    // set DIO first
    if ((DataOutNibble & (1 << i)) == (1 << i)) {  // DataOutNibble AND 1 x 2^i Equals 1 x 2^i ?
      digitalWrite(DIO_pin, HIGH);
      }
    else {
      digitalWrite(DIO_pin, LOW);
      }
    // with CLK rising edge the chip reads the DIO from arduino in
    digitalWrite(CLK_pin, HIGH);
    // data rate is f_clk 2.0 Mhz --> 0,5 micro seeconds
    delayMicroseconds(1); // :-) just nothing
  }

}

void SampleIt() {
  digitalWrite(CLK_pin, LOW);
  delayMicroseconds(1);
  digitalWrite(CLK_pin, HIGH);
  delayMicroseconds(1);

  pinMode(DIO_pin, INPUT);
  digitalWrite(CLK_pin, LOW);
  delayMicroseconds(1);
  digitalWrite(CLK_pin, HIGH);
  if (digitalRead(DIO_pin)== LOW) {
    // Blink LED because ok
    }

}

byte ShiftInNibble() {
  byte resultNibble;
  resultNibble = 0;

    for(int i = 3 ; i >= 0; i--) { // from bit 3 to 0
      // The chip Shift out results on falling CLK
      digitalWrite(CLK_pin, LOW);
      delayMicroseconds(1); // :-) just nothing
      if( digitalRead(DIO_pin) == HIGH) { // BIT set or not?
        resultNibble += 1 << i; // Store 1 x 2^i in our ResultNibble
      }
      else {
        resultNibble += 0 << i; // YES this is alway 0, just for symetry ;-)
      }
      digitalWrite(CLK_pin, HIGH);
      //delayMicroseconds(1); // :-) just nothing
    }
return resultNibble;

}

void EndBit() {
  digitalWrite(CS_pin, HIGH);
  digitalWrite(CLK_pin, HIGH);

}

int GetValue(byte Command) { // x = B1000, y = B1001, z = B1010
  int Result = 0;
  StartBit();
  ShiftOutNibble(Command);
  SampleIt();
  Result =  2048 - ((ShiftInNibble() << 8) + (ShiftInNibble() << 4) +
ShiftInNibble());
  EndBit();

  return Result;
  }

//// SETUP


void setup() {
  Serial.begin(115200);
  pinMode(CS_pin, OUTPUT);
  pinMode(CLK_pin, OUTPUT);
  pinMode(DIO_pin, OUTPUT);

  // initialize device & reset
  digitalWrite(CS_pin,LOW);
  digitalWrite(CLK_pin,LOW);
  delayMicroseconds(1);
  digitalWrite(CS_pin, HIGH);
  digitalWrite(CLK_pin,HIGH);

  motorX.attach(9);
  motorY.attach(10);

}

//// LOOP
void loop() {


  
  
  aX = GetValue(B1000);
  aY = GetValue(B1001);
  aZ = GetValue(B1010);

//PID

  

  //mXVal = (long)(aX+512)*180/1024;
  mXVal += Kp * aX + Kd * (aX - aX_old);
  //mYVal = (long)(aY+512)*180/1024;
  mYVal += Kp * aY + Kd * (aY - aY_old);
  
  aX_old = aX;
  aY_old = aY;
  
  if (mXVal > 180) 
    mXVal = 180;
  if (mXVal < 0)
    mXVal = 0;
  if (mYVal > 180) 
    mYVal = 180;
  if (mYVal < 0)
    mYVal = 0;
  
  motorX.write( mXVal );
  motorY.write( mYVal );

  //Serial.print(aX);
  Serial.print("mXVal = ");
  Serial.print( mXVal );
  Serial.print("\t");
  Serial.print("mYVal = ");
  Serial.print( mYVal );
  
  
  //Serial.print(aY);
//  Serial.print(" ");
//  Serial.print(aZ);
  Serial.println("");
  delay(100);  // loop every 10 times per sec.


} 
