class OneGraphDisplay{
    protected PVector m_pos;
    protected PVector m_len;

    protected Graph m_graph;

    OneGraphDisplay(float posX, float posY, float lenX, float lenY, int resolution){
        m_pos = new PVector(posX, posY);
        m_len = new PVector(lenX, lenY);

        m_graph = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        m_graph.setColor(color(75, 140, 140));
    }

    public void setData(float[] data){
        m_graph.setData(data);
    }

    public void draw(){
        stroke(color(100, 100, 100));
        strokeWeight(2);
        fill(color(50, 50, 50));
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        m_graph.draw();
    }



}

//=========================================================

class SpectrumDisplay extends OneGraphDisplay{
    private Graph m_sinSpectrum;
    private Graph m_cosSpectrum;
    boolean m_fullIsVisible = true;
    boolean m_sinIsVisible = true;
    boolean m_cosIsVisible = true;

    private HoverTabs m_spectrumTabs;

    SpectrumDisplay(float posX, float posY, float lenX, float lenY, int resolution){
        super(posX, posY, lenX, lenY, resolution);

        m_sinSpectrum = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        m_cosSpectrum = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);

        setAsSpectrumDisplay();

        String[] temp = new String[resolution];
        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + i ).substring(1);
        }
        m_spectrumTabs = new HoverTabs(m_pos.x, m_pos.y, m_len.x, m_len.y, temp);
    }

    public void setAsSpectrumDisplay(){
        float maxValue = 0.6;

        m_graph.setBaseValue(0);
        m_graph.setInputValueRange(0, maxValue);
        m_graph.setDisplayMode(1);
        m_graph.setColor(color(255, 120, 9));

        m_sinSpectrum.setBaseValue(0);
        m_sinSpectrum.setInputValueRange(0, maxValue);
        m_sinSpectrum.setDisplayMode(1);
        m_sinSpectrum.setColor(color(105, 255, 9));

        m_cosSpectrum.setBaseValue(0);
        m_cosSpectrum.setInputValueRange(0, maxValue);
        m_cosSpectrum.setDisplayMode(1);
        m_cosSpectrum.setColor(color(180, 10, 198));
    }

    public int getSelectedFrequency(){
        return m_spectrumTabs.getValue();
    }

    public void setSelectedFrequency(int selectedFrequency){
        m_spectrumTabs.setValue(selectedFrequency);
    }

    public int getMaxFrequency(){
        return m_spectrumTabs.getMaxValue();
    }

    public void draw(){
        stroke(color(100, 100, 100));
        strokeWeight(2);
        fill(color(50, 50, 50));
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        if(m_sinIsVisible){
            m_sinSpectrum.draw();
        }

        if(m_cosIsVisible){
            m_cosSpectrum.draw();
        }

        if(m_fullIsVisible){
            m_graph.draw();
        }

        
        m_spectrumTabs.update();
    }

    public void setSinSpectrum(float[] data){
        m_sinSpectrum.setData(data);
    }

    public void setCosSpectrum(float[] data){
        m_cosSpectrum.setData(data);
    }

    public void setFullSpectrumVisibility(boolean isVisible){
        m_fullIsVisible = isVisible;
    }

    public void setSinVisibility(boolean isVisible){
        m_sinIsVisible = isVisible;
    }

    public void setCosVisibility(boolean isVisible){
        m_cosIsVisible = isVisible;
    }


}

//=======================================================

class ContinuousGraphDisplay{
    private PVector m_pos;
    private PVector m_len;

    private Graph[] m_graph;

    ContinuousGraphDisplay(float xPos, float yPos, float xLen, float yLen, int resolution, int graphAmount){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);
        
        m_graph = new Graph[graphAmount];

        for(int i = 0; i < m_graph.length; i++){
            m_graph[i] = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
            m_graph[i].setDisplayMode(2);
        }
    }

    public void setData(int graphNumber, float[] data){
        m_graph[graphNumber].setData(data);
    }

    public void draw(){
        stroke(color(100, 100, 100));
        strokeWeight(2);
        fill(color(50, 50, 50));
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);
        for(int i = 0; i < m_graph.length; i++){
            m_graph[i].draw();
        }
    }

}