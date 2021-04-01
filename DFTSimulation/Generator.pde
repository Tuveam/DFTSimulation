class Generator{
    protected Bounds m_bounds;
    private float m_spacer;

    int m_time = 0;
    float[] m_data; //goes from -1 to 1
    float m_phase = 0; //goes from 0 to 1

    protected Tickbox m_switch;
    protected Knob[] m_knob;
    protected Tabs m_tabs;

    
    

    Generator(Bounds b, float spacer, int arrayLength){
        m_bounds = b;
        m_spacer = spacer;

        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }

        Bounds bTop = m_bounds.withoutBottom( m_spacer ).withoutBottomRatio( 0.5 );
        Bounds bMiddle = m_bounds.withYFrame( (m_bounds.getYLen() - m_spacer)/2 );
        Bounds bBottom = m_bounds.withoutTop( m_spacer ).withoutTopRatio( 0.5 );

        m_switch = new Tickbox(bTop.withLeftSquare(),
                                "Generator");

        m_knob = new Knob[3];

        m_knob[0] = new Knob(bMiddle.asSectionOfXDivisions(0, 3), "Frequency");
        m_knob[0].setRealValueRange(0.5, m_data.length);
        m_knob[0].setRealValue(1);
        m_knob[0].setSnapSteps(2 * m_data.length - 1);

        m_knob[1] = new Knob(bMiddle.asSectionOfXDivisions(1, 3), "Phase");
        m_knob[1].setRealValueRange(0, TWO_PI);
        m_knob[1].setRealValue(0);
        m_knob[1].setSnapSteps(12);

        m_knob[2] = new Knob(bMiddle.asSectionOfXDivisions(2, 3), "Amplitude");
        m_knob[2].setRealValueRange(-1, 1);
        m_knob[2].setRealValue(1);

        String[] tempSynthModes = new String[]{"0", "sin", "tria", "squ", "saw", "noise"};
        m_tabs = new Tabs(bBottom, tempSynthModes);
        m_tabs.setValue(1);
    }

    public void update(){
        noStroke();
        fill(100, 128);
        rect(m_bounds, 5);

        m_switch.update();

        if(m_switch.getValue()){
            for(int i = 0; i < m_knob.length; i++){
                m_knob[i].update();
            }

            m_tabs.update();

        }
        
    }

    public void advanceTime(){
        if(m_switch.getValue()){
            //println(m_knob[0].getRealValue());
            m_phase = (m_phase + (m_knob[0].getRealValue() / m_knob[0].getMaxRealValue() ))%1;

            float newPhase = (m_phase + m_knob[1].getValue()) % 1;

            switch(m_tabs.getValue()){
                case 0: //Zero
                m_data[getFirstIndex()] = 0;
                break;
                case 1: //Sin
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * sin( 2 * PI * newPhase );
                break;
                case 2: //Triangle
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * ( ( newPhase < 0.5 )? 4.0 * newPhase - 1 : -4.0 * newPhase + 3)/*triangle*/;
                break;
                case 3: //Square
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * ( ( newPhase < 0.5 )? 1 : -1)/*square*/;
                break;
                case 4: //Saw
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * (2.0 * newPhase - 1);
                break;
                case 5: //Noise
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * random(-1, 1);
                break;
            }
            m_time++;
        }
    }

    public float[] getArray(){
        float[] temp = new float[m_data.length];
        for(int i = 0; i < m_data.length; i++){
            int tempIndex = (i + getFirstIndex()) % temp.length;
            temp[i] = m_data[tempIndex];
        }
        return temp;
    }

    public float getLatestValue(){
        return m_data[getFirstIndex()];
    }

    protected int getFirstIndex(){
        return m_time % m_data.length;
    }

    public boolean isOn(){
        return m_switch.getValue();
    }

    public int getArrayLength(){
        return m_data.length;
    }

    public void setFrequencyRange(float minFrequency, float maxFrequency){
        m_knob[0].setRealValueRange(minFrequency, maxFrequency);
        m_knob[0].setSnapSteps(int(2 * maxFrequency - 1));
    }

    public void setFrequency(float frequency){
        m_knob[0].setRealValue(frequency);
    }

}

//===========================================================================

class DFTGenerator extends Generator{

    DFTGenerator(Bounds b, float spacer, int arrayLength){
        super(b, spacer, 1);
        m_knob[0].setRealValueRange(0.5, arrayLength);
        m_knob[0].setRealValue(1);
        m_knob[0].setSnapSteps(2 * arrayLength - 1);
    }    
}

//===========================================================================

class InstantGenerator extends Generator{
    InstantGenerator(Bounds b, float spacer, int arrayLength){
        super(b, spacer, arrayLength);
        m_knob[0].setRealValueRange(0.5, arrayLength / 2);
        m_knob[0].setRealValue(1);
        m_knob[0].setSnapSteps(2 * arrayLength - 1);
    } 

    public void update(){
        fillArray();

        noStroke();
        fill(100, 128);
        rect(m_bounds, 5);

        m_switch.update();

        if(m_switch.getValue()){
            for(int i = 0; i < m_knob.length; i++){
                m_knob[i].update();
            }

            m_tabs.update();

        }
        
    }

    protected void fillArray(){
        
        if(m_switch.getValue()){
            for(int i = 0; i < m_data.length; i++){

                float newPhase = (m_knob[0].getRealValue() * ((i * 1.0f) / m_data.length) + m_knob[1].getValue()) % 1;

                switch(m_tabs.getValue()){
                    case 0: //Zero
                    m_data[i] = 0;
                    break;
                    case 1: //Sin
                    m_data[i] = m_knob[2].getRealValue() * sin( 2 * PI * newPhase );
                    break;
                    case 2: //Triangle
                    m_data[i] = m_knob[2].getRealValue() * ( ( newPhase < 0.5 )? 4.0 * newPhase - 1 : -4.0 * newPhase + 3)/*triangle*/;
                    break;
                    case 3: //Square
                    m_data[i] = m_knob[2].getRealValue() * ( ( newPhase < 0.5 )? 1 : -1)/*square*/;
                    break;
                    case 4: //Saw
                    m_data[i] = m_knob[2].getRealValue() * (2.0 * newPhase - 1);
                    break;
                    case 5: //Noise
                    m_data[i] = m_knob[2].getRealValue() * random(-1, 1);
                    break;
                }

                //println(i + ": " + m_data[i]);
            }
        }
    }

    public float[] getArray(){
        return m_data;
    }
}