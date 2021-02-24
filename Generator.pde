class Generator{
    protected PVector m_pos;
    protected PVector m_len;
    private float m_spacer;

    int m_time = 0;
    float[] m_data; //goes from -1 to 1
    float m_phase = 0; //goes from 0 to 1

    private Tickbox m_switch;
    private Knob[] m_knob;
    private Tabs m_tabs;

    
    

    Generator(float xPos, float yPos, float xLen, float yLen, float spacer, int arrayLength){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);
        m_spacer = spacer;

        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }

        m_switch = new Tickbox(m_pos.x, m_pos.y, (m_len.y - m_spacer) / 2, (m_len.y - m_spacer) / 2);

        m_knob = new Knob[3];

        m_knob[0] = new Knob(m_pos.x, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Frequency");
        m_knob[0].setRealValueRange(0.5, m_data.length/2);

        m_knob[1] = new Knob(m_pos.x + 1 * m_len.x / 3, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Phase");
        m_knob[1].setRealValueRange(0, TWO_PI);

        m_knob[2] = new Knob(m_pos.x + 2 * m_len.x / 3, m_pos.y + m_len.y / 2 - m_spacer / 2, m_len.x / 3, m_spacer, "Amplitude");

        m_tabs = new Tabs(m_pos.x, m_pos.y + m_len.y / 2 + m_spacer / 2, m_len.x, m_len.y / 2 - m_spacer / 2, new String[]{"0", "sin", "saw", "noise"});
    }

    public void update(){
        noStroke();
        fill(100, 128);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 5);

        fill(150);
        textSize((m_len.y - m_spacer) /3);
        textAlign(LEFT);
        text("Generator", m_pos.x + (m_len.y - m_spacer) / 2, m_pos.y + (m_len.y - m_spacer) / 3);

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
            m_phase = (m_phase + m_knob[0].getRealValue() / m_data.length)%1;

            switch(m_tabs.getValue()){
                case 0: //Zero
                m_data[getFirstIndex()] = 0;
                break;
                case 1: //Sin
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * sin( 2 * PI * (m_phase + m_knob[1].getValue()) );
                break;
                case 2: //Saw
                m_data[getFirstIndex()] = m_knob[2].getRealValue() * (2.0 * (m_phase + m_knob[1].getValue()) % 2 - 1);
                break;
                case 3: //Noise
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

    protected int getFirstIndex(){
        return m_time % m_data.length;
    }

    public boolean isOn(){
        return m_switch.getValue();
    }

}