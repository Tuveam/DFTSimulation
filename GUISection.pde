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

    float[][] m_testFrequency;

    DFTSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }
    
    protected void initializeSections(){
        int totalWindowLength = 50;
        m_testFrequency = new float[totalWindowLength][totalWindowLength];

        m_menuSection = new MenuSection(m_pos, new PVector(m_len.x, m_spacer));
        m_inputSection = new InputSection(new PVector(m_pos.x, m_pos.y + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3), totalWindowLength);
        m_mathSection = new MathSection(new PVector(m_pos.x, m_pos.y + (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
        m_spectrumSection = new SpectrumSection(new PVector(m_pos.x, m_pos.y + 2 * (m_len.y - m_spacer)/3 + m_spacer), new PVector(m_len.x, (m_len.y - m_spacer)/3));
    }

    protected void drawSections(){
        if(m_menuSection.isTimeAdvancing()){
            m_inputSection.advanceTime();
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
        textSize(26);
        fill(255, 30);
        text("Menu", 0, 0);
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
    private Automation m_windowShape; 
    private Generator m_generator;
    private Graph m_input;
    private Knob m_generatorFrequencyKnob;
    private Tabs m_generatorModeTabs;
    private Tickbox m_sectionTickbox;

    private int m_sampleNumber;

    InputSection(PVector pos, PVector len, int sampleNumber){
        super(pos, len);

        m_sampleNumber = sampleNumber;
        m_generator = new Generator(m_sampleNumber);

        m_generatorFrequencyKnob.setRealValueRange(0.5, m_sampleNumber/2);
    }

    protected void initializeControllers(){
        m_sectionTickbox = new Tickbox(m_pos.x, m_pos.y, m_spacer/2, m_spacer/2);

        m_windowShape = new Automation(m_pos.x + m_len.x/3, m_pos.y + m_spacer/2, 3 * m_len.x/5, m_len.y - m_spacer, color(200, 75, 75), false);
        
        m_input = new Graph(m_pos.x + m_len.x/3, m_pos.y + m_spacer/2, 3 * m_len.x/5, m_len.y - m_spacer);

        m_generatorFrequencyKnob = new Knob(m_pos.x, m_pos.y + m_spacer/2, m_spacer, m_spacer, "Frequency");

        m_generatorModeTabs = new Tabs(m_pos.x + 5 * m_spacer/4, m_pos.y + m_spacer/2, m_len.x/3 - 1.5 * m_spacer, m_spacer * 0.4, new String[]{"0", "sin", "saw", "noise"});

    }

    protected void drawBackground(){
        noStroke();
        fill(13, 37, 51);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        textSize(26);
        fill(255, 30);
        text("Input", 0, 0);
        popMatrix();
    }

    protected void drawComponents(){
        m_sectionTickbox.update();
        m_generatorFrequencyKnob.update();
        m_generatorModeTabs.update();

        m_windowShape.drawBackground();
        
        m_input.draw(m_generator.getArray());
        //m_input.addData(sin(0.1 * m_time), m_time - 1);

        m_windowShape.update();
        
    }

    public void advanceTime(){
        //println((frameCount%2 == 0)? "tick" : "tack");
        m_generator.setVariables(m_generatorFrequencyKnob.getRealValue(), m_generatorModeTabs.getValue());
        m_generator.advanceTime();
    }
}

//====================================================================

class MathSection extends GUISection{
    Tabs m_tabs;
    MathSection(PVector pos, PVector len){
        super(pos, len);
    }

    protected void initializeControllers(){
        m_tabs = new Tabs(m_pos.x, m_pos.y, m_len.x, m_len.y/8, new String[]{"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"});
    }

    protected void drawBackground(){
        noStroke();
        fill(51, 13, 37);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        textSize(26);
        fill(255, 30);
        text("Math", 0, 0);
        popMatrix();
    }
}

//====================================================================

class SpectrumSection extends GUISection{
    SpectrumSection(PVector pos, PVector len){
        super(pos, len);
    }

    protected void drawBackground(){
        noStroke();
        fill(37, 51, 13);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);

        pushMatrix();
        translate(m_pos.x + m_len.x/2, m_pos.y + m_len.y/2);

        textSize(26);
        fill(255, 30);
        text("Spectrum", 0, 0);
        popMatrix();
    }
}