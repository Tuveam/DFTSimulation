class OneGraphDisplay{
    protected Bounds m_bounds;

    protected Graph m_graph;

    protected float m_baseValue = 0.5;

    OneGraphDisplay(Bounds b, int resolution){
        m_bounds = b;

        m_graph = new Graph(m_bounds, resolution);
        m_graph.setColor(ColorLoader.getGraphColor(0));
    }

    public void setData(float[] data){
        m_graph.setData(data);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);
        line(
            m_bounds.getXPos(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue),
            m_bounds.getXPos() + m_bounds.getXLen(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue));

        m_graph.draw();
    }

    public void setBaseValue(float baseValue){
        m_baseValue = constrain(baseValue, 0, 1);
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

    SpectrumDisplay(Bounds b, int resolution){
        super(b, resolution);

        m_sinSpectrum = new Graph(m_bounds, resolution);
        m_cosSpectrum = new Graph(m_bounds, resolution);

        setAsSpectrumDisplay();

        String[] temp = new String[resolution];
        for(int i = 0; i < temp.length; i++){
            temp[i] = ("i" + i ).substring(1);
        }
        m_spectrumTabs = new HoverTabs(m_bounds, temp);
    }

    public void setAsSpectrumDisplay(){
        float maxValue = 0.6;

        setBaseValue(0);

        m_graph.setBaseValue(0);
        m_graph.setInputValueRange(0, maxValue);
        m_graph.setDisplayMode(1);
        m_graph.setColor(ColorLoader.getGraphColor(0));

        m_sinSpectrum.setBaseValue(0);
        m_sinSpectrum.setInputValueRange(0, maxValue);
        m_sinSpectrum.setDisplayMode(1);
        m_sinSpectrum.setColor(ColorLoader.getGraphColor(1));

        m_cosSpectrum.setBaseValue(0);
        m_cosSpectrum.setInputValueRange(0, maxValue);
        m_cosSpectrum.setDisplayMode(1);
        m_cosSpectrum.setColor(ColorLoader.getGraphColor(2));
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
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);
        line(
            m_bounds.getXPos(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue),
            m_bounds.getXPos() + m_bounds.getXLen(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue));

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
    private Bounds m_bounds;

    private Graph[] m_graph;
    private boolean[] m_isVisible;

    protected float m_baseValue = 0.5;

    ContinuousGraphDisplay(Bounds b, int resolution, int graphAmount){
        m_bounds = b;
        
        m_graph = new Graph[graphAmount];
        m_isVisible = new boolean[m_graph.length];

        for(int i = 0; i < m_graph.length; i++){
            m_graph[i] = new Graph(m_bounds, resolution);
            m_graph[i].setDisplayMode(2);
            m_isVisible[i] = true;
        }
    }

    public void setData(int graphNumber, float[] data){
        m_graph[graphNumber].setData(data);
    }

    public void setVisibility(int graphNumber, boolean isVisible){
        m_isVisible[graphNumber] = isVisible;
    }

    public void setColor(int graphNumber, color c){
        m_graph[graphNumber].setColor(c);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);
        line(
            m_bounds.getXPos(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue),
            m_bounds.getXPos() + m_bounds.getXLen(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue));

        for(int i = 0; i < m_graph.length; i++){

            if(m_isVisible[i]){
                m_graph[i].draw();
            }
            
        }
    }

    public void setBaseValue(float baseValue){
        m_baseValue = constrain(baseValue, 0, 1);
    }

}

//=========================================================

class AliasGraphDisplay extends OneGraphDisplay{

    protected SampledGraph m_sampledGraph;

    AliasGraphDisplay(Bounds b, int resolution, int sampledMaxResolution){
        super(b, resolution);

        m_graph.setDisplayMode(2);

        m_sampledGraph = new SampledGraph(m_bounds, sampledMaxResolution);
    }

    public void setSampleRate(int samplerate){
        m_sampledGraph.setSampleRate(samplerate);
    }

    public void setData(float[] data){
        m_graph.setData(data);
        m_sampledGraph.setData(data);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);
        line(
            m_bounds.getXPos(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue),
            m_bounds.getXPos() + m_bounds.getXLen(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue));

        m_graph.draw();
        m_sampledGraph.draw();
    }

    public float[] getSampledData(){
        return m_sampledGraph.getData();
    }

}

//===========================================================

class InterpolationGraphDisplay {
    protected Bounds m_bounds;

    protected InterpolationGraph m_graph;

    protected float m_baseValue = 0.5;

    InterpolationGraphDisplay(Bounds b){
        m_bounds = b;

        m_graph = new InterpolationGraph(m_bounds);
    }

    public void setData(float[] data){
        m_graph.setData(data);
    }

    public void draw(){
        stroke(ColorLoader.getGreyColor(1));
        strokeWeight(2);
        fill(ColorLoader.getGreyColor(2));
        rect(m_bounds);
        line(
            m_bounds.getXPos(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue),
            m_bounds.getXPos() + m_bounds.getXLen(),
            m_bounds.getYPos() + m_bounds.getYLen() * (1-m_baseValue));

        m_graph.draw();
    }

    public void setBaseValue(float baseValue){
        m_baseValue = constrain(baseValue, 0, 1);
    }

}
