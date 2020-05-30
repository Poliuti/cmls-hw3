import oscP5.*;
import netP5.*;
import controlP5.*;

import java.util.Locale;

ControlP5 cp5;
OscP5 oscServer;
NetAddress remote;

int NBANDS = 60;

EQSlider s;

void setup() {

   s = new EQSlider(-12, 12, 10);
  
  Locale.setDefault(new Locale("en", "US")); // for string formatting

  size(800,400);
  noStroke();
  
  remote = new NetAddress("localhost", 57120); // initial value, can be overridden
  oscServer = new OscP5(this, 12000);
  
  PFont font = createFont("arial", 20);
  
  cp5 = new ControlP5(this);

  float marginTop = 40;
  float marginLeft = 10;
  float marginRight = 10;
  float marginBetween = 0;
  
  /*for (int i = 0; i < NBANDS; i++) {
    float w = (width - marginLeft - marginRight) / NBANDS - marginBetween;
    cp5.addSlider("/"+i+"/gain")
      .setRange(-12, 12)
      .setSize((int)w, height/2)
      .setPosition(marginLeft + (w + marginBetween) * i + marginBetween/2, marginTop)
      .setCaptionLabel("")
      .setLabelVisible(false)
      .setSliderMode(Slider.FLEXIBLE)
      .setMoveable(false)
      .onChange(new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          Slider s = (Slider) theEvent.getController();
          OscMessage msg = new OscMessage("/eq" + s.getName(), new Object[]{ s.getValue() });
          oscServer.send(msg, remote);
          cp5.get(Textlabel.class, "gainVal").setText(String.format("%.2f dB", s.getValue()));
          println(s.getValue());
        }
      });
  }
  
  cp5.addTextfield("ip")
    .setCaptionLabel("SuperCollider ip")
    .setValue(remote.address())
    .setPosition(5, 5)
    .setSize(80, 20)
    .setFocus(true)
    .setAutoClear(false)
    .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        remote = new NetAddress(((Textfield)theEvent.getController()).getText(), remote.port());
        println(remote);
      }
    });

  cp5.addTextfield("port")
    .setCaptionLabel("port")
    .setValue(Integer.toString(remote.port()))
    .setPosition(90, 5)
    .setSize(30, 20)
    .setAutoClear(false)
    .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        remote = new NetAddress(remote.address(), Integer.parseInt(((Textfield)theEvent.getController()).getText()));
        println(remote);
      }
    });

  cp5.addTextlabel("gainVal")
    .setText("0.0 dB")
    .setFont(createFont("arial",20))
    .setPosition(width - 100, height - 30);*/

  textFont(font);
}

void draw() {
  background(20,50,100);
  s.draw();
}
