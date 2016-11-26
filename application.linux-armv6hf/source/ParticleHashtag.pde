 
class ParticleHashtag extends LabeledParticle {
   
  int id;
  color col;
  String location;
  AttractionBehavior attraction;
   
  ParticleHashtag(float x, float y, String label, int id, String location) {
    super(x,y,label);
    this.id=id;
    this.location=location;
    this.col = rcol;
    this.attraction = attraction;
  }
  
  void setAttraction(AttractionBehavior attraction) {
    this.attraction = attraction;
  }
  
  void setColour(color C) {
    this.col = C;
  }
  
}

 