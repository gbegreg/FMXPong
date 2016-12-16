unit principale;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, FMX.Types3D, FMX.MaterialSources, FMX.Objects3D,
  FMX.Controls3D, FMX.Viewport3D, FMX.Ani,
  System.Actions, System.UIConsts,
  FMX.ActnList,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.ScrollBox,
  FMX.Memo;

type
  TfPrincipale = class(TForm)
    affichage3D: TViewport3D;
    dmyPrincipal: TDummy;
    lumiere: TLight;
    raquetteJoueur: TRoundCube;
    LightPalet: TLightMaterialSource;
    textureTable: TLightMaterialSource;
    LightAquamarine: TLightMaterialSource;
    aniBouclePrincipale: TFloatAnimation;
    dmyPalet: TDummy;
    cubeBande: TStrokeCube;
    apparition: TFloatAnimation;
    disparition: TFloatAnimation;
    CPUAI: TFloatAnimation;
    bordDroit: TCube;
    bordGauche: TCube;
    base: TCube;
    actListe: TActionList;
    actJouer: TAction;
    pnlAction: TPanel;
    btnJouer: TButton;
    btnAide: TButton;
    actAide: TAction;
    memAide: TMemo;
    StyleBook: TStyleBook;
    palet: TCylinder;
    txtGagne: TText3D;
    lblScore: TLabel;
    tbDifficulte: TTrackBar;
    LimiteZone: TPlane;
    LightLimite: TLightMaterialSource;
    procedure raquetteJoueurMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
    procedure raquetteJoueurMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
    procedure raquetteJoueurMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single; RayPos, RayDir: TVector3D);
    procedure FormCreate(Sender: TObject);
    procedure aniBouclePrincipaleProcess(Sender: TObject);
    procedure apparitionFinish(Sender: TObject);
    procedure aniBouclePrincipaleFinish(Sender: TObject);
    procedure disparitionFinish(Sender: TObject);
    procedure raquetteJoueurRender(Sender: TObject; Context: TContext3D);
    procedure actJouerExecute(
      Sender: TObject);
    procedure affichage3DClick(
      Sender: TObject);
    procedure bordDroitClick(
      Sender: TObject);
    procedure actAideExecute(
      Sender: TObject);
    procedure memAideClick(
      Sender: TObject);
    procedure tbDifficulteTracking(
      Sender: TObject);
  private
    procedure initialiserPlateau;
    procedure RetourMenu;  // Initialiser le jeu
    { Déclarations privées }
  public
    { Déclarations publiques }
    vitesse : single; // Vitesse de déplacement du palet
    vitesseInitiale : single; // Vitesse initiale du palet
    jeu, // Indique la phase du jeu à afficher
    scoreJoueur, scoreCPU : integer; // Permet de stocker les points du joueur et de l'ordi
    tempsReactionIA : single; // Délais de réaction avant de déplacer la raquette gérée par l'ordinateur
    procedure DeplacementPalet; // Déplacement du palet
    procedure Service; // mise en jeu
    procedure CPU;  // Intelligence artificielle
  end;

var
  fPrincipale: TfPrincipale;

implementation

{$R *.fmx}

// Création de la form
procedure TfPrincipale.FormCreate(Sender: TObject);
begin
  cubeBande.visible := false;
  dmyPalet.Visible := false;
  palet.Visible := false;
  initialiserPlateau;
  tempsReactionIA := 0.30;
  jeu := 1;
end;

// Affichage de l'aide
procedure TfPrincipale.actAideExecute(Sender: TObject);
begin
  jeu := 5;
end;

// Démarre une partie
procedure TfPrincipale.actJouerExecute(Sender: TObject);
begin
  txtGagne.Visible := false;
  txtGagne.RotationAngle.x := 0;
  scoreJoueur := 0;
  scoreCPU := 0;
  vitesseInitiale := 50;
  jeu := 2;
  Service;
end;

// Déplacement de la raquette gérée par l'ordi
procedure TfPrincipale.CPU;
var
  P, K, D, H : TPoint3D;
  B, S : Single;
begin
  // Si l'ordi arrive à 7 point alors il gagne
  if scoreCPU = 7 then
  begin
    jeu := 3;
    exit;
  end;

  // Si joueur arrive à 7 point alors il gagne
  if scoreJoueur = 7 then
  begin
    jeu := 4;
    exit;
  end;

  P:=dmyPalet.Position.Point;
  K:=Point3D(0, raquetteJoueur.Position.Y, 0);
  K.X:=cubeBande.Width *0.5;
  D:=dmyPalet.Position.DefaultValue.Normalize;

  // Utilisation du TFloatAnimation CPUAI pour faire déplacer la raquette gérée par l'ordi
  with CPUAI do
  begin
    if not Running and (dmyPalet.Position.DefaultValue.Y < 0) then
    begin
      // Calcul du point d'impact prévisionnel du palet et du but
      B:=Abs((P.Y - (-K.Y)) / D.Y);
      H:= P + D * B;
      S:=raquetteJoueur.Width * 0.5;
      P:=TControl3D(parent).Position.Point;
      if H.X - S < -K.X then H.X := -K.X +S;
      if H.X + S > K.X then H.X := K.X -S;
      // Calcul de la durée de l'animation de déplacement de la raquette
      duration:= tempsReactionIA + random * 0.25;
      // Paramétrage du début et de la fin de l'animation (qui est un déplacement sur l'axe X : c'est défini dans initialiserPlateau)
      StartValue := P.X;
      StopValue := H.X;
      // On lance l'animation
      Start;
    end;
  end;
end;

// Engagemenent
procedure TfPrincipale.Service;
var
  serviceAQui: Integer;
  const nbService: Integer = 2;
begin
  // affichage du score
  lblScore.text := Format(' %d : %d', [scoreCPU, scoreJoueur]);
  // chaque joueur sert deux fois de suite
  serviceAQui := 1 - (2 * (( (scoreJoueur+scoreCPU) div nbService) mod 2));
  // Positionnement du palet pour service
  dmyPalet.Position.DefaultValue:=Point3d(1,1,0) * serviceAQui;
  With base do
  begin
    dmyPalet.Position.Point:= Point3d(width - 5, height -5 ,0) * -0.5 * serviceAQui;
  end;
  // Effet de fondu pour faire apparaitre le palet
  apparition.Start;
end;

// Modification du temp de réaction de l'ia
procedure TfPrincipale.tbDifficulteTracking(Sender: TObject);
begin
   tempsReactionIA := tbDifficulte.Value/10;
end;

procedure TfPrincipale.bordDroitClick(Sender: TObject);
begin
  RetourMenu;
end;

procedure TfPrincipale.aniBouclePrincipaleFinish(Sender: TObject);
begin
  disparition.Start;
end;

procedure TfPrincipale.RetourMenu;
begin
  if (jeu = 3) or (jeu = 4) then jeu := 1;
end;

// Boucle principale du jeu
// en fonction de la variable jeu, on affiche l'écran correspondant
procedure TfPrincipale.aniBouclePrincipaleProcess(Sender: TObject);
begin
  case jeu of
    1: // Intro
       begin
         txtGagne.Visible := false;
         txtGagne.RotationAngle.x := 0;
         memAide.Visible := false;
         palet.Visible := false;
         if dmyPrincipal.Scale.X < 0.5 then
         begin
           // Zoom sur la scène 3D en plus de la rotation
           dmyPrincipal.Scale.X := dmyPrincipal.Scale.X +0.01;
           dmyPrincipal.Scale.y := dmyPrincipal.Scale.y +0.01;
           dmyPrincipal.Scale.z := dmyPrincipal.Scale.z +0.01;
         end;
         // Rotation du dmyPrincipal pour faire tourner toute la scène 3D
         dmyPrincipal.RotationAngle.Z := dmyPrincipal.RotationAngle.Z +2;
       end;
    2: // Jeu
       begin
         memAide.Visible := false;
         txtGagne.Visible := false;
         txtGagne.RotationAngle.x := 0;
         dmyPrincipal.RotationAngle.Z := 0;
         dmyPalet.Visible := true;
         palet.Visible := true;
         // On enclenche le jeu
         DeplacementPalet;
         // Et l'intelligence artificielle
         CPU;
       end;
    3: // Ordi gagne
       begin
         memAide.Visible := false;
         palet.Visible := false;
         txtGagne.Visible := true;
         txtGagne.text := 'Perdu :(';
         txtGagne.RotationAngle.x := txtGagne.RotationAngle.x +3;
       end;
    4: // Joueur gagne
       begin
         memAide.Visible := false;
         palet.Visible := false;
         txtGagne.Visible := true;
         txtGagne.text := 'Gagné :)';
         txtGagne.RotationAngle.x := txtGagne.RotationAngle.x +3;
       end;
    5: // Affichage de l'aide
       begin
         txtGagne.RotationAngle.x := 0;
         txtGagne.Visible := false;
         memAide.Visible := true;
       end;
  end;
end;

procedure TfPrincipale.apparitionFinish(Sender: TObject);
begin
  aniBouclePrincipale.Start;  // Démarre la boucle principale du jeu
end;

procedure TfPrincipale.disparitionFinish(Sender: TObject);
begin
  Service;
end;

// initialisation du plateau de jeu avec création dynamique de la raquette gérée par l'ordi
procedure TfPrincipale.initialiserPlateau;
begin
  vitesse := 1;

  // Création de la raquette gérée par l'IA par clonage de la raquette du joueur
  with TRoundCube(raquetteJoueur.Clone(nil)) do
  begin
    parent := dmyPrincipal;
    // On positionne cette raquette de l'autre coté de la table
    Position.Y := -18;
    OnRender := raquetteJoueurRender;
    HitTest := false;
    AddObject(CPUAI);
    CPUAI.PropertyName:='Position.X';
  end;

  // Création de la limite de zone de l'IA (mais l'IA ne s'en sert pas, c'est juste pour délimiter graphiquement)
  with TPlane(LimiteZone.Clone(nil)) do
  begin
    parent := dmyPrincipal;
    Position.Y := -9.5;
  end;

  // Permet de capturer automatiquement la souris si l'utilisateur clique sur l'objet
  raquetteJoueur.AutoCapture := true;
end;

// Clic sur le memo provoque le retour à l'intro
procedure TfPrincipale.memAideClick(Sender: TObject);
begin
  jeu := 1;
end;

// Déplacement du palet
procedure TfPrincipale.DeplacementPalet;
var P, D, M : TPoint3d;
    w : single;
begin
  // Calcul de la vitesse
  vitesse := TPointF.Create(base.Width, base.Height).Length / (vitesseInitiale * tbDifficulte.Value);
  // Détection de collision du palet avec cubeBande
  P:=dmyPrincipal.AbsoluteToLocal3D(dmyPalet.AbsolutePosition);
  D:=dmyPalet.Position.DefaultValue.Normalize;
  M:=Point3d(cubeBande.width, cubeBande.height, cubeBande.depth);
  M:=(M - Point3d(dmyPalet.width, dmyPalet.height, dmyPalet.depth)) * 0.5;

  P:=P + D * vitesse;
  // Si contact du palet avec les grands côtés du cubeBande, on calcule la noouvelle direction du palet
  if ((P.X > M.X) and (D.X > 0)) or ((P.X < -M.X) and (D.X < 0)) then
  begin
    if abs(d.x / d.Y) > 2 then d:=Point3D(Random, D.X, 0)
    else d.X := -D.X;

  end;

  // Si contact du palet avec les petits côtés du cubeBande, c'est qu'il y a but
  if ((P.Y > M.Y) and (D.Y > 0)) or ((P.Y < -M.Y) and (D.Y < 0)) then
  begin
    // calcul du score en fonction du but dans lequel se situe le pavé
    if P.Y > M.Y then scoreCPU := scoreCPU +1;
    if P.Y < -M.Y then scoreJoueur := scoreJoueur +1;
    // Arrêt de la boucle principale de jeu
    aniBouclePrincipale.StopAtCurrent;
    exit;
  end;

  // On déplace le palet à sa prochaine position
  with dmyPalet do
  begin
    position.point := position.Point + D * vitesse;
    position.DefaultValue := D * Point3D(1,1,0);
  end;
end;

procedure TfPrincipale.raquetteJoueurMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
begin
  // L'utilisateur clique sur sa raquette, on récupère la position de la raquette
  if ssLeft in Shift then
  begin
    with TControl3D(sender).Position do
    begin
      DefaultValue := Point - (RayDir * RayPos.Length) * Point3D(1,1,0);
    end;
  end;
end;

procedure TfPrincipale.raquetteJoueurMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single; RayPos, RayDir: TVector3D);
var
  limiteTableGauche, limiteTableDroite : single;
begin
  affichage3D.BeginUpdate;
  // L'utilisateur maintient le bouton gauche de la souris enfoncé et déplace la souris, alors on déplace sa raquette
  if ssLeft in Shift then
  begin
    with TControl3D(sender).Position do
    begin
      // Nouvelle position de la raquette du joueur
      Point := DefaultValue + (RayDir *RayPos.length) * Point3D(1,1,0);
      // Si la nouvelle position de la raquette en X sort des limites de jeu (largeur intérieure de la table
      limiteTableGauche := -(cubebande.width-raquetteJoueur.width)/2;
      limiteTableDroite := (cubebande.width-raquetteJoueur.width)/2;
      if Point.X < limiteTableGauche then Point := Point3D(limiteTableGauche,point.y,point.z);
      if Point.X > limiteTableDroite then Point := Point3D(limiteTableDroite,point.y,point.z);
      if Point.y > 19 then Point := Point3D(point.x,19,point.z);
      if Point.y < 12 then Point := Point3D(point.x,12,point.z);
    end;
  end;

  affichage3D.EndUpdate;
end;

procedure TfPrincipale.raquetteJoueurMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
begin
  TControl3D(sender).Tag := 0;
  if TControl3D(sender) = raquetteJoueur then
  begin
    // Si l'utilisateur relâche le bouton de la souris, on provoque le retour de la raquette à
    // la position d'origine (position.X=0 et position.Y=19)
    raquetteJoueur.AnimateFloat('Position.X',0);
    raquetteJoueur.AnimateFloat('Position.Y',19);
  end;
end;

// Permet de détecter les collisions entre une raquette (ordi ou celle du joueur) et le palet
procedure TfPrincipale.raquetteJoueurRender(Sender: TObject; Context: TContext3D);
var
  P, Z, R, M, D : TPoint3D;
begin
  // Récupération de la position de la raquette
  with TControl3D(Sender) do
  begin
    P:=AbsoluteToLocal3D(dmyPalet.AbsolutePosition);
    Z:=Point3D( 1 /width, 1 /height, 1 / depth);
    R:=Point3d(width, height, depth);
    D := Position.Point;
  end;

  // Récupération de la position du palet
  with dmyPalet do M:= ( R + Point3D(width, height, depth)) * 0.5;

  // Renvoie du palet si nécessaire
  if (( abs(P.X) < M.X) and (abs(P.Y) < M.Y)) then
  begin
    // Renvoi du palet en fonction de point de contact sur la raquette (plus on est vers le bord de la raquette, plus il y aura d'angle)
    D:=(dmyPalet.Position.point - D).Normalize;
    D:=D * Point3D(45,90,0);
    dmyPalet.Position.DefaultValue:=D;
  end;
end;

procedure TfPrincipale.affichage3DClick(Sender: TObject);
begin
  RetourMenu;
end;

end.
