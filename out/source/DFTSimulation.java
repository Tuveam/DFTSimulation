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

DFTSection m;


public void setup(){
    

    //fullScreen();
    m = new DFTSection(0, 0, width, height);
}

public void draw(){
    m.update();

}
class Automation extends Controller{

    ArrayList<AutomationPoint> m_point = new ArrayList<AutomationPoint>();
    private boolean m_drawBackground = true;
    private float m_baseValue = 0.5f;

    private float m_minRealValue = 0;
    private float m_maxRealValue = 1;

    Automation(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0, 0.5f), m_fillColor) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0.001f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0.999f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(1, 0.5f), m_fillColor) );
    }

    Automation(float xPos, float yPos, float xLen, float yLen, int fillColor, boolean drawBackground){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
        m_fillColor = fillColor;
        m_drawBackground = drawBackground;

        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0, 0.5f), m_fillColor) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0.001f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0.999f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(1, 0.5f), m_fillColor) );
    }

    public void setBaseValue(float baseValue){
        m_baseValue = baseValue;
    }

    public void setRealValueRange(float minRealValue, float maxRealValue){
        m_minRealValue = minRealValue;
        m_maxRealValue = maxRealValue;
    }

    private void insertPointAtIndex(AutomationPoint insert, ArrayList<AutomationPoint> toSort, int index){
        toSort.add(new AutomationPoint( new PVector(0, 0), new PVector(0, 0), new PVector(0, 0), m_fillColor));

        for(int i = toSort.size() - 2; i >= index; i--){
            toSort.set(i + 1, toSort.get(i));
        }

        toSort.set(index, insert);
    }

    protected void click(){
        if(mousePressed && m_firstClick && mouseButton == RIGHT){
            m_firstClick = false;

            boolean createPoint = true;

            for(int i = 1; i < m_point.size() - 1 && createPoint; i++){
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

                    insertPointAtIndex(new AutomationPoint(m_pos, m_len, temp, m_fillColor), m_point, index);

                }
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    public void draw(){
        
        if(m_drawBackground){//background
            drawBackground();
        }

        //points and shape
        beginShape();
        vertex(m_pos.x, m_pos.y + m_len.y * m_baseValue);
        for(int i = 0; i < m_point.size(); i++){
            m_point.get(i).update(m_point, i);
            PVector temp = m_point.get(i).getActualPosition();
            vertex(temp.x, temp.y);
        }
        vertex(m_pos.x + m_len.x, m_pos.y + m_len.y * m_baseValue);

        noStroke();
        fill(m_fillColor, 75);
        endShape(CLOSE);

    }

    public void drawBackground(){
        pushMatrix();
        translate(m_pos.x, m_pos.y);
        fill(m_backgroundColor2);
        stroke(m_backgroundColor1);
        strokeWeight(2);
        rect(0, 0, m_len.x, m_len.y);
        popMatrix();
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

    public float mapXToRealY(float x){
        return map(mapXToY(x), 0, 1, m_minRealValue, m_maxRealValue);
    }

    public float[] getArray(int index){
        float[] temp = new float[index];

        for(int i = 0; i < temp.length; i++){
            temp[i] = mapXToY(i / temp.length);
        }

        return temp;
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

    AutomationPoint(PVector windowPos, PVector windowLen, PVector value, int fillColor){
        super(windowPos, windowLen);

        m_value = value;
        m_curve = 0.5f;
        m_previousCurve = m_curve;

        setColor(m_backgroundColor1, m_backgroundColor2, fillColor);
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

        m_fillColor = color(75, 170, 75);
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

    public void setColor(int capColor, int barColor, int fillColor){
        m_backgroundColor2 = capColor;
        m_backgroundColor1 = barColor;
        m_fillColor = fillColor;
    }

}

//====================================================================

class Knob extends Controller{

    private float m_value;
    private float m_previousValue;

    private float m_minRealValue = 0;
    private float m_maxRealValue = 1;

    private float m_sensitivity = 0.25f;

    private String m_name;
    

    Knob(float xPos, float yPos, float xLen, float yLen, String name){
        super(new PVector(xPos, yPos), new PVector((xLen < yLen)? xLen : yLen, (xLen < yLen)? xLen : yLen));
        m_value = 0.8f;

        m_name = name;
        
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
        translate(m_pos.x + m_len.x / 2, m_pos.y + getKnobLen() / 2);

        //Bar
        noStroke();
        fill(m_backgroundColor1);
        arc(0, 0, getKnobLen(), getKnobLen(), PI * 3 / 4, PI * 9 / 4, PIE);

        //Fill
        float angle = map(m_value, 0, 1, PI * 3 / 4, PI * 9 / 4);
        noStroke();
        fill(m_fillColor);
        arc(0, 0, getKnobLen(), getKnobLen(), PI * 3 / 4, angle, PIE);

        
        //Cap
        noStroke();
        fill(m_backgroundColor2);
        ellipse(0, 0, 0.8f * getKnobLen(), 0.8f * getKnobLen());

        //indicator line
        stroke(m_fillColor);
        strokeWeight(3);
        line(0.1f * getKnobLen() * cos(angle), 0.1f * getKnobLen() * sin(angle), 0.3f * getKnobLen() * cos(angle), 0.3f * getKnobLen() * sin(angle));

        popMatrix();

        //name
        textAlign(CENTER);
        fill(m_backgroundColor1);
        textSize(getTextLenY());
        if(m_selected){
            text(getRealValue(), m_pos.x + m_len.x/2, m_pos.y + getKnobLen() + getTextLenY()/2);
        }else{
            text(m_name, m_pos.x + m_len.x/2, m_pos.y + getKnobLen() + getTextLenY()/2);
        }
        
        
    }

    private float getKnobLen(){
        return (0.8f * m_len.x);
    }

    private float getTextLenY(){
        return (m_len.y - getKnobLen());
    }

    public float getValue(){
        return m_value;
    }

    public float getRealValue(){
        return map(m_value, 0, 1, m_minRealValue, m_maxRealValue);
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

        if(!m_pressed && !m_selected && m_value){
            m_value = false;
        }

        if(!m_selected && m_pressed){
            m_value = true;
            m_pressed = false;
            m_tickCooldown = 0;
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



class GUISection{
    protected PVector m_pos;
    protected PVector m_len;

    protected float m_spacer = 65;

    GUISection(PVector pos, PVector len){
        m_pos = pos;
        m_len = len;

        initializeControllers();
        initializeSections();
    }

    protected void initializeControllers(){

    }

    protected void initializeSections(){

    }

    public void update(){
        draw();
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

    }

    protected void drawComponents(){

    }  
}

//====================================================================

class DFTSection extends GUISection{

    MenuSection m_menuSection;
    InputSection m_inputSection;
    MathSection m_mathSection;
    SpectrumSection m_spectrumSection;


    DFTSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }
    
    protected void initializeSections(){
        int totalWindowLength = 50;
        int testFreqAmount = totalWindowLength;

        m_menuSection = new MenuSection(m_pos, new PVector(m_len.x, m_spacer));
        m_inputSection = new InputSection(new PVector(m_pos.x, m_pos.y + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), testFreqAmount, totalWindowLength);
        m_mathSection = new MathSection(new PVector(m_pos.x, m_pos.y + (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), testFreqAmount, totalWindowLength);
        m_spectrumSection = new SpectrumSection(new PVector(m_pos.x, m_pos.y + 2 * (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), testFreqAmount/2);
    }

    protected void drawSections(){
        if(m_menuSection.isTimeAdvancing()){
            m_inputSection.advanceTime();
        }

        if(m_mathSection.hasChangedTestFreq()){
            m_inputSection.setTestFreq(m_mathSection.getTestFreq());
        }

        if(true){
            m_mathSection.setData(m_inputSection.getMultiplicationData());
        }

        if(true){
            m_spectrumSection.setData(m_inputSection.getSpectrum());
        }

        m_menuSection.update();
        m_inputSection.update();
        m_mathSection.update();
        m_spectrumSection.update();
    }

}

//====================================================================

class MenuSection extends GUISection{
    PlayButton m_playButton;
    Button m_skipButton;
    Knob m_sampleRateKnob;

    int m_iterateTime = 0;
    boolean m_isAdvancingTime = false;

    int m_blink = 0;

    MenuSection(PVector pos, PVector len){
        super(pos, len);
    }

    protected void initializeControllers(){
        m_playButton = new PlayButton(m_pos.x + m_spacer, m_pos.y, m_spacer, m_spacer);
        m_skipButton = new Button(m_pos.x + 8 * m_spacer/4, m_pos.y, m_spacer, m_spacer);
        m_sampleRateKnob = new Knob(m_pos.x + 13 * m_spacer/4, m_pos.y, m_spacer, m_spacer, "Samplerate");
        m_sampleRateKnob.setRealValueRange(60, 1);
    }

    public void update(){
        draw();

        m_isAdvancingTime = false;
        if(m_playButton.getValue()){
            if(m_iterateTime >= m_sampleRateKnob.getRealValue()){
                m_isAdvancingTime = true;
                m_iterateTime = 0;
            }

            m_iterateTime++;
        }else if(m_skipButton.getValue()){
            m_isAdvancingTime = true;
        }
    }

    protected void drawBackground(){
        noStroke();
        fill(40);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();

        blink();
    }

    private void blink(){
        if(m_isAdvancingTime){
            m_blink = 10;
        }

        fill(map(m_blink, 0, 10, 0, 255), 0, 0);
        noStroke();
        ellipse(m_pos.x + m_len.x - m_len.y/2, m_pos.y + m_len.y/2, m_len.y, m_len.y);

        if(m_blink > 0){
            m_blink--;
        }
    }

    protected void drawComponents(){
        m_playButton.update();
        m_skipButton.update();
        m_sampleRateKnob.update();
    }

    public boolean isTimeAdvancing(){
        return m_isAdvancingTime;
    }

}

//====================================================================

class InputSection extends GUISection{
    private Tickbox m_sectionTickbox;
    private Generator m_generator;

    private Tickbox m_testFreqTickbox;
    private Tickbox m_windowShapeTickbox;
    

    private int m_sampleNumber;

    SignalDisplay m_signalDisplay;

    boolean multiplicationChanged = true;
    boolean spectrumChanged = true;

    InputSection(PVector pos, PVector len, int testFreqAmount, int sampleNumber){
        super(pos, len);

        m_sampleNumber = sampleNumber;
        m_generator = new Generator(m_pos.x + m_spacer/2,
                                    m_pos.y + m_spacer / 2,
                                    2 * m_len.x / 7,
                                    5 * m_spacer / 3,
                                    m_spacer, m_sampleNumber);
        m_signalDisplay = new SignalDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7,
                                            m_len.y - m_spacer,
                                            testFreqAmount,
                                            m_sampleNumber);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2);
        m_testFreqTickbox = new Tickbox(m_pos.x + m_spacer/2,
                                        m_pos.y + 5 * m_spacer / 2,
                                        m_spacer/3,
                                        m_spacer/3);
        m_windowShapeTickbox = new Tickbox(m_pos.x + m_spacer/2,
                                        m_pos.y + 19 * m_spacer / 6,
                                        m_spacer/3,
                                        m_spacer/3);
        
    }

    protected void drawBackground(){
        noStroke();
        fill(13, 37, 51);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_generator.update();

            noStroke();
            fill(100, 128);
            rect(m_pos.x + m_spacer/2,
                m_pos.y + 5 * m_spacer / 2 - m_spacer / 12,
                2 * m_len.x / 7,
                m_spacer/2,
                m_spacer/8);
            
            fill(150);
            textSize(m_spacer /5);
            textAlign(LEFT);
            text("Test Frequency",
                m_pos.x + m_spacer,
                m_pos.y + 5 * m_spacer / 2 + m_spacer / 4);
            m_testFreqTickbox.update();

            noStroke();
            fill(100, 128);
            rect(m_pos.x + m_spacer/2,
                m_pos.y + 19 * m_spacer / 6 - m_spacer / 12,
                2 * m_len.x / 7,
                m_spacer/2,
                m_spacer/8);
            
            fill(150);
            textSize(m_spacer /5);
            textAlign(LEFT);
            text("Window Shape",
                m_pos.x + m_spacer,
                m_pos.y + 19 * m_spacer / 6 + m_spacer / 4);
            m_windowShapeTickbox.update();

            m_signalDisplay.setInputVisibility(m_generator.isOn());
            m_signalDisplay.setTestFreqVisibility(m_testFreqTickbox.getValue());
            m_signalDisplay.setAutomationVisibility(m_windowShapeTickbox.getValue());

            m_signalDisplay.draw();

            //m_windowShape.update();
        }
        
        
    }

    public void advanceTime(){
        //println((frameCount%2 == 0)? "tick" : "tack");
        m_generator.advanceTime();

        m_signalDisplay.setDataForInput(m_generator.getArray());
    }

    public void setTestFreq(int testFreq){
        m_signalDisplay.setTestFreq(testFreq);
    }

    public float[] getMultiplicationData(){
        return m_signalDisplay.getMultipliedArray();
    }

    public float[] getSpectrum(){
        return m_signalDisplay.getSpectrum();
    }
}

//====================================================================

class MathSection extends GUISection{
    private SinCosTabs m_tabs;
    private int m_testFreq = 0;
    private Tickbox m_sectionTickbox;
    OneGraphDisplay m_mult;


    MathSection(PVector pos, PVector len, int testFreqAmount, int sampleNumber){
        super(pos, len);

        String[] temp = new String[testFreqAmount];

        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + (i % (temp.length/2) )).substring(1);
        }

        m_tabs = new SinCosTabs(m_pos.x + m_spacer/2, m_pos.y, m_len.x - m_spacer/2, m_spacer/2, temp);

        m_mult = new OneGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7, m_pos.y + m_spacer/2, m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7, m_len.y - m_spacer, sampleNumber);
    }

    protected void initializeControllers(){
        
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2);
    }


    protected void drawBackground(){
        noStroke();
        fill(51, 13, 37);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_tabs.update();

            m_mult.draw();
        }
        
        
    }

    public boolean hasChangedTestFreq(){
        boolean temp = (m_testFreq == m_tabs.getValue());
        m_testFreq = m_tabs.getValue();
        return temp;
    }

    public int getTestFreq(){
        return m_tabs.getValue();
    }

    public void setData(float[] data){
        m_mult.setData(data);
    }
}

//====================================================================

class SpectrumSection extends GUISection{
    private Tickbox m_sectionTickbox;

    private OneGraphDisplay m_spectrum;

    SpectrumSection(PVector pos, PVector len, int testFreqAmount){
        super(pos, len);

        m_spectrum = new OneGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7, m_pos.y + m_spacer/2, m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7, m_len.y - m_spacer, testFreqAmount);
        m_spectrum.setAsSpectrumDisplay();
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2);
    }

    protected void drawBackground(){
        noStroke();
        fill(37, 51, 13);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_spectrum.draw();
        }
        
        
    }

    public void setData(float[] data){
        m_spectrum.setData(data);
    }
}
class Generator{
    protected PVector m_pos;
    protected PVector m_len;
    private float m_spacer;

    int m_time = 0;
    float[] m_data; //goes from -1 to 1
    float m_phase = 0; //goes from 0 to 1

    private Tickbox m_switch;
    private Knob[] m_knob;
    private Tabs m_tabs;

    
    

    Generator(float xPos, float yPos, float xLen, float yLen, float spacer, int arrayLength){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);
        m_spacer = spacer;

        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }

        m_switch = new Tickbox(m_pos.x, m_pos.y, (m_len.y - m_spacer) / 2, (m_len.y - m_spacer) / 2);

        m_knob = new Knob[3];

        m_knob[0] = new Knob(m_pos.x, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Frequency");
        m_knob[0].setRealValueRange(0.5f, m_data.length/2);

        m_knob[1] = new Knob(m_pos.x + 1 * m_len.x / 3, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Phase");
        m_knob[1].setRealValueRange(0, TWO_PI);

        m_knob[2] = new Knob(m_pos.x + 2 * m_len.x / 3, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Amplitude");

        m_tabs = new Tabs(m_pos.x, m_pos.y + m_len.y / 2 + m_spacer / 2, m_len.x, m_len.y / 2 - m_spacer / 2, new String[]{"0", "sin", "saw", "noise"});
    }

    public void update(){
        noStroke();
        fill(100, 128);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 5);

        fill(150);
        textSize((m_len.y - m_spacer) /3);
        textAlign(LEFT);
        text("Generator", m_pos.x + (m_len.y - m_spacer) / 2, m_pos.y + (m_len.y - m_spacer) / 3);

        m_switch.update();

        if(m_switch.getValue()){
            for(int i = 0; i < m_knob.length; i++){
                m_knob[i].update();
            }

            m_tabs.update();

        }
        
    }

    public void advanceTime(){
        if(m_switch.getValue()){
            m_phase = (m_phase + m_knob[0].getRealValue() / m_data.length)%1;

            switch(m_tabs.getValue()){
                case 0: //Zero
                m_data[getFirstIndex()] = 0;
                break;
                case 1: //Sin
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * sin( 2 * PI * (m_phase + m_knob[1].getValue()) );
                break;
                case 2: //Saw
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * (2.0f * (m_phase + m_knob[1].getValue()) % 2 - 1);
                break;
                case 3: //Noise
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * random(-1, 1);
                break;
            }
            m_time++;
        }
    }

    public float[] getArray(){
        float[] temp = new float[m_data.length];
        for(int i = 0; i < m_data.length; i++){
            int tempIndex = (i + getFirstIndex()) % temp.length;
            temp[i] = m_data[tempIndex];
        }
        return temp;
    }

    protected int getFirstIndex(){
        return m_time % m_data.length;
    }

    public boolean isOn(){
        return m_switch.getValue();
    }

}
class Graph{
    private PVector m_pos;
    private PVector m_len;
    private int m_color;

    private float[] m_data;
    private float m_baseValue = 0.5f;
    private float m_minInputValue = -1;
    private float m_maxInputValue = 1;

    private int m_displayMode = 0;

    Graph(float xPos, float yPos, float xLen, float yLen, int resolution){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);

        m_color = color(75, 170, 75);

        m_data = new float[resolution];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }
    }

    public void setBaseValue(float baseValue){
        m_baseValue = baseValue;
    }

    public void setInputValueRange(float minInputValue, float maxInputValue){
        m_minInputValue = minInputValue;
        m_maxInputValue = maxInputValue;
    }

    public void setData(float[] data){
        //println("Graph.setData(): " + data[data.length - 1]);
        if(data.length == m_data.length){
            m_data = data;
        }
    }

    public void setColor(int c){
        m_color = c;
    }

    public void setDisplayMode(int mode){
        m_displayMode = mode;
    }

    public float[] getData(){
        return m_data;
    }

    public void draw(){
        switch(m_displayMode){
            case 0:
            drawPointsAndLines();
            break;

            case 1:
            drawShapeAndLines();
            break;
        }
        
    }

    private void drawPointsAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        for(int i = 0; i < m_data.length; i++){
            
            ellipse(m_pos.x + i * m_len.x / m_data.length,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                10, 10);
            line(m_pos.x + i * m_len.x / m_data.length,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                m_pos.x + i * m_len.x / m_data.length,
                m_pos.y + (1 - m_baseValue) * m_len.y);
        }
    }

    private void drawShapeAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        beginShape();

        for(int i = 0; i < m_data.length; i++){
            vertex(m_pos.x + i * m_len.x / m_data.length,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y));
            line(m_pos.x + i * m_len.x / m_data.length,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                m_pos.x + i * m_len.x / m_data.length,
                m_pos.y + (1 - m_baseValue) * m_len.y);
        }

        
        endShape();
    }

    public int getLength(){
        return m_data.length;
    }
}

//==========================================================================================

class OneGraphDisplay{
    private PVector m_pos;
    private PVector m_len;

    private Graph m_graph;

    OneGraphDisplay(float posX, float posY, float lenX, float lenY, int resolution){
        m_pos = new PVector(posX, posY);
        m_len = new PVector(lenX, lenY);

        m_graph = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        m_graph.setColor(color(75, 140, 140));
    }

    public void setAsSpectrumDisplay(){
        m_graph.setBaseValue(0);
        m_graph.setInputValueRange(0, 0.6f);
        m_graph.setDisplayMode(1);
    }

    public void setData(float[] data){
        m_graph.setData(data);
    }

    public void draw(){
        stroke(color(100, 100, 100));
        strokeWeight(2);
        fill(color(50, 50, 50));
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        m_graph.draw();
    }



}
class SignalDisplay{
    private PVector m_pos;
    private PVector m_len;
    
    boolean m_automationIsVisible = true;
    boolean m_inputIsVisible = true;
    boolean m_testFreqVisible = true;
    int m_testFreqIndex = 0;

    private Automation m_automation;
    private Graph m_input;
    private Graph[] m_testFreq;

    SignalDisplay(float posX, float posY, float lenX, float lenY, int testSineAmount, int resolution){
        m_pos = new PVector(posX, posY);
        m_len = new PVector(lenX, lenY);

        m_automation = new Automation(m_pos.x, m_pos.y, m_len.x, m_len.y,
                                        color(200, 75, 75), false);
        m_automation.setRealValueRange(-1, 1);

        m_input = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        m_input.setColor(color(75, 75, 170));

        m_testFreq = new Graph[testSineAmount];
        for(int i = 0; i < m_testFreq.length; i++){
            m_testFreq[i] = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        }
        setDataForTestFreqs();

        
    }

    private void setDataForTestFreqs(){
        for(int i = 0; i < m_testFreq.length; i++){
            float[] temp = new float[m_testFreq[0].getLength()];

            if(i < m_testFreq.length/2){
                for(int x = 0; x < temp.length; x++){
                    temp[x] = sin(i * TWO_PI * x / temp.length);
                }
            }else{
                for(int x = 0; x < temp.length; x++){
                    temp[x] = cos((i % (m_testFreq.length/2) ) * TWO_PI * x / temp.length);
                }
            }

            m_testFreq[i].setData(temp);
        }
    }

    public void setDataForInput(float[] data){
        m_input.setData(data);
        //println("SignalDisplay.setDataForInput(): " + data[data.length - 1]);
    }

    public void setInputVisibility(boolean isVisible){
        m_inputIsVisible = isVisible;
    }

    public void setTestFreqVisibility(boolean isVisible){
        m_testFreqVisible = isVisible;
    }

    public void setTestFreq(int testFreqIndex){
        m_testFreqIndex = testFreqIndex;
    }

    public void setAutomationVisibility(boolean isVisible){
        m_automationIsVisible = isVisible;
    }

    public float[] getMultipliedArray(int withTestFreq){
        float[] temp = new float[m_input.getData().length];

        float[] ip = m_input.getData();

        float[] tf = new float[m_input.getData().length];

        if(m_testFreqVisible){
            tf = m_testFreq[withTestFreq].getData();
        }
        

        for(int i = 0; i < temp.length; i++){
            temp[i] = ip[i];

            if(m_automationIsVisible){
                temp[i] *= m_automation.mapXToRealY(i / (1.0f * temp.length));
            }

            if(m_testFreqVisible){
                
                temp[i] *= tf[i];
            }
            
        }

        return temp;
    }

    public float[] getMultipliedArray(){
        return getMultipliedArray(m_testFreqIndex);
    }

    public float getMultipliedArrayAdded(int withTestFreq){
        float ret = 0;

        float[] temp = getMultipliedArray(withTestFreq);

        for(int i = 0; i < temp.length; i++){
            ret += temp[i];
        }

        return ret / temp.length;
    }

    public float getMultipliedArrayAdded(){
        return getMultipliedArrayAdded(m_testFreqIndex);
    }

    public float[] getSpectrum(){
        int freqAmount = m_testFreq.length / 2;
        float[] temp = new float[freqAmount];

        for(int i = 0; i < freqAmount; i++){
            temp[i] = sqrt(getMultipliedArrayAdded(i) * getMultipliedArrayAdded(i)
                        + getMultipliedArrayAdded(i + freqAmount) * getMultipliedArrayAdded(i + freqAmount));
        }

        return temp;
    }


    public void draw(){
        stroke(color(100, 100, 100));
        strokeWeight(2);
        fill(color(50, 50, 50));
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        

        if(m_testFreqVisible){
            //println("Yes" + m_testFreq[i].getData());
            m_testFreq[m_testFreqIndex].draw();
        }

        if(m_inputIsVisible){
            m_input.draw();
        }
        
        if(m_automationIsVisible){
            m_automation.update();
        }
        
    }

}
class Tabs extends Controller{

    protected int m_value;
    protected String[] m_tabName;

    Tabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_value = 0;

        m_tabName = tabName;
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            if(mouseX >= m_pos.x &&
                mouseX <= m_pos.x + m_len.x &&
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                int xPartitions = m_tabName.length;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = constrain(floor(xPartitions * (mouseX - m_pos.x)/m_len.x), 0, m_tabName.length - 1);

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

    public int getValue(){
        return m_value;
    }

}

//====================================================================

class SinCosTabs extends Tabs{

    SinCosTabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(xPos, yPos, xLen, yLen, tabName);
    }

    public void draw(){
        int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(m_pos.x,
            m_pos.y + m_len.y/10,
            m_len.x,
            4 * m_len.y / 5);
        
        //Unmarked Tabs
        if(m_value < xPartitions){
            //Upper Deck
            if(m_value > 0){//Left
                rect(m_pos.x, m_pos.y,
                    m_value * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }

            if(m_value < xPartitions - 1){//Right
                rect(m_pos.x + (m_value + 1) * m_len.x / xPartitions,
                    m_pos.y,
                    (xPartitions - m_value) * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }

            //Lower Deck
            rect(m_pos.x, m_pos.y + m_len.y/2, m_len.x, m_len.y/2, m_len.y/10);
        }else{
            //Upper Deck
            rect(m_pos.x, m_pos.y, m_len.x, m_len.y/2, m_len.y/10);

            //Lower Deck
            if((m_value % xPartitions) > 0){//Left
                rect(m_pos.x,
                    m_pos.y + m_len.y/2,
                    (m_value % xPartitions) * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }

            if((m_value % xPartitions) < xPartitions - 1){
                rect(m_pos.x + ((m_value % xPartitions) + 1) * m_len.x / xPartitions,
                    m_pos.y + m_len.y/2,
                    (xPartitions - (m_value % xPartitions)) * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }
        }
        
        //Marked Tab
        noStroke();
        fill(m_fillColor);
        rect(m_pos.x + (m_value % xPartitions) * m_len.x / xPartitions,
            m_pos.y + m_len.y/10 + (m_value / xPartitions) * m_len.y * 2 / 5,
            m_len.x / xPartitions,
            m_len.y * 2 / 5);

        //Lines
        stroke(m_backgroundColor1);
        strokeWeight(2);
        //line(m_pos.x, m_pos.y + m_len.y/2, m_pos.x + m_len.x, m_pos.y + m_len.y/2);

        for(int i = 1; i < xPartitions; i++){
            line(m_pos.x + i * m_len.x / xPartitions,
                m_pos.y + m_len.y/10,
                m_pos.x + i * m_len.x / xPartitions,
                m_pos.y + 9 * m_len.y/10);
        }

        //Tabnames
        fill(m_backgroundColor1);
        textAlign(CENTER);
        textSize(m_len.y/2);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i],
                m_pos.x + ((i % xPartitions) + 0.5f) * m_len.x/xPartitions,
                m_pos.y + 5 * m_len.y/12 + (i / xPartitions) * m_len.y/2);
        }
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            
            m_firstClick = false;

            if(mouseX >= m_pos.x &&
                mouseX <= m_pos.x + m_len.x &&
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = constrain(xPartitions * round((mouseY - m_pos.y)/m_len.y) + floor(xPartitions * (mouseX - m_pos.x)/m_len.x), 0, m_tabName.length - 1);

            }

        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
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
