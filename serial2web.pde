// include necessary libraries
#include <SPI.h>
#include <Ethernet.h>
#include <NewSoftSerial.h>
#include <string.h>
#include <stdio.h>

//************************** Setting Current Cost ********************************//

// define used pins for CC input
#define rxPin 3                             // floor 1
#define txPin 300                           // set write to non-existent pin (300)

NewSoftSerial currentcost(rxPin, txPin);   // set up the software serial port

// set up initial variables
char readChar = 0xFF;
int charCounter = 0;
boolean firstRun = true;
String finalValue;

//*********************** Setting Ethernet Connection  *************************//

byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x10, 0x1E };
byte ip[] = { 10,3,0,63  };
//byte gateway[] = {10,3,8,70};     
//byte subnet[] = { 255,255,252,0 };  
byte server[] = { 10,3,4,173 };  //hostname

Client client(server, 5000);    // setup connection


//******************************  Setup Stuff   ********************************//

void setup() {
  Ethernet.begin(mac, ip);     // begin ethernet
  currentcost.begin(57600);    // begin current cost
  Serial.begin(115200);        // connect to the serial port for debugging info
  delay(1000);
}

//******************************  Post Stuff   ********************************//


void postValue(String finalValue) {
   
   //char body[17] = "floor=1&value=00145";    // example string string
   char body[20];
   finalValue.toCharArray(body,20);

  if (client.connect()) {
    Serial.println("Connected...");
    
    // Make a HTTP request:
    client.println("POST /floors/updateEnergynow HTTP/1.1");
    client.println("Host: hostname");
    client.println("Content-Type: application/x-www-form-urlencoded");
    client.print("Content-Length: ");    
    client.println(sizeof(body), DEC);
    client.println();
    client.println(body);
    Serial.print("Posting: ");
    Serial.println(body);

  } 
  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println("Disconnecting...");
    client.stop();
  }
}

//******************************  Loop Stuff   ********************************//

void loop () {
  
  // current cost    ********************************************************//
  
  if (currentcost.available()) {
    char someChar = currentcost.read();
    //     Serial.print(someChar);
    if(someChar == 13) {
      charCounter = 0;
      firstRun = false;      
      Serial.println("");
      finalValue = "";
    } else {
      charCounter++; 
    }

    if (!firstRun) {
      if (charCounter == 91) {
          //Serial.print("floor=");
          //Serial.print(someChar);
          finalValue += "floor=";
          finalValue += someChar;
      } else if (charCounter == 92) {
         //Serial.print("&value="); 
         finalValue += "&value=";
      } else if (charCounter >= 141 && charCounter <= 145 ) {
         //Serial.print(someChar);
         finalValue += someChar;
         // print final string
      } else if(charCounter == 146) {
          postValue(finalValue); // string is ready
        //Serial.println(charCounter);
      }
    }
  }
  
  

 
}




