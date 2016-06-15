// RFID reader ID-12 for Arduino
// Wiring - http://hcgilje.wordpress.com/resources/rfid_id12_tagreader/
// Remark: disconnect the rx serial wire to the ID-12 when uploading the sketch


void setup() {
  Serial.begin(9600);                                 // connect to the serial port
}

#define MAX_VIDEOS 24

int   keys[MAX_VIDEOS] = { 81,87,69,82,84,89,85,73,65,83,68,70,71,72,74,75,90,88,67,86,66,78,77,44 };
byte  codes [MAX_VIDEOS][5] = { 
                          
                            {0x0,0x0,0x0,0x2,0x37},  
                            {0x0,0x0,0x0,0x1,0x51},
                            {0x0,0x0,0x0,0x1,0x5F},
                            {0x0,0x0,0x0,0x1,0x0E},
                            {0x0,0x0,0x0,0x1,0x04},
                            {0x0,0x0,0x0,0x2,0x10},
                            {0x0,0x0,0x0,0x1,0x91},
                            {0x0,0x0,0x0,0x0,0xD5},
                            {0x0,0x0,0x0,0x0,0xE1},
                            {0x0,0x4E,0x33,0x88,0x13},
                            {0x0,0x78,0x1B,0x87,0x5A},
                            {0x0,0x78,0x1B,0x88,0x23},
                            {0x0,0x78,0x1B,0x87,0xDA},
                            {0x0,0x78,0x0C,0x6C,0x89},
                            {0x0,0x78,0x1B,0x87,0xDF},
                            {0x0,0x78,0x1B,0x88,0xEB},
                            {0x0,0x78,0x1B,0x87,0xEE},
                            {0x0,0x78,0x1B,0x88,0x4F},
                            {0x0,0x78,0x1B,0x87,0xA7},
                            {0x0,0x78,0x1B,0x87,0x41},
                            {0x0,0x78,0x1B,0x88,0xA7},
                            {0x0,0x78,0x1B,0x88,0x6C},
                            {0x0,0x78,0x1B,0x88,0x91},
                            {0x0,0x78,0x1B,0x87,0xF0}
                   };//Contains the IDs of the coded Tag, to add new a new one uncomment the below #define and manually add the printed ID

//#define DEBUG 

int sendVideo(byte *id){
  for(int i=0;i<MAX_VIDEOS;i++){

  if(id[0] == codes[i][0] && id[1] == codes[i][1] && id[2] == codes[i][2] && id[3] == codes[i][3] && id[4] == codes[i][4] ){
      return keys[i];
    }
  }
  return 25;
}

void loop () {
  byte i = 0;
  byte val = 0;
  byte code[6];
  byte checksum = 0;
  byte bytesread = 0;
  byte tempbyte = 0;

  if(Serial.available() > 0) {
    if((val = Serial.read()) == 2) {                  // check for header 
      bytesread = 0; 
      while (bytesread < 12) {                        // read 10 digit code + 2 digit checksum
        if( Serial.available() > 0) { 
          val = Serial.read();
          if((val == 0x0D)||(val == 0x0A)||(val == 0x03)||(val == 0x02)) { // if header or stop bytes before the 10 digit reading 
            break;                                    // stop reading
          }

          // Do Ascii/Hex conversion:
          if ((val >= '0') && (val <= '9')) {
            val = val - '0';
          } else if ((val >= 'A') && (val <= 'F')) {
            val = 10 + val - 'A';
          }

          // Every two hex-digits, add byte to code:
          if (bytesread & 1 == 1) {
            // make some space for this hex-digit by
            // shifting the previous hex-digit with 4 bits to the left:
            code[bytesread >> 1] = (val | (tempbyte << 4));

            if (bytesread >> 1 != 5) {                // If we're at the checksum byte,
              checksum ^= code[bytesread >> 1];       // Calculate the checksum... (XOR)
            };
          } else {
            tempbyte = val;                           // Store the first hex digit first...
          };

          bytesread++;                                // ready to read next digit
        } 
      } 

      // Output to Serial:

      if (bytesread == 12) {                          // if 12 digit read is complete
        //Serial.print("5-byte code: ");
#ifdef DEBUG
        for (i=0; i<5; i++) {
          if (code[i] < 16) Serial.print("0");
          Serial.print(code[i], HEX);
          Serial.print(" ");
        }

        Serial.println();
        Serial.print("Send Video: ");
#endif      
        Serial.print(sendVideo(code));
#ifdef DEBUG        
        Serial.println();
        Serial.println();

        Serial.print("Checksum: ");
        Serial.print(code[5], HEX);
        Serial.println(code[5] == checksum ? " -- passed." : " -- error.");
        Serial.println();
#endif
      }

      bytesread = 0;
    }
  }
}
