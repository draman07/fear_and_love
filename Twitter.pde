void getNewTweets()
{
  try
  {
      println("Updating tweets ...");
      // get tweets
      Query fearQuery = new Query(fearSearchString);
      fearQuery.setCount(50);
      //Query loveQuery = new Query(loveSearchString);
      //loveQuery.setCount(50);
      QueryResult fearResult = twitter.search(fearQuery);
      //QueryResult loveResult = twitter.search(loveQuery);
      fear_tweets = fearResult.getTweets();
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

      // put tweets first image into list of pictures 
      for (int i=0; i<all_tweets.size();i++) {
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

void refreshTweets()
{
    while (true)
    {
      println("Updating Tweets");
      getNewTweets();
      delay(int(reset_time*1000));
    }
}

void drawTweet(Status thisStatus, String what, int id, float x, float y)
{
  MediaEntity[] media_entity = thisStatus.getMediaEntities();
  HashtagEntity[] hashtags_entity = thisStatus.getHashtagEntities();
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
      PImage img = tweets_pictures.get(id);
      int w = img.width;
      int h = img.height;
      //tint(255, 0, 255, 200);
      image(img, x-MESSAGE_SIZE/2, y-MESSAGE_SIZE/2, w/MESSAGE_SCALE, h/MESSAGE_SCALE);
      String hashtags_text = "";
      if (hashtags_entity.length>0) {
        for (int j=0; j<hashtags_entity.length; j++) {
          HashtagEntity hashtag = hashtags_entity[j];
          String hashtag_text = hashtag.getText();
          
          if (!hashtag_text.equals("driversofchange")) {
            //println(str(id)+" "+hashtag_text);
            if (hashtag_text.equals("fear")) {
              all_hashtags.add(id,"fear");
              VerletSpring2D s = new VerletSpring2D(physics.particles.get(1), physics.particles.get(id+NUM_HASHTAGS), MESSAGE_SIZE, 0.001);
              physics.addSpring(s);
            }
            else if (hashtag_text.equals("love")) {
              all_hashtags.add(id,"love");
              VerletSpring2D s = new VerletSpring2D(physics.particles.get(0), physics.particles.get(id+NUM_HASHTAGS), MESSAGE_SIZE, 0.001);
              physics.addSpring(s);
            }
            else if (hashtag_text.length()>0) other_hashtags.add(id,hashtag_text);
            hashtags_text += hashtag_text+" | ";
          }
        }
      }
      //text(thisStatus.getText(), x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2, MESSAGE_SIZE, MESSAGE_SIZE);
      //text(hashtags_text, x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2+10, MESSAGE_SIZE, MESSAGE_SIZE);
      text(other_hashtags.get(id), x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2+10, MESSAGE_SIZE, MESSAGE_SIZE);
      text(all_hashtags.get(id), x-MESSAGE_SIZE/2, y+h/MESSAGE_SCALE-MESSAGE_SIZE/2+10+15, MESSAGE_SIZE, MESSAGE_SIZE);
  }
    
    //println("Array: "+fear_media);
    //println(fear_media.length);
    tint(0,255);
  } else {
    text(thisStatus.getText(), x-MESSAGE_SIZE/2, y-MESSAGE_SIZE/2, MESSAGE_SIZE, MESSAGE_SIZE);
  }
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