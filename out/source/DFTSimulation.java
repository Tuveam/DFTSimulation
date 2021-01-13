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

//command+shift+b to run it in vscode
//Anything in here is only testing code and can be deleted

MainSection m;


public void setup(){
    
    m = new MainSection(0, 0, width, height);
}

public void draw(){
    m.update();

}
class Controller{
    //private float/boolean m_value = 0;
    
    protected PVector m_pos;
    protected PVector m_len;

    protected boolean m_selected = false;
    protected boolean m_firstClick = true;

    protected PVector m_mouseClicked;

    protected int m_fillColor;
    protected int m_backgroundColor1;
    protected int m_backgroundColor2;

    Controller(PVector pos, PVector len){
        m_pos = pos;
        m_len = len;

        m_fillColor = color(75, 200, 75);
        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);
        
        m_mouseClicked = new PVector(mouseX, mouseY);
    }

    public void update(){
        click();
        adjust();
        draw();
    }

    protected void click(){
        /*if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_pos.x && 
                mouseX <= m_pos.x + m_len.x && 
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                m_mouseClickedX = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }*/
        
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
    private float m_previousValue;

    private float m_minRealValue = 0;
    private float m_maxRealValue = 1;

    private float m_sensitivity = 0.25f;
    

    Knob(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector((xLen < yLen)? xLen : yLen, (xLen < yLen)? xLen : yLen));
        m_value = 0.8f;
        
    }

    protected void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_pos.x && 
                mouseX <= m_pos.x + m_len.x && 
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;
                m_previousValue = m_value;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
    }

    protected void adjust(){
        if(m_selected){
            m_value = m_previousValue + m_sensitivity * (m_mouseClicked.y - mouseY) / m_len.y;

            

            if(m_value < 0){
                m_value = 0;
            }

            if(m_value > 1){
                m_value = 1;
            }

            //println(m_value);
        }
    }

    protected void draw(){
        colorMode(RGB, 255, 255, 255);

        pushMatrix();
        translate(m_pos.x + m_len.x / 2, m_pos.y + m_len.y / 2);

        //Bar
        noStroke();
        fill(m_backgroundColor1);
        arc(0, 0, m_len.x, m_len.y, PI * 3 / 4, PI * 9 / 4, PIE);

        //Fill
        float angle = map(m_value, 0, 1, PI * 3 / 4, PI * 9 / 4);
        noStroke();
        fill(m_fillColor);
        arc(0, 0, m_len.x, m_len.y, PI * 3 / 4, angle, PIE);

        
        //Cap
        noStroke();
        fill(m_backgroundColor2);
        ellipse(0, 0, 0.8f * m_len.x, 0.8f * m_len.y);

        //indicator line
        stroke(m_fillColor);
        strokeWeight(3);
        line(0.1f * m_len.x * cos(angle), 0.1f * m_len.y * sin(angle), 0.3f * m_len.x * cos(angle), 0.3f * m_len.y * sin(angle));

        popMatrix();
    }

    public float getValue(){
        return m_value;
    }

    public float getRealValue(){
        return map(m_value, 0, 1, m_minRealValue, m_maxRealValue);
    }

    public void setColor(int capColor, int barColor, int fillColor){
        m_backgroundColor2 = capColor;
        m_backgroundColor1 = barColor;
        m_fillColor = fillColor;
    }

    public void setRealValueRange(float minRealValue, float maxRealValue){
        m_minRealValue = minRealValue;
        m_maxRealValue = maxRealValue;
    }
}

//====================================================================

class Tickbox extends Controller{

    protected boolean m_value;

    protected boolean m_pressed = false;


    Tickbox(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);

        m_value = true;
    }

    protected void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_pos.x && 
                mouseX <= m_pos.x + m_len.x && 
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    protected void adjust(){
        if(m_selected){
            m_pressed = true;
        }

        if(!m_selected && m_pressed){
            m_value = !m_value;
            m_pressed = false;
        }
    }

    protected void draw(){
        pushMatrix();
        translate(m_pos.x, m_pos.y);

        float rounding = ((m_len.x < m_len.y)? m_len.x : m_len.y)/4;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(0, 0, m_len.x, m_len.y, rounding);
        float indent = 0.1f;

        drawTick(indent, rounding);

        popMatrix();
    }

    protected void drawTick(float indent, float rounding){
        //Tick
        if(m_value){
            noStroke();
            fill(m_fillColor);
        }else{
            noStroke();
            fill(m_backgroundColor1);
        }

        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        //Highlight
        if(m_pressed){
            noStroke();
            fill(255, 100);
            rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);
        }
    }


    public boolean getValue(){
        return m_value;
    }

    public void setColor(int backgroundColor1, int backgroundColor2, int fillColor){
        m_backgroundColor1 = backgroundColor1;
        m_backgroundColor2 = backgroundColor2;
        m_fillColor = fillColor;
    }
}

class Button extends Tickbox{
    protected int m_cooldown = 20;
    protected int m_tickCooldown = m_cooldown;

    Button(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen);
    }

    protected void adjust(){
        if(m_selected){
            m_pressed = true;
        }

        if(!m_selected && m_pressed){
            m_value = true;
            m_pressed = false;
            m_tickCooldown = 0;
        }

        if(!m_pressed && !m_selected && m_value){
            m_value = false;
        }

        if(m_tickCooldown < m_cooldown){
            m_tickCooldown++;
        }

        if(m_tickCooldown > m_cooldown){
            m_tickCooldown = m_cooldown;
        }
    }

    protected void drawTick(float indent, float rounding){
        noStroke();
        fill(m_backgroundColor1);
        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        fill(m_fillColor, map(m_tickCooldown, 0, 20, 255, 0));
        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        fill(m_backgroundColor2);
        rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
        beginShape();
            vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
            vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
            vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
        endShape();

        if(m_pressed){
            fill(255,100);
            rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
            beginShape();
            vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
            vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
            vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
            endShape();
        }
    }
}

class PlayButton extends Tickbox{

    PlayButton(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen);

        m_value = false;
    }

    protected void drawTick(float indent, float rounding){
        //Tick
        if(m_value){
            noStroke();
            fill(m_fillColor);
        }else{
            noStroke();
            fill(m_backgroundColor1);
        }

        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        if(m_value){//PAUSE
            noStroke();
            fill(m_backgroundColor2);
            rect(m_len.x * 3 * indent, m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
            rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));

            if(m_pressed){
                fill(255, 100);
                rect(m_len.x * 3 * indent, m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
                rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
            }
        }else{//PLAY
            noStroke();
            fill(m_fillColor);

            beginShape();
            vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
            vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
            vertex(m_len.x - m_len.x * 3 * indent, m_len.y/2);
            endShape();

            if(m_pressed){
                fill(255,100);
                beginShape();
                vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
                vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
                vertex(m_len.x - m_len.x * 3 * indent, m_len.y/2);
                endShape();
            }
        }
    }
}

//====================================================================

class Automation extends Controller{

    ArrayList<AutomationPoint> m_point = new ArrayList<AutomationPoint>();

    private int m_backgroundColor1;
    private int m_backgroundColor2;

    Automation(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);

        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0, 0)) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(1, 1)) );
    }

    private void insertPointAtIndex(AutomationPoint insert, ArrayList<AutomationPoint> toSort, int index){
        toSort.add(new AutomationPoint( new PVector(0, 0), new PVector(0, 0), new PVector(0, 0)));

        for(int i = toSort.size() - 2; i >= index; i--){
            toSort.set(i + 1, toSort.get(i));
        }

        toSort.set(index, insert);
    }

    protected void click(){
        if(mousePressed && m_firstClick && mouseButton == RIGHT){
            m_firstClick = false;

            boolean createPoint = true;

            for(int i = 0; i < m_point.size() && createPoint; i++){
                if(m_point.get(i).checkHitbox()){
                    createPoint  = false;
                    m_point.remove(i);
                }

                if(m_point.get(i).checkCurveHandleHitbox(m_point, i)){
                    createPoint  = false;
                    m_point.get(i).resetCurve();
                }
            }

            if(createPoint){
                if( mouseX >= m_pos.x && 
                    mouseX <= m_pos.x + m_len.x && 
                    mouseY >= m_pos.y && 
                    mouseY <= m_pos.y + m_len.y){

                    m_mouseClicked.x = mouseX;
                    m_mouseClicked.y = mouseY;

                    m_selected = true;

                    int index = m_point.size()-1;

                    for(int i = m_point.size()-2; i >= 0; i--){
                        if(m_point.get(i).getActualPosition().x < mouseX){
                            break;
                        }
                        index = i;
                    }

                    PVector temp = new PVector( (mouseX - m_pos.x) / m_len.x, 1 - (mouseY - m_pos.y) / m_len.y);

                    insertPointAtIndex(new AutomationPoint(m_pos, m_len, temp), m_point, index);

                }
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    public void draw(){
        pushMatrix();
        translate(m_pos.x, m_pos.y);

        //background
        fill(m_backgroundColor2);
        stroke(m_backgroundColor1);
        strokeWeight(2);
        rect(0, 0, m_len.x, m_len.y);

        popMatrix();

        //points
        for(int i = 0; i < m_point.size(); i++){
            m_point.get(i).update(m_point, i);
        }

    }

    public void setColor(int backgroundColor1, int backgroundColor2, int fillColor){
        m_backgroundColor1 = backgroundColor1;
        m_backgroundColor2 = backgroundColor2;
        m_fillColor = fillColor;
    }

    public float mapXToY(float x){
        if(x < 0){
            return m_point.get(0).getValue().y;
        }

        int index = 0;

        for(int i = 0; i < m_point.size(); i++){
            if(x <= m_point.get(i).getValue().x){
                return m_point.get(index).mapXToY(x, m_point, index);
            }

            index = i;
        }

        return m_point.get(m_point.size() - 1).getValue().y;
    }

}

class AutomationPoint extends Controller{

    private PVector m_value;

    private float m_curve;
    private float m_previousCurve;
    private int m_displayIncrement = 10;
    private boolean m_selectedCurveHandle = false;
    private float m_curveHandleSensitivity = 1;

    private float m_radius = 6;

    AutomationPoint(PVector windowPos, PVector windowLen, PVector value){
        super(windowPos, windowLen);

        m_value = value;
        m_curve = 0.5f;
        m_previousCurve = m_curve;
    }

    public PVector getActualPosition(){
        return new PVector(m_pos.x + m_value.x * m_len.x, m_pos.y + (1 - m_value.y) * m_len.y);
    }

    private void setActualPosition(float x, float y){
        m_value.x = (x - m_pos.x) / m_len.x;
        m_value.y = 1 - (y - m_pos.y) / m_len.y;
    }

    public void update(ArrayList<AutomationPoint> others, int myIndex){
        click(others, myIndex);
        adjust(others, myIndex);
        draw(others, myIndex);
    }

    protected void click(ArrayList<AutomationPoint> others, int myIndex){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if(checkHitbox()){

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                
            }else if(checkCurveHandleHitbox(others, myIndex)){
                
                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selectedCurveHandle = true;
                m_previousCurve = m_curve;

            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_selectedCurveHandle = false;
            m_firstClick = true;
            
        }
        
    }

    public PVector getValue(){
        return m_value;
    }

    protected void adjust(ArrayList<AutomationPoint> others, int myIndex){
        
        if(m_selected){
            
            setActualPosition(mouseX, mouseY);

            if(myIndex == 0){
                m_value.x = 0;
            }else if(myIndex == others.size() - 1){
                m_value.x = 1;
            }else{
                if(m_value.x < others.get(myIndex - 1).getValue().x){
                    m_value.x = others.get(myIndex - 1).getValue().x;
                }

                if(m_value.x > others.get(myIndex + 1).getValue().x){
                    m_value.x = others.get(myIndex + 1).getValue().x;
                }
            }

            if(m_value.y < 0){
                m_value.y = 0;
            }

            if(m_value.y > 1){
                m_value.y = 1;
            }

            //println(m_value);
        }else if(m_selectedCurveHandle){

            //println(m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_len.y);
            if(myIndex < others.size() - 1){
                if(others.get(myIndex + 1).getValue().y > getValue().y){
                    m_curve = m_previousCurve + m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_len.y;
                }else{
                    m_curve = m_previousCurve - m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_len.y;
                }
                if(m_curve < 0){
                    m_curve = 0;
                }
                
                if(m_curve > 1){
                    m_curve = 1;
                }
            }
            
        }
    }

    public void draw(ArrayList<AutomationPoint> others, int myIndex){
        pushMatrix();
        translate(getActualPosition().x, getActualPosition().y);

        //Point
        noFill();
        stroke(m_fillColor);
        strokeWeight(2);
        if(m_selected){
            ellipse(0, 0, 3 * m_radius, 3 * m_radius);
        }else{
            ellipse(0, 0, 2 * m_radius, 2 * m_radius);
        }

        popMatrix();

        //Curve
        if(myIndex < others.size() - 1){
            if(m_curve == 0.5f || getActualPosition().x == others.get(myIndex + 1).getActualPosition().x){
                strokeWeight(2);
                stroke(m_fillColor);
                line(getActualPosition().x, getActualPosition().y, others.get(myIndex + 1).getActualPosition().x, others.get(myIndex + 1).getActualPosition().y);
            }else{
                beginShape();
                for(int i = PApplet.parseInt(getActualPosition().x); i < others.get(myIndex + 1).getActualPosition().x; i += m_displayIncrement){
                    float x = map(i, getActualPosition().x, others.get(myIndex + 1).getActualPosition().x, 0, 1);
                    float actualY = map(getY(x), 0, 1, getActualPosition().y, others.get(myIndex + 1).getActualPosition().y);

                    vertex(i, actualY);
                }
                vertex(others.get(myIndex + 1).getActualPosition().x, others.get(myIndex + 1).getActualPosition().y);
                endShape();
            }
        }

        //CurveHandle
        
        if(myIndex < others.size() - 1){
            if(!(getActualPosition().x == others.get(myIndex + 1).getActualPosition().x)){
                pushMatrix();

                translate(getCurveHandlePosition(others, myIndex).x, getCurveHandlePosition(others, myIndex).y);

                noFill();
                stroke(m_fillColor);
                strokeWeight(2);

                if(m_selectedCurveHandle){
                    rect(-m_radius, -m_radius, 2 * m_radius, 2 * m_radius);
                }else{
                    rect(-0.5f * m_radius, -0.5f * m_radius, m_radius, m_radius);
                }
                popMatrix();
            }
        }
        
        
        
        
        

    }

    private PVector getCurveHandlePosition(ArrayList<AutomationPoint> others, int myIndex){
        if(myIndex < others.size() - 1){
            float actualX = map(0.5f, 0, 1, getActualPosition().x, others.get(myIndex + 1).getActualPosition().x);
            float actualY = map(getY(0.5f), 0, 1, getActualPosition().y, others.get(myIndex + 1).getActualPosition().y);

            return new PVector(actualX, actualY);
        }else{
            return new PVector(0, 0);
        }
    }

    private float getY(float x){
        float s = map(m_curve, 0, 1, 0.001f, 0.999f)/(1-map(m_curve, 0, 1, 0.001f, 0.999f));
        float y;
        if(s == 1){
            y = x;
        }else{
            y = 1 - 1/((s-2+1/s) * x + 1 - 1/s) + 1/(s-1);
        }
        
        return y;
    }

    public float mapXToY(float windowX, ArrayList<AutomationPoint> others, int myIndex){
        if(windowX == m_value.x){
            return m_value.y;
        }

        float curveX = map(windowX, m_value.x, others.get(myIndex + 1).getValue().x, 0, 1);
        float curveY = getY(curveX);

        return map(curveY, 0, 1, m_value.y, others.get(myIndex + 1).getValue().y);
    }

    public boolean checkHitbox(){
        return ( (mouseX - getActualPosition().x) * (mouseX - getActualPosition().x)
                 + (mouseY - getActualPosition().y) * (mouseY - getActualPosition().y) )
                 < (m_radius * m_radius);
    }

    public boolean checkCurveHandleHitbox(ArrayList<AutomationPoint> others, int myIndex){
        return ( (mouseX - getCurveHandlePosition(others, myIndex).x) * (mouseX - getCurveHandlePosition(others, myIndex).x)
                 + (mouseY - getCurveHandlePosition(others, myIndex).y) * (mouseY - getCurveHandlePosition(others, myIndex).y) )
                 < (m_radius * m_radius);
    }

    public void resetCurve(){
        m_curve = 0.5f;
    }

}

//====================================================================

class Tabs extends Controller{

    private int m_value;
    private String[] m_tabName;

    Tabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_value = 0;

        m_tabName = tabName;
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            for(int i = 0; i < m_tabName.length; i++){
                if( mouseX >= (m_pos.x + i * m_len.x/m_tabName.length) &&
                    mouseX <= (m_pos.x + (i + 1) * m_len.x/m_tabName.length) &&
                    mouseY >= m_pos.y && 
                    mouseY <= m_pos.y + m_len.y){

                        m_mouseClicked.x = mouseX;
                        m_mouseClicked.y = mouseY;

                        m_selected = true;

                        m_value = i;
                    }
            }

        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    protected void draw(){
        noStroke();
        fill(m_backgroundColor2);
        rect(m_pos.x, m_pos.y, m_len.x, 4 * m_len.y/5, 10);

        if(m_value > 0){
            rect(m_pos.x, m_pos.y, m_value * m_len.x/m_tabName.length, m_len.y, 10);
        }

        if(m_value < (m_tabName.length - 1)){
            rect(m_pos.x + (m_value + 1) * m_len.x/m_tabName.length, m_pos.y, (m_tabName.length - (m_value + 1)) * m_len.x/m_tabName.length, m_len.y, m_len.y/5);
        }

        fill(m_fillColor);
        rect(m_pos.x + m_value * m_len.x/m_tabName.length, m_pos.y, m_len.x/m_tabName.length, 4 * m_len.y/5);

        stroke(m_backgroundColor1);
        strokeWeight(2);
        for(int i = 1; i < m_tabName.length; i++){
            line(m_pos.x + i * m_len.x/m_tabName.length, m_pos.y + m_len.y/5, m_pos.x + i * m_len.x/m_tabName.length, m_pos.y + 4 * m_len.y/5);
        }

        fill(m_backgroundColor1);
        textAlign(CENTER);
        textSize(m_len.y/2);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i], m_pos.x + (i + 0.5f) * m_len.x/m_tabName.length, m_pos.y + 5 * m_len.y/8);
        }

    }

}
class GUISection{
    protected PVector m_pos;
    protected PVector m_len;
    protected GUISection[] m_section;
    protected Controller[] m_controller;

    float m_spacer = 50;

    GUISection(PVector pos, PVector len, int sectionAmount, int controllerAmount){
        m_pos = pos;
        m_len = len;
        m_section = new GUISection[sectionAmount];
        m_controller = new Controller[controllerAmount];

        initializeSections();
        initializeControllers();
    }

    protected void initializeSections(){
        for(int i = 0; i < m_section.length; i++){

            m_section[i] = new GUISection(m_pos, m_len, 0, 0);
        }
    }

    protected void initializeControllers(){
        for(int i = 0; i < m_controller.length; i++){

            m_controller[i] = new Controller(m_pos, m_len);
        }
    }

    public void update(){
        tick();
        draw();
    }

    protected void tick(){
        //to be overloaded
    }

    protected void draw(){
        drawBackground();
        drawComponents();
        drawSections();
    }

    protected void drawBackground(){
        noStroke();
        fill(10);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);
    }

    protected void drawSections(){
        for(int i = 0; i < m_section.length; i++){

            m_section[i].update();
        }
    }

    protected void drawComponents(){
        for(int i = 0; i < m_controller.length; i++){
            m_controller[i].update();
        }
    }  
    
}

//====================================================================

class MainSection extends GUISection{

    private int m_time = 0;

    MainSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen), 4, 0);

    }

    protected void tick(){
        //if(m_section[0].isTimeAdvancing()){
        //    m_time++;
        //}
    }

    protected void initializeSections(){
        m_section[0] = new MenuSection(m_pos, new PVector(m_len.x, m_spacer));
        m_section[1] = new InputSection(new PVector(m_pos.x, m_pos.y + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
        m_section[2] = new MathSection(new PVector(m_pos.x, m_pos.y + (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
        m_section[3] = new SpectrumSection(new PVector(m_pos.x, m_pos.y + 2 * (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
    }

    protected void drawSections(){
        //m_section[1].setTime(m_time);
        for(int i = 0; i < m_section.length; i++){

            m_section[i].update();
        }
    }

}

//====================================================================

class MenuSection extends GUISection{
    boolean isAdvancingTime = false;

    MenuSection(PVector pos, PVector len){
        super(pos, len, 0, 3);
    }

    protected void initializeControllers(){
        m_controller[0] = new PlayButton(m_pos.x + m_spacer, m_pos.y, m_spacer, m_spacer);
        m_controller[1] = new Button(m_pos.x + 8 * m_spacer/4, m_pos.y, m_spacer, m_spacer);
        m_controller[2] = new Knob(m_pos.x + 13 * m_spacer/4, m_pos.y, m_spacer, m_spacer);
    }

    protected void drawBackground(){
        noStroke();
        fill(40);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);
        textSize(26);
        fill(255, 30);
        text("Menu", 0, 0);
        popMatrix();
    }

    protected void tick(){
        isAdvancingTime = false;
        //if(m_controller[1].getValue()){
        //    isAdvancingTime = true;
        //}
    }


    public boolean isTimeAdvancing(){
        return isAdvancingTime;
    }

}

//====================================================================

class InputSection extends GUISection{
    private Graph m_input;
    private int m_time = 1;

    InputSection(PVector pos, PVector len){
        super(pos, len, 0, 0);

        m_input = new Graph(m_pos.x + m_len.x/4, m_pos.y + m_len.y/8, 3 * m_len.x/5, 3 * m_len.y/4, 50);
    }

    protected void drawBackground(){
        noStroke();
        fill(26, 75, 103);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        textSize(26);
        fill(255, 30);
        text("Input", 0, 0);
        popMatrix();
    }

    protected void drawComponents(){
        for(int i = 0; i < m_controller.length; i++){
            m_controller[i].update();
        }

        
        m_input.draw(m_time);
        m_input.addData(sin(0.1f * m_time), m_time - 1);
        
    }

    public void setTime(int time){
        m_time = time;
    }
}

//====================================================================

class MathSection extends GUISection{
    MathSection(PVector pos, PVector len){
        super(pos, len, 0, 1);
    }

    protected void initializeControllers(){
        m_controller[0] = new Tabs(m_pos.x, m_pos.y, m_len.x, m_len.y/8, new String[]{"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"});
    }

    protected void drawBackground(){
        noStroke();
        fill(26, 75, 103);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        textSize(26);
        fill(255, 30);
        text("Math", 0, 0);
        popMatrix();
    }
}

//====================================================================

class SpectrumSection extends GUISection{
    SpectrumSection(PVector pos, PVector len){
        super(pos, len, 0, 0);
    }

    protected void drawBackground(){
        noStroke();
        fill(26, 75, 103);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        textSize(26);
        fill(255, 30);
        text("Spectrum", 0, 0);
        popMatrix();
    }
}
class Graph{
    private PVector m_pos;
    private PVector m_len;
    private float[] m_data; //goes from -1 to 1
    private int m_color;

    Graph(float xPos, float yPos, float xLen, float yLen, int arrayLength){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);

        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }

        m_color = color(3, 250, 75);
    }

    public void draw(int index){
        index %= m_data.length;

        for(int i = index; i < m_data.length; i++){
            noFill();
            stroke(m_color);
            strokeWeight(2);
            ellipse(m_pos.x + (i - index) * m_len.x / m_data.length, getPointYPos(i), 10, 10);
            line(m_pos.x + (i - index) * m_len.x / m_data.length, getPointYPos(i), m_pos.x + (i - index) * m_len.x / m_data.length, m_pos.y + m_len.y/2);
        }

        for(int i = 0; i < index; i++){
            noFill();
            stroke(m_color);
            strokeWeight(2);
            ellipse(m_pos.x + (i + m_data.length - index) * m_len.x / m_data.length, getPointYPos(i), 10, 10);
            line(m_pos.x + (i + m_data.length - index) * m_len.x / m_data.length, getPointYPos(i), m_pos.x + (i + m_data.length - index) * m_len.x / m_data.length, m_pos.y + m_len.y/2);
        }
    }

    private float getPointYPos(int index){
        return map(m_data[index], -1, 1, m_pos.y + m_len.y, m_pos.y);
    }

    public void addData(float data, int index){
        index %= m_data.length;
        m_data[index] = data;
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
