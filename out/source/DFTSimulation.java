import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class DFTSimulation extends PApplet {


Knob[] a = new Knob[4];

public void setup(){
    

    for(int i = 0; i < a.length; i++){
        a[i] = new Knob(100 + i*200, 400, 50, 50);
    }


}

public void draw(){
    background(255, 0, 0);

    for(int i = 0; i < a.length; i++){
        a[i].update();
    }

}
class Controller{
    //private float/boolean m_value = 0;
    
    protected float m_xPos, m_yPos, m_xLen, m_yLen;

    protected boolean m_selected = false;
    protected boolean m_firstClick = true;

    protected float m_mouseClickedX;
    protected float m_mouseClickedY;

    Controller(float xPos, float yPos, float xLen, float yLen){
        m_xPos = xPos;
        m_yPos = yPos;
        m_xLen = xLen;
        m_yLen = yLen;
    }

    public void update(){
        click();
        adjust();
        draw();
    }

    private void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_xPos && 
                mouseX <= m_xPos + m_xLen && 
                mouseY >= m_yPos && 
                mouseY <= m_yPos + m_yLen){

                m_mouseClickedX = mouseX;
                m_mouseClickedY = mouseY;

                m_selected = true;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
    }

    protected void adjust(){
        //to be inherited and overloaded
    }

    protected void draw(){
        //to be inherited and overloaded
    }

    //public float getValue(){
        //to be inherited and overloaded
    //}

}

//====================================================================

class Knob extends Controller{

    private float m_value;

    private float m_sensitivity = 1;

    private int m_capColor;
    private int m_barColor;
    private int m_fillColor;

    Knob(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, (xLen < yLen)? xLen : yLen, (xLen < yLen)? xLen : yLen);
        m_value = 0.8f;
        m_capColor = color(150, 150, 150);
        m_barColor = color(100, 100, 100);
        m_fillColor = color(50, 150, 50);
    }

    protected void adjust(){
        if(m_selected){
            m_value = m_sensitivity * (m_mouseClickedY - mouseY) / m_yLen;

            

            if(m_value < 0){
                m_value = 0;
            }

            if(m_value > 1){
                m_value = 1;
            }

            println(m_value);
        }
    }

    protected void draw(){
        colorMode(RGB, 255, 255, 255);

        //Bar
        noStroke();
        fill(m_barColor);
        arc(m_xPos + m_xLen / 2, m_yPos + m_yLen / 2, m_xLen, m_yLen, PI * 3 / 4, PI / 4, PIE);

        //Fill
        noStroke();
        fill(m_fillColor);
        arc(m_xPos + m_xLen / 2, m_yPos + m_yLen / 2, m_xLen, m_yLen, PI * 3 / 4, map(m_value, 0, 1, 0, 3 * PI / 2), PIE);
        
        //Cap
        noStroke();
        fill(m_capColor);
        ellipse(m_xPos + m_xLen / 2, m_yPos + m_yLen / 2, 0.6f * m_xLen, 0.6f * m_yLen);
    }

    public float getValue(){
        return m_value;
    }

    public void setColor(int capColor, int barColor, int fillColor){
        m_capColor = capColor;
        m_barColor = barColor;
        m_fillColor = fillColor;
    }
}
  public void settings() {  size(800,800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "DFTSimulation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
