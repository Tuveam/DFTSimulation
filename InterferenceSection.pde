class InterferenceSection extends GUISection{

    private InterferenceInputSection m_inputSection;
    private InterferenceOutputSection m_outputSection;

    InterferenceSection(float xPos, float yPos, float xLen, float yLen, int resolution){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_inputSection = new InterferenceInputSection(m_pos.x, m_pos.y + m_spacer, m_len.x, (m_len.y - m_spacer) / 2, resolution);
        m_outputSection = new InterferenceOutputSection(m_pos.x, m_pos.y + m_spacer + (m_len.y - m_spacer)/2, m_len.x, (m_len.y - m_spacer) / 2, resolution);
    }

    protected void drawSections(){
        m_inputSection.update();
        m_outputSection.update();
    }

}

//====================================================================

class InterferenceInputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected InstantGenerator[] m_generator;
    protected ContinuousGraphDisplay m_graphDisplay;

    InterferenceInputSection(float xPos, float yPos, float xLen, float yLen, int resolution){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2, "Input");

        m_generator = new InstantGenerator[2];

        for(int i = 0; i < m_generator.length; i++){
            m_generator[i] = new InstantGenerator(m_pos.x + m_spacer/2,
                                            m_pos.y + m_spacer/2 + i * (m_len.y - 3 * m_spacer/4) / m_generator.length,
                                            2 * m_len.x / 7,
                                            (m_len.y - 3 * m_spacer/4) / m_generator.length - m_spacer/4,
                                            m_spacer,
                                            resolution);
        }

        m_graphDisplay = new ContinuousGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7,
                                            m_len.y - m_spacer,
                                            resolution,
                                            m_generator.length);
    }

    protected void drawBackground(){
        noStroke();
        fill(13, 37, 51);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            for(int i = 0; i < m_generator.length; i++){
                m_generator[i].update();
                m_graphDisplay.setData(i, m_generator[i].getArray());
            }

            m_graphDisplay.draw();
        }
        
    }  
}

//====================================================================

class InterferenceOutputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected ContinuousGraphDisplay m_graphDisplay;

    InterferenceOutputSection(float xPos, float yPos, float xLen, float yLen, int resolution){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2, "Output");
        m_graphDisplay = new ContinuousGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7,
                                            m_len.y - m_spacer,
                                            resolution,
                                            1);
    }

    protected void drawBackground(){
        noStroke();
        fill(51, 13, 37);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){

            m_graphDisplay.draw();
        }
        
    }  
}