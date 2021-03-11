class Tutorial{
    protected Bounds m_bounds;
    protected float m_spacer;

    protected TutorialButton m_questionmark;

    Tutorial(Bounds b, float spacer){
        m_bounds = new Bounds(b);
        m_spacer = spacer;

        m_questionmark = new TutorialButton(m_bounds.withLen(2 * m_spacer, m_spacer));
        
    }

    public void update(){

        m_questionmark.update();
    }
}