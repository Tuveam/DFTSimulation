class DFTSection extends GUISection{

    MenuSection m_menuSection;
    InputSection m_inputSection;
    MathSection m_mathSection;
    SpectrumSection m_spectrumSection;

    private int m_windowLength;
    private int m_selectedFrequency = 0;


    DFTSection(Bounds b, int windowLength){
        super(b);

        m_windowLength = windowLength;

        m_menuSection = new MenuSection(m_bounds.withYLen(m_spacer));
        m_inputSection = new InputSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(0, 3
            ).withFrame(m_spacer/8),
            m_windowLength,
            m_windowLength);
        m_mathSection = new MathSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(1, 3
            ).withFrame(m_spacer/8),
            m_windowLength,
            m_windowLength);
        m_spectrumSection = new SpectrumSection(
            m_bounds.withoutTop(m_spacer
            ).asSectionOfYDivisions(2, 3
            ).withFrame(m_spacer/8),
            m_windowLength/2);

    }

    protected void preDrawUpdate(){
        checkSelectedFrequency();
        updateSelectedFrequency();
    }

    protected void checkSelectedFrequency(){

        int mathTemp = m_mathSection.getSelectedFrequency();
        int spectrumTemp = m_spectrumSection.getSelectedFrequency();
        if(spectrumTemp != mathTemp){
            //println("sel: " + m_selectedFrequency + "; spec: " + spectrumTemp + "; math: " + mathTemp);
            if(spectrumTemp != m_selectedFrequency){
                //println("spec");
                m_selectedFrequency = spectrumTemp;
            }else{
                //println("math");
                m_selectedFrequency = mathTemp;
            }
        }
    }

    protected void updateSelectedFrequency(){
        m_mathSection.setSelectedFrequency(m_selectedFrequency);
        m_spectrumSection.setSelectedFrequency(m_selectedFrequency);
        if(m_mathSection.hasChangedSelectedFrequency()){
            m_inputSection.setSelectedFrequency(m_selectedFrequency);
        }
    }

    protected void drawSections(){
        if(m_menuSection.isTimeAdvancing()){
            m_inputSection.advanceTime();
        }

        if(true){
            m_mathSection.setData(m_inputSection.getMultiplicationData());
        }

        if(true){
            m_spectrumSection.setFullSpectrum(m_inputSection.getFullSpectrum());
            m_spectrumSection.setSinSpectrum(m_inputSection.getSinSpectrum());
            m_spectrumSection.setCosSpectrum(m_inputSection.getCosSpectrum());
        }

        m_menuSection.update();
        m_inputSection.update();
        m_mathSection.update();
        m_spectrumSection.update();
    }

}

//====================================================================

class MenuSection extends GUISection{
    PlayButton m_playButton;
    SkipButton m_skipButton;
    Knob m_sampleRateKnob;

    int m_iterateTime = 0;
    boolean m_isAdvancingTime = false;

    int m_blink = 0;

    MenuSection(Bounds b){
        super(b);
    }

    protected void initializeControllers(){
        Bounds area = m_bounds.withoutLeft(m_bounds.getXLen() - 4 * m_spacer);
        m_playButton = new PlayButton(area.asSectionOfXDivisions(0, 4));
        m_playButton.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

        m_skipButton = new SkipButton(area.asSectionOfXDivisions(1, 4));
        m_skipButton.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

        m_sampleRateKnob = new Knob(area.asSectionOfXDivisions(2, 4), "Samplerate");
        m_sampleRateKnob.setRealValueRange(60, 1);
        m_sampleRateKnob.setSnapSteps(59);
        m_sampleRateKnob.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));
    }

    public void update(){
        draw();

        m_isAdvancingTime = false;
        if(m_playButton.getValue()){
            if(m_iterateTime >= m_sampleRateKnob.getRealValue()){
                m_isAdvancingTime = true;
                m_iterateTime = 0;
            }

            m_iterateTime++;
        }else if(m_skipButton.getValue()){
            m_isAdvancingTime = true;
        }
    }

    protected void drawBackground(){
        noStroke();
        fill(m_backgroundColor);
        rect(m_bounds);

        blink();
    }

    private void blink(){
        if(m_isAdvancingTime){
            m_blink = 10;
        }

        fill(ColorLoader.getFillColor(0), map(m_blink, 0, 10, 0, 255));
        noStroke();
        ellipse(m_bounds.withoutLeft(m_bounds.getXLen() - m_spacer));

        fill(200);
        textSize(15);
        textAlign(CENTER);
        text(round(frameRate) + " FPS", m_bounds.getXPos() + m_bounds.getXLen() - m_spacer/2,
            m_bounds.getYPos() + m_bounds.getYLen()/2 + 5);

        if(m_blink > 0){
            m_blink--;
        }
    }

    protected void drawComponents(){
        m_playButton.update();
        m_skipButton.update();
        m_sampleRateKnob.update();
    }

    public boolean isTimeAdvancing(){
        return m_isAdvancingTime;
    }

}

//====================================================================

class InputSection extends GUISection{
    private Tickbox m_sectionTickbox;
    private DFTGenerator m_generator;

    private Tickbox m_testFreqTickbox;
    private Tickbox m_windowShapeTickbox;
    

    private int m_sampleNumber;

    SignalDisplay m_signalDisplay;

    boolean multiplicationChanged = true;
    boolean spectrumChanged = true;

    InputSection(Bounds b, int testFreqAmount, int sampleNumber){
        super(b);

        Bounds area = m_bounds.withFrame(m_spacer/4);

        m_sampleNumber = sampleNumber;
        m_generator = new DFTGenerator(m_bounds.withFrame(m_spacer/2
                ).withoutRightRatio(5.0f/7
                ).withoutRight(m_spacer/4
                ).withYLen(m_bounds.getYLen()/2),
                m_spacer,
                m_sampleNumber);
        m_generator.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

        m_signalDisplay = new SignalDisplay(area.withoutLeftRatio(2.0f/7),
                                            testFreqAmount,
                                            m_sampleNumber);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Input Signal");
        m_sectionTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));
        
        m_testFreqTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + m_spacer/2,
                                        m_bounds.getYPos() + 5 * m_spacer / 2,
                                        m_spacer/3,
                                        m_spacer/3), "Test Frequency");
        m_testFreqTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(1), ColorLoader.getGreyColor(0));
        
        m_windowShapeTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + m_spacer/2,
                                        m_bounds.getYPos() + 19 * m_spacer / 6,
                                        m_spacer/3,
                                        m_spacer/3), "Window Shape");
        m_windowShapeTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(2), ColorLoader.getGreyColor(0));
        
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_generator.update();

            m_testFreqTickbox.update();

            m_windowShapeTickbox.update();

            m_signalDisplay.setInputVisibility(m_generator.isOn());
            m_signalDisplay.setTestFreqVisibility(m_testFreqTickbox.getValue());
            m_signalDisplay.setAutomationVisibility(m_windowShapeTickbox.getValue());

            m_signalDisplay.draw();

            //m_windowShape.update();
        }
        
        
    }

    public void advanceTime(){
        //println((frameCount%2 == 0)? "tick" : "tack");
        m_generator.advanceTime();

        m_signalDisplay.setLatestValueForInput(m_generator.getLatestValue());
    }

    public void setSelectedFrequency(int testFreq){
        m_signalDisplay.setTestFreq(testFreq);
    }

    public float[] getMultiplicationData(){
        return m_signalDisplay.getMultipliedArray();
    }

    public float[] getFullSpectrum(){
        return m_signalDisplay.getSpectrum();
    }

    public float[] getSinSpectrum(){
        return m_signalDisplay.getSinSpectrum();
    }

    public float[] getCosSpectrum(){
        return m_signalDisplay.getCosSpectrum();
    }
}

//====================================================================

class MathSection extends GUISection{
    private SinCosTabs m_tabs;
    private int m_selectedFrequency = 0;
    private Tickbox m_sectionTickbox;
    OneGraphDisplay m_mult;


    MathSection(Bounds b, int testFreqAmount, int sampleNumber){
        super(b);

        String[] temp = new String[testFreqAmount];

        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + (i % (temp.length/2) )).substring(1);
        }

        m_tabs = new SinCosTabs(m_bounds.withXFrame(m_spacer/4
            ).withYLen(m_spacer/2
            ).withoutLeftRatio(0.2),
            temp);
        m_tabs.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(1), ColorLoader.getGreyColor(0));

        m_mult = new OneGraphDisplay(m_bounds.withXFrame(m_spacer/4
            ).withoutLeftRatio(2.0f/7
            ).withoutTop(m_spacer/2), sampleNumber);
    
        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void initializeControllers(){
        
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Multiplication");
        m_sectionTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

    }

    protected int getSelectedFrequency(){
        return m_tabs.getValue();
    }

    protected void setSelectedFrequency(int selectedFrequency){

        m_tabs.setValue(selectedFrequency);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        m_tabs.update();
        fill(150);
        textSize(m_spacer /5);
        textAlign(LEFT);
        text("Sin",
        m_bounds.getXPos() + 3 * m_spacer,
        m_bounds.getYPos() + 2 * m_spacer/9);
        text("Cos",
        m_bounds.getXPos() + 3 * m_spacer,
        m_bounds.getYPos() + m_spacer/4 + 2 * m_spacer/9);


        if(m_sectionTickbox.getValue()){
            
            m_mult.draw();
        }
        
        
    }

    public boolean hasChangedSelectedFrequency(){
        boolean temp = (m_selectedFrequency == m_tabs.getValue());
        m_selectedFrequency = m_tabs.getValue();
        return temp;
    }

    public void setData(float[] data){
        m_mult.setData(data);
    }
}

//====================================================================

class SpectrumSection extends GUISection{
    private Tickbox m_sectionTickbox;

    private Tickbox m_sinTickbox;
    private Tickbox m_cosTickbox;
    private Tickbox m_spectrumTickbox;

    private SpectrumDisplay m_spectrum;

    private int m_selectedFrequency;

    SpectrumSection(Bounds b, int testFreqAmount){
        super(b);

        m_spectrum = new SpectrumDisplay(m_bounds.withFrame(m_spacer/4
            ).withoutLeftRatio(0.2),
            testFreqAmount);

        m_backgroundColor = ColorLoader.getBackgroundColor(1);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_bounds.withLen(m_spacer/2, m_spacer/2), "Spectrum");
        m_sectionTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

        m_sinTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + 4 * m_spacer/6,
                                    m_bounds.getYPos() + 4 * m_spacer/6, 
                                    m_spacer/3, 
                                    m_spacer/3), "Sine");
        m_sinTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(1), ColorLoader.getGreyColor(0));

        m_cosTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + 4 * m_spacer/6,
                                    m_bounds.getYPos() + 4 * m_spacer/6 + m_spacer/2, 
                                    m_spacer/3, 
                                    m_spacer/3), "Cos");
        m_cosTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(2), ColorLoader.getGreyColor(0));

        m_spectrumTickbox = new Tickbox(new Bounds(m_bounds.getXPos() + 4 * m_spacer/6,
                                    m_bounds.getYPos() + 4 * m_spacer/6 + m_spacer, 
                                    m_spacer/3, 
                                    m_spacer/3), "Spectrum");
        m_spectrumTickbox.setColor(ColorLoader.getGreyColor(2), ColorLoader.getGreyColor(1), ColorLoader.getFillColor(0), ColorLoader.getGreyColor(0));

    }

    protected int getSelectedFrequency(){
        int maxFrequency = m_spectrum.getMaxFrequency();
        int spectrumSelectedFrequency = m_spectrum.getSelectedFrequency();

        if( (m_selectedFrequency % maxFrequency) != spectrumSelectedFrequency){
            m_selectedFrequency = (m_selectedFrequency / maxFrequency) * maxFrequency + spectrumSelectedFrequency;
        }
        return m_selectedFrequency;
    }

    protected void setSelectedFrequency(int selectedFrequency){
        m_selectedFrequency = selectedFrequency;
        m_spectrum.setSelectedFrequency(m_selectedFrequency % m_spectrum.getMaxFrequency());
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_sinTickbox.update();
            m_cosTickbox.update();
            m_spectrumTickbox.update();

            m_spectrum.setFullSpectrumVisibility(m_spectrumTickbox.getValue());
            m_spectrum.setSinVisibility(m_sinTickbox.getValue());
            m_spectrum.setCosVisibility(m_cosTickbox.getValue());
            m_spectrum.draw();
        }
        
        
    }

    public void setFullSpectrum(float[] data){
        m_spectrum.setData(data);
    }

    public void setSinSpectrum(float[] data){
        m_spectrum.setSinSpectrum(data);
    }

    public void setCosSpectrum(float[] data){
        m_spectrum.setCosSpectrum(data);
    }
}