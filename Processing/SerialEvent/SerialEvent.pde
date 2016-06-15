import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import processing.serial.*;

KeystrokeSimulator keySim;

Robot robot; 
import processing.serial.*; 
 
Serial myPort;    // The serial port
int videoID=0;  // Input string from serial port

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
  size(400,200); 
  keySim = new KeystrokeSimulator();
  myPort = new Serial(this, Serial.list()[getSerialDevice()], 9600); 
  myPort.buffer(2);
} 
 
void draw() { 
  background(0); 
  text("Play video: " + Character.toString((char) videoID), 10,50);
} 
 
void serialEvent(Serial p) {
  try{
    
    videoID = Integer.parseInt(p.readString());
    keySim.simulate(videoID);
    
  }catch(AWTException e){
    println(e);
  }
}