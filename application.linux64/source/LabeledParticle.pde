
class LabeledParticle extends VerletParticle2D {
   
  String label;
   
  LabeledParticle(float x, float y, String label) {
    super(x,y);
    this.label=label;
  }
}