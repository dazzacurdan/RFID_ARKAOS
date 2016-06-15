import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import processing.serial.*;
import ddf.minim.*;

KeystrokeSimulator keySim;

Robot robot;
Minim minim;
AudioPlayer player;
boolean lock;

Serial myPort;    // The serial port
int videoID=0;  // Input string from serial port
int startTime;

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
  minim = new Minim(this);
  player = minim.loadFile("audio.mp3",512);
  lock = false;
  
  keySim = new KeystrokeSimulator();
  myPort = new Serial(this, Serial.list()[getSerialDevice()], 9600); 
  myPort.buffer(2);
} 
 
void draw() { 
  background(0); 
  text("Play video: " + Character.toString((char) videoID), 10,50);
  if(lock)
  {
    fill(0, 102, 153);
    textSize(150);
    text((int)((millis()-startTime)/1e3),213,240);
  }
} 
 
void serialEvent(Serial p) {
  videoID = Integer.parseInt(p.readString());
  
  if( videoID != 25 )//tag is valid
  {
    
    startTime = millis();
    if(!lock)
    {
      thread("lockFunction");
    }
  }
  
  try{
    
    keySim.simulate(videoID);
    
  }catch(AWTException e){
    println(e);
  }
}

void lockFunction()
{
  println(".:LOCK:.");
  lock = true;
  if ( player.isPlaying() )
  {
    player.pause();
  }
  int diff = startTime;
  while( diff >= 35)
  {
    diff = (int)((millis()-startTime)/1e3);
  }
  if ( !player.isPlaying() )
  {
    player.loop();
  }
  //delay(10000);
  lock = false;
  println(".:UNLOCK:.");
}