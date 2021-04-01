//command+shift+b to run it in vscode
//Anything in here is only testing code and can be deleted

MainSection m;


void setup(){
    size(1250,850);

    //savePNG();

    //fullScreen();
    m = new MainSection(new Bounds(0, 0, width, height));

    
}

void draw(){
    m.update();

}
