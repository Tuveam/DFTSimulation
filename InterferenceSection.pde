class InterferenceSection extends GUISection{

    private InterferenceInputSection m_inputSection;
    private InterferenceOutputSection m_outputSection;

    InterferenceSection(float xPos, float yPos, float xLen, float yLen, int resolution){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        resolution = floor(m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7);

        m_inputSection = new InterferenceInputSection(m_pos.x, m_pos.y + m_spacer, m_len.x, (m_len.y - m_spacer) / 2, resolution);
        m_outputSection = new InterferenceOutputSection(m_pos.x, m_pos.y + m_spacer + (m_len.y - m_spacer)/2, m_len.x, (m_len.y - m_spacer) / 2, resolution);
    }

    protected void drawSections(){
        m_inputSection.setOutputMode(m_outputSection.getMode());
        m_outputSection.setData(m_inputSection.getOutput());

        m_inputSection.update();
        m_outputSection.update();
    }

}

//====================================================================

class InterferenceInputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected InstantGenerator[] m_generator;
    protected ContinuousGraphDisplay m_graphDisplay;

    protected int m_outputMode = 0;

    InterferenceInputSection(float xPos, float yPos, float xLen, float yLen, int resolution){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_sectionTickbox = new Tickbox(new Bounds(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2), "Input");

        m_generator = new InstantGenerator[2];

        

        for(int i = 0; i < m_generator.length; i++){
            m_generator[i] = new InstantGenerator(new Bounds(m_pos.x + m_spacer/2,
                                            m_pos.y + m_spacer/2 + i * (m_len.y - 3 * m_spacer/4) / m_generator.length,
                                            2 * m_len.x / 7,
                                            (m_len.y - 3 * m_spacer/4) / m_generator.length - m_spacer/4),
                                            m_spacer,
                                            resolution);
        }

        m_graphDisplay = new ContinuousGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7,
                                            m_len.y - m_spacer,
                                            resolution,
                                            m_generator.length);

        m_graphDisplay.setColor(0, color(75, 75, 200));
        m_graphDisplay.setColor(1, color(200, 75, 75));
    }

    public void setOutputMode(int mode){
        m_outputMode = mode;
    }

    public float[] getOutput(){
        float[] ret = new float[m_generator[0].getArrayLength()];

        switch(m_outputMode){
            case 0:
            for(int i = 0; i < ret.length; i++){
                ret[i] = 0;
            }

            int generatorCount = 0;

            for(int i = 0; i < m_generator.length; i++){
                if(m_generator[i].isOn()){
                    float[] generatorData = m_generator[i].getArray();
                    for(int j = 0; j < generatorData.length; j++){
                        ret[j] += generatorData[j];
                    }
                    generatorCount++;
                }
            }

            for(int i = 0; i < ret.length; i++){
                ret[i] /= generatorCount;
            }

            break;
            case 1:
            for(int i = 0; i < ret.length; i++){
                ret[i] = 1;
            }

            for(int i = 0; i < m_generator.length; i++){
                if(m_generator[i].isOn()){
                    float[] generatorData = m_generator[i].getArray();
                    for(int j = 0; j < generatorData.length; j++){
                        ret[j] *= generatorData[j];
                    }
                }
            }
            break;
        }

        return ret;
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
                m_graphDisplay.setVisibility(i, m_generator[i].isOn());
                m_graphDisplay.setData(i, m_generator[i].getArray());
            }

            m_graphDisplay.draw();
        }
        
    }  
}

//====================================================================

class InterferenceOutputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected Tabs m_modeTabs;
    protected ContinuousGraphDisplay m_graphDisplay;

    InterferenceOutputSection(float xPos, float yPos, float xLen, float yLen, int resolution){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
        m_sectionTickbox = new Tickbox(new Bounds(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2), "Output");
        
        String[] modeNames = new String[]{"Addition", "Multiplication"};
        m_modeTabs = new Tabs(new Bounds(m_pos.x + m_spacer/2,
                            m_pos.y + m_len.y/2 - m_spacer/4,
                            2 * m_len.x / 7,
                            m_spacer/2),
                            modeNames);

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

            m_modeTabs.update();

            m_graphDisplay.draw();
        }
        
    }  

    public int getMode(){
        return m_modeTabs.getValue();
    }

    public void setData(float[] data){
        m_graphDisplay.setData(0, data);
    }
}