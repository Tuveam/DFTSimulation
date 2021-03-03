class Generator{
    protected PVector m_pos;
    protected PVector m_len;
    private float m_spacer;

    int m_time = 0;
    float[] m_data; //goes from -1 to 1
    float m_phase = 0; //goes from 0 to 1

    private Tickbox m_switch;
    protected Knob[] m_knob;
    private Tabs m_tabs;

    
    

    Generator(float xPos, float yPos, float xLen, float yLen, float spacer, int arrayLength){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);
        m_spacer = spacer;

        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }

        m_switch = new Tickbox(m_pos.x,
                                m_pos.y,
                                (m_len.y - m_spacer) / 2,
                                (m_len.y - m_spacer) / 2,
                                "Generator");

        m_knob = new Knob[3];

        m_knob[0] = new Knob(m_pos.x, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Frequency");
        m_knob[0].setRealValueRange(0.5, m_data.length);
        m_knob[0].setRealValue(1);

        m_knob[1] = new Knob(m_pos.x + 1 * m_len.x / 3, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Phase");
        m_knob[1].setRealValueRange(0, TWO_PI);
        m_knob[1].setRealValue(0);

        m_knob[2] = new Knob(m_pos.x + 2 * m_len.x / 3, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Amplitude");
        m_knob[2].setRealValue(1);

        String[] tempSynthModes = new String[]{"0", "sin", "tria", "squ", "saw", "noise"};
        m_tabs = new Tabs(m_pos.x, m_pos.y + m_len.y / 2 + m_spacer / 2, m_len.x, m_len.y / 2 - m_spacer / 2, tempSynthModes);
        m_tabs.setValue(1);
    }

    public void update(){
        noStroke();
        fill(100, 128);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 5);

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

}

//===========================================================================

class DFTGenerator extends Generator{

    DFTGenerator(float xPos, float yPos, float xLen, float yLen, float spacer, int arrayLength){
        super(xPos, yPos, xLen, yLen, spacer, 1);
        m_knob[0].setRealValueRange(0.5, arrayLength);
        m_knob[0].setRealValue(1);
    }    
}