import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import toxi.geom.*; 
import toxi.physics2d.*; 
import toxi.physics2d.behaviors.*; 
import processing.serial.*; 
import java.util.List; 
import java.util.Iterator; 
import twitter4j.conf.*; 
import twitter4j.*; 
import twitter4j.auth.*; 
import twitter4j.api.*; 
import java.util.*; 

import twitter4j.*; 
import twitter4j.api.*; 
import twitter4j.auth.*; 
import twitter4j.conf.*; 
import twitter4j.json.*; 
import twitter4j.management.*; 
import twitter4j.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class fear_and_love extends PApplet {

// Love and Fear 2016  - an interactive visualisation for the Design Museum
// 2016-10-16 francesco.anselmo@arup.com
// http://lightlab.arup.com















//String fearSearchString = "source:aruplightlab fear";
//String loveSearchString = "source:aruplightlab love";

//String fearSearchString = "fear";
//String loveSearchString = "%23love";

int NUM_TWEETS = 500;  // number of big particles associated with messages
int NUM_HASHTAGS = 2;  // number of invisible particles associated with hashtags, acting as attractors
int NUM_DOTS = 1200; // number of small particles used to visualise the force field
//int MESSAGE_SIZE = 150; // pixel size of floating messages
//int MESSAGE_SCALE = 7;
int MESSAGE_W = 200;
int MESSAGE_H = 150;

int tweets_n = 0;

//boolean showFullscreen = true;   // switch to turn fullscreen on or off
boolean demo = true;         // switch to use signals from Synapse RF100 physical devices (false) or demo signals (true)
boolean debug = false;       // switch to display debug information on the screen 
boolean showLabels = true;  // switch to display particle labels
boolean doReset = true;      // switch to enable reset
boolean showLogo = false;    // show logo

float reset_time = 20;  // update time in seconds for reset - at reset time a central attractor is created
float smooth_time = 10;  // smoothing time in seconds - actuates an attraction behaviour if proximity is detected

float tweets_time = 30;

int bgcol = color(0, 0, 0);       // background colour
int lcol = color(200, 200, 255);  // line colour
int tcol = color(255,255,255);    // tweets colour
int rcol = color(90, 50, 10);     // hashtags colour

VerletPhysics2D physics;

PImage logo;

ArrayList tweets;
ArrayList hashtags;
ArrayList attractors_tweets;
ArrayList attractors_hashtags;
ArrayList springs_tweets;


int[][] signal;

PFont font;
PFont fontsmall;
PFont fontextrasmall;

//String peopleFile = "people.csv"; // edit this file inside the data folder to name and colour the people particles
//String placesFile = "places.csv"; // edit this file inside the data folder to name and locate the places particles

String hashtagsFile = "hashtags.csv";

Serial myPort;
String inString;  // input string from serial port 
int lf = 10;      // ASCII linefeed
float current_time;
float previous_time;
float current_smooth_time;
float previous_smooth_time;
float current_tweets_time;
float previous_tweets_time;


int time = 0;

Vec2D mousePos;
AttractionBehavior mouseAttractor;
AttractionBehavior centreAttractor;
AttractionBehavior Attractor1;
AttractionBehavior Attractor2;
AttractionBehavior Attractor3;
AttractionBehavior Attractor4;

Twitter twitter;
List<Status> fear_tweets;
List<Status> love_tweets;
List<Status> home_tweets;
List<Status> all_tweets;

ArrayList<String> all_hashtags = new ArrayList(); 
ArrayList<String> other_hashtags = new ArrayList(); 


ArrayList<PImage> fear_pictures = new ArrayList();
ArrayList<PImage> love_pictures = new ArrayList();
ArrayList<PImage> home_pictures = new ArrayList();
ArrayList<PImage> tweets_pictures = new ArrayList();
int currentFearTweet;
int currentLoveTweet;
int currentHomeTweet;
//ArrayList<String> tWords = new ArrayList();

int fear_color = color(0,255,0);
int love_color = color(255,0,255);
int home_color = color(255,255,255);

String imgTemp = null;

public void setup() {
  //size(1280, 1024);
  
  noCursor();
  
  //if (showFullscreen) {fullScreen();}
  //else {size(displayWidth, displayHeight);}
  logo = loadImage("ArupLogo2010_w.png");
  
  // twitter stuff
  ConfigurationBuilder cb = new ConfigurationBuilder();
  /*
  cb.setOAuthConsumerKey("tjkuTdwPXGZ3iSEFvqiQonVtE");
  cb.setOAuthConsumerSecret("jexA6felupzws9rQKUHmFClr2POdn7BDQ0Ay87S8G6bviEgKhd");
  cb.setOAuthAccessToken("2882966836-0Zp60El0zAkzHUIq132dqvJKqujRtvEBjbPOHWS");
  cb.setOAuthAccessTokenSecret("VB9sxqQUKqx4C5Fy7KdSVewGi5wJcW1TVZov7Sms8UuQi");
  */
  
  cb.setOAuthConsumerKey("8gwWMe6zG63lqmwYZaRUibf0a");
  cb.setOAuthConsumerSecret("Ibnnj7wjAwgiltf903iPJDiMxSzeREmCQURN7XnCTN9D1s96VV");
  cb.setOAuthAccessToken("793523469535350784-uYIBol8DMbNWdww3rRxs6oPNQ7dvh7u");
  cb.setOAuthAccessTokenSecret("cVzj7Klp8xCJphANaDO7PZoosi44UOUJjqHnNy9QfYiqr");
  
  
  TwitterFactory tf = new TwitterFactory(cb.build());
  twitter = tf.getInstance();
  
  currentFearTweet = 0;
  currentLoveTweet = 0;
  //thread("refreshTweets");

  // populate tweet pictures list
  for (int i=0; i<NUM_TWEETS;i++) {
    PImage img = createImage(100, 100, RGB);
    fear_pictures.add(img);
    love_pictures.add(img);
    home_pictures.add(img);
    tweets_pictures.add(img);
    //HashtagEntity h = new HashtagEntity();
    all_hashtags.add("");
    other_hashtags.add("");
  }
  //println(tweets_pictures.size());


  // physics stuff
  initPhysicsTest();

  signal = new int[hashtags.size()][tweets.size()];

  font = loadFont("SansSerif-48.vlw");
  fontsmall = loadFont("SansSerif-24.vlw");
  fontextrasmall = loadFont("SansSerif-12.vlw");
  textFont(font);

  // the Synapse system is not used for this installation, but keeping some legacy code in here just in case ...
  // if not in demo mode, the Synapse USB module is connected using the serial library
  if (!demo) {
    println(Serial.list()); // list all the available serial ports 
    //myPort = new Serial(this, Serial.list()[0], 9600); // comment out this line of code to take the first port in the serial list
    myPort = new Serial(this, "/dev/cu.SLAB_USBtoUART", 9600); // change the port to the one the Synapse USB module is connected to
    myPort.bufferUntil(lf);
  }

  current_time = millis();
  current_smooth_time = millis();
  

  // create the floating dots
  for (int i=0; i<NUM_DOTS; i++) {
    addDot(width/2, height/2);
  }
  
  
  getNewTweets();
  
}

public void draw() {
  current_time = millis();
  current_smooth_time = millis();
  current_tweets_time = millis();
  background(bgcol);
  
  tint(255, 255/4);  // display the Arup logo at 1/4 opacity
  //if (showLogo) image(logo, width/2-logo.width/2, height/2-logo.height/2);
  if (showLogo) image(logo, width/2-logo.width/2, height-logo.height-10);
  tint(255, 255);
  
  physics.update();    // update the toxiclibs particle system

  // draw springs
  for (VerletSpring2D s : physics.springs) {
    //print(s);
    stroke(255,255,255);
    strokeWeight(1);
    line(s.a.x,s.a.y,s.b.x,s.b.y);
  }

  //stroke(255, 255, 255);
  noStroke();

  // draw particles
  int j=0;
  for (VerletParticle2D p : physics.particles) {
    //ParticleMessage lp=(ParticleMessage)p;
    if (j<NUM_HASHTAGS) {
      // particles are messages, hashtags and particles dust
      // don't draw hashtags yet
      //fill(255,0,0);
      //ellipse(p.x, p.y, 30, 30);
    } 
    else if (j<(NUM_TWEETS+NUM_HASHTAGS)) {
      // don't draw messages yet
      //fill(0,0,255);
      //ellipse(p.x, p.y, 10, 10);
    } 
    else {
      // only draw small particles, all in white
      fill(255,255,255);
      ellipse(p.x, p.y, 4, 4);
    }
    j++;
    if (j>(NUM_TWEETS+NUM_HASHTAGS+NUM_DOTS)) j=0;
  }

  if (debug) text(current_time + " " + previous_time, 50, height - 50);

  if (demo) {
    // create random messages in demo mode to emulate proximity events
    long tag_n = PApplet.parseInt(random(tweets.size()));
    long reader_n = PApplet.parseInt(random(hashtags.size()));
    ParticleMessage t = (ParticleMessage) tweets.get(PApplet.parseInt(tag_n));
    ParticleHashtag r = (ParticleHashtag) hashtags.get(PApplet.parseInt(reader_n));
    inString=(t.label+","+r.label+","+random(1, 10)+"\n");
  }

  if (inString!=null)
  {
    // process the incoming message
    if (debug) print(" "+inString+" ");
    String[] p = splitTokens(inString, ",\n\r\t");
    if (debug) text("message: ["+p[0]+"] / place: ["+p[1]+"] / link quality: [" +p[2]+"]", 20, height-200);
    int q = ((PApplet.parseInt(p[2])));
    //println(q);

    // update the 2D particle simulation
    long tag_n = findTag(tweets, p[0]);  
    long reader_n = findReader(hashtags, p[1]);
    if (debug) print("tag: "+tag_n+" / reader: "+reader_n+" / link quality: " +q);
    if ((tag_n>=0) && (reader_n>=0)) {
      ParticleMessage t = (ParticleMessage) tweets.get(PApplet.parseInt(tag_n));
      ParticleHashtag r = (ParticleHashtag) hashtags.get(PApplet.parseInt(reader_n));
      t.setSignal(r.id, q);
      float lq = PApplet.parseFloat(q);
      if (current_smooth_time > (previous_smooth_time + smooth_time*1000)) {
        if (lq<30) {
          if (debug) println("update");
          if (debug) print("attractor #");
          if (debug) println(reader_n);
          int ii = 0;
          for (Iterator i=physics.behaviors.iterator(); i.hasNext();) {
            AttractionBehavior a=(AttractionBehavior)i.next();
            if (ii==(reader_n)) {
              float strength = 2.0f/lq;
              println(strength);
              a.setStrength(-strength);
              if (debug) println(a.getStrength());
            }
            ii++;
          }
          if (debug) println("["+lq+"] ["+p[2]+"]");
        }
        else {

          t.col=color(255, 255, 255);
          if (debug) print("attractor #");
          if (debug) println(reader_n);
          int ii = 0;
          for (Iterator i=physics.behaviors.iterator(); i.hasNext();) {
            AttractionBehavior a=(AttractionBehavior)i.next();
            if (ii==(reader_n)) {
              a.setStrength(0);
              if (debug) println(a.getStrength());
            }
            ii++;
          }

        }
        previous_smooth_time = current_smooth_time;
      }
      if (debug) text("tag: "+t.label+" / reader: "+r.location+" / distance: " +q, 20, height-100);
    }
  }
  
  if (current_time > (previous_time + reset_time*1000)) {

    if (doReset) {
      centreAttractor = new AttractionBehavior(new Vec2D(width/3, height/3), width, 10.0f);
      Attractor1 = new AttractionBehavior(new Vec2D(width-width/10, height-height/10), width, 1.0f);
      Attractor2 = new AttractionBehavior(new Vec2D(width/10, height/10), width, 1.0f);
      Attractor3 = new AttractionBehavior(new Vec2D(width/10, height-height/10), width, 1.0f);
      Attractor4 = new AttractionBehavior(new Vec2D(width-width/10, height/10), width, 1.0f);

      physics.addBehavior(centreAttractor);
      physics.addBehavior(Attractor1);
      physics.addBehavior(Attractor2);
      physics.addBehavior(Attractor3);
      physics.addBehavior(Attractor4);
      //initPhysicsTest();
      if (debug) println("reset");
    }
    //getNewTweets();
    previous_time = current_time;
  } 
  else {
    if (millis()>time) {
      time = millis() + 10000;
    } 
    else {
      physics.removeBehavior(centreAttractor);
    }
  }
  
  if (current_tweets_time > (previous_tweets_time + tweets_time*1000)) {
    getNewTweets();
    previous_tweets_time = current_tweets_time;
  }

  // draw simulation
  tint(255, 255); // opaque

  // draw particles
  int k=0;
  //for (VerletParticle2D p : physics.particles) {
  for(int i=physics.particles.size()-1; i>=0; i--){
    VerletParticle2D p=physics.particles.get(i);
    float t_scale = 1.5f/(i/0.8f+0.001f)+0.3f;
    //float t_scale = 1-i*i/4/physics.particles.size();
    //fill(rcol);

    // draw messages
    if (p instanceof ParticleMessage) {
      // we need to cast particle to be a ParticleMessagein order to access its properties
      //if (debug) println(physics.particles.get(k).distanceTo(physics.particles.get(NUM_TWEETS+NUM_HASHTAGS)));
      ParticleMessage lp=(ParticleMessage)p;
      //float dist = physics.particles.get(k).distanceTo(physics.particles.get(NUM_TWEETS+NUM_HASHTAGS+1));
      float dist = physics.particles.get(k).distanceTo(physics.particles.get(0));
      //lp.setColour(color(red(tcol)-red(tcol)*dist/width,green(tcol)*dist/width,blue(tcol)-blue(tcol)*dist/width));
      //lp.setColour(color(dist,0,dist));
      lp.setColour(tcol);
      fill(lp.col);
      Vec2D v = p.getVelocity();
      tint(255, 50);
      //ellipse(p.x, p.y, 50, 50);
      tint(255, 255);
      if (showLabels)
      {
        //println(lp.id);
        textFont(fontextrasmall);
        //Status messageStatus = fear_tweets.get(lp.id);
        //String what = "";
        //if (lp.id<NUM_TWEETS) {
        //  messageStatus = fear_tweets.get(lp.id);
        //  what = "fear";
        //  fill(fear_color);
        //}
        //if (lp.id>=NUM_TWEETS) {
        //  messageStatus = love_tweets.get(lp.id);
        //  what = "love";
        //  fill(love_color);
        //}
        try {
        Status messageStatus = all_tweets.get(lp.id);
        drawTweet(messageStatus, "all", lp.id, p.x, p.y,t_scale);
        fill(255,255,255);
        
        //text(str(lp.id)+"-"+str(k), p.x-20, p.y+5);
        textFont(font);
        } 
        catch (IndexOutOfBoundsException e) {
        }
      }
      if (debug) {
        fill(255,0,0);
        textFont(fontsmall);
        //text(str(lp.id), p.x, p.y-2);
        text(str(dist), p.x, p.y-2);
        textFont(font);
      }
    }
  }
  for (VerletParticle2D p : physics.particles) {
    // draw hashtags
    if (p instanceof ParticleHashtag) {
      // we need to cast particle to be a ParticleHashtag in order to access its properties
      ParticleHashtag lp=(ParticleHashtag)p;
      
      fill(lp.col);
      //ellipse(p.x, p.y, 10, 10);
      if (showLabels) {
        textFont(font);
        //text(lp.location, p.x-MESSAGE_SIZE/2, p.y-10);
        textFont(font);
      }
    }

    fill(255,255,255);
    k++;
  }
  


  
  if (k>(NUM_TWEETS+NUM_HASHTAGS+NUM_DOTS)) k=0;
}

public void initPhysicsTest() {
  physics=new VerletPhysics2D();
  physics.setDrag(0.05f);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  getHashtags(hashtagsFile);
  getTweets();
}

public void serialEvent(Serial p) { 
  inString = p.readString();
}

public void mousePressed() {
  mousePos = new Vec2D(mouseX, mouseY);
  // create a new positive attraction force field around the mouse position
  mouseAttractor = new AttractionBehavior(mousePos, width/3, 3f);
  physics.addBehavior(mouseAttractor);
}

public void mouseDragged() {
  // update mouse attraction focal point
  mousePos.set(mouseX, mouseY);
}

public void mouseReleased() {
  // remove the mouse attraction when button has been released
  physics.removeBehavior(mouseAttractor);
}

public void keyPressed() {
  if (key=='r') {
    // refresh Tweets
    getNewTweets();
    // reset the particle simulation
    initPhysicsTest();
    for (int i=0; i<NUM_DOTS; i++) {
      addDot(width/2, height/2);
    }
  }
  if (key=='l') {
    showLabels = !showLabels;
  }
  if (key=='q') {
    exit();
  }
}

//boolean sketchFullScreen() {
//  return fullScreen;
//}

class LabeledParticle extends VerletParticle2D {
   
  String label;
   
  LabeledParticle(float x, float y, String label) {
    super(x,y);
    this.label=label;
  }
}
public void getTweets(){
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
    int tagcol = tcol;

    ParticleMessage message = new ParticleMessage(random(width), random(height), label, id, name, tweets_pictures.get(i));
    message.col=tagcol;
    physics.addParticle(message);
    physics.addBehavior(new AttractionBehavior(message, MESSAGE_W, -0.1f, 0.00f));  // add repulsive force 
    tweets.add(message);
        
  }

}

public void getHashtags(String rFile){
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
   
    int id = PApplet.parseInt(pieces[0]);
    String label = pieces[1];
    String location = pieces[2];
    int x = PApplet.parseInt(pieces[3]);
    int y = PApplet.parseInt(pieces[4]); // 5,6,7,8,
    int readcol = color(PApplet.parseInt(pieces[9]),PApplet.parseInt(pieces[10]),PApplet.parseInt(pieces[11]));
  
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

public long findReader(ArrayList readers_list, String name) {
  int res = -1;
  for (int i=0; i < readers_list.size(); i++) {
    ParticleHashtag r = (ParticleHashtag) readers_list.get(i);
    if (r.label.equals(name)) {
      res = i;      
    }
  }
  return(res);
}

public long findTag(ArrayList tags_list, String name) {
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

public void addDot(int x, int y) {
  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(x, y));
  physics.addParticle(p);
  physics.addBehavior(new AttractionBehavior(p, 10, -0.1f, 0.00f));
}
 
class ParticleHashtag extends LabeledParticle {
   
  int id;
  int col;
  String location;
  AttractionBehavior attraction;
   
  ParticleHashtag(float x, float y, String label, int id, String location) {
    super(x,y,label);
    this.id=id;
    this.location=location;
    this.col = rcol;
    this.attraction = attraction;
  }
  
  public void setAttraction(AttractionBehavior attraction) {
    this.attraction = attraction;
  }
  
  public void setColour(int C) {
    this.col = C;
  }
  
}

 
 
class ParticleMessage extends LabeledParticle {
   
  int id;
  int col;
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
  
  public void setSignal(int r, int s) {
    this.signal[r] = s;
    //println(s);
  }
  
  public int getSignal(int r) {
    return this.signal[r];
  }
  
  public void setColour(int C) {
    this.col = C;
  }
  
  public void show() {
    
  }
}

 
public void getNewTweets()
{
  try
  {
      println("Updating tweets ...");
      // get tweets
      //Query fearQuery = new Query(fearSearchString);
      //fearQuery.setCount(50);
      //Query loveQuery = new Query(loveSearchString);
      //loveQuery.setCount(50);
      //QueryResult fearResult = twitter.search(fearQuery);
      //QueryResult loveResult = twitter.search(loveQuery);
      //fear_tweets = fearResult.getTweets();
      //love_tweets = loveResult.getTweets();
      Paging paging = new Paging(1,1000);
      all_tweets = twitter.getUserTimeline(paging);

      //home_tweets = twitter.getUserTimeline(paging);
      //all_tweets = home_tweets;
      //all_tweets.addAll(fear_tweets);
      
      //println("Got new tweets");
      //println(fear_tweets);
      //println(fear_tweets.size());
      //println(fear_pictures);
      //println(fear_pictures.size());
      //println(love_tweets);
      //println(love_tweets.size());
      //println(love_pictures);
      //println(love_pictures.size());
      //print("all_tweets: ");
      //println(all_tweets);
      println(all_tweets.size() + " tweets.");
      tweets_n = all_tweets.size();

      // put tweets first image into list of pictures 
      for (int i=(all_tweets.size()-1); i>=0;i--) {
        //Status fearStatus = fear_tweets.get(i);
        //MediaEntity[] media_entity = fearStatus.getMediaEntities();
        //HashtagEntity[] hashtags_entity = thisStatus.getHashtagEntities();
        //if (media_entity.length>0) {
        //  MediaEntity media = media_entity[0];
        //  String imageURL = media.getMediaURL();
        //  PImage img = loadImage(imageURL); 
        //  //println(img);
        //  fear_pictures.set(i,img);
        //}
        //Status loveStatus = love_tweets.get(i);
        //media_entity = loveStatus.getMediaEntities();
        //if (media_entity.length>0) {
        //  MediaEntity media = media_entity[0];
        //  String imageURL = media.getMediaURL();
        //  PImage img = loadImage(imageURL); 
        //  //println(img);
        //  love_pictures.set(i,img);
        //}
        Status homeStatus = all_tweets.get(i);
        MediaEntity[] media_entity = homeStatus.getMediaEntities();
        HashtagEntity[] hashtags_entity = homeStatus.getHashtagEntities();
        //media_entity = homeStatus.getMediaEntities();
        //println(media_entity.length);
        if (media_entity.length>0) {
          MediaEntity media = media_entity[0];
          String imageURL = media.getMediaURL();
          PImage img = loadImage(imageURL); 
          //println(img);
          tweets_pictures.set(i,img);
        }
        //String hashtags_text = "";
        if (hashtags_entity.length>0) {
          String h = "";
          for (int j=0; j<hashtags_entity.length; j++) {
            HashtagEntity hashtag = hashtags_entity[j];
            h += hashtag.getText()+" ";
          }
          all_hashtags.set(i,h);
        }
      }
  }
  catch (TwitterException te)
  {
      // deal with the case where we can't get them here
      System.out.println("Failed to search tweets: " + te.getMessage());
      //System.exit(-1);
  }


}

public void refreshTweets()
{
    while (true)
    {
      println("Updating Tweets");
      getNewTweets();
      delay(PApplet.parseInt(reset_time*1000));
    }
}

public void drawTweet(Status thisStatus, String what, int id, float x, float y, float tweet_scale)
{
  //println("id="+id);
  //println(other_hashtags.size()+" "+all_hashtags.size());
  
  MediaEntity[] media_entity = thisStatus.getMediaEntities();
  HashtagEntity[] hashtags_entity = thisStatus.getHashtagEntities();
  
  //pushMatrix();
  //translate(0,0);
  //scale(tweet_scale);
  
  
  if (media_entity.length>0) {
    //println(fear_media.Size);
    
    //MediaEntity media = media_entity[0];
    //String imageURL = media.getMediaURL();
    //PImage img = loadImage(imageURL); 
    //int w = media.getSizes().get(1).getWidth();
    //int h = media.getSizes().get(1).getHeight();
    //if (what=="fear") {
    //  PImage img = fear_pictures.get(id);
    //  int w = img.width;
    //  int h = img.height;
    //  //image(img, x, y, w/4, h/4);
    //  //tint(0, 255, 0, 200);
    //  image(img, x-MESSAGE_SIZE/2, y-MESSAGE_SIZE/2, MESSAGE_SIZE, MESSAGE_SIZE);
    //}
    //if (what=="love") {
    //  PImage img = love_pictures.get(id-fear_pictures.size());
    //  int w = img.width;
    //  int h = img.height;
    //  tint(255, 0, 255, 200);
    //  image(img, x-MESSAGE_SIZE/2, y-MESSAGE_SIZE/2, MESSAGE_SIZE, MESSAGE_SIZE);
    //}
    if (what=="all") {
      
      VerletParticle2D p = physics.particles.get(id+NUM_HASHTAGS); // the first particles are static hashtags so skipping them
      if (p instanceof ParticleHashtag) {
         println(str(id)+" hashtag");
      }
      fill(255,255,255);
      
      PImage img = tweets_pictures.get(id);
      int w = img.width;
      int h = img.height;
      //tint(255, 0, 255, 200);
      int padding = 10;
      //rect(x-MESSAGE_SIZE/2-padding, y-MESSAGE_SIZE/2-3*padding, float(w/MESSAGE_SCALE+2*padding), float(h/MESSAGE_SCALE+6*padding));
      //rect(MESSAGE_SIZE/2-padding, MESSAGE_SIZE/2-3*padding, float(w/MESSAGE_SCALE+2*padding), float(h/MESSAGE_SCALE+6*padding));
      //translate(x,y);
      rect(x-(MESSAGE_W/2-padding/2)*tweet_scale, y-(MESSAGE_H/2-padding)*tweet_scale, (PApplet.parseFloat(MESSAGE_W)+padding)*tweet_scale, (PApplet.parseFloat(MESSAGE_H)+padding*4)*tweet_scale);
      image(img, x-MESSAGE_W/2*tweet_scale+padding*tweet_scale, y-MESSAGE_H/2*tweet_scale+3*padding*tweet_scale, MESSAGE_W*tweet_scale, MESSAGE_H*tweet_scale);


      //image(img, x-MESSAGE_SIZE/2, y-MESSAGE_SIZE/2, w/MESSAGE_SCALE, h/MESSAGE_SCALE);
      //image(img, MESSAGE_SIZE/2, MESSAGE_SIZE/2, w/MESSAGE_SCALE, h/MESSAGE_SCALE);
      String hashtags_text = "";
      if (hashtags_entity.length>0) {
        for (int j=0; j<hashtags_entity.length; j++) {
          HashtagEntity hashtag = hashtags_entity[j];
          String hashtag_text = hashtag.getText();
          
          if (!hashtag_text.equals("driversofchange")) {
            //println(str(id)+" "+hashtag_text);
            if (hashtag_text.equals("fear")) {
              all_hashtags.set(id,"#fear");
              VerletSpring2D s = new VerletSpring2D(physics.particles.get(1), physics.particles.get(id+NUM_HASHTAGS), random(MESSAGE_W*tweet_scale,MESSAGE_H*tweet_scale), 1.01f);
              physics.addSpring(s);
            }
            else if (hashtag_text.equals("love")) {
              all_hashtags.set(id,"#love");
              VerletSpring2D s = new VerletSpring2D(physics.particles.get(0), physics.particles.get(id+NUM_HASHTAGS), random(MESSAGE_W*tweet_scale,MESSAGE_H*tweet_scale), 1.01f);
              physics.addSpring(s);
              //println("#love");
            }
            else if (hashtag_text.length()>0) {
              other_hashtags.set(id,"#"+hashtag_text);
              //println(hashtag_text+" / "+getHashtagNumber(other_hashtags, hashtag_text));
              if (getHashtagNumber(other_hashtags, hashtag_text)>1) {
                VerletSpring2D s = new VerletSpring2D(physics.particles.get(findHashtag(other_hashtags, hashtag_text)+NUM_HASHTAGS), physics.particles.get(id+NUM_HASHTAGS), 100, 1.01f);
                physics.addSpring(s);
                //println("linked "+(findHashtag(other_hashtags, hashtag_text)+NUM_HASHTAGS)+" with "+(id+NUM_HASHTAGS));
              }
              //println(hashtag_text);
            }
            hashtags_text += hashtag_text+" | ";
          }
        }
      }

      fill(0,0,0);
      //fill(255,255,255);
      //text(thisStatus.getText(), x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2, MESSAGE_SIZE, MESSAGE_SIZE);
      //text(hashtags_text, x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2+10, MESSAGE_SIZE, MESSAGE_SIZE);
      //text(other_hashtags.get(id), x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2+10, MESSAGE_SIZE, MESSAGE_SIZE);
      //text(other_hashtags.get(id), MESSAGE_SIZE/2, h/MESSAGE_SCALE-MESSAGE_SIZE/2+10, MESSAGE_SIZE, MESSAGE_SIZE);

      //println(tweet_scale);
      textSize(tweet_scale*12);
      text(all_hashtags.get(id), x-MESSAGE_W/2*tweet_scale+padding*tweet_scale, y-MESSAGE_H/2*tweet_scale+padding*tweet_scale*2.5f);
      text(other_hashtags.get(id), x-MESSAGE_W/2*tweet_scale+padding*tweet_scale, y+MESSAGE_H*tweet_scale-padding*tweet_scale*3);
      //text(all_hashtags.get(id), x-MESSAGE_W/2*tweet_scale+padding*tweet_scale, y+(h+padding)*tweet_scale, (w-padding)*tweet_scale, padding);
      //text(all_hashtags.get(id), x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2+10+15, MESSAGE_SIZE, MESSAGE_SIZE);
      //text(all_hashtags.get(id), x-MESSAGE_SIZE/2, y-h/MESSAGE_SCALE-15, MESSAGE_SIZE, MESSAGE_SIZE);
      //text(all_hashtags.get(id), MESSAGE_SIZE/2,   h/MESSAGE_SCALE-15, MESSAGE_SIZE, MESSAGE_SIZE);
      //text(other_hashtags.get(id), x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2+10, MESSAGE_SIZE, MESSAGE_SIZE);

      fill(255,255,255);
  }
    
    //println("Array: "+fear_media);
    //println(fear_media.length);
    tint(0,255);
  } else {
    text(thisStatus.getText(), x-MESSAGE_W/2, y-MESSAGE_H/2, MESSAGE_W, MESSAGE_H);
  }
  //scale(1/tweet_scale);
  //translate(x,y);

  //popMatrix();
}

public int getHashtagNumber(ArrayList<String> hashtags, String what){
    int i = 0;
    int count = 0;
    //println(hashtags.size());
    for (String hashtag : hashtags) {
               //print(hashtag+" ");
               if(hashtag.matches("#"+what)){
                   count++;
               }
               i++;
    }
    return count; 
}

public int findHashtag(ArrayList<String> hashtags, String what){
    int i = 0;
    int count = 0;
    //println(hashtags.size());
    for (String hashtag : hashtags) {
               //print(hashtag+" ");
               if(hashtag.matches("#"+what)){
                   count++;
               }
               i++;
    }
    return i-1; 
}

/*
void getNewTweets()
{
    try 
    {
        Query query = new Query(searchString);

        QueryResult result = twitter.search(query);

        tweets = result.getTweets();
    } 
    catch (TwitterException te) 
    {
        System.out.println("Failed to search tweets: " + te.getMessage());
        System.exit(-1);
    } 
    println(tweets.size());
    
    
    for (int i = 0; i < tweets.size(); i++) {
      Status t = (Status) tweets.get(i);
      String user = t.getUser().getName();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet by " + user + " at " + d + ": " + msg);

      tWords.add("@" + user + ": " + msg);
 
      
      if (i<numlights) {
           tWords.set(i, "@" + user + ": " + msg);
           println(tWords.get(i));
      }
     
      //Break the tweet into words
      //String[] input = msg.split(" ");
      //for (int j = 0;  j < input.length; j++) {
       //Put each word into the words ArrayList
       //words.add(input[j]);
      //}
    };
    
}

void refreshTweets()
{
    while (true)
    {
        getNewTweets();

        println("Updated Tweets"); 
        
         println();
    print( next+" ");

//    String testWords = tWords.get(0);
//    if( testWords.equals(lights[0].text) ) { testWords = tWords.get(next); }

//    loadTL(next, testWords);

    next++;
    if( next == numlights ) { next = 0; }

        delay(10000);
        
        
        
    }
}
*/
  public void settings() {  fullScreen();  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "fear_and_love" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
