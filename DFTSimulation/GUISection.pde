class GUISection{
    protected Bounds m_bounds;

    protected color m_backgroundColor;

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

