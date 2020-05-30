import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;
OscP5 oscServer;
NetAddress remote;

int NBANDS = 60;

void setup() {
  size(800,400);
  noStroke();
  
  PFont font = createFont("arial", 20);
  
  cp5 = new ControlP5(this);

  float marginTop = 40;
  float marginLeft = 10;
  float marginRight = 10;
  float marginBetween = 1;
  
  for (int i = 0; i < NBANDS; i++) {
    float w = (width - marginLeft - marginRight) / NBANDS - marginBetween;
    cp5.addSlider("/"+i+"/gain")
      .setRange(-12, 12)
      .setSize((int)w, height/2)
      .setPosition(marginLeft + (w + marginBetween) * i + marginBetween/2, marginTop)
      .setCaptionLabel("");
  }
  
  cp5.addTextfield("ip")
    .setPosition(5, 5)
    .setSize(80, 20)
    .setFocus(true);

  cp5.addTextfield("port")
    .setPosition(90, 5)
    .setSize(20, 20)
    .setFocus(true);
     
  textFont(font);
}

void draw() {
  background(20,50,100);

}

public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}
