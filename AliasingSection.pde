class AliasingSection extends GUISection{

    protected AliasInputSection m_inputSection;
    protected InterpolationSection m_interpolationSection;

    AliasingSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }

    protected void initializeSections(){
        m_inputSection = new AliasInputSection(m_pos.x, m_pos.y + m_spacer, m_len.x, (m_len.y - m_spacer)/2);
        m_interpolationSection = new InterpolationSection(m_pos.x, m_pos.y + m_spacer + (m_len.y - m_spacer)/2, m_len.x, (m_len.y - m_spacer)/2);
    }


    protected void drawSections(){
        m_interpolationSection.setData(m_inputSection.getSampledData());

        m_inputSection.update();
        m_interpolationSection.update();
    }

}

//====================================================================

class AliasInputSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    protected InstantGenerator m_generator;
    protected Knob m_sampleRate;
    protected AliasGraphDisplay m_graphDisplay;

    AliasInputSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_sectionTickbox = new Tickbox(new Bounds(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2), "Input");

        int resolution = floor(m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7);

        m_generator = new InstantGenerator(new Bounds(m_pos.x + m_spacer/2,
                                            m_pos.y + m_spacer/2,
                                            2 * m_len.x / 7,
                                            (m_len.y - 3 * m_spacer/4) / 2 - m_spacer/4),
                                            m_spacer,
                                            resolution);
        m_generator.setFrequencyRange(0.5, 25);
        m_generator.setFrequency(1);


        int maxSamplerate = 150;
        m_sampleRate = new Knob(new Bounds(m_pos.x + m_spacer/2,
                                m_pos.y + m_len.y/2 + m_spacer/2,
                                m_spacer,
                                m_spacer),
                                "Samplerate");
        m_sampleRate.setRealValueRange(1, maxSamplerate);
        m_sampleRate.setRealValue(20);
        m_sampleRate.setSnapSteps(maxSamplerate - 1);

        m_graphDisplay = new AliasGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            resolution,
                                            m_len.y - m_spacer,
                                            resolution,
                                            maxSamplerate);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_generator.update();

            m_sampleRate.update();

            m_graphDisplay.setSampleRate(floor(m_sampleRate.getRealValue()));
            m_graphDisplay.setData(m_generator.getArray());

            m_graphDisplay.draw();
        }
        
    }

    public float[] getSampledData(){
        return m_graphDisplay.getSampledData();
    }

}

//====================================================================

class InterpolationSection extends GUISection{
    protected Tickbox m_sectionTickbox;
    InterpolationGraphDisplay m_graphDisplay;

    InterpolationSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_sectionTickbox = new Tickbox(new Bounds(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2), "Interpolated");
        m_graphDisplay = new InterpolationGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7,
                                            m_len.y - m_spacer);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            
            m_graphDisplay.draw();
        }
        
    }

    public void setData(float[] data){
        m_graphDisplay.setData(data);
    }

}