class Controller{
    //private float/boolean m_value = 0;
    
    protected Bounds m_bounds;

    protected boolean m_selected = false;
    protected boolean m_firstClick = true;

    protected PVector m_mouseClicked;

    protected color m_fillColor;
    protected color m_backgroundColor1;
    protected color m_backgroundColor2;
    protected color m_textColor;

    protected float m_textSize = 15;
    protected PFont m_font;

    Controller(Bounds b){
        m_bounds = new Bounds(b);

        m_fillColor = color(75, 170, 75);
        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);
        m_textColor = color(200, 200, 200);
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
    

    Knob(Bounds b, String name){
        super(b);
        
        m_value = 0.8;

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
            float actualSensitivity = m_sensitivity;

            if(keyPressed && key == CODED){
                if(keyCode == ALT){
                    actualSensitivity = 10 * m_sensitivity;
                }
            }

            m_value = m_value + (m_mouseClicked.y - mouseY) / (m_bounds.getYLen() * actualSensitivity);

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
        ellipse(knobBounds.withFrameRatio(0.1));

        //indicator line
        stroke(m_fillColor);
        strokeWeight(3);
        line(knobBounds.getXPos() + knobBounds.getXLen()/2 + 0.1 * knobBounds.getXLen() * cos(angle),
            knobBounds.getYPos() + knobBounds.getYLen()/2 + 0.1 * knobBounds.getYLen() * sin(angle), 
            knobBounds.getXPos() + knobBounds.getXLen()/2 + 0.3 * knobBounds.getXLen() * cos(angle), 
            knobBounds.getYPos() + knobBounds.getYLen()/2 + 0.3 * knobBounds.getYLen() * sin(angle));


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
        return m_bounds.withoutBottomRatio(0.2).withCenteredSquare();
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
        float indent = 0.1;

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
        rect(b.withoutLeftRatio(0.6));
        
        pushMatrix();
        translate(b);
        beginShape();
            vertex(0, 0);
            vertex(0, b.getYLen());
            //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
            vertex(0.6 * b.getXLen(), 0.5 * b.getYLen());
        endShape();
        popMatrix();

        if(m_pressed){
            fill(255,100);
            rect(b.withoutLeftRatio(0.6));
            
            pushMatrix();
            translate(b);
            beginShape();
                vertex(0, 0);
                vertex(0, b.getYLen());
                //vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
                vertex(0.6 * b.getXLen(), 0.5 * b.getYLen());
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
            rect(b.withoutLeftRatio(0.6));
            rect(b.withoutRightRatio(0.6));

            if(m_pressed){
                fill(255, 100);
                rect(b.withoutLeftRatio(0.6));
                rect(b.withoutRightRatio(0.6));
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
                vertex(b.getXLen(), 0.5 * b.getYLen());
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
                    vertex(b.getXLen(), 0.5 * b.getYLen());
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
        float indent = 0.1;

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
            vertex(b.getXLen(), 0.5 * b.getYLen());
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
        float indent = 0.1;

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
            vertex(0, 0.5 * b.getYLen());
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


