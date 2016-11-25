void getTweets(){
  tweets = new ArrayList(); 
  //NUM_TWEETS
  for (int i = 0; i < NUM_TWEETS; ++i) {

    //String[] pieces = split(t[i], ',');
    //println(pieces);

    // tag/people format
    // id, label, name
    // 1,04012D,unknown,R,G,B

    int id = i;
    String label = str(i);
    String name = str(i);
    color tagcol = tcol;

    ParticleMessage message = new ParticleMessage(random(width), random(height), label, id, name, tweets_pictures.get(i));
    message.col=tagcol;
    physics.addParticle(message);
    physics.addBehavior(new AttractionBehavior(message, MESSAGE_W, -0.1f, 0.00f));  // add repulsive force 
    tweets.add(message);
        
  }

}

void getHashtags(String rFile){
  hashtags = new ArrayList(); 
  String[] r = loadStrings(rFile);

  int number = r.length;
  println((number) + " hashtags.");
  
  for (int i = 0; i < NUM_HASHTAGS; ++i) {

    String[] pieces = split(r[i], ',');
    if (debug) println(pieces);
   
    // hashtags format
    // id, label,   location,  x,  y,  z 
    // 1 ,042A6F,living room,100,100,  0
   
    int id = int(pieces[0]);
    String label = pieces[1];
    String location = pieces[2];
    int x = int(pieces[3]);
    int y = int(pieces[4]); // 5,6,7,8,
    color readcol = color(int(pieces[9]),int(pieces[10]),int(pieces[11]));
  
    ParticleHashtag hashtag=new ParticleHashtag(x, y, label, id, location);
    hashtag.col = readcol;
    //hashtag.lock(); // lock the particle in its place
    physics.addParticle(hashtag);
    AttractionBehavior a = new AttractionBehavior(hashtag, width/3, 0.1f, 0.00f);
    physics.addBehavior(a); 
    hashtags.add(hashtag);
        
  }

}

//void getPlaces(String rFile) {
//  String[] r = loadStrings(rFile);

//  int number = r.length;
//  println((number) + " places");

//  places = new ArrayList(); 

//  for (int i = 0; i < number; ++i) {

//    String[] pieces = split(r[i], ',');
//    println(pieces);
   
//    // reader/places format
//    // id, label,   location,  x,  y,  z 
//    // 1 ,042A6F,living room,100,100,  0
   
//    int id = int(pieces[0]);
//    String label = pieces[1];
//    String location = pieces[2];
//    int x = int(pieces[3]);
//    int y = int(pieces[4]); // 5,6,7,8,
//    color readcol = color(int(pieces[9]),int(pieces[10]),int(pieces[11]));

//    ParticleHashtag reader=new ParticleHashtag(x, y, label, id, location);
//    reader.col = readcol;
//    reader.lock(); // lock the particle in its place
//    physics.addParticle(reader);
//    AttractionBehavior a = new AttractionBehavior(reader, width/3, 0.0f, 0.01f);
//    physics.addBehavior(a);  
//    places.add(reader);
        
//  }
//}

//void getPeople(String tFile) {
//  String[] t = loadStrings(tFile);

//  int number = t.length;
//  println((number) + " people");

//  people = new ArrayList(); 
   

//  for (int i = 0; i < number; ++i) {

//    String[] pieces = split(t[i], ',');
//    println(pieces);

//    // tag/people format
//    // id, label, name
//    // 1,04012D,unknown,R,G,B

//    int id = int(pieces[0]);
//    String label = pieces[1];
//    String name = pieces[2];
//    color tagcol = color(int(pieces[3]),int(pieces[4]),int(pieces[5]));

//    ParticleMessage tag=new ParticleMessage(random(width), random(height), label, id, name);
//    tag.col=tagcol;
//    physics.addParticle(tag);
//    physics.addBehavior(new AttractionBehavior(tag, 100, -1.5f, 0.01f));  // add repulsive force 
//    people.add(tag);
        
//  }
  
//}

long findReader(ArrayList readers_list, String name) {
  int res = -1;
  for (int i=0; i < readers_list.size(); i++) {
    ParticleHashtag r = (ParticleHashtag) readers_list.get(i);
    if (r.label.equals(name)) {
      res = i;      
    }
  }
  return(res);
}

long findTag(ArrayList tags_list, String name) {
  int res = -1;
  for (int i=0; i < tags_list.size(); i++) {
    ParticleMessage t = (ParticleMessage) tags_list.get(i);
    if (t.label.equals(name)) {
      res = i;      
    }
  }
  return(res);
}

//void addPeople() {
//  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(width/2, width/2));
//  physics.addParticle(p);
//  p.setWeight(1000);
//  AttractionBehavior pb = new AttractionBehavior(p, 100, -0.1f, 0.5f);
//  physics.addBehavior(pb);
//  attractors_people.add(pb);
//}

//void addPlace(int x, int y) {
//  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(width/2, width/2));
//  physics.addParticle(p);
//  AttractionBehavior pb = new AttractionBehavior(p, 200, 0.0f, 0.5f);
//  physics.addBehavior(pb);
//  attractors_places.add(pb);
//}

void addDot(int x, int y) {
  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(x, y));
  physics.addParticle(p);
  physics.addBehavior(new AttractionBehavior(p, 10, -0.1f, 0.00f));
}