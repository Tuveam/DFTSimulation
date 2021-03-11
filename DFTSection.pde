class DFTSection extends GUISection{

    MenuSection m_menuSection;
    InputSection m_inputSection;
    MathSection m_mathSection;
    SpectrumSection m_spectrumSection;

    private int m_windowLength;
    private int m_selectedFrequency = 0;


    DFTSection(float xPos, float yPos, float xLen, float yLen, int windowLength){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_windowLength = windowLength;

        m_menuSection = new MenuSection(m_pos, new PVector(m_len.x, m_spacer));
        m_inputSection = new InputSection(new PVector(m_pos.x, m_pos.y + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), m_windowLength, m_windowLength);
        m_mathSection = new MathSection(new PVector(m_pos.x, m_pos.y + (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), m_windowLength, m_windowLength);
        m_spectrumSection = new SpectrumSection(new PVector(m_pos.x, m_pos.y + 2 * (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), m_windowLength/2);
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

    MenuSection(PVector pos, PVector len){
        super(pos, len);
    }

    protected void initializeControllers(){
        m_playButton = new PlayButton(new Bounds(m_pos.x + m_len.x - 4 * m_spacer, m_pos.y, m_spacer, m_spacer));
        m_skipButton = new SkipButton(new Bounds(m_pos.x + m_len.x - 3 * m_spacer, m_pos.y, m_spacer, m_spacer));
        m_sampleRateKnob = new Knob(new Bounds(m_pos.x + m_len.x - 2 * m_spacer, m_pos.y, m_spacer, m_spacer), "Samplerate");
        m_sampleRateKnob.setRealValueRange(60, 1);
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
        fill(40);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        blink();
    }

    private void blink(){
        if(m_isAdvancingTime){
            m_blink = 10;
        }

        fill(map(m_blink, 0, 10, 0, 255), 0, 0);
        noStroke();
        ellipse(m_pos.x + m_len.x - m_len.y/2, m_pos.y + m_len.y/2, m_len.y, m_len.y);

        fill(200);
        textSize(20);
        textAlign(CENTER);
        text(frameRate, m_pos.x + m_len.x - m_len.y/2, m_pos.y + m_len.y/2);

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

    InputSection(PVector pos, PVector len, int testFreqAmount, int sampleNumber){
        super(pos, len);

        m_sampleNumber = sampleNumber;
        m_generator = new DFTGenerator(new Bounds(m_pos.x + m_spacer/2,
                                    m_pos.y + m_spacer / 2,
                                    2 * m_len.x / 7,
                                    5 * m_spacer / 3),
                                    m_spacer,
                                    m_sampleNumber);
        m_signalDisplay = new SignalDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7,
                                            m_len.y - m_spacer,
                                            testFreqAmount,
                                            m_sampleNumber);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(new Bounds(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2), "Input Signal");
        m_testFreqTickbox = new Tickbox(new Bounds(m_pos.x + m_spacer/2,
                                        m_pos.y + 5 * m_spacer / 2,
                                        m_spacer/3,
                                        m_spacer/3), "Test Frequency");
        m_windowShapeTickbox = new Tickbox(new Bounds(m_pos.x + m_spacer/2,
                                        m_pos.y + 19 * m_spacer / 6,
                                        m_spacer/3,
                                        m_spacer/3), "Window Shape");
        
    }

    protected void drawBackground(){
        noStroke();
        fill(13, 37, 51);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_generator.update();

            noStroke();
            fill(100, 128);
            rect(m_pos.x + m_spacer/2,
                m_pos.y + 5 * m_spacer / 2 - m_spacer / 12,
                2 * m_len.x / 7,
                m_spacer/2,
                m_spacer/8);
            
            m_testFreqTickbox.update();

            noStroke();
            fill(100, 128);
            rect(m_pos.x + m_spacer/2,
                m_pos.y + 19 * m_spacer / 6 - m_spacer / 12,
                2 * m_len.x / 7,
                m_spacer/2,
                m_spacer/8);
            
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


    MathSection(PVector pos, PVector len, int testFreqAmount, int sampleNumber){
        super(pos, len);

        String[] temp = new String[testFreqAmount];

        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + (i % (temp.length/2) )).substring(1);
        }

        m_tabs = new SinCosTabs(new Bounds(m_pos.x + 5 * m_spacer/2, m_pos.y + m_len.y - m_spacer/2, m_len.x - 3 * m_spacer, m_spacer/2), temp);

        m_mult = new OneGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7, m_pos.y + m_spacer/2, m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7, m_len.y - m_spacer, sampleNumber);
    }

    protected void initializeControllers(){
        
        m_sectionTickbox = new Tickbox(new Bounds(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2), "Multiplication");
    }

    protected int getSelectedFrequency(){
        return m_tabs.getValue();
    }

    protected void setSelectedFrequency(int selectedFrequency){

        m_tabs.setValue(selectedFrequency);
    }


    protected void drawBackground(){
        noStroke();
        fill(51, 13, 37);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_tabs.update();
            fill(150);
            textSize(m_spacer /5);
            textAlign(LEFT);
            text("Sin",
            m_pos.x + 2 * m_spacer,
            m_pos.y + m_len.y - m_spacer/2 + 2 * m_spacer/9);
            text("Cos",
            m_pos.x + 2 * m_spacer,
            m_pos.y + m_len.y - m_spacer/4 + 2 * m_spacer/9);

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

    SpectrumSection(PVector pos, PVector len, int testFreqAmount){
        super(pos, len);

        m_spectrum = new SpectrumDisplay(m_pos.x + 5 * m_spacer / 2, m_pos.y + m_spacer/2, m_len.x - 3 * m_spacer, m_len.y - m_spacer, testFreqAmount);

    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(new Bounds(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2), "Spectrum");

        m_sinTickbox = new Tickbox(new Bounds(m_pos.x + 4 * m_spacer/6,
                                    m_pos.y + 4 * m_spacer/6, 
                                    m_spacer/3, 
                                    m_spacer/3), "Sine");
        m_cosTickbox = new Tickbox(new Bounds(m_pos.x + 4 * m_spacer/6,
                                    m_pos.y + 4 * m_spacer/6 + m_spacer/2, 
                                    m_spacer/3, 
                                    m_spacer/3), "Cos");
        m_spectrumTickbox = new Tickbox(new Bounds(m_pos.x + 4 * m_spacer/6,
                                    m_pos.y + 4 * m_spacer/6 + m_spacer, 
                                    m_spacer/3, 
                                    m_spacer/3), "Spectrum");

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

    protected void drawBackground(){
        noStroke();
        fill(37, 51, 13);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
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