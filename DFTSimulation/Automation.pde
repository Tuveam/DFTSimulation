class Automation extends Controller{

    ArrayList<AutomationPoint> m_point = new ArrayList<AutomationPoint>();
    private boolean m_drawBackground = true;
    private float m_baseValue = 0.5;

    private float m_minRealValue = 0;
    private float m_maxRealValue = 1;

    Automation(Bounds b){
        super(b);

        m_point.add( new AutomationPoint(b, new PVector(0, 1), m_fillColor) );
        m_point.add( new AutomationPoint(b, new PVector(1, 1), m_fillColor) );
    }

    public void setBaseValue(float baseValue){
        m_baseValue = constrain(baseValue, 0, 1);

        for(int i = 0; i < m_point.size(); i++){
            m_point.get(i).setBaseValue(baseValue);
        }
    }

    public void setDrawBackground(boolean drawBackground){
        m_drawBackground = drawBackground;
    }

    public void setColor(color backgroundColor, color lineColor, color fillColor){
        m_backgroundColor2 = backgroundColor;
        m_backgroundColor1 = lineColor;
        m_fillColor = fillColor;

        for(int i = 0; i < m_point.size(); i++){
            m_point.get(i).setColor(backgroundColor, lineColor, fillColor);
        }
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
        if(
            MouseControl.amIClicked(m_id,
                                m_bounds.checkHitbox(mouseX, mouseY),
                                mousePressed,
                                frameCount)
            && mouseButton == RIGHT
            ){
            
            m_selected = true;
            
        }
        
        if(!mousePressed){
            m_selected = false;
        }
        
    }

    protected void adjust(){
        if(m_selected){
            boolean createPoint = true;

            for(int i = 1; i < m_point.size() - 1 && createPoint; i++){
                if(m_point.get(i).checkHitbox()){
                    createPoint = false;
                    m_point.remove(i);
                    m_selected = false;
                    return;
                }
            }

            if(createPoint){

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                int index = m_point.size()-1;

                for(int i = m_point.size()-2; i >= 0; i--){
                    if(m_point.get(i).getActualPosition().x < mouseX){
                        break;
                    }
                    index = i;
                }

                PVector temp = new PVector( (mouseX - m_bounds.getXPos()) / m_bounds.getXLen(), 1 - (mouseY - m_bounds.getYPos()) / m_bounds.getYLen());

                insertPointAtIndex(new AutomationPoint(m_bounds, temp, m_fillColor), m_point, index);
                
                m_selected = false;
                
                return;
            }
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
            
        }
        vertex(m_bounds.getXPos() + m_bounds.getXLen(),
                m_bounds.getYPos() + m_bounds.getYLen() * m_baseValue);

        strokeWeight(2);
        stroke(m_fillColor);
        fill(m_fillColor, 30);
        endShape(OPEN);

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

//====================================================================

class AutomationPoint extends Controller{

    private int m_curveHandleID;

    private PVector m_value;
    private float m_baseValue;

    private float m_curve;
    private float m_previousCurve;
    private int m_displayIncrement = 1;
    private boolean m_selectedCurveHandle = false;
    private float m_curveHandleSensitivity = 1;

    private float m_radius = 6;

    AutomationPoint(Bounds windowBounds, PVector value, color fillColor){
        super(windowBounds);

        m_curveHandleID = MouseControl.getID();

        m_value = value;
        m_baseValue = 0.5;
        m_curve = 0.5;
        m_previousCurve = m_curve;

        setColor(m_backgroundColor1, m_backgroundColor2, fillColor);
    }

    public void setBaseValue(float baseValue){
        m_baseValue = constrain(baseValue, 0, 1);
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
        if(
            MouseControl.amIClicked(m_id,
                                checkHitbox() && mouseButton == LEFT,
                                mousePressed,
                                frameCount)
            ){

            m_mouseClicked.x = mouseX;
            m_mouseClicked.y = mouseY;

            m_selected = true;
        }
                
        if(
            MouseControl.amIClicked(m_curveHandleID,
                                checkCurveHandleHitbox(others, myIndex),
                                mousePressed,
                                frameCount)
            ){
                
                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selectedCurveHandle = true;
                m_previousCurve = m_curve;

            }
        
        
        if(!mousePressed){
            m_selected = false;
            m_selectedCurveHandle = false;
            
        }
        
    }

    public PVector getValue(){
        return m_value;
    }

    protected void adjust(ArrayList<AutomationPoint> others, int myIndex){
        
        if(m_selected){
            setActualPosition(mouseX, mouseY);

            if(keyPressed && key == CODED && keyCode == CONTROL){
                m_value.y = m_baseValue;
            }

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

            if(mouseButton == LEFT){
                if(myIndex < others.size() - 1){
                    if(others.get(myIndex + 1).getValue().y > getValue().y){
                        m_curve = m_previousCurve + m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_bounds.getYLen();
                    }else{
                        m_curve = m_previousCurve - m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_bounds.getYLen();
                    }

                    m_curve = constrain(m_curve, 0, 1);
                }
            }else if(mouseButton == RIGHT){
                resetCurve();
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
            vertex(getActualPosition());
            if(m_curve == 0.5 || getActualPosition().x == others.get(myIndex + 1).getActualPosition().x){
                
            }else{
                
                for(int i = int(getActualPosition().x) + m_displayIncrement; i < others.get(myIndex + 1).getActualPosition().x; i += m_displayIncrement){
                    float x = map(i, getActualPosition().x, others.get(myIndex + 1).getActualPosition().x, 0, 1);
                    float actualY = map(getY(x), 0, 1, getActualPosition().y, others.get(myIndex + 1).getActualPosition().y);

                    vertex(i, actualY);
                }
                vertex(others.get(myIndex + 1).getActualPosition().x, others.get(myIndex + 1).getActualPosition().y);
                
            }
            vertex(others.get(myIndex + 1).getActualPosition());
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
                    rect(-0.5 * m_radius, -0.5 * m_radius, m_radius, m_radius);
                }
                popMatrix();
            }
        }
        
        
        
        
        

    }

    private PVector getCurveHandlePosition(ArrayList<AutomationPoint> others, int myIndex){
        if(myIndex < others.size() - 1){
            float actualX = map(0.5, 0, 1, getActualPosition().x, others.get(myIndex + 1).getActualPosition().x);
            float actualY = map(getY(0.5), 0, 1, getActualPosition().y, others.get(myIndex + 1).getActualPosition().y);

            return new PVector(actualX, actualY);
        }else{
            return new PVector(0, 0);
        }
    }

    private float getY(float x){
        float s = map(m_curve, 0, 1, 0.001, 0.999)/(1-map(m_curve, 0, 1, 0.001, 0.999));
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
        m_curve = 0.5;
    }

}