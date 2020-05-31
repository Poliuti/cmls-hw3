import oscP5.*;
import netP5.*;
import controlP5.*;
import java.util.Locale;

int NBANDS = 60;

OscP5 oscServer;
NetAddress remote;

UIFlexbox mixer;
ControlP5 cp5;
Textfield ip, port;
Textlabel gain;

void setup() {
  
  Locale.setDefault(new Locale("en", "US")); // for string formatting

  size(800,400);
  noStroke();
  
  remote = new NetAddress("localhost", 57120); // initial value, can be overridden
  oscServer = new OscP5(this, 12000);
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Mixer Board
  
  mixer = new UIFlexbox(10, 2, Direction.HORIZONTAL);
  mixer.setPosition(0, 40).setSize(width, height/2);

  for (int i = 0; i < NBANDS; i++) {
    EQSlider s = new EQSlider(-12, 12, 5);
    s.onChange = new Callback() {
      public void action(UIElement el) {
        EQSlider sl = (EQSlider) el;
        int j = mixer.elements.indexOf(sl);
        OscMessage msg = new OscMessage("/eq/gain/" + j, new Object[]{ sl.v });
        oscServer.send(msg, remote);
        gain.setText(String.format("%.2f dB", sl.v));
        println(sl.v);
      }
    };
    mixer.elements.add(s);
  }
  
  mixer.layout();
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // IP/port and dB value
  
  cp5 = new ControlP5(this);
  PFont font = createFont("arial", 20);
  
  ip = cp5.addTextfield("ip")
    .setCaptionLabel("SuperCollider ip")
    .setValue(remote.address())
    .setPosition(5, 5)
    .setSize(80, 20)
    .setFocus(true)
    .setAutoClear(false);

  port = cp5.addTextfield("port")
    .setCaptionLabel("port")
    .setValue(Integer.toString(remote.port()))
    .setPosition(90, 5)
    .setSize(30, 20)
    .setAutoClear(false);

  gain = cp5.addTextlabel("gainVal")
    .setText("0.0 dB")
    .setFont(createFont("arial",20))
    .setPosition(width - 100, height - 30);

  textFont(font);
}

void draw() {
  background(20,50,100);
  mixer.draw();
}

void keypressed() {
  remote = new NetAddress(ip.getText(), Integer.parseInt(port.getText()));
}
