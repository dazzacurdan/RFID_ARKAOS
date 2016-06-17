import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import processing.serial.*;

KeystrokeSimulator keySim;
Robot robot;

int countLock = 0;

Serial myPort;    // The serial port
int videoID=0;  // Input string from serial port
int startTime;
int lastID = 25;

int getSerialDevice()
{
  String[] devices = Serial.list();
  for(int i=0; i < devices.length ;++i)
  {
    if( devices[i].contains("cu.usbmodem1411"))
    {
      println("Enable device: "+i);
      return i;
    }
  }
  println(".:FAILED TO INIT SERIAL:.");
  return 0;
}
 
void setup() { 
  size(640,480);

  keySim = new KeystrokeSimulator();
  myPort = new Serial(this, Serial.list()[getSerialDevice()], 9600); 
  myPort.buffer(2);
  fill(0, 102, 153);
  textSize(50);
} 
 
void draw() { 
  background(0); 
  
  if(countLock > 0)
  {
    text("Play video: " + Character.toString((char) videoID), 10,50);
    text((int)((millis()-startTime)/1e3),213,240);
  }else
  {
    text("LOOP", 10,50);
  }
  
} 
 
void serialEvent(Serial p) {
  videoID = Integer.parseInt(p.readString());
  
  if( videoID != 25 && videoID != lastID)//tag is valid
  {
    lastID = videoID;
    thread("lockFunction");
    try{
    
      keySim.simulate(videoID);
    
    }catch(AWTException e){
      println(e);
    }
  }
}

void lockFunction()
{
  int id = countLock;
  println(".:LOCK "+id+":.");
  ++countLock;
  startTime = millis();
  delay(10000);
  println(".:UNLOCK "+id+":.");
  --countLock;
  if( countLock == 0 )
  {
    println("Reset videoID and Start back ground");
    lastID = 0;
    try{
    
      keySim.simulate(KeyEvent.VK_P);
    
    }catch(AWTException e){
      println(e);
    }
  }
}