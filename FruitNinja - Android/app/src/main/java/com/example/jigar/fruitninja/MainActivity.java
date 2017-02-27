package com.example.jigar.fruitninja;

import android.app.Activity;
import android.content.res.Resources;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView;
import android.widget.TextView;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends Activity {
        // create the game
        private Animation mAnimation,mAnimation1,mAnimation2;
        private int iClicks = 0;
    float xv=0,xv1=0,xv2=0;
    float y1=5,y=0,y2=8;

        ImageView img,img1,img2;
        ImageView[] imgV = new ImageView[10];
        @Override
        protected void onCreate (Bundle savedInstanceState){
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            //timer
            Timer timer = new Timer();
            timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            TextView timertxt = (TextView) findViewById(R.id.timertxt);
                            // task to be done every 1000 milliseconds
                            iClicks = iClicks + 1;
                            if (y == Resources.getSystem().getDisplayMetrics().heightPixels) {
                                y = 0;
                            }
                            y += Resources.getSystem().getDisplayMetrics().heightPixels / 10;
                            if (y1 == Resources.getSystem().getDisplayMetrics().heightPixels) {
                                y1 = 0;
                            }
                            y1 += Resources.getSystem().getDisplayMetrics().heightPixels / 15;

                            if (y2 == Resources.getSystem().getDisplayMetrics().heightPixels) {
                                y2 = 0;
                            }
                            y2 += Resources.getSystem().getDisplayMetrics().heightPixels /20;


                            //generating fruits each secs
                            timertxt.setText(String.valueOf(iClicks));
                        }
                    });

                }
            }, 0, 1000);

            displayImages();
            displayImages1();
            displayImages2();

        }
    public void displayImages()
    {

            img=(ImageView)findViewById(R.id.imageView1);
            String[] imageArray = {"watermelon","apple","orange","strawberry","pineapple","papaya","grape"};
            Random rand = new Random();
            Random sx = new Random();
            int x = sx.nextInt(720 + 1);
            img.setX(x);
            xv=x;
            int rndInt = rand.nextInt(7);
            int resID = getResources().getIdentifier(imageArray[rndInt], "drawable",  getPackageName());
            img.setImageResource(resID);



            mAnimation = new TranslateAnimation(
                    TranslateAnimation.ABSOLUTE, 0f,
                    TranslateAnimation.ABSOLUTE, 0f,
                    TranslateAnimation.RELATIVE_TO_PARENT, 0f,
                    TranslateAnimation.RELATIVE_TO_PARENT, 1.0f);
            mAnimation.setDuration(10000);
            mAnimation.setRepeatCount(-1);
            mAnimation.setInterpolator(new LinearInterpolator());
            img.setAnimation(mAnimation);

    }
    public void displayImages1()
    {

        img1=(ImageView)findViewById(R.id.imageView2);
        String[] imageArray = {"watermelon","apple","orange","strawberry","pineapple","papaya","grape"};
        Random rand = new Random();
        Random sx = new Random();
        int x1 = sx.nextInt(720 + 1);
        img1.setX(x1);
        xv1=x1;
        int rndInt = rand.nextInt(7);
        int resID = getResources().getIdentifier(imageArray[rndInt], "drawable",  getPackageName());
        img1.setImageResource(resID);



        mAnimation1 = new TranslateAnimation(
                TranslateAnimation.ABSOLUTE, 0f,
                TranslateAnimation.ABSOLUTE, 0f,
                TranslateAnimation.RELATIVE_TO_PARENT, 0f,
                TranslateAnimation.RELATIVE_TO_PARENT, 1.0f);
        mAnimation1.setDuration(15000);
        mAnimation1.setRepeatCount(-1);
        mAnimation1.setInterpolator(new LinearInterpolator());
        img1.setAnimation(mAnimation1);

    }

    public void displayImages2()
    {
        img2=(ImageView)findViewById(R.id.imageView3);
        String[] imageArray = {"watermelon","apple","orange","strawberry","pineapple","papaya","grape"};
        Random rand = new Random();
        Random sx = new Random();
        int x2 = sx.nextInt(720 + 1);
        img2.setX(x2);
        xv2=x2;
        int rndInt = rand.nextInt(7);
        int resID = getResources().getIdentifier(imageArray[rndInt], "drawable",  getPackageName());
        img2.setImageResource(resID);

        mAnimation2 = new TranslateAnimation(
                TranslateAnimation.ABSOLUTE, 0f,
                TranslateAnimation.ABSOLUTE, 0f,
                TranslateAnimation.RELATIVE_TO_PARENT, 0f,
                TranslateAnimation.RELATIVE_TO_PARENT, 1.0f);
        mAnimation2.setDuration(20000);
        mAnimation2.setRepeatCount(-1);
        mAnimation2.setInterpolator(new LinearInterpolator());
        img2.setAnimation(mAnimation2);

    }
    //catch touch events
    @Override
    public boolean onTouchEvent(MotionEvent event) {

        if(((event.getY()>= (y-200)) && (event.getY()<= (y+200)) && ((event.getX()>= (xv-100)) && (event.getX()<= (xv+100)))))
        {
            y=0;
            displayImages();
        }
        else if(((event.getY()>= (y1-200)) && (event.getY()<= (y1+200)) && ((event.getX()>= (xv1-100)) && (event.getX()<= (xv1+100)))))
        {
            y1=5;
            displayImages1();
        }
        else if(((event.getY()>= (y2-200)) && (event.getY()<= (y2+200)) && ((event.getX()>= (xv2-100)) && (event.getX()<= (xv2+100)))))
        {
            y2=8;
            displayImages2();
        }

        return super.onTouchEvent(event);
    }

    }
