import oscP5.*;
import netP5.*;
import controlP5.*;
import java.util.Locale;

int NBANDS = 30;

OscP5 oscServer;
NetAddress remote;

Mixer mixer;
ControlP5 cp5;
Textfield ip, port;
Textlabel gain;
DraggingEllipse cerchio;


void setup() {
  
  Locale.setDefault(new Locale("en", "US")); // for string formatting

  size(800,400);
  noStroke();
  
  remote = new NetAddress("localhost", 57120); // initial value, can be overridden
  oscServer = new OscP5(this, 12000);

  cerchio= new DraggingEllipse(400,318);

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Mixer Board
  
  mixer = new Mixer(10, 2);
  mixer.setPosition(0, 40).setSize(width, height/2);

  for (int i = 0; i < NBANDS; i++) {
    EQSlider s = new EQSlider(-12, 12, 3, 5);
    s.onChange = new Callback() {
      public void action(UIElement el) {
        EQSlider sl = (EQSlider) el;
        int j = mixer.elements.indexOf(sl);
        OscMessage msg = new OscMessage("/eq/gain/" + j, new Object[]{ sl.v });
        oscServer.send(msg, remote);
        gain.setText(String.format("%.2f dB", sl.v));
        println(j + ": " + sl.v);
      }
    };
    mixer.elements.add(s);
  }
  
  mixer.layout();
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // IP/port and dB value
  
  cp5 = new ControlP5(this);
  PFont font = createFont("arial", 20);
  textFont(font);
  
  ip = cp5.addTextfield("ip")
    .setCaptionLabel("SuperCollider ip")
    .setValue(remote.address())
    .setPosition(10, 8)
    .setSize(80, 20)
    .setFocus(true)
    .setAutoClear(false);

  port = cp5.addTextfield("port")
    .setCaptionLabel("port")
    .setValue(Integer.toString(remote.port()))
    .setPosition(95, 8)
    .setSize(30, 20)
    .setAutoClear(false);

  gain = cp5.addTextlabel("gainVal")
    .setText("0.0 dB")
    .setFont(createFont("arial",25))
    .setPosition(width - 120, height - 30);

}

void draw() {
  background(20,50,100);
  mixer.draw();
  stroke(10);
  fill(205);
  //rectMode(CENTER);
  rect(325,243,150,150);
  fill(204, 102, 0);
  cerchio.draw();
}

void keyReleased() {
  remote = new NetAddress(ip.getText(), Integer.parseInt(port.getText()));
  println(remote);
}

void mouseClicked(MouseEvent evt) {
  for (UIElement e : mixer.elements) {
    EQSlider s = (EQSlider) e;
    if (evt.getCount() == 2 && s.isOver())
      s.setValue(0);
  }
}
