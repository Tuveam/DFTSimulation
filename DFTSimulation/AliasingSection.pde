class AliasingSection extends GUISection{

    protected AliasInputSection m_inputSection;
    protected InterpolationSection m_interpolationSection;

    AliasingSection(Bounds b){
        super(b);
    }

    protected void initializeSections(){
        m_inputSection = new AliasInputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(0, 2
            ).withFrame(m_spacer/8));
        m_interpolationSection = new InterpolationSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(1, 2
            ).withFrame(m_spacer/8));
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

    AliasInputSection(Bounds b){
        super(b);

        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Input");
        m_sectionTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

        Bounds area = m_bounds.withFrame(m_spacer/4);

        int resolution = floor(area.withoutLeftRatio(2.0f/7).getXLen());

        Bounds inputArea = area.withoutRightRatio(5.0f/7.0f);

        m_generator = new InstantGenerator(
                inputArea.asSectionOfYDivisions(0, 2
                ).withFrame(m_spacer/4),
                m_spacer,
                resolution);
        m_generator.setFrequencyRange(0.5, 60);
        m_generator.setFrequency(1);
        m_generator.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));


        int maxSamplerate = 150;
        m_sampleRate = new Knob(
            new Bounds(
                inputArea.getXPos() + inputArea.getXLen()/2 - m_spacer/2,
                inputArea.getYPos() + 3 * inputArea.getYLen()/4 - m_spacer/2,
                m_spacer,
                m_spacer),
            "Samplerate");
        m_sampleRate.setRealValueRange(1, maxSamplerate);
        m_sampleRate.setRealValue(20);
        m_sampleRate.setSnapSteps(maxSamplerate - 1);
        m_sampleRate.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(1), ColorLoader.getGreyColor(0));

        m_graphDisplay = new AliasGraphDisplay(area.withoutLeftRatio(2.0f/7),
                                            resolution,
                                            maxSamplerate);
        m_graphDisplay.setGraphColor(ColorLoader.getGraphColor(0));
        m_graphDisplay.setSampledColor(ColorLoader.getGraphColor(1));

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

    InterpolationSection(Bounds b){
        super(b);

        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Interpolated");
        m_sectionTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(2), ColorLoader.getGreyColor(0));

        Bounds area = m_bounds.withFrame(m_spacer/4);
        m_graphDisplay = new InterpolationGraphDisplay(area.withoutLeftRatio(2.0f/7));
        m_graphDisplay.setColor(ColorLoader.getGraphColor(2));

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