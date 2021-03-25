class GUISection{
    protected PVector m_pos;
    protected PVector m_len;

    protected color m_backgroundColor;

    protected float m_spacer = 65;

    GUISection(PVector pos, PVector len){
        m_pos = pos;
        m_len = len;

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
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);
    }

    protected void drawSections(){

    }

    protected void drawComponents(){

    }  
}

//====================================================================

