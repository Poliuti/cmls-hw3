import oscP5.*;
import netP5.*;
import controlP5.*;
import java.util.Locale;

int NBANDS = 30;
int NPANS  = 3;

OscP5 oscServer;
NetAddress remote;

Mixer mixer;
UIStack panners;
UIGroup guiroot;

ControlP5 cp5;
Textfield ip, port;
Textlabel curVal;


void setup() {
  
  Locale.setDefault(new Locale("en", "US")); // for string formatting (dot for decimal separator)

  size(800,400);
  noStroke();
  
  cp5 = new ControlP5(this);
  guiroot = new UIGroup();
  
  remote = new NetAddress("localhost", 57120); // initial value, can be overridden in the gui
  oscServer = new OscP5(this, 12000);  // Processing OSC server

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
        float val = sl.getValue();
        OscMessage msg = new OscMessage("/eq/gain/" + j, new Object[]{ val });
        oscServer.send(msg, remote);
        curVal
          .setText(String.format("%.2f dB", val))
          .setPosition(width - 120, 8);
        //println(String.format("gain%d: %.6f", j, val));
      }
    };
    mixer.elements.add(s);
  }
  
  mixer.layout();
  
  guiroot.elements.add(mixer);
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Panning Board
  panners = new UIStack(10, 30, Direction.HORIZONTAL);
  
  for (int i = 0; i < NPANS; i++) {
    PanSlider d = new PanSlider(-1, 1, 3, 25);
    d.setSize(150, 150);
    d.onChange = new Callback() {
      public void action(UIElement el) {
        PanSlider de = (PanSlider) el;
        int j = panners.elements.indexOf(de);
        float[] val = de.getValue();
        OscMessage msg = new OscMessage("/eq/pan/" + j, new Object[]{ val[0], val[1] });
        oscServer.send(msg, remote);
        curVal
          .setText(String.format("%.2f / %.2f", val[0], val[1]))
          .setPosition(width - 150, 8);
        //println(String.format("pan%d: %.6f / %.6f", j, val[0], val[1]));
      }
    };
    panners.elements.add(d);
  }
  
  panners.layout(); // layout first to update stack size
  panners.setPosition(width/2 - panners.w/2, height - panners.h);
  panners.layout(); // layout again to re-position children elements
  guiroot.elements.add(panners);
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Other labels and textboxes using ControlP5
  
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

  curVal = cp5.addTextlabel("curVal")
    .setText("")
    .setFont(createFont("comfortaa bold",25));
    
  cp5.addBang("reset")
    .setPosition(10, height - 40)
    .onClick(new CallbackListener() {
       public void controlEvent(CallbackEvent evt) {
         resetAll();
       }
    });
  
  surface.setTitle("");
  
  cp5.addTextlabel("title")
    .setText("spacEq")
    .setFont(createFont("radio space bold", 32))
    .setPosition(width/2 - 70, 4);

}

void draw() {
  background(20,50,100);
  guiroot.draw();
}


// Receive OSC messages to update meters
void oscEvent(OscMessage msg) {
  if (msg.addrPattern().indexOf("/gui/volumes/") == 0) {
    String[] path = msg.addrPattern().split("/");  // gui, volumes, i
    int i = Integer.parseInt(path[path.length-1]); // ←------------ ↑
    Float val = (Float) msg.arguments()[0];
    //println(String.format("meter%d: %.3f", i, val));
    ((EQSlider)mixer.elements.get(i)).setMeter(val);
  }
}

// for typing on text boxes
void keyReleased() {
  remote = new NetAddress(ip.getText(), Integer.parseInt(port.getText()));
  println(remote);
}

// for resetting sliders
void mouseClicked(MouseEvent evt) {
  resetSlider(evt, false);
}

void resetAll() {
  resetSlider(null, true);
  curVal.setText("");
}

void resetSlider(MouseEvent evt, boolean all) {
  for (UIElement e : mixer.elements) {
    EQSlider s = (EQSlider) e;
    if (all || evt.getCount() == 2 && s.isOver())
      s.setValue(0);
  }
  for (UIElement e : panners.elements) {
    PanSlider s = (PanSlider) e;
    if (all || evt.getCount() == 2 && s.isOver())
      s.setValue(0, 0);
  }
}
