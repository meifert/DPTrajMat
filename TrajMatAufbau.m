global LadungAnfang Verbrauch Charge DPErgebnispfad DPBilderpfad T0 SOC_beg IGen ILoad TestName
%clear all 
%
% Pfad definieren
%Rechner='FFAPC'
%Rechner='ACPC'
%Rechner='FFALaptop'
switch Rechner
case 'FFAPC'
    BasisPfad='C:\meifert\DP\';
case 'ACPC'
    BasisPfad='C:\Dokumente und Einstellungen\Mark\Eigene Dateien\';
case 'FFALaptop'
    BasisPfad='C:\Documents and Settings\meifert\My Documents\';
case 'MemoryStick'
    BasisPfad='E:\Laptop DPFocus 221008\'
end
%
DPPfad         = strcat(BasisPfad,'DPHIL\');
DPErgebnispfad = strcat(BasisPfad,'DPHIL\Ergebnisse\');
DPBilderpfad   = strcat(BasisPfad,'DPHIL\Bilder\');
DPMatpfad      = strcat(BasisPfad,'DPHIL\TrajMatricies\');
%
%ModelName='Fahrzeug'
%ModelName='VB_Fahrzeug_Acc'    % vereinfachte Batteriemodel
%ModelName='V_Fahrzeug_Acc_Mat'  % vereinfactes Fahrzeugmodel für Aufbau von Trajektorie-Matrix
%TestName='VBAcc51X51U1LL'
Anfangszeit=datestr(now)
%
% Fahrzeugdatei laden
%load NoGen_260808 % Workspace mit Fahrzeugdata und Trajektorien
load(NoGenDatei)
%enginerecalc
if KonstantLMEffFlag==1;lichtmaschinerecalc;end
%
%  Trakektorien:
%                 sim_sample_time   (s)                 
%                 Drv_V_VehTarg     (km/h)             
%                 PwpPt_Mf_EngFuel  (kg/h)        
%                 PwpPt_Tg_EngGross (Nm)           
%                 PwpPt_W_EngDn     (W)
%                                       
% Elektrische Parameter definieren
%LoadOffset=0;
%ILoad=15.7;           %    elektrische Fahrzeuglast in A
%Imax=100 % 100;       %    Maximaler Lichmaschinestrom          
% Bateriedatei laden  %
DP_Batt_Init          %    R cancelled out
%
% Zyklus Paramter definieren
%EndZeit=200 %176   %200 %1180     %Test0 200  %1180
N=EndZeit+1; %    Zahl Zeitpunkte
PlotIndex=find(sim_sample_time<=EndZeit);
if 1; figure;plot(sim_sample_time(PlotIndex),Drv_V_VehTarg(PlotIndex),'g');grid;xlabel('Seconds');ylabel('km/h, Nm');hold on;plot(sim_sample_time(PlotIndex),PwpPt_Tq_EngGross(PlotIndex),'b'); end
%
% DP Parameter definieren
%CC=100000;
%Xmin=  -1
%Xmax=   1
%ZahlZus= 51 %21 Test0; %51
%QS=(Xmax-Xmin)/(ZahlZus-1);                          % Quantisierungsstufenzahl
%X=[Xmin:QS:Xmax];
%EndZusAbstand=0.05; %0.1 Test0
%XmidIndex=find(X<EndZusAbstand & X>-EndZusAbstand)   % Index Zustände in End-Fenster
%XmidIndex=interp1(X,[1:length(X)],0,'nearest');      % Index von Anfangsladezustand
%USchritt=2;
Umax=Imax;
SimSchritt=0.01;
Kmayer=1;
Klagrange=100;
%
% Leerlauf-Suchparameter
%LeerlaufFlag=1;
KonstantLeerlaufStrom=0;
%
% Trajektorie-Matrix aufbauen
for k=N-1:-1:1
    clear Verbrauch Charge
    T0=k-1;                                           % Zeitpunkt beim Anfang von Schritt k
    if isempty(find(interp1(sim_sample_time,Drv_V_VehTarg,[T0:SimSchritt:T0+1])==0)) % Fahrzeug bewegt sich; kein Leerlauf
        if isempty(find(interp1(sim_sample_time,PwpPt_Tq_EngGross,[T0:SimSchritt:T0+1])<0)) % Antriebsmoment
            %%%%%%%%%%%%%%%%%%%%%% Schleife über Antriebspunkte
            disp(strcat(num2str(T0),' Antrieb'))
            IGen=[0:USchritt:Umax];            % Vektor von E-Maschine-Strom-Werten
            %LadungAnfang=0 %  +SOC_beg;       % Batterie-Zustand immer Anfanszustand; simulierter SOC ist immer relativ
            %battery.init_SOC=LadungAnfang;
            sim(ModelName)
            [Charge] = BattChargeModel(IGen,ILoad,nom_cap,0,-100*3600,100*3600); % Ladezustand in Ah; Minimaler SOC: -100 Ah; Maximaler SOC: 100 Ah
            %[Verbrauch Charge] = FZModel(T0,SimSchritt,sim_sample_time,PwpPt_W_EngDn,PwpPt_Tq_EngGross,lm_alternator,drive_acc,IGen,engine,ILoad,nom_cap,X(n),Xmin,Xmax);
            %Kosten=(Klagrange*Verbrauch(length(Verbrauch)))+(Kmayer*interp1(X,R(:,k+1),Charge(length(Charge))));
            %RelativSOC=Charge-LadungAnfang;
            TrajMat(k,1,:)=Verbrauch(length(Verbrauch),:);
            TrajMat(k,2,:)=Charge;
            %
        else %%%%%%%%%%%%%%%%%%%%% Verzögerungsmoment vorhanden
            disp(strcat(num2str(T0),' Verzögerung'))
            %for n=1:length(X)                     % Schleife über Zustandsindex
            IGen=ILoad*ones(size([0:USchritt:Umax]));
            %LadungAnfang=SOC_beg;
            %battery.init_SOC=LadungAnfang;
            sim(ModelName)
            [Charge] = BattChargeModel(IGen,ILoad,nom_cap,0,-100*3600,100*3600); % Ladezustand in Ah; Minimaler SOC: -100 Ah; Maximaler SOC: 100 Ah
            TrajMat(k,1,:)=Verbrauch(length(Verbrauch),:);
            TrajMat(k,2,:)=Charge;
        end 
        %
    else %%%%%%%%%%%%%%%%%%%%% Fahrzeug steht
        disp(strcat(num2str(T0),' Leerlauf'))
        if LeerlaufFlag==1                % Stromschleife in Leerlauf erlaubt
            IGen=[0:USchritt:Umax];           % Vektor von E-Maschine-Strom-Werten
            sim(ModelName)
            [Charge] = BattChargeModel(IGen,ILoad,nom_cap,0,-100*3600,100*3600); % Ladezustand in Ah; Minimaler SOC: -100 Ah; Maximaler SOC: 100 Ah
            TrajMat(k,1,:)=Verbrauch(length(Verbrauch),:);
            TrajMat(k,2,:)=Charge;
        else % vorgegebener Strom in Leerlauf
            IGen=KonstantLeerlaufStrom*ones(size([0:USchritt:Umax]));
            sim(ModelName)
            [Charge] = BattChargeModel(IGen,ILoad,nom_cap,0,-100*3600,100*3600); % Ladezustand in Ah; Minimaler SOC: -100 Ah; Maximaler SOC: 100 Ah
            TrajMat(k,1,:)=Verbrauch(length(Verbrauch),:);
            TrajMat(k,2,:)=Charge;
        end % End if LeerlaufFlag
    end % Speed-Test
    %
end % Schleife über Zeitschritte
%
%Command=['save ' strcat(strcat(DPErgebnispfad,TestName),' R Xmin Xmax X N EndZeit ZahlZus USchritt EMatrix SimSchritt Umax']
%Command=['save ' strcat(strcat(TestName,' ModelName TrajMatName ILoad Imax USchritt LeerlaufFlag KonstantLeerlaufStrom IGen TrajMat'))]
Command=['save ' strcat(strcat(TrajMatName,' ILoad Imax USchritt IGen TrajMat'))]

%
try
    cd(DPMatpfad)
    eval(Command);
catch
    disp('Save not possible.')
end
%
try
    cd(DPBilderpfad)
    for n=1:EndZeit;for m=1:length(IGen);VerMat(n,m)=TrajMat(n,1,m);end;end;
    for n=1:EndZeit;for m=1:length(IGen);SOCMat(n,m)=TrajMat(n,2,m);end;end;
    [XX YY]=meshgrid(0:USchritt:Umax,1:N-1);
    figure;mesh(XX,YY,VerMat);grid on;xlabel('Current in A');ylabel('Time Step');zlabel('Fuel Consumption in g');title(strcat(TrajMatName,': Fuel Consumption Matrix'))
    Command=['print -djpeg ' strcat(TrajMatName,'_Verbrauch')]
    eval(Command)
    figure;mesh(XX,YY,SOCMat);grid on;xlabel('Current in A');ylabel('Time Step');zlabel('Delta SOC in As');title(strcat(TrajMatName,': Relative SOC Matrix'))
    Command=['print -djpeg ' strcat(TrajMatName,'_DeltaSOC')]
    eval(Command)
catch
    disp('Plot or save not possible.')
end
%
cd(DPPfad)
%
disp(' ')
disp('Trajektorie-Matrix aufgebaut')
Anfangszeit
datestr(now)