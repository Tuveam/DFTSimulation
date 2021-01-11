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

    public void draw(){
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

            m_section[i].draw();
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

    

    MainSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen), 4, 0);

    }

    protected void initializeSections(){
        m_section[0] = new MenuSection(m_pos, new PVector(m_len.x, m_spacer));
        m_section[1] = new InputSection(new PVector(m_pos.x, m_pos.y + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
        m_section[2] = new MathSection(new PVector(m_pos.x, m_pos.y + (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
        m_section[3] = new SpectrumSection(new PVector(m_pos.x, m_pos.y + 2 * (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
    }

}

//====================================================================

class MenuSection extends GUISection{
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


}

//====================================================================

class InputSection extends GUISection{
    InputSection(PVector pos, PVector len){
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
        text("Input", 0, 0);
        popMatrix();
    }
}

//====================================================================

class MathSection extends GUISection{
    MathSection(PVector pos, PVector len){
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