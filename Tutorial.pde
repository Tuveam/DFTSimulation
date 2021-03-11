class Tutorial{
    protected Bounds m_bounds;
    protected float m_spacer;

    protected QuestionMarkTickbox m_questionmark;

    Tutorial(Bounds b, float spacer){
        m_bounds = new Bounds(b);
        m_spacer = spacer;

        m_questionmark = new QuestionMarkTickbox(m_bounds.withLen(m_spacer, m_spacer));
        
    }

    public void update(){

        m_questionmark.update();
    }
}