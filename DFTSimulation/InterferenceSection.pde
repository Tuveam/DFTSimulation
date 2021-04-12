class InterferenceSection extends GUISection{

    private InterferenceInputSection m_inputSection;
    private InterferenceOutputSection m_outputSection;

    InterferenceSection(Bounds b, int resolution){
        super(b);

        resolution = floor(m_bounds.withFrame(m_spacer/8).withFrame(m_spacer/4).withoutLeftRatio(2.0f/7).getXLen());

        m_inputSection = new InterferenceInputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(0, 2
            ).withFrame(m_spacer/8),
            resolution);
        m_outputSection = new InterferenceOutputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(1, 2
            ).withFrame(m_spacer/8),
            resolution);
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

    InterferenceInputSection(Bounds b, int resolution){
        super(b);

        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Input");
        m_sectionTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

        m_generator = new InstantGenerator[2];

        Bounds area = m_bounds.withFrame(m_spacer/4);

        for(int i = 0; i < m_generator.length; i++){
            Bounds gen = area.withoutRightRatio(5.0f/7
                ).asSectionOfYDivisions(i, m_generator.length
                ).withFrame(m_spacer/4);
            m_generator[i] = new InstantGenerator(gen,
                                            m_spacer,
                                            resolution);
            m_generator[i].setFrequencyRange(0.5, 25);
            m_generator[i].setFrequency(1);
            m_generator[i].setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(i), ColorLoader.getGreyColor(0));

        }

        m_graphDisplay = new ContinuousGraphDisplay(area.withoutLeftRatio(2.0f/7),
                                            resolution,
                                            m_generator.length);

        m_graphDisplay.setColor(0, ColorLoader.getGraphColor(0));
        m_graphDisplay.setColor(1, ColorLoader.getGraphColor(1));

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
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

    InterferenceOutputSection(Bounds b, int resolution){
        super(b);
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Output");
        m_sectionTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(2), ColorLoader.getGreyColor(0));
        
        Bounds area = m_bounds.withFrame(m_spacer/4);

        String[] modeNames = new String[]{"Addition", "Multiplication"};
        m_modeTabs = new Tabs(m_bounds.withYLen(m_spacer/2
                            ).withoutRightRatio(5.0f/7
                            ).withXFrame(m_spacer/2
                            ).withYPos(area.getYPos() + area.getYLen()/2 - m_spacer/4),
                            modeNames);
        m_modeTabs.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getBackgroundColor(2), ColorLoader.getGreyColor(0));

        m_graphDisplay = new ContinuousGraphDisplay(area.withoutLeftRatio(2.0f/7),
                                            resolution,
                                            1);
        m_graphDisplay.setColor(0, ColorLoader.getGraphColor(2));

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
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