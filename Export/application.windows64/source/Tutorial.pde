class Tutorial{
    protected Bounds m_bounds;
    protected float m_spacer;

    protected QuestionMarkTickbox m_questionmark;

    protected TextBox m_text;

    Tutorial(Bounds b, float spacer, String[] tabName){
        m_bounds = new Bounds(b);
        m_spacer = spacer;

        m_questionmark = new QuestionMarkTickbox(m_bounds.withLen(m_spacer, m_spacer));
        
        m_text = new TextBox(m_bounds.withoutLeftRatio(0.5).withFrame(m_spacer/2), tabName, m_spacer);
    }

    public void update(){

        m_questionmark.update();

        if(m_questionmark.getValue()){
            m_text.draw();
        }
    }

    public void setCurrentTab(int currentTab){
        m_text.setTabCache(currentTab);
    }
}

//===========================================================

class TextBox{
    protected Bounds m_bounds;
    protected float m_spacer;

    protected Tabs m_topic;
    protected PageButton m_page;

    protected color m_backgroundColor;
    protected color m_textColor;
    protected PFont m_font;
    protected String[] m_currentText;


    protected int m_tabCache;
    protected int m_previousTabCache;

    protected int[] m_topicCache; //[tab]
    protected int m_previousTopicCache;

    protected int[][] m_pageCache; //[tab][topic]
    protected int m_previousPageCache;


    protected String[] m_tabName;

    TextBox(Bounds b, String[] tabName, float spacer){
        m_bounds = new Bounds(b);
        m_spacer = spacer;
        m_tabName = tabName;

        initializeFromJSON();
        m_page = new PageButton(
            m_bounds.withoutTop(m_bounds.getYLen() - m_spacer/2
            ).withoutLeft(m_bounds.getXLen() - m_spacer)
            );

        

        m_backgroundColor = color(0, 118, 96);
        m_textColor = color(200);
        m_font = createFont("Courier New", 20);
        m_currentText = new String[1];
        m_currentText[0] = "Test";
        setTabTopicPage(0, 0, 0);
    }

    private void initializeFromJSON(){
        m_tabCache = 0;
        m_topicCache = new int[m_tabName.length];
        m_pageCache = new int[m_tabName.length][];

        m_previousTabCache = -1;
        m_previousTopicCache = -1;
        m_previousPageCache = -1;

        m_topic = new Tabs(m_bounds.withYLen(m_spacer/2), new String[]{"No Topics loaded"});

        for(int i = 0; i < m_pageCache.length; i++){
            int topicsPerTab = 1;

            JSONArray data = loadJSONArray("tutorial.json");

            if( data.getJSONObject(i
                    ).getString("type"
                    ).equals("tab") ){

                if( data.getJSONObject(i
                        ).getString("name"
                        ).equals(m_tabName[i]) ){

                    topicsPerTab = data.getJSONObject(i
                                        ).getJSONArray("content"
                                        ).size();
                    
                }
            }else{
                
                for(int j = 0; j < data.size(); j++){

                    if( data.getJSONObject(j
                            ).getString("name"
                            ).equals(m_tabName[i]) ){

                        topicsPerTab = data.getJSONObject(j
                                            ).getJSONArray("content"
                                            ).size();
                        
                        println("tab " + i + " misaligned at JSONIndex " + topicsPerTab);

                        break;
                    }

                }
            }

            m_pageCache[i] = new int[topicsPerTab];

            for(int j = 0; j < m_pageCache[i].length; j++){
                m_pageCache[i][j] = 0;
            }
        }
    }

    protected void setTabTopicPage(int tabIndex, int topicIndex, int pageIndex){
        if(tabIndex > 0 && tabIndex < m_topicCache.length){
            if(topicIndex > 0 && topicIndex < m_pageCache[tabIndex].length){
                m_tabCache = tabIndex;
                m_topicCache[tabIndex] = topicIndex;
                m_pageCache[tabIndex][topicIndex] = pageIndex;
            }
        }

        setText();
    }

    private void setText(){
        boolean hasTabChanged = (m_previousTabCache != m_tabCache);
        boolean hasTopicChanged = (m_previousTopicCache != m_topicCache[m_tabCache]);
        boolean hasPageChanged = (m_previousPageCache != m_pageCache[m_tabCache][m_topicCache[m_tabCache]]);
        
        JSONArray data = new JSONArray();

        int jsonTabIndex = -1;
        //check if page changed:
        if(hasPageChanged || hasTabChanged || hasTopicChanged){
            

            data = loadJSONArray("tutorial.json");
            //check if page is in range, otherwise constrain

            jsonTabIndex = getJSONTabIndex(data, m_tabCache);
            
            //set page value
            m_page.setPage(m_pageCache[m_tabCache][m_topicCache[m_tabCache]]);
            //get the text
            //set the text
            //divide text into line sensibly
            m_currentText = getTextFromJSON(
                data,
                jsonTabIndex,
                m_topicCache[m_tabCache],
                m_pageCache[m_tabCache][m_topicCache[m_tabCache]]
                );
            
            
            m_previousPageCache = m_pageCache[m_tabCache][m_topicCache[m_tabCache]];
        }

        //check if topic changed:
        if(hasTopicChanged || hasTabChanged){
            //set max page-number of m_page
            m_page.setMaxPage( getMaxPage(data, jsonTabIndex, m_topicCache[m_tabCache]) );

            m_previousTopicCache = m_topicCache[m_tabCache];
        }
        
        //check if tab changed:
        if(hasTabChanged){
            //get topic names
            String[] topicName = getTopicName(data, jsonTabIndex);
            //set m_topic to new topic names
            m_topic.setTabName(topicName);
            //set topic value
            m_topic.setValue(m_topicCache[m_tabCache]);

            m_previousTabCache = m_tabCache;
        }
               
    }

    private String[] getTopicName(JSONArray data, int tabIndex){
        String[] ret;

        if(tabIndex != -1){
            JSONArray content = data.getJSONObject(tabIndex
                ).getJSONArray("content");

            ret = new String[content.size()];

            for(int i = 0; i < content.size(); i++){
                if(content.getJSONObject(i).getString("type").equals("topic")){
                    ret[i] = content.getJSONObject(i).getString("name");
                }else{
                    ret[i] = "Wrong type";
                }
            }

            return ret;
        }

        ret = new String[1];
        ret[0] = "no topics found";

        return ret;
    }

    private int getMaxPage(JSONArray data, int jsonTabIndex, int topicIndex){
        return data.getJSONObject(jsonTabIndex
                    ).getJSONArray("content"
                    ).getJSONObject(topicIndex
                    ).getJSONArray("content").size();
    }

    private String[] getTextFromJSON(JSONArray data, int jsonTabIndex, int topicIndex, int pageIndex){
        String[] ret = new String[20];

        String temp = data.getJSONObject(jsonTabIndex
                    ).getJSONArray("content"
                    ).getJSONObject(topicIndex
                    ).getJSONArray("content"
                    ).getJSONObject(pageIndex
                    ).getString("text");

        int lastCutIndex = 0;
        int lineLength = 34;
        
        for(int i = 0; i < ret.length; i++){
            int nextCut = lastCutIndex + lineLength;
            
            if(lastCutIndex >= temp.length()){
                ret[i] = "";
            }else if(nextCut > temp.length()){
                nextCut = temp.length();
                ret[i] = temp.substring(lastCutIndex, nextCut);
                lastCutIndex  = nextCut + 1;
            }else{
                while(temp.charAt(nextCut) != ' '){
                    nextCut--;
                }
                ret[i] = temp.substring(lastCutIndex, nextCut);
                lastCutIndex = nextCut + 1;
            }
            
            
        }
        

        return ret;
    }

    private int getJSONTabIndex(JSONArray data, int tabIndex){
        int jsonTabIndex = -1;

        if(//get jsonTabIndex
            tabIndex < data.size() 
            && data.getJSONObject(tabIndex
            ).getString("type"
            ).equals("tab") 
            && data.getJSONObject(tabIndex
            ).getString("name"
            ).equals(m_tabName[tabIndex]) 
            ){

            jsonTabIndex = tabIndex;

        }else{
            for(int i = 0; i < data.size(); i++){

                if(
                    data.getJSONObject(i
                    ).getString("type"
                    ).equals("tab") 
                    && data.getJSONObject(i
                    ).getString("name"
                    ).equals(m_tabName[tabIndex]) 
                    ){

                    jsonTabIndex = i;
                }
            }
        }

        return jsonTabIndex;
    }


    public void draw(){
        

        fill(m_backgroundColor);
        noStroke();
        rect(m_bounds, 10);

        Bounds textBounds = m_bounds.withFrame(m_spacer/2).withoutBottomRatio(0.33);
        textFont(m_font);
        textAlign(LEFT);
        fill(m_textColor);
        for(int i = 0; i < m_currentText.length; i++){
            text(m_currentText[i], textBounds.asSectionOfYDivisions(i, m_currentText.length), LEFT);
        }
        
    
        m_topic.update();
        m_topicCache[m_tabCache] = m_topic.getValue();

        m_page.update();
        m_pageCache[m_tabCache][m_topicCache[m_tabCache]] = m_page.getPage();
    }

    public void setTabCache(int tabCache){
        m_tabCache = tabCache;
        setText();
    }
}
