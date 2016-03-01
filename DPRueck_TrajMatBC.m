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
end
%
DPPfad         = strcat(BasisPfad,'DPHIL\');
DPErgebnispfad = strcat(BasisPfad,'DPHIL\Ergebnisse\');
DPBilderpfad   = strcat(BasisPfad,'DPHIL\Bilder\');
DPMatpfad      = strcat(BasisPfad,'DPHIL\TrajMatricies\');
%
Anfangszeit=datestr(now)
%
% Fahrzeugdatei laden
%load NoGen_260808 % Workspace mit Fahrzeugdata und Trajektorien
load(NoGenDatei)
clear t tout v
if KonstantLMEffFlag==1;lichtmaschinerecalc;end    % 0: Standard-Lichtmaschine / 1: Lichtmaschine mit einstellbarem Wirkungsgrad
%
%  Trakektorien:
%                 sim_sample_time   (s)                 
%                 Drv_V_VehTarg     (km/h)             
%                 PwpPt_Mf_EngFuel  (kg/h)        
%                 PwpPt_Tg_EngGross (Nm)           
%                 PwpPt_W_EngDn     (rpm)
%                                       
% DP Trajektorie-Matrix laden
disp(strcat('Loading... ',strcat(DPMatpfad,TrajMatName)))
load(strcat(DPMatpfad,TrajMatName))
%TestName='MT51Xp2mp851U1LL'               % Test only!
%EndZeit=200                               % Test only!
%
% DP Trajektorie-Matrix
% TrajMat(t,p,u)
%                 t: Zeit-Parameter
%                 p: Parameter-Kennzahl; 1:Verbrauch in g; 2: Delta SOC in Prozent
%                 u: Strom-Eingang-Parameter
% TrajMat(:,1,:): Matrix von Verbrauchswerte mit Dimensionen (N-1,length(U))
% TrajMat(:,2,:): Matrix von relativen Änderungen in SOC mit Dimensionen (N-1,length(U))
%
if LeerlaufFlag==0
    for ii=1:length(IGen); VerbrauchVektor(ii)=TrajMat(k,1,ii); end
    for ii=1:length(IGen);    ChargeVektor(ii)=TrajMat(k,2,ii); end
    LLVerbrauch = interp1(IGen,VerbrauchVektor,KonstantLeerlaufStrom);
    LLCharge    = interp1(IGen,ChargeVektor,   KonstantLeerlaufStrom);
end
%
% Bateriedatei laden
DP_Batt_Init % R cancelled out
%
% Zyklus Paramter definieren
N=EndZeit-StartZeit+1; %    Zahl Zeitpunkte
PlotIndex=find((sim_sample_time<=EndZeit) & (sim_sample_time>=StartZeit));
if 1; figure;plot(sim_sample_time(PlotIndex),Drv_V_VehTarg(PlotIndex),'g');grid;xlabel('Seconds');ylabel('km/h, Nm');title(TestName);hold on;plot(sim_sample_time(PlotIndex),PwpPt_Tq_EngGross(PlotIndex),'b'); end
%
% DP Parameter definieren
CC=100000;
%
%ZahlZus= 51 %21 Test0; %51
%QS=(Xmax-Xmin)/(ZahlZus-1);                          % Quantisierungsstufenzahl
QS = 1; % As
%X=[Xmin:QS:Xmax];
CWmin = floor(nom_cap*3600*Xmin/100)                  % Minimum Charge-Window-Wert in As
CWmax =  ceil(nom_cap*3600*Xmax/100)                  % Maximum Charge-Window-Wert in As
X=[CWmin:QS:CWmax];
ZahlZus=length(X);
%EndZusAbstand=0.05; %0.1 Test0
%XmidIndex=find(X<EndZusAbstand & X>-EndZusAbstand)   % Index Zustände in End-Fenster
XmidIndex=interp1(X,[1:length(X)],0,'nearest');       % Index von Anfangsladezustand
%USchritt=2;
Umax=Imax;
SimSchritt=0.01;
%Kmayer=1;
%Klagrange=100;
%
% Leerlauf-Suchparameter
%LeerlaufFlag=1;
%KonstantLeerlaufStrom=0;
LeerlaufWertFlag=0;
%
% Restkostenmatrix initializieren
R=CC*ones(length(X),N);                              % Restkostenmatrix mit grosser Zahl belegen
R(XmidIndex,N)=0;
if 0; figure;plot(X,R(:,N));grid on;xlabel('Delta SOC in As');ylabel('Cost');end % Mayer-Kosten plotten
EMatrix=zeros(size(R));                              % Erreichbarkeitsmatrix
EMatrix(:,N)=1;
EMatrix(XmidIndex,N)=0;
%
OptTime=[StartZeit:1:EndZeit];
OptI=zeros(size(OptTime));
%
% Restkostmatrix aufbauen
for k=N-1:-1:1
    clear Verbrauch Charge
    %OptFlag=0;
    %OptKosten=CC;
    T0=k-1+StartZeit;                                                                       % Zeitpunkt beim Anfang von Schritt k
    if isempty(find(interp1(sim_sample_time,Drv_V_VehTarg,[T0:SimSchritt:T0+1])==0))        % Fahrzeug bewegt sich; kein Leerlauf
        if isempty(find(interp1(sim_sample_time,PwpPt_Tq_EngGross,[T0:SimSchritt:T0+1])<0)) % Antriebsmoment
            %%%%%%%%%%%%%%%%%%%%%% Schleife über Antriebspunkte
            strcat(num2str(T0),' Antrieb')
            for n=1:length(X)                                            % Schleife über Zustandsindex
                DeltaSOC=max(min(CWmax,TrajMat(k,2,:)+X(n)),CWmin);      % CWmin <= X <=CWmax
                %sdsoc=size((Kmayer*interp1(X,R(:,k+1),X(n)+DeltaSOC)))  % Diagnostics
                %pause                                                   % Diagnostics
                Kosten=(Klagrange*TrajMat(k,1,:))+(Kmayer*interp1(X,R(:,k+1),DeltaSOC));
                R(n,k)=Kosten(min(find(Kosten==min(Kosten))));           % Neuer Wert in Restkostenmatrix scheiben
                %
                if R(n,k)>=0.9*CC
                    EMatrix(n,k)=1;
                end
            end % End Schleife über Zustände X
            %
        else %%%%%%%%%%%%%%%%%%%%% Verzögerungsmoment vorhanden
            strcat(num2str(T0),' Verzögerung')
            for n=1:length(X)                                             % Schleife über Zustandsindex
                DeltaSOC=max(min(CWmax,TrajMat(k,2,:)+X(n)),CWmin);       % CWmin <= X <=CWmax
                Kosten=(Klagrange*TrajMat(k,1,:))+(Kmayer*interp1(X,R(:,k+1),DeltaSOC));
                R(n,k)=Kosten(min(find(Kosten==min(Kosten))));            % Neuer Wert in Restkostenmatrix scheiben
                %
                if R(n,k)>=0.9*CC
                    EMatrix(n,k)=1;
                end
            end % End Schleife über Zustände X
        end % End Fall von fahrendem Fahrzeug
        %
    else %%%%%%%%%%%%%%%%%%%%% Fahrzeug steht
        strcat(num2str(T0),' Leerlauf')
        for n=1:length(X)                                                 % Schleife über Zustandsindex
            if LeerlaufFlag==1                                            % Stromschleife in Leerlauf erlaubt
                DeltaSOC=max(min(CWmax,TrajMat(k,2,:)+X(n)),CWmin);       % CWmin <= X <=CWmax
                Kosten=(Klagrange*TrajMat(k,1,:))+(Kmayer*interp1(X,R(:,k+1),DeltaSOC));
                R(n,k)=Kosten(min(find(Kosten==min(Kosten))));            % Neuer Wert in Restkostenmatrix scheiben
                
                %
                if R(n,k)>=0.9*CC
                    EMatrix(n,k)=1;
                else
                    if 0
                        disp('*********************************************************************')          % Diagnostics
                        batterystate=X(n)                                                                      % Diagnostics
                        sizedsoc  =size((Kmayer*interp1(X,R(:,k+1),DeltaSOC)))                                 % Diagnostics
                        sizefuel  =size(Klagrange*TrajMat(k,1,:))                                              % Diagnostics
                        sizekosten=size((Klagrange*TrajMat(k,1,:))+(Kmayer*interp1(X,R(:,k+1),X(n)+DeltaSOC))) % Diagnostics
                        findresult=find(Kosten==min(Kosten))                                                   % Diagnostics
                        Rnk=Kosten(min(find(Kosten==min(Kosten))))                                             % Diagnostics
                        pause                                                                                  % Diagnostics
                    end
                end
            else % vorgegebener Strom in Leerlauf
                DeltaSOC    = max(min(CWmax,LLCharge+X(n)),CWmin);          % CWmin <= X <=CWmax
                Kosten=(Klagrange*LLVerbrauch)+(Kmayer*interp1(X,R(:,k+1),DeltaSOC));
                R(n,k)=Kosten;                                            % neuer Wert in Restkostenmatrix scheiben
                %
                if R(n,k)>=0.9*CC
                    EMatrix(n,k)=1;
                end
            end % End if LeerlaufFlag
        end % End Schleife über Zustände X
    end % Speed-Test
    %
    if length(find(min(R(:,k))))>1
        if 1
            disp(' ')
            disp('No optimum found')
            disp(' ')
            Time_Step=k
            [XX YY]=meshgrid(1:N,X);
            figure;mesh(XX,YY,R);grid on;xlabel('Time Step');ylabel('Delta SOC');zlabel('Cost')
            datestr(now)
            save NoOptWorkspace
            disp('Workspace saved')
            pause
        end
    end
    %
    if 0
        if k==N-1                                                                                             % Diagnostics
            figure                                                                                            % Diagnostics
        end                                                                                                   % Diagnostics
        plot(X,R(:,k));grid on;xlabel('Delta SOC in %');ylabel('Cost');title(strcat('Time Step:',num2str(k))) % Diagnostics
        pause                                                                                                 % Diagnostics
    end
end % Schleife über Zeitschritte
%
try
    % EMatrix von Liste entfernt: disp('Save variables ModelName, TestName, ILoad, Imax, Kmayer, Klagrange, LeerlaufFlag, KonstantLeerlaufStrom, R, Xmin, Xmax, CWmin, CWmax, X, N, StartZeit EndZeit, ZahlZus, USchritt, SimSchritt ,Umax, EMatrix')
    disp('Save variables ModelName, TestName, ILoad, Imax, Kmayer, Klagrange, LeerlaufFlag, KonstantLeerlaufStrom, R, Xmin, Xmax, CWmin, CWmax, X, N, StartZeit EndZeit, ZahlZus, USchritt, SimSchritt ,Umax')
    disp('in...')
    disp(strcat(DPErgebnispfad,TestName))
    disp(' ')
    save(strcat(DPErgebnispfad,TestName),'ModelName', 'TestName', 'ILoad', 'Imax', 'Kmayer', 'Klagrange', 'LeerlaufFlag', 'KonstantLeerlaufStrom', 'R', 'Xmin', 'Xmax', 'CWmin', 'CWmax', 'X', 'N', 'StartZeit', 'EndZeit', 'ZahlZus', 'USchritt', 'SimSchritt' ,'Umax')
    %cd(DPErgebnispfad)
    %eval(SaveCommand);
catch
    disp('Data save not possible.')
    pause
end
%
if 0
try
    TempR=R;
    TempR(find(EMatrix==1))=nan;
    [XX YY]=meshgrid(1:N,X);
    figure;mesh(XX,YY,TempR);grid on;xlabel('Time Step');ylabel('Delta SOC in As');zlabel('Cost');title(strcat(TestName,': Value Function Matrix'))
catch
    disp('Plot not possible.')
    pause
end
end
%
%PrintCommand=['print -djpeg ' strcat(strcat(DPBilderpfad,TestName),'_Restkostenmatrix')];
%disp(PrintCommand)
%
try
    %cd(DPBilderpfad)
    %eval(PrintCommand)
    print('-djpeg',strcat(strcat(DPBilderpfad,TestName),'_TestTraj'))
catch
    disp('Print save not possible.')
    pause
end
%
cd(DPPfad)
%
disp(' ')
disp('Restkostenmatrix aufgebaut')
Anfangszeit
datestr(now)