unit U_M;

interface

uses
  Windows, Messages, SysUtils,  Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls,  jpeg;

type
  TFarticl = class(TForm)
    Panel5: TPanel;
    Pmidl: TPanel;
    midlimage: TImage;
    sb1: TStatusBar;
    imx: TImage;
    imr: TImage;
    //*************Mes Procedures***************************
 Procedure fdesign;

    procedure btimageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  //*********colorise****************
   procedure arcenciel;
procedure coloriser(Im:Timage ; acolor : tcolor);
Procedure colim(c:Tcolor);
    Procedure BmpCouleur(couleur: tcolor);
    procedure ImcolorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

  //*************************

//***********Fin de Mes Procedure*********************
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure midlimageDblClick(Sender: TObject);
    procedure imrClick(Sender: TObject);
    procedure imxClick(Sender: TObject);
    procedure sb1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sb1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sb1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Farticl: TFarticl;
  resiz:boolean;
  bitmap1, bitmap2: tbitmap;
cfont:Tcolor;
  imcolor,leftimage,rightimage,btitre:Timage;
   implementation

{$R *.dfm}
type
  TRGBArray = ARRAY[0..0] OF TRGBTriple;   // élément de bitmap (API windows)
  pRGBArray = ^TRGBArray;     // type pointeur vers tableau 3 octets 24 bits


//*************Mes Procedures***************************

//********Colorise************************
function mini(a,b : integer): integer;
begin
  if a < b then result := a else result := b;
end;

function maxi(a,b : integer): integer;
begin
  if a > b then result := a else result := b;
end;

Procedure HSVtoRGB (const zH, zS, zV: integer; var aR, aG, aB: integer);
const
  d = 255*60;
var
  a    : integer;
  hh   : integer;
  p,q,t: integer;
  vs   : integer;
begin
  if (zH = 0) or (zS = 0) or (ZV = 0)  then    // niveaux de gris
  begin
    aR := zV;
    aG := zV;
    aB := zV;
  end
  else
  begin              // en couleur
    if zH = 360 then hh := 0 else hh := zH;
    a  := hh mod 60;     // a intervalle  0..59
    hh := hh div 60;    // hh intervalle 0..6
    vs := zV * zS;
    p  := zV - vs div 255;              // p = v * (1 - s)
    q  := zV - (vs*a) div d;            // q = v * (1 - s*a)
    t  := zV - (vs*(60 - a)) div d;     // t = v * (1 - s * (1 - f))
    case hh of
    0: begin aR := zV; aG :=  t ; aB :=  p; end;
    1: begin aR :=  q; aG := zV ; aB :=  p; end;
    2: begin aR :=  p; aG := zV ; aB :=  t; end;
    3: begin aR :=  p; aG :=  q ; aB := zV; end;
    4: begin aR :=  t; aG :=  p ; aB := zV; end;
    5: begin aR := zV; aG :=  p ; aB :=  q; end;
    else begin aR := 0; aG := 0 ; aB := 0; end;
    end;  // case
  end;
end;


// RGB = Red Green Blue intervalle 0..255
// Hue          H = 0° to 360° (correspond à la couleur)
// Saturation   S = 0 (niveau de gris)  à 255 (couleur pure)
// Valeur       V = 0 (noir) à 255 (blanc)

procedure RGBtoHSV(const aR, aG,aB: integer; var zH, zS, zV: integer);
var
  Delta : integer;
  Min   : integer;
begin
  Min := mini(aR, mini(aG,aB));
  zV   := maxi(aR, maxi(aG,aB));
  Delta := zV - Min;
  // Saturation
  if zV =  0 then    // valeur maxi = 0 donc noir
     zS := 0 else zS := (Delta*255) div zV;
  if zS  = 0 then    // pas de saturation
     zH := 0         // donc niveau de gris
  else
  begin                   // couleur
    if aR = zV then         // dominante rouge -> entre jaune et violet
    zH := ((aG-aB)*60) div delta
    else
    if aG = zV then         // dominante vert  -> entre bleu-vert et jaune
    zH := 120 + ((aB-aR)*60) div Delta
    else
    if  aB = zV then        // dominante bleu  -> entre violet et bleu vert
    zH := 240 + ((aR-aG)*60) div Delta;
    if zH <= 0 then zH := zH + 360;  // intervalle 0..359°
  end;
end;

Procedure TFarticl.BmpCouleur(couleur: tcolor);
var
  x, y : integer;      // index pixels
  Rowa : Prgbarray;    // scanlines
  Rowb : Prgbarray;
  R,G,B : integer;
  R0,G0,B0 : integer;
  H0       : integer;
  H,S,V    : integer;
begin
  R0 := GetRValue( ColorToRGB(couleur));
  G0 := GetGValue( ColorToRGB(couleur));
  B0 := GetBValue( ColorToRGB(couleur));
  RGBtoHSV(R0, G0, B0, H, S, V);
  H0 := H;       // on ne mémorise que la couleur (hue)
  For y := 0 to bitmap2.height-1 do
  begin
    rowa := Bitmap1.scanline[y];
    rowb := Bitmap2.scanline[y];
    for x := 0 to bitmap2.width-1 do
    begin
      R := rowa[x].RgbtRed;
      G := rowa[x].Rgbtgreen;
      B := rowa[x].Rgbtblue;
      // récupération saturation et valeur
      RGBtoHSV(R, G, B, H, S, V);
      HSVtoRGB(H0, S, V, R, G, B);  // on répartit la couleur demandée
      // Validité des couleurs
      if R > 255 then R := 255 else if R < 0 then R := 0;
     if G > 255 then G := 255 else if G < 0 then G := 0;
     if B > 255 then B := 255 else if B < 0 then B := 0;
      rowb[x].Rgbtred   := R;
      rowb[x].Rgbtgreen := G;
      rowb[x].Rgbtblue  := B;
    end;
  end;
end;

procedure TFarticl.coloriser(Im:Timage ; acolor : tcolor);
var
 rec:Trect;
begin

 bitmap1.free;
  bitmap1 := tbitmap.create;
  bitmap1.pixelformat := pf24bit;
  bitmap1.width  := im.width;
  bitmap1.height := im.height;
  bitmap1.canvas.draw(0,0,im.picture.graphic);
  bitmap2.free;
  bitmap2 := tbitmap.create;
  bitmap2.pixelformat := pf24bit;
  bitmap2.width  := im.width;
  bitmap2.height := im.height;
  bmpcouleur(acolor); 
  if WindowState=Wsmaximized then
  begin
 //  faire un stretching de Bitmap
  Rec := Rect(0,0, im.width, im.height);
//bitmap2.Canvas.StretchDraw(Rec, im.picture.Bitmap);

im.picture.Bitmap.Canvas.StretchDraw(Rec,Bitmap2);
end else
  im.picture.Bitmap.assign(bitmap2);
end;
//********************************
procedure Tfarticl.arcenciel;
var
  i : integer;
  colo : Tcolor;
  R,G,B : integer;
begin
  for i := 1 to imcolor.width do  // paintbox fait 360 pixels de long
  begin
    HSVtoRGB(i, 255, 255, R, G, B);
    colo := RGB(R,G,B);
    with imcolor.canvas do
    begin
      pen.color := colo;
      moveto(i,0);
      lineto(i, imcolor.height);
    end;
    end;
end;

  Procedure TFarticl.colim(c:Tcolor);
begin
//midlimage.Stretch:=false;
 coloriser(midlimage,cfont);
 //midlimage.Stretch:=true;
 //btitre.Stretch:=false;
  coloriser(btitre,cfont);
//  btitre.Stretch:=true;
   coloriser(leftimage,cfont);
    coloriser(rightimage,cfont);
   //  coloriser(imx,cfont);
   //   coloriser(imr,cfont);
      sb1.Color:=cfont;
end;





//******pour déplacé la form avec click sur l'image de la bar de titre de la form********
 procedure TFarticl.btimageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
if  farticl.WindowState=wsnormal   then
begin
ReleaseCapture();
  Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;
procedure TFarticl.midlimageDblClick(Sender: TObject);
begin
 imx.Anchors:=[Akright,AKtop];
imr.Anchors:=[Akright,Aktop];
if farticl.WindowState=wsmaximized then
farticl.WindowState:=wsnormal
else
farticl.WindowState:=wsmaximized;

end;

//***************
procedure TFARTICL.ImcolorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
cfont:= imcolor.canvas.pixels[X,Y] ;
colim(cfont);
end;
//********************************

 Procedure TFarticl.fdesign;
var ptitre,pleft,pright:Tpanel;
 imf:string;
 begin
 //******trouvé chemain de notre application pour l'utiliser
imf:=ExtractFilePath(Application.ExeName) ;


//********creat bar title form ;)510**********
 ptitre:=Tpanel.Create(self);
   with ptitre do
   begin
   parent:=Panel5;
   Align:=altop;
   Height:= 22;
   BevelOuter:=BVnone;
        end;
   btitre:=Timage.Create(self);
   with btitre do
   begin
  parent:=ptitre;
   Align:=alclient;
Picture.Bitmap.LoadFromFile(imf+'Bin\btitre.bmp');
onMouseDown:=btimageMouseDown;
OnDblClick:=midlimageDblClick;
stretch:=true;
    end;
     //************icons de fermeture et de reduire
 imx.Parent:=ptitre;
 imr.Parent:=ptitre;
//imx.Left:=740;
//imr.Left:=700;
imx.Top:=2;
imr.Top:=2;
//*****fin de la bar de titre de la forme************

//**********les couins*****************
/////////coté gauche
 pleft:=Tpanel.Create(self);
   with pleft do
   begin
   parent:=Panel5;
   Align:=alleft;
   width:= 12;
   BevelOuter:=BVnone;
      end;
   leftimage:=Timage.Create(self);
   with leftimage do
   begin
  parent:=pleft;
   Align:=alclient;
Picture.Bitmap.LoadFromFile(imf+'Bin\leftf.bmp');
stretch:=true;
    end;
 //*****************
 //***********coté droit****************
 pright:=Tpanel.Create(self);
   with pright do
   begin
   parent:=Panel5;
   Align:=alright;
   width:= 12;
   BevelOuter:=BVnone;
      end;
   rightimage:=Timage.Create(self);
   with rightimage do
   begin
  parent:=pright;
   Align:=alclient;
Picture.Bitmap.LoadFromFile(imf+'Bin\rightf.bmp');
stretch:=true;
    end;
    //************
midlimage.Picture.Bitmap.LoadFromFile('Bin\midlf.bmp');

//*************image couleur********
  imcolor:=Timage.Create(self);
  with imcolor do
  begin
 parent:=sb1;
Visible:=true;
  left:=4;
  top:=4;
  width:=145;
  height:=14;
OnMouseUp:=ImcolorMouseUp;

  end;
//**********fin*********************
 end;

//***********Fin de Mes Procedure*********************


procedure TFarticl.FormCreate(Sender: TObject);
begin
SetWindowRgn(farticl.handle,CreateRoundRectRgn(0,0,farticl.Width,farticl.Height,14,14),true);
//**************************
fdesign;
arcenciel;
//*******************
  resiz:=false;
end;

procedure TFarticl.FormResize(Sender: TObject);
begin
SetWindowRgn(farticl.handle,CreateRoundRectRgn(0,0,farticl.Width,farticl.Height,14,14),true);
imx.Anchors:=[Akright,AKtop];
imr.Anchors:=[Akright,Aktop];
end;



procedure TFarticl.imrClick(Sender: TObject);
begin
application.Minimize;
end;

procedure TFarticl.imxClick(Sender: TObject);
begin
close;
end;

procedure TFarticl.sb1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//showmessage(inttostr(sb1.width+farticl.Left));
if (mouse.CursorPos.X > sb1.width+farticl.Left-15)and ( mouse.CursorPos.X < sb1.width+farticl.Left)  then
 resiz:=true;

end;

procedure TFarticl.sb1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
resiz:=false;
end;

procedure TFarticl.sb1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
  var   fl,ft,mx,my:integer;
begin
//if  (farticl.Width > 150 ) and (farticl.Height > 50) then
//begin
//************intialiser les variables
fl:=farticl.Left;
  ft:=farticl.top;
  mx:=mouse.CursorPos.X;  //********position sourie (x)
  my:=mouse.CursorPos.y;   //********position sourie (y)
//*******************************************
if (mx > sb1.width+fl-15)and (mx < sb1.width+fl) then
sb1.Cursor:=crSizenwse else
sb1.Cursor:=crdefault;                            //
if (resiz=true) then
begin
farticl.Width:=mx-fl;
farticl.height:=my-ft;
 end;

 end;
end.
