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
    

    //savePNG();

    //fullScreen();
    m = new MainSection(new Bounds(0, 0, width, height));

    
}

public void draw(){
    m.update();

}
class AliasingSection extends GUISection{

    protected AliasInputSection m_inputSection;
    protected InterpolationSection m_interpolationSection;

    AliasingSection(Bounds b){
        super(b);
    }

    protected void initializeSections(){
        m_inputSection = new AliasInputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(0, 2
            ).withFrame(m_spacer/8));
        m_interpolationSection = new InterpolationSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(1, 2
            ).withFrame(m_spacer/8));
    }


    protected void drawSections(){
        m_interpolationSection.setData(m_inputSection.getSampledData());

        m_inputSection.update();
        m_interpolationSection.update();
    }

}

//====================================================================

class AliasInputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected InstantGenerator m_generator;
    protected Knob m_sampleRate;
    protected AliasGraphDisplay m_graphDisplay;

    AliasInputSection(Bounds b){
        super(b);

        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Input");

        Bounds area = m_bounds.withFrame(m_spacer/4);

        int resolution = floor(area.withoutLeftRatio(2.0f/7).getXLen());

        m_generator = new InstantGenerator(
                area.withoutRightRatio(5.0f/7
                ).asSectionOfYDivisions(0, 2
                ).withFrame(m_spacer/4),
                m_spacer,
                resolution);
        m_generator.setFrequencyRange(0.5f, 25);
        m_generator.setFrequency(1);


        int maxSamplerate = 150;
        m_sampleRate = new Knob(area.withoutTopRatio(0.5f).withLen(m_spacer, m_spacer),
                                "Samplerate");
        m_sampleRate.setRealValueRange(1, maxSamplerate);
        m_sampleRate.setRealValue(20);
        m_sampleRate.setSnapSteps(maxSamplerate - 1);

        m_graphDisplay = new AliasGraphDisplay(area.withoutLeftRatio(2.0f/7),
                                            resolution,
                                            maxSamplerate);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_generator.update();

            m_sampleRate.update();

            m_graphDisplay.setSampleRate(floor(m_sampleRate.getRealValue()));
            m_graphDisplay.setData(m_generator.getArray());

            m_graphDisplay.draw();
        }
        
    }

    public float[] getSampledData(){
        return m_graphDisplay.getSampledData();
    }

}

//====================================================================

class InterpolationSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    InterpolationGraphDisplay m_graphDisplay;

    InterpolationSection(Bounds b){
        super(b);

        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Interpolated");
        Bounds area = m_bounds.withFrame(m_spacer/4);
        m_graphDisplay = new InterpolationGraphDisplay(area.withoutLeftRatio(2.0f/7));

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            
            m_graphDisplay.draw();
        }
        
    }

    public void setData(float[] data){
        m_graphDisplay.setData(data);
    }

}
class Automation extends Controller{

    ArrayList<AutomationPoint> m_point = new ArrayList<AutomationPoint>();
    private boolean m_drawBackground = true;
    private float m_baseValue = 0.5f;

    private float m_minRealValue = 0;
    private float m_maxRealValue = 1;

    Automation(Bounds b){
        super(b);

        m_point.add( new AutomationPoint(b, new PVector(0, 0.5f), m_fillColor) );
        m_point.add( new AutomationPoint(b, new PVector(0.001f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(b, new PVector(0.999f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(b, new PVector(1, 0.5f), m_fillColor) );
    }

    Automation(Bounds b, int fillColor, boolean drawBackground){
        super(b);
        m_fillColor = fillColor;
        m_drawBackground = drawBackground;

        m_point.add( new AutomationPoint(b, new PVector(0, 0.5f), m_fillColor) );
        m_point.add( new AutomationPoint(b, new PVector(0.001f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(b, new PVector(0.999f, 1), m_fillColor) );
        m_point.add( new AutomationPoint(b, new PVector(1, 0.5f), m_fillColor) );
    }

    public void setBaseValue(float baseValue){
        m_baseValue = baseValue;
    }

    public void setRealValueRange(float minRealValue, float maxRealValue){
        m_minRealValue = minRealValue;
        m_maxRealValue = maxRealValue;
    }

    private void insertPointAtIndex(AutomationPoint insert, ArrayList<AutomationPoint> toSort, int index){
        toSort.add(new AutomationPoint( new Bounds(0, 0, 0, 0), new PVector(0, 0), m_fillColor));

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
                if( m_bounds.checkHitbox(mouseX, mouseY)){

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

                    PVector temp = new PVector( (mouseX - m_bounds.getXPos()) / m_bounds.getXLen(), 1 - (mouseY - m_bounds.getYPos()) / m_bounds.getYLen());

                    insertPointAtIndex(new AutomationPoint(m_bounds, temp, m_fillColor), m_point, index);

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
        vertex(m_bounds.getXPos(),
                m_bounds.getYPos() + m_bounds.getYLen() * m_baseValue);
        for(int i = 0; i < m_point.size(); i++){
            m_point.get(i).update(m_point, i);
            PVector temp = m_point.get(i).getActualPosition();
            vertex(temp.x, temp.y);
        }
        vertex(m_bounds.getXPos() + m_bounds.getXLen(),
                m_bounds.getYPos() + m_bounds.getYLen() * m_baseValue);

        noStroke();
        fill(m_fillColor, 30);
        endShape(CLOSE);

    }

    public void drawBackground(){
        fill(m_backgroundColor2);
        stroke(m_backgroundColor1);
        strokeWeight(2);
        rect(m_bounds);
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

    AutomationPoint(Bounds windowBounds, PVector value){
        super(windowBounds);

        m_value = value;
        m_curve = 0.5f;
        m_previousCurve = m_curve;
    }

    AutomationPoint(Bounds windowBounds, PVector value, int fillColor){
        super(windowBounds);

        m_value = value;
        m_curve = 0.5f;
        m_previousCurve = m_curve;

        setColor(m_backgroundColor1, m_backgroundColor2, fillColor);
    }

    public PVector getActualPosition(){
        return new PVector(m_bounds.getXPos() + m_value.x * m_bounds.getXLen(),
                        m_bounds.getYPos() + (1 - m_value.y) * m_bounds.getYLen());
    }

    private void setActualPosition(float x, float y){
        m_value.x = (x - m_bounds.getXPos()) / m_bounds.getXLen();
        m_value.y = 1 - (y - m_bounds.getYPos()) / m_bounds.getYLen();
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
                    m_curve = m_previousCurve + m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_bounds.getYLen();
                }else{
                    m_curve = m_previousCurve - m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_bounds.getYLen();
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
class Bounds{
    private PVector m_pos;
    private PVector m_len;

//_________________Constructors_________________________________________________
    Bounds(float xPos, float yPos, float xLen, float yLen){
        construct(xPos, yPos, xLen, yLen);
    }

    Bounds(PVector pos, PVector len){
        construct(pos.x, pos.y, len.x, len.y);
    }

    Bounds(Bounds in){
        construct(in.getXPos(), in.getYPos(), in.getXLen(), in.getYLen());
    }

    private void construct(float xPos, float yPos, float xLen, float yLen){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);
    }

//_________________getterFunctions______________________________________________
    public float getXPos(){ return m_pos.x; }

    public float getYPos(){ return m_pos.y; }

    public PVector getPos(){ return m_pos; }

    public float getXLen(){ return m_len.x; }

    public float getYLen(){ return m_len.y; }

    public PVector getLen(){ return m_len; }

//_________________Hitbox_______________________________________________________

    public boolean checkHitbox(float x, float y){
        return (
            x < m_pos.x + m_len.x &&
            x > m_pos.x &&
            y < m_pos.y + m_len.y &&
            y > m_pos.y
        );
    }

    public int checkHitboxXPartition(float x, int xPartitions){
        return constrain(floor(xPartitions * (x - m_pos.x)/m_len.x), 0, xPartitions - 1);
    }

    public int checkHitboxYPartition(float y, int yPartitions){
        return constrain(floor(yPartitions * (y - m_pos.y)/m_len.y), 0, yPartitions - 1);
    }
    
//_________________withPosAndLen________________________________________________ 
    public Bounds withPosAndLen(float xPos, float yPos, float xLen, float yLen){
        return new Bounds(xPos, yPos, xLen, yLen);
    }
    
    public Bounds withPosAndLen(PVector newPos, PVector newLen){
        return withPosAndLen(newPos.x, newPos.y, newLen.x, newLen.y);
    }

//_________________withPos______________________________________________________ 
    public Bounds withPos(float xPos, float yPos){
        return withPosAndLen(xPos, yPos, m_len.x, m_len.y);
    }

    public Bounds withPos(PVector newPos){
        return withPos(newPos.x, newPos.y);
    }

    public Bounds withXPos(float xPos){
        return withPos(xPos, m_pos.y);
    }

    public Bounds withYPos(float yPos){
        return withPos(m_pos.x, yPos);
    }

//_________________withLen______________________________________________________ 
    public Bounds withLen(float xLen, float yLen){
        return withPosAndLen(m_pos.x, m_pos.y, xLen, yLen);
    }

    public Bounds withLen(PVector newLen){
        return withLen(newLen.x, newLen.y);
    }

    public Bounds withXLen(float xLen){
        return withLen(xLen, m_len.y);
    }

    public Bounds withYLen(float yLen){
        return withLen(m_len.x, yLen);
    }

//_________________without_side_________________________________________________ 
    public Bounds withoutLeft(float remove){
        return withPosAndLen(m_pos.x + remove, m_pos.y, m_len.x - remove, m_len.y);
    }

    public Bounds withoutLeftRatio(float removeRatio){
        return withoutLeft(m_len.x * removeRatio);
    }

    public Bounds withoutRight(float remove){
        return withPosAndLen(m_pos.x, m_pos.y, m_len.x - remove, m_len.y);
    }

    public Bounds withoutRightRatio(float removeRatio){
        return withoutRight(m_len.x * removeRatio);
    }

    public Bounds withoutTop(float remove){
        return withPosAndLen(m_pos.x, m_pos.y + remove, m_len.x, m_len.y - remove);
    }

    public Bounds withoutTopRatio(float removeRatio){
        return withoutTop(m_len.y * removeRatio);
    }

    public Bounds withoutBottom(float remove){
        return withPosAndLen(m_pos.x, m_pos.y, m_len.x, m_len.y - remove);
    }

    public Bounds withoutBottomRatio(float removeRatio){
        return withoutBottom(m_len.y * removeRatio);
    }

//_________________framing______________________________________________________ 
    public Bounds withFrame(float frameThickness){
        return withPosAndLen(m_pos.x + frameThickness,
                            m_pos.y + frameThickness,
                            m_len.x - 2 * frameThickness,
                            m_len.y - 2 * frameThickness);
    }

    public Bounds withFrameRatio(float frameRatio){
        float frameThickness = (m_len.x < m_len.y)? (m_len.x * frameRatio) : (m_len.y * frameRatio) ;
        return withFrame(frameThickness);
    }

    public Bounds withXFrame(float frameThickness){
        return withPosAndLen(m_pos.x + frameThickness,
                            m_pos.y,
                            m_len.x - 2 * frameThickness,
                            m_len.y);
    }

    public Bounds withXFrameRatio(float frameRatio){
        return withXFrame(m_len.x * frameRatio);
    }

    public Bounds withYFrame(float frameThickness){
        return withPosAndLen(m_pos.x,
                            m_pos.y + frameThickness,
                            m_len.x,
                            m_len.y - 2 * frameThickness);
    }

    public Bounds withYFrameRatio(float frameRatio){
        return withYFrame(m_len.y * frameRatio);
    }

//_________________Squares______________________________________________________

    public Bounds withCenteredSquare(){
        float side = (m_len.x < m_len.y)? m_len.x : m_len.y;

        return withPosAndLen(m_pos.x + m_len.x/2 - side/2,
                            m_pos.y + m_len.y/2 - side/2,
                            side,
                            side);
    }

    public Bounds withLeftSquare(){
        float side = (m_len.x < m_len.y)? m_len.x : m_len.y;

        return withPosAndLen(m_pos.x,
                            m_pos.y + m_len.y/2 - side/2,
                            side,
                            side);
    }

//_________________Sections_____________________________________________________

    public Bounds fromToSectionOfXDivisions(int fromSection, int toSection, int divisions){
        //toSection is exclusive!!
        return withoutLeftRatio((1.0f * fromSection) / divisions).withoutRightRatio(1 - ( 1.0f * (toSection - fromSection) ) / (divisions-fromSection));
    }

    public Bounds asSectionOfXDivisions(int section, int divisions){
        return fromToSectionOfXDivisions(section, section + 1, divisions);
    }

    public Bounds fromToSectionOfYDivisions(int fromSection, int toSection, int divisions){
        //toSection is exclusive!!
        return withoutTopRatio((1.0f * fromSection) / divisions).withoutBottomRatio(1 - ( 1.0f * (toSection - fromSection) ) / (divisions-fromSection));
    }

    public Bounds asSectionOfYDivisions(int section, int divisions){
        return fromToSectionOfYDivisions(section, section + 1, divisions);
    }

    

}

//_________________Translate____________________________________________________
    public void translate(Bounds b){
        translate(b.getXPos(), b.getYPos());
    }
//_________________Rectangle____________________________________________________
    public void rect(Bounds b, float tl, float tr, float br, float bl){
        rectMode(CORNER);
        rect(b.getXPos(), b.getYPos(), b.getXLen(), b.getYLen(), tl, tr, br, bl);
    }

    public void rect(Bounds b, float rounding){
        rect(b, rounding, rounding, rounding, rounding);
    }

    public void rect(Bounds b){
        rect(b, 0);
    }

//_________________Ellipse______________________________________________________

    public void ellipse(Bounds b){
        ellipseMode(CENTER);
        ellipse(b.getXPos() + b.getXLen()/2, b.getYPos() + b.getYLen()/2, b.getXLen(), b.getYLen());
    }

//_________________Arc__________________________________________________________

    public void arc(Bounds b, float startAngle, float endAngle, int arcMode){
        ellipseMode(CENTER);
        arc(b.getXPos() + b.getXLen()/2,
            b.getYPos() + b.getYLen()/2,
            b.getXLen(),
            b.getYLen(),
            startAngle,
            endAngle,
            arcMode);
    }
static class ColorLoader{

    static private boolean m_isConstructed = false;
    static private int[][] m_color;

    ColorLoader(){
    }

    static private void construct(PImage colorPalette){
        if(!m_isConstructed){
            m_isConstructed = true;

            colorPalette.loadPixels();
            m_color = new int[colorPalette.height][colorPalette.width];

            for(int y = 0; y < m_color.length; y++){
                for(int x = 0; x < m_color[0].length; x++){
                    int i = x + colorPalette.width * y;
                    m_color[y][x] = colorPalette.pixels[i];
                }
                
            }
        }
    }

    static public int getColor(int group, int variant){

        if(group < m_color.length && variant < m_color[0].length){
            return m_color[group][variant];
        }

        return m_color[0][0];
        
    }

    static public int getGreyColor(int variant){
        return getColor(0, variant);
    }

    static public int getFillColor(int variant){
        return getColor(1, variant);
    }

    static public int getGraphColor(int variant){
        return getColor(2, variant);
    }

    static public int getBackgroundColor(int variant){
        return getColor(3, variant);
    }

}


public void savePNG(){

    PImage temp = createImage(10, 4, RGB);

    temp.loadPixels();

    //global greys
    temp.pixels[0 * temp.width + 0] = color(228, 228, 228, 255);
    temp.pixels[0 * temp.width + 1] = color(100, 100, 100, 255);
    temp.pixels[0 * temp.width + 2] = color(50, 50, 50, 255);

    //fillcolors
    temp.pixels[1 * temp.width + 0] = color(56, 174, 65, 255);
    temp.pixels[1 * temp.width + 1] = color(56, 174, 65, 255);
    temp.pixels[1 * temp.width + 2] = color(56, 174, 65, 255);

    //graphcolors
    temp.pixels[2 * temp.width + 0] = color(56, 174, 65, 255);
    temp.pixels[2 * temp.width + 1] = color(200, 50, 50, 255);
    temp.pixels[2 * temp.width + 2] = color(224, 211, 36, 255);

    //backgroundcolors
    temp.pixels[3 * temp.width + 0] = color(17, 53, 20, 255);
    temp.pixels[3 * temp.width + 1] = color(65, 19, 19, 255);
    temp.pixels[3 * temp.width + 2] = color(102, 96, 14, 255);

    temp.updatePixels();

    temp.save("ColorPalette.png");
}
class Controller{
    //private float/boolean m_value = 0;
    
    protected Bounds m_bounds;

    protected boolean m_selected = false;
    protected boolean m_firstClick = true;

    protected PVector m_mouseClicked;

    protected int m_fillColor;
    protected int m_backgroundColor1;
    protected int m_backgroundColor2;
    protected int m_textColor;

    protected float m_textSize = 15;
    protected PFont m_font;

    Controller(Bounds b){
        m_bounds = new Bounds(b);

        m_fillColor = ColorLoader.getFillColor(0);
        m_backgroundColor1 = ColorLoader.getGreyColor(1);
        m_backgroundColor2 = ColorLoader.getGreyColor(2);
        m_textColor = ColorLoader.getGreyColor(0);
        m_font = createFont("Arial", m_textSize);
        
        m_mouseClicked = new PVector(mouseX, mouseY);
    }

    public void update(){
        click();
        adjust();
        draw();
    }

    protected void click(){
        
    }

    protected void adjust(){
        //to be inherited and overloaded
    }

    protected void draw(){
        //to be inherited and overloaded
    }

    public void setColor(int capColor, int barColor, int fillColor){
        m_backgroundColor2 = capColor;
        m_backgroundColor1 = barColor;
        m_fillColor = fillColor;
    }

}

//====================================================================

class Knob extends Controller{

    private float m_value;

    private float m_minRealValue = 0;
    private float m_maxRealValue = 1;

    private float m_sensitivity = 4;
    private int m_snapSteps;

    private String m_name;
    

    Knob(Bounds b, String name){
        super(b);
        
        m_value = 0.8f;

        m_name = name;

        m_snapSteps = 4;
        
    }

    protected void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( m_bounds.checkHitbox(mouseX, mouseY) ){

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
            float actualSensitivity = m_sensitivity;
            boolean isSnapping = false;

            if(keyPressed && key == CODED){
                if(keyCode == ALT){
                    actualSensitivity = 10 * m_sensitivity;
                }

                if(keyCode == CONTROL){
                    isSnapping = true;
                    actualSensitivity = m_snapSteps * m_sensitivity / 10.0f;
                }
            }

            if(isSnapping){
                float newValue = map( round( map(
                                m_value + (m_mouseClicked.y - mouseY) / (m_bounds.getYLen() * actualSensitivity),
                                0, 1, 0, m_snapSteps)),
                                0, m_snapSteps, 0, 1);
                if(m_value != newValue){
                    m_value = newValue;

                    m_mouseClicked.x = mouseX;
                    m_mouseClicked.y = mouseY;
                }

            }else{
                m_value = m_value + (m_mouseClicked.y - mouseY) / (m_bounds.getYLen() * actualSensitivity);
                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;
            }

            

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

        Bounds knobBounds = getKnobBounds();


        //Bar
        noStroke();
        fill(m_backgroundColor1);
        arc(knobBounds, PI * 3 / 4, PI * 9 / 4, PIE);

        //Fill
        float angle = map(m_value, 0, 1, PI * 3 / 4, PI * 9 / 4);
        noStroke();
        fill(m_fillColor);
        arc(knobBounds, PI * 3 / 4, angle, PIE);

        
        //Cap
        noStroke();
        fill(m_backgroundColor2);
        ellipse(knobBounds.withFrameRatio(0.1f));

        //indicator line
        stroke(m_fillColor);
        strokeWeight(3);
        line(knobBounds.getXPos() + knobBounds.getXLen()/2 + 0.1f * knobBounds.getXLen() * cos(angle),
            knobBounds.getYPos() + knobBounds.getYLen()/2 + 0.1f * knobBounds.getYLen() * sin(angle), 
            knobBounds.getXPos() + knobBounds.getXLen()/2 + 0.3f * knobBounds.getXLen() * cos(angle), 
            knobBounds.getYPos() + knobBounds.getYLen()/2 + 0.3f * knobBounds.getYLen() * sin(angle));


        //name
        textAlign(CENTER);
        fill(m_textColor);
        textFont(m_font);
        if(m_selected){
            text(getRealValue(),
                m_bounds.getXPos() + m_bounds.getXLen()/2,
                m_bounds.getYPos() + knobBounds.getYLen() + getTextLenY()/2);
        }else{
            text(m_name, 
                m_bounds.getXPos() + m_bounds.getXLen()/2,
                m_bounds.getYPos() + knobBounds.getYLen() + getTextLenY()/2);
        }
        
        
    }


    private Bounds getKnobBounds(){
        return m_bounds.withoutBottomRatio(0.2f).withCenteredSquare();
    }

    private float getTextLenY(){
        return m_textSize /*(m_len.y - getKnobLen())*/;
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

    public void setRealValue(float realValue){
        m_value = map(realValue, m_minRealValue, m_maxRealValue, 0, 1);
    }

    public float getMaxRealValue(){
        return m_maxRealValue;
    }

    public void setSnapSteps(int snapSteps){
        m_snapSteps = snapSteps;
    }
}

//====================================================================

class Tickbox extends Controller{

    protected boolean m_value;

    protected boolean m_pressed = false;

    protected String m_name;


    Tickbox(Bounds b, String name){
        super(b);

        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);

        m_value = true;

        m_name = name;
    }

    protected void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( m_bounds.checkHitbox(mouseX, mouseY) ){

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
        //translate(m_pos.x, m_pos.y);

        float rounding = min(m_bounds.getXLen(), m_bounds.getYLen())/4;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(m_bounds, rounding);
        float indent = 0.1f;

        drawTick(indent, rounding);

        fill(m_textColor);
        textAlign(LEFT);
        textFont(m_font);
        text(m_name, 
            m_bounds.getXPos() + 4 * m_bounds.getXLen()/3,
            m_bounds.getYPos() + m_bounds.getYLen()/2 + m_textSize/3);

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

        rect(m_bounds.withFrameRatio(indent), rounding);

        //Highlight
        if(m_pressed){
            noStroke();
            fill(255, 100);
            rect(m_bounds.withFrameRatio(indent), rounding);
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

//======================================================================

class Button extends Tickbox{
    protected int m_cooldown = 20;
    protected int m_tickCooldown = m_cooldown;

    Button(Bounds b){
        super(b, "");
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
            doTask();
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

    protected void doTask(){

    }

    protected void drawTick(float indent, float rounding){
        noStroke();
        fill(m_backgroundColor1);
        rect(m_bounds.withFrameRatio(indent), rounding);

        fill(m_fillColor, map(m_tickCooldown, 0, 20, 255, 0));
        rect(m_bounds.withFrameRatio(indent), rounding);

        drawTickSymbol(indent, rounding);

    }

    protected void drawTickSymbol(float indent, float rounding){
        if(m_pressed){
            fill(255,100);
            rect(m_bounds.withFrameRatio(indent), rounding);
        }
    }
}

//===========================================================

class SkipButton extends Button{
    SkipButton(Bounds b){
        super(b);
    }

    protected void drawTickSymbol(float indent, float rounding){
        Bounds b = m_bounds.withFrameRatio(3 * indent);

        fill(m_backgroundColor2);
        //rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
        rect(b.withoutLeftRatio(0.6f));
        
        pushMatrix();
        translate(b);
        beginShape();
            vertex(0, 0);
            vertex(0, b.getYLen());
            //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
            vertex(0.6f * b.getXLen(), 0.5f * b.getYLen());
        endShape();
        popMatrix();

        if(m_pressed){
            fill(255,100);
            rect(b.withoutLeftRatio(0.6f));
            
            pushMatrix();
            translate(b);
            beginShape();
                vertex(0, 0);
                vertex(0, b.getYLen());
                //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
                vertex(0.6f * b.getXLen(), 0.5f * b.getYLen());
            endShape();
            popMatrix();
        }
    }
}

//===========================================================

class PlayButton extends Tickbox{

    PlayButton(Bounds b){
        super(b, "");

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

        rect(m_bounds.withFrameRatio(indent), rounding);

        Bounds b = m_bounds.withFrameRatio(3 * indent);

        if(m_value){//PAUSE
            noStroke();
            fill(m_backgroundColor2);
            rect(b.withoutLeftRatio(0.6f));
            rect(b.withoutRightRatio(0.6f));

            if(m_pressed){
                fill(255, 100);
                rect(b.withoutLeftRatio(0.6f));
                rect(b.withoutRightRatio(0.6f));
            }
        }else{//PLAY
            noStroke();
            fill(m_fillColor);

            pushMatrix();
            translate(b);
            beginShape();
                vertex(0, 0);
                vertex(0, b.getYLen());
                //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
                vertex(b.getXLen(), 0.5f * b.getYLen());
            endShape();
            popMatrix();

            if(m_pressed){
                fill(255,100);

                pushMatrix();
                translate(b);
                beginShape();
                    vertex(0, 0);
                    vertex(0, b.getYLen());
                    //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
                    vertex(b.getXLen(), 0.5f * b.getYLen());
                endShape();
                popMatrix();
            }
        }
    }
}

//===========================================================

class LinkButton extends Button{
    String m_link;

    LinkButton(Bounds b){
        super(b);
    }

    public void setLink(String link){
        m_link = link;
    }

    protected void doTask(){
        if(m_link != null){
            link(m_link);
        }
    }

    protected void drawTickSymbol(float indent, float rounding){
        Bounds b = m_bounds.withFrameRatio(3 * indent);

        strokeWeight(m_bounds.getXLen() * indent);
        stroke(m_backgroundColor2);

        pushMatrix();
        translate(b);
        line(0, b.getYLen(), b.getXLen(), 0);
        line(b.getXLen() / 2, 0, b.getXLen(), 0);
        line(b.getXLen(), b.getXLen() / 2, b.getXLen(), 0);
        popMatrix();

        /*line(3 * indent * m_len.x,
            m_len.y - 3 * indent * m_len.y,
            m_len.x - 3 * indent * m_len.x,
            3 * indent * m_len.y);
        line(m_len.x / 2,
            3 * indent * m_len.y,
            m_len.x - 3 * indent * m_len.x,
            3 * indent * m_len.y);
        line(m_len.x - 3 * indent * m_len.x,
            3 * indent * m_len.y,
            m_len.x - 3 * indent * m_len.x,
            m_len.y / 2);*/

        if(m_pressed){
            stroke(255,100);

            pushMatrix();
            translate(b);
            line(0, b.getYLen(), b.getXLen(), 0);
            line(b.getXLen() / 2, 0, b.getXLen(), 0);
            line(b.getXLen(), b.getXLen() / 2, b.getXLen(), 0);
            popMatrix();
        }
    }
}

//===========================================================

class QuestionMarkTickbox extends Tickbox{
    QuestionMarkTickbox(Bounds b){
        super(b, "");

        m_value = false;
    }

    protected void drawTick(float indent, float rounding){
        //Tick
        if(m_value){
            
            fill(m_fillColor);
        }else{
            fill(m_backgroundColor1);
        }
        noStroke();
        rect(m_bounds.withFrameRatio(indent), rounding);

        //Questionmark
        if(m_value){
            
            fill(m_backgroundColor2);
        }else{
            fill(m_fillColor);
        }
        textFont(m_font);
        textSize(m_bounds.getYLen());
        textAlign(CENTER);
        text("?", m_bounds.getXPos() + m_bounds.getXLen()/2,
                m_bounds.getYPos() + m_bounds.getYLen()/2 + 3 * m_bounds.getYLen()/8);

        //Highlight
        if(m_pressed){
            noStroke();
            fill(255, 100);
            rect(m_bounds.withFrameRatio(indent), rounding);
        }
    }
}

//===========================================================

class ForwardButton extends Button{
    ForwardButton(Bounds b){
        super(b);
    }

    protected void draw(){

        float rounding = min(m_bounds.getXLen(), m_bounds.getYLen())/4;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(m_bounds, 0, rounding, rounding, 0);
        float indent = 0.1f;

        drawTick(indent, rounding);
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

        Bounds bTick = m_bounds.withoutRightRatio(indent).withYFrameRatio(indent);

        rect(bTick, 0, rounding, rounding, 0);

        drawTickSymbol(indent, rounding);

        //Highlight
        if(m_pressed){
            noStroke();
            fill(255, 100);
            rect(bTick, 0, rounding, rounding, 0);
        }
    }

    protected void drawTickSymbol(float indent, float rounding){
        Bounds b = m_bounds.withFrameRatio(3 * indent).withCenteredSquare();

        pushMatrix();
        translate(b);
        beginShape();
            vertex(0, 0);
            vertex(0, b.getYLen());
            //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
            vertex(b.getXLen(), 0.5f * b.getYLen());
        noStroke();
        fill(m_backgroundColor2);
        endShape();
        popMatrix();
    }

}

//===========================================================

class BackwardButton extends Button{
    BackwardButton(Bounds b){
        super(b);
    }

    protected void draw(){

        float rounding = min(m_bounds.getXLen(), m_bounds.getYLen())/4;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(m_bounds, rounding, 0, 0, rounding);
        float indent = 0.1f;

        drawTick(indent, rounding);
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

        Bounds bTick = m_bounds.withoutLeftRatio(indent).withYFrameRatio(indent);

        rect(bTick, rounding, 0, 0, rounding);

        drawTickSymbol(indent, rounding);

        //Highlight
        if(m_pressed){
            noStroke();
            fill(255, 100);
            rect(bTick, rounding, 0, 0, rounding);
        }
    }

    protected void drawTickSymbol(float indent, float rounding){
        Bounds b = m_bounds.withFrameRatio(3 * indent).withCenteredSquare();

        pushMatrix();
        translate(b);
        beginShape();
            vertex(b.getXLen(), 0);
            vertex(b.getXLen(), b.getYLen());
            //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
            vertex(0, 0.5f * b.getYLen());
        noStroke();
        fill(m_backgroundColor2);
        endShape();
        popMatrix();
    }

}

//===========================================================

class TutorialButton{
    protected QuestionMarkTickbox m_questionmark;
    protected BackwardButton m_backward;
    protected ForwardButton m_forward;

    protected int m_page = 0;

    TutorialButton(Bounds b){
        m_questionmark = new QuestionMarkTickbox(b.asSectionOfXDivisions(0, 2));
        m_backward = new BackwardButton(b.asSectionOfXDivisions(2, 4));
        m_forward = new ForwardButton(b.asSectionOfXDivisions(3, 4));
    }

    public void update(){
        m_questionmark.update();

        if(m_questionmark.getValue()){
            m_backward.update();
            m_forward.update();
        }

        if(m_backward.getValue()){
            m_page--;
        }
        
        if(m_forward.getValue()){
            m_page++;
        }
    }

    public boolean isOn(){
        return m_questionmark.getValue();
    }

    public int getPage(){
        return m_page;
    }

    public void resetPage(){
        m_page = 0;
    }
}


class DFTSection extends GUISection{

    MenuSection m_menuSection;
    InputSection m_inputSection;
    MathSection m_mathSection;
    SpectrumSection m_spectrumSection;

    private int m_windowLength;
    private int m_selectedFrequency = 0;


    DFTSection(Bounds b, int windowLength){
        super(b);

        m_windowLength = windowLength;

        m_menuSection = new MenuSection(m_bounds.withYLen(m_spacer));
        m_inputSection = new InputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(0, 3
            ).withFrame(m_spacer/8),
            m_windowLength,
            m_windowLength);
        m_mathSection = new MathSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(1, 3
            ).withFrame(m_spacer/8),
            m_windowLength,
            m_windowLength);
        m_spectrumSection = new SpectrumSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(2, 3
            ).withFrame(m_spacer/8),
            m_windowLength/2);
    }

    protected void preDrawUpdate(){
        checkSelectedFrequency();
        updateSelectedFrequency();
    }

    protected void checkSelectedFrequency(){

        int mathTemp = m_mathSection.getSelectedFrequency();
        int spectrumTemp = m_spectrumSection.getSelectedFrequency();
        if(spectrumTemp != mathTemp){
            //println("sel: " + m_selectedFrequency + "; spec: " + spectrumTemp + "; math: " + mathTemp);
            if(spectrumTemp != m_selectedFrequency){
                //println("spec");
                m_selectedFrequency = spectrumTemp;
            }else{
                //println("math");
                m_selectedFrequency = mathTemp;
            }
        }
    }

    protected void updateSelectedFrequency(){
        m_mathSection.setSelectedFrequency(m_selectedFrequency);
        m_spectrumSection.setSelectedFrequency(m_selectedFrequency);
        if(m_mathSection.hasChangedSelectedFrequency()){
            m_inputSection.setSelectedFrequency(m_selectedFrequency);
        }
    }

    protected void drawSections(){
        if(m_menuSection.isTimeAdvancing()){
            m_inputSection.advanceTime();
        }

        if(true){
            m_mathSection.setData(m_inputSection.getMultiplicationData());
        }

        if(true){
            m_spectrumSection.setFullSpectrum(m_inputSection.getFullSpectrum());
            m_spectrumSection.setSinSpectrum(m_inputSection.getSinSpectrum());
            m_spectrumSection.setCosSpectrum(m_inputSection.getCosSpectrum());
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
    SkipButton m_skipButton;
    Knob m_sampleRateKnob;

    int m_iterateTime = 0;
    boolean m_isAdvancingTime = false;

    int m_blink = 0;

    MenuSection(Bounds b){
        super(b);
    }

    protected void initializeControllers(){
        Bounds area = m_bounds.withoutLeft(m_bounds.getXLen() - 4 * m_spacer);
        m_playButton = new PlayButton(area.asSectionOfXDivisions(0, 4));
        m_skipButton = new SkipButton(area.asSectionOfXDivisions(1, 4));
        m_sampleRateKnob = new Knob(area.asSectionOfXDivisions(2, 4), "Samplerate");
        m_sampleRateKnob.setRealValueRange(60, 1);
        m_sampleRateKnob.setSnapSteps(59);
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
        fill(m_backgroundColor);
        rect(m_bounds);

        blink();
    }

    private void blink(){
        if(m_isAdvancingTime){
            m_blink = 10;
        }

        fill(map(m_blink, 0, 10, 0, 255), 0, 0);
        noStroke();
        ellipse(m_bounds.withoutLeft(m_bounds.getXLen() - m_spacer));

        fill(200);
        textSize(20);
        textAlign(CENTER);
        text(frameRate, m_bounds.getXPos() + m_bounds.getXLen() - m_spacer/2,
            m_bounds.getYPos() + m_bounds.getYLen()/2);

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
    private DFTGenerator m_generator;

    private Tickbox m_testFreqTickbox;
    private Tickbox m_windowShapeTickbox;
    

    private int m_sampleNumber;

    SignalDisplay m_signalDisplay;

    boolean multiplicationChanged = true;
    boolean spectrumChanged = true;

    InputSection(Bounds b, int testFreqAmount, int sampleNumber){
        super(b);

        Bounds area = m_bounds.withFrame(m_spacer/4);

        m_sampleNumber = sampleNumber;
        m_generator = new DFTGenerator(m_bounds.withFrame(m_spacer/2
                ).withoutRightRatio(5.0f/7
                ).withoutRight(m_spacer/4
                ).withYLen(m_bounds.getYLen()/2),
                m_spacer,
                m_sampleNumber);
        m_signalDisplay = new SignalDisplay(area.withoutLeftRatio(2.0f/7),
                                            testFreqAmount,
                                            m_sampleNumber);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Input Signal");
        m_testFreqTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + m_spacer/2,
                                        m_bounds.getYPos() + 5 * m_spacer / 2,
                                        m_spacer/3,
                                        m_spacer/3), "Test Frequency");
        m_windowShapeTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + m_spacer/2,
                                        m_bounds.getYPos() + 19 * m_spacer / 6,
                                        m_spacer/3,
                                        m_spacer/3), "Window Shape");
        
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_generator.update();

            m_testFreqTickbox.update();

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

        m_signalDisplay.setLatestValueForInput(m_generator.getLatestValue());
    }

    public void setSelectedFrequency(int testFreq){
        m_signalDisplay.setTestFreq(testFreq);
    }

    public float[] getMultiplicationData(){
        return m_signalDisplay.getMultipliedArray();
    }

    public float[] getFullSpectrum(){
        return m_signalDisplay.getSpectrum();
    }

    public float[] getSinSpectrum(){
        return m_signalDisplay.getSinSpectrum();
    }

    public float[] getCosSpectrum(){
        return m_signalDisplay.getCosSpectrum();
    }
}

//====================================================================

class MathSection extends GUISection{
    private SinCosTabs m_tabs;
    private int m_selectedFrequency = 0;
    private Tickbox m_sectionTickbox;
    OneGraphDisplay m_mult;


    MathSection(Bounds b, int testFreqAmount, int sampleNumber){
        super(b);

        String[] temp = new String[testFreqAmount];

        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + (i % (temp.length/2) )).substring(1);
        }

        m_tabs = new SinCosTabs(m_bounds.withXFrame(m_spacer/4
            ).withYLen(m_spacer/2
            ).withoutLeftRatio(0.2f),
            temp);

        m_mult = new OneGraphDisplay(m_bounds.withXFrame(m_spacer/4
            ).withoutLeftRatio(2.0f/7
            ).withoutTop(m_spacer/2), sampleNumber);
    
        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void initializeControllers(){
        
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Multiplication");
    }

    protected int getSelectedFrequency(){
        return m_tabs.getValue();
    }

    protected void setSelectedFrequency(int selectedFrequency){

        m_tabs.setValue(selectedFrequency);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        m_tabs.update();
        fill(150);
        textSize(m_spacer /5);
        textAlign(LEFT);
        text("Sin",
        m_bounds.getXPos() + 3 * m_spacer,
        m_bounds.getYPos() + 2 * m_spacer/9);
        text("Cos",
        m_bounds.getXPos() + 3 * m_spacer,
        m_bounds.getYPos() + m_spacer/4 + 2 * m_spacer/9);


        if(m_sectionTickbox.getValue()){
            
            m_mult.draw();
        }
        
        
    }

    public boolean hasChangedSelectedFrequency(){
        boolean temp = (m_selectedFrequency == m_tabs.getValue());
        m_selectedFrequency = m_tabs.getValue();
        return temp;
    }

    public void setData(float[] data){
        m_mult.setData(data);
    }
}

//====================================================================

class SpectrumSection extends GUISection{
    private Tickbox m_sectionTickbox;

    private Tickbox m_sinTickbox;
    private Tickbox m_cosTickbox;
    private Tickbox m_spectrumTickbox;

    private SpectrumDisplay m_spectrum;

    private int m_selectedFrequency;

    SpectrumSection(Bounds b, int testFreqAmount){
        super(b);

        m_spectrum = new SpectrumDisplay(m_bounds.withFrame(m_spacer/4
            ).withoutLeftRatio(0.2f),
            testFreqAmount);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Spectrum");

        m_sinTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + 4 * m_spacer/6,
                                    m_bounds.getYPos() + 4 * m_spacer/6, 
                                    m_spacer/3, 
                                    m_spacer/3), "Sine");
        m_cosTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + 4 * m_spacer/6,
                                    m_bounds.getYPos() + 4 * m_spacer/6 + m_spacer/2, 
                                    m_spacer/3, 
                                    m_spacer/3), "Cos");
        m_spectrumTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + 4 * m_spacer/6,
                                    m_bounds.getYPos() + 4 * m_spacer/6 + m_spacer, 
                                    m_spacer/3, 
                                    m_spacer/3), "Spectrum");

    }

    protected int getSelectedFrequency(){
        int maxFrequency = m_spectrum.getMaxFrequency();
        int spectrumSelectedFrequency = m_spectrum.getSelectedFrequency();

        if( (m_selectedFrequency % maxFrequency) != spectrumSelectedFrequency){
            m_selectedFrequency = (m_selectedFrequency / maxFrequency) * maxFrequency + spectrumSelectedFrequency;
        }
        return m_selectedFrequency;
    }

    protected void setSelectedFrequency(int selectedFrequency){
        m_selectedFrequency = selectedFrequency;
        m_spectrum.setSelectedFrequency(m_selectedFrequency % m_spectrum.getMaxFrequency());
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_sinTickbox.update();
            m_cosTickbox.update();
            m_spectrumTickbox.update();

            m_spectrum.setFullSpectrumVisibility(m_spectrumTickbox.getValue());
            m_spectrum.setSinVisibility(m_sinTickbox.getValue());
            m_spectrum.setCosVisibility(m_cosTickbox.getValue());
            m_spectrum.draw();
        }
        
        
    }

    public void setFullSpectrum(float[] data){
        m_spectrum.setData(data);
    }

    public void setSinSpectrum(float[] data){
        m_spectrum.setSinSpectrum(data);
    }

    public void setCosSpectrum(float[] data){
        m_spectrum.setCosSpectrum(data);
    }
}
class GUISection{
    protected Bounds m_bounds;

    protected int m_backgroundColor;

    protected float m_spacer = 65;

    GUISection(Bounds b){
        m_bounds = b;

        ColorLoader.construct(loadImage("ColorPalette.png"));

        m_backgroundColor = ColorLoader.getBackgroundColor(0);

        initializeControllers();
        initializeSections();
    }

    protected void initializeControllers(){

    }

    protected void initializeSections(){

    }

    public void update(){
        preDrawUpdate();
        draw();
    }

    protected void preDrawUpdate(){

    }

    protected void draw(){
        drawBackground();
        drawComponents();
        drawSections();
    }

    protected void drawBackground(){
        noStroke();
        fill(m_backgroundColor);
        rect(m_bounds);
    }

    protected void drawSections(){

    }

    protected void drawComponents(){

    }  
}

//====================================================================

class Generator{
    protected Bounds m_bounds;
    private float m_spacer;

    int m_time = 0;
    float[] m_data; //goes from -1 to 1
    float m_phase = 0; //goes from 0 to 1

    protected Tickbox m_switch;
    protected Knob[] m_knob;
    protected Tabs m_tabs;

    
    

    Generator(Bounds b, float spacer, int arrayLength){
        m_bounds = b;
        m_spacer = spacer;

        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }

        Bounds bTop = m_bounds.withoutBottom( m_spacer ).withoutBottomRatio( 0.5f );
        Bounds bMiddle = m_bounds.withYFrame( (m_bounds.getYLen() - m_spacer)/2 );
        Bounds bBottom = m_bounds.withoutTop( m_spacer ).withoutTopRatio( 0.5f );

        m_switch = new Tickbox(bTop.withLeftSquare(),
                                "Generator");

        m_knob = new Knob[3];

        m_knob[0] = new Knob(bMiddle.asSectionOfXDivisions(0, 3), "Frequency");
        m_knob[0].setRealValueRange(0.5f, m_data.length);
        m_knob[0].setRealValue(1);
        m_knob[0].setSnapSteps(2 * m_data.length - 1);

        m_knob[1] = new Knob(bMiddle.asSectionOfXDivisions(1, 3), "Phase");
        m_knob[1].setRealValueRange(0, TWO_PI);
        m_knob[1].setRealValue(0);
        m_knob[1].setSnapSteps(12);

        m_knob[2] = new Knob(bMiddle.asSectionOfXDivisions(2, 3), "Amplitude");
        m_knob[2].setRealValueRange(-1, 1);
        m_knob[2].setRealValue(1);

        String[] tempSynthModes = new String[]{"0", "sin", "tria", "squ", "saw", "noise"};
        m_tabs = new Tabs(bBottom, tempSynthModes);
        m_tabs.setValue(1);
    }

    public void update(){
        noStroke();
        fill(100, 128);
        rect(m_bounds, 5);

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
            //println(m_knob[0].getRealValue());
            m_phase = (m_phase + (m_knob[0].getRealValue() / m_knob[0].getMaxRealValue() ))%1;

            float newPhase = (m_phase + m_knob[1].getValue()) % 1;

            switch(m_tabs.getValue()){
                case 0: //Zero
                m_data[getFirstIndex()] = 0;
                break;
                case 1: //Sin
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * sin( 2 * PI * newPhase );
                break;
                case 2: //Triangle
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * ( ( newPhase < 0.5f )? 4.0f * newPhase - 1 : -4.0f * newPhase + 3)/*triangle*/;
                break;
                case 3: //Square
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * ( ( newPhase < 0.5f )? 1 : -1)/*square*/;
                break;
                case 4: //Saw
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * (2.0f * newPhase - 1);
                break;
                case 5: //Noise
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

    public float getLatestValue(){
        return m_data[getFirstIndex()];
    }

    protected int getFirstIndex(){
        return m_time % m_data.length;
    }

    public boolean isOn(){
        return m_switch.getValue();
    }

    public int getArrayLength(){
        return m_data.length;
    }

    public void setFrequencyRange(float minFrequency, float maxFrequency){
        m_knob[0].setRealValueRange(minFrequency, maxFrequency);
        m_knob[0].setSnapSteps(PApplet.parseInt(2 * maxFrequency - 1));
    }

    public void setFrequency(float frequency){
        m_knob[0].setRealValue(frequency);
    }

}

//===========================================================================

class DFTGenerator extends Generator{

    DFTGenerator(Bounds b, float spacer, int arrayLength){
        super(b, spacer, 1);
        m_knob[0].setRealValueRange(0.5f, arrayLength);
        m_knob[0].setRealValue(1);
        m_knob[0].setSnapSteps(2 * arrayLength - 1);
    }    
}

//===========================================================================

class InstantGenerator extends Generator{
    InstantGenerator(Bounds b, float spacer, int arrayLength){
        super(b, spacer, arrayLength);
        m_knob[0].setRealValueRange(0.5f, arrayLength / 2);
        m_knob[0].setRealValue(1);
        m_knob[0].setSnapSteps(2 * arrayLength - 1);
    } 

    public void update(){
        fillArray();

        noStroke();
        fill(100, 128);
        rect(m_bounds, 5);

        m_switch.update();

        if(m_switch.getValue()){
            for(int i = 0; i < m_knob.length; i++){
                m_knob[i].update();
            }

            m_tabs.update();

        }
        
    }

    protected void fillArray(){
        
        if(m_switch.getValue()){
            for(int i = 0; i < m_data.length; i++){

                float newPhase = (m_knob[0].getRealValue() * ((i * 1.0f) / m_data.length) + m_knob[1].getValue()) % 1;

                switch(m_tabs.getValue()){
                    case 0: //Zero
                    m_data[i] = 0;
                    break;
                    case 1: //Sin
                    m_data[i] = m_knob[2].getRealValue() * sin( 2 * PI * newPhase );
                    break;
                    case 2: //Triangle
                    m_data[i] = m_knob[2].getRealValue() * ( ( newPhase < 0.5f )? 4.0f * newPhase - 1 : -4.0f * newPhase + 3)/*triangle*/;
                    break;
                    case 3: //Square
                    m_data[i] = m_knob[2].getRealValue() * ( ( newPhase < 0.5f )? 1 : -1)/*square*/;
                    break;
                    case 4: //Saw
                    m_data[i] = m_knob[2].getRealValue() * (2.0f * newPhase - 1);
                    break;
                    case 5: //Noise
                    m_data[i] = m_knob[2].getRealValue() * random(-1, 1);
                    break;
                }

                //println(i + ": " + m_data[i]);
            }
        }
    }

    public float[] getArray(){
        return m_data;
    }
}
class Graph{
    private Bounds m_bounds;
    private int m_color;

    protected float[] m_data;
    protected int m_dataLength;
    protected int m_firstIndex;
    private float m_baseValue = 0.5f;
    private float m_minInputValue = -1;
    private float m_maxInputValue = 1;

    private int m_displayMode = 0;

    Graph(Bounds b, int resolution){
        m_bounds = b;

        m_color = ColorLoader.getGraphColor(0);

        m_data = new float[resolution];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }
        m_dataLength = m_data.length;

        m_firstIndex = m_data.length - 1;
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
        }else{
            println("Wrong Data size");
        }

        m_firstIndex = m_data.length - 1;
    }

    public void setLatestValue(float value){
        int lastIndex = getLastIndex();
        m_data[lastIndex] = value;
        m_firstIndex = lastIndex;
    }

    public int getFirstIndex(){
        return m_firstIndex;
    }

    protected int getLastIndex(){
        return (m_firstIndex + 1) % m_data.length;
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

            case 2:
            drawShape();
            break;

            case 3:
            drawPointsAndLines();
            drawShape();
            break;
        }
        
    }

    private void drawPointsAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        float spacing = m_bounds.getXLen() / (m_dataLength - 1);
        for(int i = 0; i < m_dataLength; i++){

            float drawValue = getDrawValue(i);

            ellipse(m_bounds.getXPos() + i * spacing,
                drawValue,
                10, 10);
            line(m_bounds.getXPos() + i * spacing,
                drawValue,
                m_bounds.getXPos() + i * spacing,
                m_bounds.getYPos() + (1 - m_baseValue) * m_bounds.getYLen());
        }
    }

    private void drawShapeAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        beginShape();
        float spacing = m_bounds.getXLen() / (m_dataLength);
        for(int i = 0; i < m_dataLength; i++){

            float drawValue = getDrawValue(i);

            vertex(m_bounds.getXPos() + spacing/2 + i * spacing,
                drawValue);
            line(m_bounds.getXPos() + spacing/2 + i * spacing,
                drawValue,
                m_bounds.getXPos() + spacing/2 + i * spacing,
                m_bounds.getYPos() + (1 - m_baseValue) * m_bounds.getYLen());
        }

        
        endShape();
    }

    private void drawShape(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        beginShape();
        float spacing = m_bounds.getXLen() / (m_dataLength - 1);
        for(int i = 0; i < m_dataLength; i++){

            float drawValue = getDrawValue(i);

            vertex(m_bounds.getXPos() + i * spacing,
                drawValue);
        }

        
        endShape();
    }

    protected float getDrawValue(int index){
        return map(m_data[getDrawIndex(index)],
                    m_minInputValue, 
                    m_maxInputValue, 
                    m_bounds.getYPos() + m_bounds.getYLen(), 
                    m_bounds.getYPos());
    }

    public int getDrawIndex(int index){
        return (index + m_firstIndex + 1) % m_dataLength;
    }

    public int getLength(){
        return m_dataLength;
    }
}

//==========================================================================================

class SampledGraph extends Graph{
    private float[] m_inputData;

    SampledGraph(Bounds b, int maxResolution){
        super(b, maxResolution);

    }

    public void setSampleRate(int samplerate){
        m_dataLength = samplerate;
    }

    public void setData(float[] data){
        //println("Graph.setData(): " + data[data.length - 1]);
        m_inputData = data;

        translateData();

        m_firstIndex = m_data.length - 1;
    }

    protected void translateData(){
        for(int i = 0; i < m_dataLength - 1; i++){
            m_data[i] = m_inputData[i * m_inputData.length/(m_dataLength - 1) ];
        }

        m_data[m_dataLength - 1] = m_inputData[m_inputData.length - 1];
    }

    public int getDrawIndex(int index){
        return index;
    }

    public float[] getData(){
        return subset(m_data, 0, m_dataLength);
    }

}

//==========================================================================================

class InterpolationGraph extends Graph{
    InterpolationGraph(Bounds b){
        super(b, 1);
        setDisplayMode(3);
    }

    public void setData(float[] data){
        m_data = data;
        m_dataLength = m_data.length;
    }

    public int getDrawIndex(int index){
        return index;
    }
}
class InfoSection extends GUISection{
    protected String[] m_infoText;

    protected LinkButton[] m_linkButton;

    InfoSection(Bounds b){
        super(b);
        m_infoText = loadStrings("info.txt");

        m_linkButton = new LinkButton[3];

        Bounds area = m_bounds.withoutLeft(m_bounds.getXLen() - 2 * m_spacer
            ).withoutRight(m_spacer
            ).withYFrame(m_spacer);
        for(int i = 0; i < m_linkButton.length; i++){
            m_linkButton[i] = new LinkButton(area.withYPos(area.getYPos() + i * 3 * m_spacer/2
                ).withYLen(m_spacer));
            m_linkButton[i].setLink(m_infoText[i]);
        }
    }

    protected void drawBackground(){
        noStroke();
        fill(40);
        rect(m_bounds);

        float textSize = 25;
        fill(200);
        textSize(textSize);
        textAlign(LEFT);
        for(int i = m_linkButton.length; i < m_infoText.length; i++){
            text( m_infoText[i], m_bounds.getXPos() + m_spacer, m_bounds.getYPos() + m_spacer + i * textSize);
        }
        
    }

    protected void drawComponents(){

        for(int i = 0; i < m_linkButton.length; i++){


            m_linkButton[i].update();
        }
    } 


}
class InterferenceSection extends GUISection{

    private InterferenceInputSection m_inputSection;
    private InterferenceOutputSection m_outputSection;

    InterferenceSection(Bounds b, int resolution){
        super(b);

        resolution = floor(m_bounds.withFrame(m_spacer/8).withFrame(m_spacer/4).withoutLeftRatio(2.0f/7).getXLen());

        m_inputSection = new InterferenceInputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(0, 2
            ).withFrame(m_spacer/8),
            resolution);
        m_outputSection = new InterferenceOutputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(1, 2
            ).withFrame(m_spacer/8),
            resolution);
    }

    protected void drawSections(){
        m_inputSection.setOutputMode(m_outputSection.getMode());
        m_outputSection.setData(m_inputSection.getOutput());

        m_inputSection.update();
        m_outputSection.update();
    }

}

//====================================================================

class InterferenceInputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected InstantGenerator[] m_generator;
    protected ContinuousGraphDisplay m_graphDisplay;

    protected int m_outputMode = 0;

    InterferenceInputSection(Bounds b, int resolution){
        super(b);

        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Input");

        m_generator = new InstantGenerator[2];

        Bounds area = m_bounds.withFrame(m_spacer/4);

        for(int i = 0; i < m_generator.length; i++){
            Bounds gen = area.withoutRightRatio(5.0f/7
                ).asSectionOfYDivisions(i, m_generator.length
                ).withFrame(m_spacer/4);
            m_generator[i] = new InstantGenerator(gen,
                                            m_spacer,
                                            resolution);
            m_generator[i].setFrequencyRange(0.5f, 25);
            m_generator[i].setFrequency(1);
        }

        m_graphDisplay = new ContinuousGraphDisplay(area.withoutLeftRatio(2.0f/7),
                                            resolution,
                                            m_generator.length);

        m_graphDisplay.setColor(0, ColorLoader.getGraphColor(0));
        m_graphDisplay.setColor(1, ColorLoader.getGraphColor(1));

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    public void setOutputMode(int mode){
        m_outputMode = mode;
    }

    public float[] getOutput(){
        float[] ret = new float[m_generator[0].getArrayLength()];

        switch(m_outputMode){
            case 0:
            for(int i = 0; i < ret.length; i++){
                ret[i] = 0;
            }

            int generatorCount = 0;

            for(int i = 0; i < m_generator.length; i++){
                if(m_generator[i].isOn()){
                    float[] generatorData = m_generator[i].getArray();
                    for(int j = 0; j < generatorData.length; j++){
                        ret[j] += generatorData[j];
                    }
                    generatorCount++;
                }
            }

            for(int i = 0; i < ret.length; i++){
                ret[i] /= generatorCount;
            }

            break;
            case 1:
            for(int i = 0; i < ret.length; i++){
                ret[i] = 1;
            }

            for(int i = 0; i < m_generator.length; i++){
                if(m_generator[i].isOn()){
                    float[] generatorData = m_generator[i].getArray();
                    for(int j = 0; j < generatorData.length; j++){
                        ret[j] *= generatorData[j];
                    }
                }
            }
            break;
        }

        return ret;
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            for(int i = 0; i < m_generator.length; i++){
                m_generator[i].update();
                m_graphDisplay.setVisibility(i, m_generator[i].isOn());
                m_graphDisplay.setData(i, m_generator[i].getArray());
            }

            m_graphDisplay.draw();
        }
        
    }  
}

//====================================================================

class InterferenceOutputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected Tabs m_modeTabs;
    protected ContinuousGraphDisplay m_graphDisplay;

    InterferenceOutputSection(Bounds b, int resolution){
        super(b);
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Output");
        
        Bounds area = m_bounds.withFrame(m_spacer/4);

        String[] modeNames = new String[]{"Addition", "Multiplication"};
        m_modeTabs = new Tabs(area.withYLen(m_spacer/2
                            ).withoutRightRatio(5.0f/7
                            ).withoutLeft(m_spacer/4
                            ).withYPos(area.getYPos() + area.getYLen()/2 - m_spacer/4),
                            modeNames);

        m_graphDisplay = new ContinuousGraphDisplay(area.withoutLeftRatio(2.0f/7),
                                            resolution,
                                            1);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){

            m_modeTabs.update();

            m_graphDisplay.draw();
        }
        
    }  

    public int getMode(){
        return m_modeTabs.getValue();
    }

    public void setData(float[] data){
        m_graphDisplay.setData(0, data);
    }
}
class MainSection extends GUISection{
    protected VerticalTabs m_tabs;
    protected Tutorial m_tutorial;

    protected InterferenceSection m_interferenceSection;
    protected AliasingSection m_aliasingSection;
    protected DFTSection m_dftSection;
    protected InfoSection m_infoSection;


    MainSection(Bounds b){
        super(b);

        //savePNG();

        textFont(createFont("Arial", 20));

        String[] tempTabNames = new String[]{"+&x", "Aliasing", "DFT", "Info"};
        m_tabs = new VerticalTabs(m_bounds.withoutTop(m_spacer).withXLen(m_spacer), tempTabNames);

        m_tutorial = new Tutorial(m_bounds, m_spacer);
    }

    protected void initializeSections(){
        Bounds temp = m_bounds.withoutLeft(m_spacer);
        m_interferenceSection = new InterferenceSection(temp, 150);
        m_dftSection = new DFTSection(temp, 80);
        m_aliasingSection = new AliasingSection(temp);
        m_infoSection = new InfoSection(temp);
    }

    protected void drawSections(){
        m_tabs.update();
        

        switch(m_tabs.getValue()){
            case 0:
            m_interferenceSection.update();
            break;
            case 1:
            m_aliasingSection.update();
            break;
            case 2:
            m_dftSection.update();
            break;
            case 3:
            m_infoSection.update();
            break;
        }

        m_tutorial.update();
        
    }


}
class OneGraphDisplay{
    protected Bounds m_bounds;

    protected Graph m_graph;

    OneGraphDisplay(Bounds b, int resolution){
        m_bounds = b;

        m_graph = new Graph(m_bounds, resolution);
        m_graph.setColor(ColorLoader.getGraphColor(0));
    }

    public void setData(float[] data){
        m_graph.setData(data);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);

        m_graph.draw();
    }



}

//=========================================================

class SpectrumDisplay extends OneGraphDisplay{
    private Graph m_sinSpectrum;
    private Graph m_cosSpectrum;
    boolean m_fullIsVisible = true;
    boolean m_sinIsVisible = true;
    boolean m_cosIsVisible = true;

    private HoverTabs m_spectrumTabs;

    SpectrumDisplay(Bounds b, int resolution){
        super(b, resolution);

        m_sinSpectrum = new Graph(m_bounds, resolution);
        m_cosSpectrum = new Graph(m_bounds, resolution);

        setAsSpectrumDisplay();

        String[] temp = new String[resolution];
        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + i ).substring(1);
        }
        m_spectrumTabs = new HoverTabs(m_bounds, temp);
    }

    public void setAsSpectrumDisplay(){
        float maxValue = 0.6f;

        m_graph.setBaseValue(0);
        m_graph.setInputValueRange(0, maxValue);
        m_graph.setDisplayMode(1);
        m_graph.setColor(ColorLoader.getGraphColor(0));

        m_sinSpectrum.setBaseValue(0);
        m_sinSpectrum.setInputValueRange(0, maxValue);
        m_sinSpectrum.setDisplayMode(1);
        m_sinSpectrum.setColor(ColorLoader.getGraphColor(1));

        m_cosSpectrum.setBaseValue(0);
        m_cosSpectrum.setInputValueRange(0, maxValue);
        m_cosSpectrum.setDisplayMode(1);
        m_cosSpectrum.setColor(ColorLoader.getGraphColor(2));
    }

    public int getSelectedFrequency(){
        return m_spectrumTabs.getValue();
    }

    public void setSelectedFrequency(int selectedFrequency){
        m_spectrumTabs.setValue(selectedFrequency);
    }

    public int getMaxFrequency(){
        return m_spectrumTabs.getMaxValue();
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);

        if(m_sinIsVisible){
            m_sinSpectrum.draw();
        }

        if(m_cosIsVisible){
            m_cosSpectrum.draw();
        }

        if(m_fullIsVisible){
            m_graph.draw();
        }

        
        m_spectrumTabs.update();
    }

    public void setSinSpectrum(float[] data){
        m_sinSpectrum.setData(data);
    }

    public void setCosSpectrum(float[] data){
        m_cosSpectrum.setData(data);
    }

    public void setFullSpectrumVisibility(boolean isVisible){
        m_fullIsVisible = isVisible;
    }

    public void setSinVisibility(boolean isVisible){
        m_sinIsVisible = isVisible;
    }

    public void setCosVisibility(boolean isVisible){
        m_cosIsVisible = isVisible;
    }


}

//=======================================================

class ContinuousGraphDisplay{
    private Bounds m_bounds;

    private Graph[] m_graph;
    private boolean[] m_isVisible;

    ContinuousGraphDisplay(Bounds b, int resolution, int graphAmount){
        m_bounds = b;
        
        m_graph = new Graph[graphAmount];
        m_isVisible = new boolean[m_graph.length];

        for(int i = 0; i < m_graph.length; i++){
            m_graph[i] = new Graph(m_bounds, resolution);
            m_graph[i].setDisplayMode(2);
            m_isVisible[i] = true;
        }
    }

    public void setData(int graphNumber, float[] data){
        m_graph[graphNumber].setData(data);
    }

    public void setVisibility(int graphNumber, boolean isVisible){
        m_isVisible[graphNumber] = isVisible;
    }

    public void setColor(int graphNumber, int c){
        m_graph[graphNumber].setColor(c);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);
        for(int i = 0; i < m_graph.length; i++){

            if(m_isVisible[i]){
                m_graph[i].draw();
            }
            
        }
    }

}

//=========================================================

class AliasGraphDisplay extends OneGraphDisplay{

    protected SampledGraph m_sampledGraph;

    AliasGraphDisplay(Bounds b, int resolution, int sampledMaxResolution){
        super(b, resolution);

        m_graph.setDisplayMode(2);

        m_sampledGraph = new SampledGraph(m_bounds, sampledMaxResolution);
    }

    public void setSampleRate(int samplerate){
        m_sampledGraph.setSampleRate(samplerate);
    }

    public void setData(float[] data){
        m_graph.setData(data);
        m_sampledGraph.setData(data);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);

        m_graph.draw();
        m_sampledGraph.draw();
    }

    public float[] getSampledData(){
        return m_sampledGraph.getData();
    }

}

//===========================================================

class InterpolationGraphDisplay {
    protected Bounds m_bounds;

    protected InterpolationGraph m_graph;

    InterpolationGraphDisplay(Bounds b){
        m_bounds = b;

        m_graph = new InterpolationGraph(m_bounds);
    }

    public void setData(float[] data){
        m_graph.setData(data);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);

        m_graph.draw();
    }

}
class SignalDisplay{
    private Bounds m_bounds;
    
    boolean m_automationIsVisible = true;
    boolean m_inputIsVisible = true;
    boolean m_testFreqVisible = true;
    int m_testFreqIndex = 0;

    private Automation m_automation;
    private Graph m_input;
    private Graph[] m_testFreq;

    SignalDisplay(Bounds b, int testSineAmount, int resolution){
        m_bounds = b;

        m_automation = new Automation(m_bounds, ColorLoader.getGraphColor(2), false);
        m_automation.setRealValueRange(-1, 1);

        m_input = new Graph(m_bounds, resolution);
        m_input.setColor(ColorLoader.getGraphColor(0));

        m_testFreq = new Graph[testSineAmount];
        for(int i = 0; i < m_testFreq.length; i++){
            m_testFreq[i] = new Graph(m_bounds, resolution);
            m_testFreq[i].setColor(ColorLoader.getGraphColor(1));
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

    public void setLatestValueForInput(float value){
        m_input.setLatestValue(value);
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
            temp[i] = ip[m_input.getDrawIndex(i)];

            if(m_automationIsVisible){
                temp[i] *= m_automation.mapXToRealY(i / (1.0f * temp.length));
            }

            if(m_testFreqVisible){
                temp[i] *= tf[m_testFreq[withTestFreq].getDrawIndex(i)];
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

    public float[] getSinSpectrum(){
        int freqAmount = m_testFreq.length / 2;
        float[] temp = new float[freqAmount];

        for(int i = 0; i < freqAmount; i++){
            temp[i] = abs(getMultipliedArrayAdded(i));
        }

        return temp;
    }

    public float[] getCosSpectrum(){
        int freqAmount = m_testFreq.length / 2;
        float[] temp = new float[freqAmount];

        for(int i = 0; i < freqAmount; i++){
            temp[i] = abs(getMultipliedArrayAdded(i + freqAmount));
        }

        return temp;
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
        rect(m_bounds);

        

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

    Tabs(Bounds b, String[] tabName){
        super(b);

        m_value = 0;

        m_tabName = tabName;
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            if(m_bounds.checkHitbox(mouseX, mouseY)){

                int xPartitions = m_tabName.length;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = m_bounds.checkHitboxXPartition(mouseX, xPartitions);

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
        rect(m_bounds.withoutBottomRatio(0.2f), 10);

        if(m_value > 0){
            //rect(m_pos.x, m_pos.y, m_value * m_len.x/m_tabName.length, m_len.y, 10);
            rect(m_bounds.fromToSectionOfXDivisions(0, m_value, m_tabName.length), 10);
        }

        if(m_value < (m_tabName.length - 1)){
            //rect(m_pos.x + (m_value + 1) * m_len.x/m_tabName.length, m_pos.y, (m_tabName.length - (m_value + 1)) * m_len.x/m_tabName.length, m_len.y, m_len.y/5);
            rect(m_bounds.fromToSectionOfXDivisions(m_value + 1, m_tabName.length, m_tabName.length), 10);
        }

        //marked Tab
        fill(m_fillColor);
        //rect(m_pos.x + m_value * m_len.x/m_tabName.length, m_pos.y, m_len.x/m_tabName.length, 4 * m_len.y/5);
        rect( m_bounds.asSectionOfXDivisions(m_value, m_tabName.length).withoutBottomRatio( 0.2f ) );

        stroke(m_backgroundColor1);
        strokeWeight(2);
        for(int i = 1; i < m_tabName.length; i++){
            line(m_bounds.getXPos() + i * m_bounds.getXLen()/m_tabName.length,
                m_bounds.getYPos() + m_bounds.getYLen()/5,
                m_bounds.getXPos() + i * m_bounds.getXLen()/m_tabName.length,
                m_bounds.getYPos() + 4 * m_bounds.getYLen()/5);
        }

        fill(m_textColor);
        textAlign(CENTER);
        textFont(m_font);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i], m_bounds.getXPos() + (i + 0.5f) * m_bounds.getXLen()/m_tabName.length, m_bounds.getYPos() + 5 * m_bounds.getYLen()/8);
        }

    }

    public int getValue(){
        return m_value;
    }

    public void setValue(int value){
        if(value < m_tabName.length && value >= 0){
            m_value = value;
        }
    }

    public int getMaxValue(){
        return m_tabName.length;
    }

}

//====================================================================

class SinCosTabs extends Tabs{

    SinCosTabs(Bounds b, String[] tabName){
        super(b, tabName);
    }

    protected void draw(){
        int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        /*rect(m_pos.x,
            m_pos.y + m_len.y/10,
            m_len.x,
            4 * m_len.y / 5);*/
        rect(m_bounds.withYFrameRatio(0.1f));
        
        //Unmarked Tabs
        if(m_value < xPartitions){
            //Upper Deck
            if(m_value > 0){//Left
                rect(m_bounds.withoutBottomRatio(0.5f).fromToSectionOfXDivisions(0, m_value, xPartitions),
                    m_bounds.getYLen()/10);
            }

            if(m_value < xPartitions - 1){//Right
                rect(m_bounds.withoutBottomRatio(0.5f).fromToSectionOfXDivisions(m_value + 1, xPartitions, xPartitions),
                    m_bounds.getYLen()/10);
            }

            //Lower Deck
            rect(m_bounds.withoutTopRatio(0.5f), m_bounds.getYLen()/10);
        }else{
            //Upper Deck
            rect(m_bounds.withoutBottomRatio(0.5f), m_bounds.getYLen()/10);

            //Lower Deck
            if((m_value % xPartitions) > 0){//Left
                rect( m_bounds.withoutTopRatio(0.5f).fromToSectionOfXDivisions(0, m_value % xPartitions, xPartitions) );
            }

            if((m_value % xPartitions) < xPartitions - 1){
                rect( m_bounds.withoutTopRatio(0.5f).fromToSectionOfXDivisions( (m_value % xPartitions) + 1, xPartitions, xPartitions) );
            }
        }
        
        //Marked Tab
        noStroke();
        fill(m_fillColor);
        rect( m_bounds.withoutBottomRatio(0.6f
                        ).withYPos( m_bounds.getYPos() + ((m_value / xPartitions) * 0.4f + 0.1f) * m_bounds.getYLen() 
                        ).asSectionOfXDivisions(m_value % xPartitions, xPartitions) );


        //Lines
        stroke(m_backgroundColor1);
        strokeWeight(2);

        for(int i = 1; i < xPartitions; i++){
            line(m_bounds.getXPos() + i * m_bounds.getXLen()/xPartitions,
                m_bounds.getYPos() + m_bounds.getYLen()/10,
                m_bounds.getXPos() + i * m_bounds.getXLen()/xPartitions,
                m_bounds.getYPos() + 9 * m_bounds.getYLen()/10);
        }

        //Tabnames
        fill(m_textColor);
        textAlign(CENTER);
        textFont(m_font);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i],
                m_bounds.getXPos() + ((i % xPartitions) + 0.5f) * m_bounds.getXLen()/xPartitions,
                m_bounds.getYPos() + 5 * m_bounds.getYLen()/12 + (i / xPartitions) * m_bounds.getYLen()/2);
        }
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            
            m_firstClick = false;

            if(m_bounds.checkHitbox(mouseX, mouseY)){

                int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = constrain(xPartitions * m_bounds.checkHitboxYPartition(mouseY, 2) + m_bounds.checkHitboxXPartition(mouseX, xPartitions), 0, m_tabName.length - 1);

            }

        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }


}

//====================================================================

class HoverTabs extends Tabs{
    private int m_hoverValue = 0;

    HoverTabs(Bounds b, String[] tabName){
        super(b, tabName);

    }

    protected void draw(){
        //float spacing = m_len.x / m_tabName.length;

        //m_value-Rectangle
        Bounds bValue = m_bounds.asSectionOfXDivisions(m_value, m_tabName.length);
        fill(m_fillColor, 50);
        noStroke();
        //rect(m_pos.x + m_value * spacing, m_pos.y, spacing, m_len.y);
        rect(bValue);

        fill(m_textColor);
        textAlign(CENTER);
        textFont(m_font);
        text(m_tabName[m_value], bValue.getXPos() + bValue.getXLen()/2, bValue.getYPos() + bValue.getXLen());

        //m_hoverValue-Rectangle
        Bounds bHoverValue = m_bounds.asSectionOfXDivisions(m_hoverValue, m_tabName.length);
        fill(255, 50);
        noStroke();
        //rect(m_pos.x + m_hoverValue * spacing, m_pos.y, spacing, m_len.y);
        rect( bHoverValue );

        fill(m_textColor);
        textAlign(CENTER);
        textFont(m_font);
        text(m_tabName[m_hoverValue], bHoverValue.getXPos() + bHoverValue.getXLen()/2, bHoverValue.getYPos() + bHoverValue.getXLen());
    }

    public void update(){
        hover();
        click();
        adjust();
        draw();
    }

    protected void hover(){
        if(m_firstClick && 
            m_bounds.checkHitbox(mouseX, mouseY)){

            int xPartitions = m_tabName.length;

            m_hoverValue = m_bounds.checkHitboxXPartition(mouseX, xPartitions);
        }else{
            m_hoverValue = m_value;
        }

    }

}

//====================================================================

class VerticalTabs extends Tabs{

    VerticalTabs(Bounds b, String[] tabName){
        super(b, tabName);
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            if(m_bounds.checkHitbox(mouseX, mouseY)){

                int yPartitions = m_tabName.length;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = m_bounds.checkHitboxYPartition(mouseY, yPartitions);

            }

        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    protected void draw(){

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(m_bounds.withoutRightRatio(0.2f), 10);

        //Unmarked Tabs
        //Upper
        if(m_value > 0){
            rect( m_bounds.fromToSectionOfYDivisions(0, m_value, m_tabName.length), m_bounds.getXLen()/5 );
        }

        //Lower
        if(m_value < (m_tabName.length - 1)){
            rect( m_bounds.fromToSectionOfYDivisions(m_value + 1, m_tabName.length, m_tabName.length), m_bounds.getXLen()/5 );
        }

        //Marked Tab
        fill(m_fillColor);
        rect( m_bounds.asSectionOfYDivisions(m_value, m_tabName.length).withoutRightRatio( 0.2f ) );

        //Lines
        stroke(m_backgroundColor1);
        strokeWeight(2);
        for(int i = 1; i < m_tabName.length; i++){
            line(m_bounds.getXPos() + m_bounds.getXLen()/5,
                m_bounds.getYPos() + i * m_bounds.getYLen()/m_tabName.length,
                m_bounds.getXPos() + 4 * m_bounds.getXLen()/5,
                m_bounds.getYPos() + i * m_bounds.getYLen()/m_tabName.length);
        }

        //Text
        fill(m_textColor);
        textAlign(CENTER);
        textFont(m_font);
        for(int i = 0; i < m_tabName.length; i++){
            pushMatrix();
            translate(m_bounds.getXPos() + 5 * m_bounds.getXLen()/8,
                    m_bounds.getYPos() + (i + 0.5f) * m_bounds.getYLen()/m_tabName.length);
            rotate(3 * PI / 2);
            text(m_tabName[i], 0, 0);
            popMatrix();
            
        }

    }
}
class Tutorial{
    protected Bounds m_bounds;
    protected float m_spacer;

    protected TutorialButton m_questionmark;

    protected TextBox m_text;

    Tutorial(Bounds b, float spacer){
        m_bounds = new Bounds(b);
        m_spacer = spacer;

        m_questionmark = new TutorialButton(m_bounds.withLen(2 * m_spacer, m_spacer));
        
        m_text = new TextBox(m_bounds.withoutLeftRatio(0.5f).withoutTopRatio(0.5f));
    }

    public void update(){

        m_questionmark.update();

        if(m_questionmark.isOn()){
            m_text.draw();
        }
    }
}

class TextBox{
    protected Bounds m_bounds;

    protected int m_backgroundColor;
    protected int m_textColor;
    protected PFont m_font;
    protected String[] m_text;

    TextBox(Bounds b){
        m_bounds = new Bounds(b);

        m_backgroundColor = color(0, 118, 96);
        m_textColor = color(200);
        m_font = createFont("Courier New", 20);
        m_text = new String[1];
        m_text[0] = "Test";
    }

    public void draw(){

        fill(m_backgroundColor);
        noStroke();
        rect(m_bounds, 10);

        textFont(m_font);
        textAlign(LEFT);
        fill(m_textColor);
        text(m_text[0], m_bounds.getXPos(), m_bounds.getYPos());
    }
}
  public void settings() {  size(1250,850); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "DFTSimulation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
