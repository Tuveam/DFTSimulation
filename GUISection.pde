class GUISection{
    protected PVector m_pos;
    protected PVector m_len;

    protected float m_spacer = 65;

    GUISection(PVector pos, PVector len){
        m_pos = pos;
        m_len = len;

        initializeControllers();
        initializeSections();
    }

    protected void initializeControllers(){

    }

    protected void initializeSections(){

    }

    public void update(){
        draw();
    }

    protected void draw(){
        drawBackground();
        drawComponents();
        drawSections();
    }

    protected void drawBackground(){
        noStroke();
        fill(10);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);
    }

    protected void drawSections(){

    }

    protected void drawComponents(){

    }  
}

//====================================================================

class DFTSection extends GUISection{

    MenuSection m_menuSection;
    InputSection m_inputSection;
    MathSection m_mathSection;
    SpectrumSection m_spectrumSection;


    DFTSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }
    
    protected void initializeSections(){
        int totalWindowLength = 50;
        int testFreqAmount = totalWindowLength;

        m_menuSection = new MenuSection(m_pos, new PVector(m_len.x, m_spacer));
        m_inputSection = new InputSection(new PVector(m_pos.x, m_pos.y + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), testFreqAmount, totalWindowLength);
        m_mathSection = new MathSection(new PVector(m_pos.x, m_pos.y + (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), testFreqAmount, totalWindowLength);
        m_spectrumSection = new SpectrumSection(new PVector(m_pos.x, m_pos.y + 2 * (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), testFreqAmount/2);
    }

    protected void drawSections(){
        if(m_menuSection.isTimeAdvancing()){
            m_inputSection.advanceTime();
        }

        if(m_mathSection.hasChangedTestFreq()){
            m_inputSection.setTestFreq(m_mathSection.getTestFreq());
        }

        if(true){
            m_mathSection.setData(m_inputSection.getMultiplicationData());
        }

        if(true){
            m_spectrumSection.setData(m_inputSection.getSpectrum());
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
    Button m_skipButton;
    Knob m_sampleRateKnob;

    int m_iterateTime = 0;
    boolean m_isAdvancingTime = false;

    int m_blink = 0;

    MenuSection(PVector pos, PVector len){
        super(pos, len);
    }

    protected void initializeControllers(){
        m_playButton = new PlayButton(m_pos.x + m_spacer, m_pos.y, m_spacer, m_spacer);
        m_skipButton = new Button(m_pos.x + 8 * m_spacer/4, m_pos.y, m_spacer, m_spacer);
        m_sampleRateKnob = new Knob(m_pos.x + 13 * m_spacer/4, m_pos.y, m_spacer, m_spacer, "Samplerate");
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

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();

        blink();
    }

    private void blink(){
        if(m_isAdvancingTime){
            m_blink = 10;
        }

        fill(map(m_blink, 0, 10, 0, 255), 0, 0);
        noStroke();
        ellipse(m_pos.x + m_len.x - m_len.y/2, m_pos.y + m_len.y/2, m_len.y, m_len.y);

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
    private Generator m_generator;

    private Tickbox m_testFreqTickbox;
    private Tickbox m_windowShapeTickbox;
    

    private int m_sampleNumber;

    SignalDisplay m_signalDisplay;

    boolean multiplicationChanged = true;
    boolean spectrumChanged = true;

    InputSection(PVector pos, PVector len, int testFreqAmount, int sampleNumber){
        super(pos, len);

        m_sampleNumber = sampleNumber;
        m_generator = new Generator(m_pos.x + m_spacer/2,
                                    m_pos.y + m_spacer / 2,
                                    2 * m_len.x / 7,
                                    5 * m_spacer / 3,
                                    m_spacer, m_sampleNumber);
        m_signalDisplay = new SignalDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7,
                                            m_pos.y + m_spacer/2,
                                            m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7,
                                            m_len.y - m_spacer,
                                            testFreqAmount,
                                            m_sampleNumber);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2);
        m_testFreqTickbox = new Tickbox(m_pos.x + m_spacer/2,
                                        m_pos.y + 5 * m_spacer / 2,
                                        m_spacer/3,
                                        m_spacer/3);
        m_windowShapeTickbox = new Tickbox(m_pos.x + m_spacer/2,
                                        m_pos.y + 19 * m_spacer / 6,
                                        m_spacer/3,
                                        m_spacer/3);
        
    }

    protected void drawBackground(){
        noStroke();
        fill(13, 37, 51);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();
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
            
            fill(150);
            textSize(m_spacer /5);
            textAlign(LEFT);
            text("Test Frequency",
                m_pos.x + m_spacer,
                m_pos.y + 5 * m_spacer / 2 + m_spacer / 4);
            m_testFreqTickbox.update();

            noStroke();
            fill(100, 128);
            rect(m_pos.x + m_spacer/2,
                m_pos.y + 19 * m_spacer / 6 - m_spacer / 12,
                2 * m_len.x / 7,
                m_spacer/2,
                m_spacer/8);
            
            fill(150);
            textSize(m_spacer /5);
            textAlign(LEFT);
            text("Window Shape",
                m_pos.x + m_spacer,
                m_pos.y + 19 * m_spacer / 6 + m_spacer / 4);
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

        m_signalDisplay.setDataForInput(m_generator.getArray());
    }

    public void setTestFreq(int testFreq){
        m_signalDisplay.setTestFreq(testFreq);
    }

    public float[] getMultiplicationData(){
        return m_signalDisplay.getMultipliedArray();
    }

    public float[] getSpectrum(){
        return m_signalDisplay.getSpectrum();
    }
}

//====================================================================

class MathSection extends GUISection{
    private SinCosTabs m_tabs;
    private int m_testFreq = 0;
    private Tickbox m_sectionTickbox;
    OneGraphDisplay m_mult;


    MathSection(PVector pos, PVector len, int testFreqAmount, int sampleNumber){
        super(pos, len);

        String[] temp = new String[testFreqAmount];

        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + (i % (temp.length/2) )).substring(1);
        }

        m_tabs = new SinCosTabs(m_pos.x + m_spacer/2, m_pos.y, m_len.x - m_spacer/2, m_spacer/2, temp);

        m_mult = new OneGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7, m_pos.y + m_spacer/2, m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7, m_len.y - m_spacer, sampleNumber);
    }

    protected void initializeControllers(){
        
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2);
    }


    protected void drawBackground(){
        noStroke();
        fill(51, 13, 37);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_tabs.update();

            m_mult.draw();
        }
        
        
    }

    public boolean hasChangedTestFreq(){
        boolean temp = (m_testFreq == m_tabs.getValue());
        m_testFreq = m_tabs.getValue();
        return temp;
    }

    public int getTestFreq(){
        return m_tabs.getValue();
    }

    public void setData(float[] data){
        m_mult.setData(data);
    }
}

//====================================================================

class SpectrumSection extends GUISection{
    private Tickbox m_sectionTickbox;

    private OneGraphDisplay m_spectrum;

    SpectrumSection(PVector pos, PVector len, int testFreqAmount){
        super(pos, len);

        m_spectrum = new OneGraphDisplay(m_pos.x + m_spacer + 2 * m_len.x / 7, m_pos.y + m_spacer/2, m_len.x - 3 * m_spacer/2 - 2 * m_len.x / 7, m_len.y - m_spacer, testFreqAmount);
        m_spectrum.setAsSpectrumDisplay();
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2);
    }

    protected void drawBackground(){
        noStroke();
        fill(37, 51, 13);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        popMatrix();
    }

    protected void drawComponents(){
        m_sectionTickbox.update();

        if(m_sectionTickbox.getValue()){
            m_spectrum.draw();
        }
        
        
    }

    public void setData(float[] data){
        m_spectrum.setData(data);
    }
}