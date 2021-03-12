class Tutorial{
    protected Bounds m_bounds;
    protected float m_spacer;

    protected TutorialButton m_questionmark;

    protected TextBox m_text;

    Tutorial(Bounds b, float spacer){
        m_bounds = new Bounds(b);
        m_spacer = spacer;

        m_questionmark = new TutorialButton(m_bounds.withLen(2 * m_spacer, m_spacer));
        
        m_text = new TextBox(m_bounds.withoutLeftRatio(0.5).withoutTopRatio(0.5));
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

    protected color m_backgroundColor;
    protected color m_textColor;
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