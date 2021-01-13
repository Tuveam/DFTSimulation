//command+shift+b to run it in vscode
//Anything in here is only testing code and can be deleted

MainSection m;


void setup(){
    size(800,800);
    m = new MainSection(0, 0, width, height);
}

void draw(){
    m.update();

}
