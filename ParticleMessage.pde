 
class ParticleMessage extends LabeledParticle {
   
  int id;
  color col;
  String name;
  int[] signal;
  String type;
  PImage img;
  //HashtagEntity hashtags;

  //ParticleMessage(float x, float y, String label, int id, String name, PImage img, HashtagEntity hashtags) {

  ParticleMessage(float x, float y, String label, int id, String name, PImage img) {
    super(x,y,label);
    this.id = id;
    this.name = name;
    this.col = tcol;
    this.signal = new int[hashtags.size()*2+1];
    this.img = img;
    //this.hashtags = hashtags;
  }
  
  void setSignal(int r, int s) {
    this.signal[r] = s;
    //println(s);
  }
  
  int getSignal(int r) {
    return this.signal[r];
  }
  
  void setColour(color C) {
    this.col = C;
  }
  
  void show() {
    
  }
}

 