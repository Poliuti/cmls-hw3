class DraggingEllipse
{
  int x;
  int y;
  int h;
  int wi;
  float d = dist(mouseX,mouseY,this.x,this.y);
  boolean clicked;
  public DraggingEllipse(int posx, int posy){
      x=posx;
      y=posy;
      h=30;
      wi=30;

  }
  public void draw(){
    fill(299,209,46);
    stroke(0);
    ellipse(x,y,h,wi);
  }
 
 
   public void mouseDragged(){ 
     if (d<h/2){
    x=mouseX;
    y=mouseY;
     }
}}
