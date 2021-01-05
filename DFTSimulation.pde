//command+shift+b to run it in vscode
//Anything in here is only testing code and can be deleted


Automation a;

void setup(){
    size(800,800);

    a = new Automation(200, 200, 500, 300);


}

void draw(){
    background(50, 0, 0);

    a.draw();

}