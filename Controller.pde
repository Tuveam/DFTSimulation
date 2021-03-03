class Controller{
    //private float/boolean m_value = 0;
    
    protected PVector m_pos;
    protected PVector m_len;

    protected boolean m_selected = false;
    protected boolean m_firstClick = true;

    protected PVector m_mouseClicked;

    protected color m_fillColor;
    protected color m_backgroundColor1;
    protected color m_backgroundColor2;
    protected color m_textColor;

    protected float m_textSize = 13;

    Controller(PVector pos, PVector len){
        m_pos = pos;
        m_len = len;

        m_fillColor = color(75, 170, 75);
        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);
        m_textColor = color(200, 200, 200);
        
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

    public void setColor(color capColor, color barColor, color fillColor){
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

    private String m_name;
    

    Knob(float xPos, float yPos, float xLen, float yLen, String name){
        super(new PVector(xPos, yPos), new PVector((xLen < yLen)? xLen : yLen, (xLen < yLen)? xLen : yLen));
        m_value = 0.8;

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

            if(keyPressed && key == CODED){
                if(keyCode == ALT){
                    actualSensitivity = 10 * m_sensitivity;
                }
            }

            m_value = m_value + (m_mouseClicked.y - mouseY) / (m_len.y * actualSensitivity);

            m_mouseClicked.x = mouseX;
            m_mouseClicked.y = mouseY;

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
        ellipse(0, 0, 0.8 * getKnobLen(), 0.8 * getKnobLen());

        //indicator line
        stroke(m_fillColor);
        strokeWeight(3);
        line(0.1 * getKnobLen() * cos(angle), 0.1 * getKnobLen() * sin(angle), 0.3 * getKnobLen() * cos(angle), 0.3 * getKnobLen() * sin(angle));

        popMatrix();

        //name
        textAlign(CENTER);
        fill(m_textColor);
        textSize(getTextLenY());
        if(m_selected){
            text(getRealValue(), m_pos.x + m_len.x/2, m_pos.y + getKnobLen() + getTextLenY()/2);
        }else{
            text(m_name, m_pos.x + m_len.x/2, m_pos.y + getKnobLen() + getTextLenY()/2);
        }
        
        
    }

    private float getKnobLen(){
        return (0.8 * m_len.x);
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
}

//====================================================================

class Tickbox extends Controller{

    protected boolean m_value;

    protected boolean m_pressed = false;

    protected String m_name;


    Tickbox(float xPos, float yPos, float xLen, float yLen, String name){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);

        m_value = true;

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
        float indent = 0.1;

        drawTick(indent, rounding);

        fill(m_textColor);
        textAlign(LEFT);
        textSize(m_textSize);
        text(m_name, 4 * m_len.x/3, m_len.y/2 + m_textSize/3);

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

    public void setColor(color backgroundColor1, color backgroundColor2, color fillColor){
        m_backgroundColor1 = backgroundColor1;
        m_backgroundColor2 = backgroundColor2;
        m_fillColor = fillColor;
    }
}

//======================================================================

class Button extends Tickbox{
    protected int m_cooldown = 20;
    protected int m_tickCooldown = m_cooldown;

    Button(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen, "");
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
        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        fill(m_fillColor, map(m_tickCooldown, 0, 20, 255, 0));
        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        drawTickSymbol(indent, rounding);

    }

    protected void drawTickSymbol(float indent, float rounding){
        if(m_pressed){
            fill(255,100);
            rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);
        }
    }
}

//===========================================================

class SkipButton extends Button{
    SkipButton(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen);
    }

    protected void drawTickSymbol(float indent, float rounding){
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

//===========================================================

class PlayButton extends Tickbox{

    PlayButton(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen, "");

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

//===========================================================

class LinkButton extends Button{
    String m_link;

    LinkButton(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen);
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
        strokeWeight(m_len.x * indent);
        stroke(m_backgroundColor2);
        line(3 * indent * m_len.x,
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
            m_len.y / 2);

        if(m_pressed){
            stroke(255,100);
            line(3 * indent * m_len.x,
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
                m_len.y / 2);
        }
    }
}



