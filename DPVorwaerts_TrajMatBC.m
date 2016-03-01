global LadungAnfang Verbrauch Charge DPErgebnispfad DPBilderpfad T0 SOC_beg IGen ILoad TestName R
clear IGen
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
DPPfad=strcat(BasisPfad,'DPHIL\');
DPErgebnispfad=strcat(BasisPfad,'DPHIL\Ergebnisse\');
DPBilderpfad=strcat(BasisPfad,'DPHIL\Bilder\');
%
%ModelName='Fahrzeug'
%ModelName='VB_Fahrzeug_Acc'             % vereinfachte Batteriemodel
%TestName='VBAcc51X51U1LL'
%
% Fahrzeugdatei laden
%load NoGen_260808 % Workspace mit Fahrzeugdata und Trajektorien
load(NoGenDatei)
clear t tout v
%enginerecalc   % TEMPORARY
if KonstantLMEffFlag==1;lichtmaschinerecalc;end   % 0: Standard-Lichtmaschine / 1: Lichtmaschine mit einstellbarem Wirkungsgrad
%
%  Trakektorien:
%                 sim_sample_time   (s)                 
%                 Drv_V_VehTarg     (km/h)             
%                 PwpPt_Mf_EngFuel  (kg/h)        
%                 PwpPt_Tg_EngGross (Nm)           
%                 PwpPt_W_EngDn     (rpm)
%                                       
% Elektrische Parameter definieren
%LoadOffset=0;
%ILoad=LoadOffset+15.7;  %    elektrische Fahrzeuglast in A
%Imax=100 % 100;    %    Maximaler Lichmaschinestrom          
% Bateriedatei laden
DP_Batt_Init
%
% Zyklus Paramter definieren
%EndZeit=200 %176   %200 %1180     %Test0 200  %1180
%N=EndZeit+1; %    Zahl Zeitpunkte
%PlotIndex=find(sim_sample_time<=EndZeit);
%if 1; figure;plot(sim_sample_time(PlotIndex),Drv_V_VehTarg(PlotIndex),'g');grid;xlabel('Seconds');ylabel('km/h, Nm');hold on;plot(sim_sample_time(PlotIndex),PwpPt_Tq_EngGross(PlotIndex),'b'); end
%
% DP Parameter definieren
CC=100000;
%Xmin=  -1
%Xmax=   1
%ZahlZus= 51 %21 Test0; %51
%QS=(Xmax-Xmin)/(ZahlZus-1);                          % Quantisierungsstufenzahl
%X=[Xmin:QS:Xmax]
%EndZusAbstand=0.05; %0.1 Test0
%XmidIndex=find(X<EndZusAbstand & X>-EndZusAbstand)   % Index Zustände in End-Fenster
%XmidIndex=interp1(X,[1:length(X)],0,'nearest');      % Index von Anfangsladezustand
%USchritt=2;
%Umax=Imax;
SimSchritt=0.01;
%Kmayer=1;
%Klagrange=100;
%
% Leerlauf-Suchparameter
%LeerlaufFlag=1;
%KonstantLeerlaufStrom=0;
%
%OptTime=[0:1:EndZeit];
%OptI=zeros(size(OptTime));
%
% Anfangszustände
LadungAnfang     = 0; %SOC_beg;
%battery.init_SOC = LadungAnfang;
IOptV=[];
SOCOptV=[SOC_beg]; % [LadungAnfang]    %
%
for k=1:N-1
    clear Verbrauch Charge
    OptFlag=0;
    OptKosten=100*CC*CC;
    T0=k-1+StartZeit;                                                                       % Zeitpunkt beim Anfang von Schritt k
    if isempty(find(interp1(sim_sample_time,Drv_V_VehTarg,[T0:SimSchritt:T0+1])==0))        % Fahrzeug bewegt sich; kein Leerlauf
        if isempty(find(interp1(sim_sample_time,PwpPt_Tq_EngGross,[T0:SimSchritt:T0+1])<0)) % Antriebsmoment
            %%%%%%%%%%%%%%%%%%%%%% Schleife über Antriebspunkte
            strcat(num2str(T0),' Antrieb')
            for IGen=0:USchritt:Umax;            % Schleife über E-Maschine-Strom
                sim(ModelName)
                [Charge] = BattChargeModel(IGen,ILoad,nom_cap,LadungAnfang,CWmin,CWmax); % Minimaler abs. SOC: CWmin; Maximaler abs. SOC: CWmax; SOC in As
                %Kosten=(Klagrange*Verbrauch(length(Verbrauch)))+(Kmayer*interp1(X,R(:,k+1),Charge(length(Charge))));
                Kosten=Verbrauch(length(Verbrauch))+(KmayerV*interp1(X,R(:,k+1),Charge(length(Charge))));
                %
                if Kosten<OptKosten              % Eingangsgrößen verursachen niedrigsten Kosten
                    OptFlag=1;
                    Uopt=IGen;
                    InitialCharge=Charge(length(Charge));
                    OptKosten=Kosten;
                end
            end
            %
        else %%%%%%%%%%%%%%%%%%%%% Verzögerungsmoment vorhanden
            strcat(num2str(T0),' Verzögerung')
            IGen=ILoad;
            sim(ModelName)
            [Charge] = BattChargeModel(IGen,ILoad,nom_cap,LadungAnfang,CWmin,CWmax); % Minimaler abs. SOC: CWmin; Maximaler abs. SOC: CWmax; SOC in As
            %Kosten=(Klagrange*Verbrauch(length(Verbrauch)))+(Kmayer*interp1(X,R(:,k+1),Charge(length(Charge))));
            Kosten=Verbrauch(length(Verbrauch))+interp1(X,R(:,k+1),Charge(length(Charge)));
            %
            OptFlag=1;
            Uopt=IGen;
            InitialCharge=Charge(length(Charge));
            OptKosten=Kosten;
        end
        %
    else %%%%%%%%%%%%%%%%%%%%% Fahrzeug steht
        strcat(num2str(T0),' Leerlauf')
        if LeerlaufFlag==1                % Stromschleife in Leerlauf erlaubt
            for IGen=0:USchritt:Umax;         % 0:USchritt*DZ(k)/9.55:Umax % Schleife über elektische Leistung
                sim(ModelName)
                [Charge] = BattChargeModel(IGen,ILoad,nom_cap,LadungAnfang,CWmin,CWmax); % Minimaler abs. SOC: CWmin; Maximaler abs. SOC: CWmax; SOC in As
                %Kosten=(Klagrange*Verbrauch(length(Verbrauch)))+(Kmayer*interp1(X,R(:,k+1),Charge(length(Charge))));
                Kosten=Verbrauch(length(Verbrauch))+interp1(X,R(:,k+1),Charge(length(Charge)));
                %
                if Kosten<OptKosten              % Eingangsgrößen verursachen niedrigsten Kosten
                    OptFlag=1;
                    Uopt=IGen;
                    InitialCharge=Charge(length(Charge));
                    OptKosten=Kosten;
                end
            end
        else % vorgegebener Strom in Leerlauf
            IGen=KonstantLeerlaufStrom;
            sim(ModelName)
            [Charge] = BattChargeModel(IGen,ILoad,nom_cap,LadungAnfang,CWmin,CWmax); % Minimaler abs. SOC: CWmin; Maximaler abs. SOC: CWmax; SOC in As
            %Kosten=(Klagrange*Verbrauch(length(Verbrauch)))+(Kmayer*interp1(X,R(:,k+1),Charge(length(Charge))));
            Kosten=Verbrauch(length(Verbrauch))+interp1(X,R(:,k+1),Charge(length(Charge)));
            %
            OptFlag=1;
            Uopt=IGen;
            InitialCharge=Charge(length(Charge));
            OptKosten=Kosten;
        end
        
    end % Speed-Test
    %
    if OptFlag==0
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
            figure;plot(IOptV);xlabel('Seconds');ylabel('Amps');grid on; hold on
            figure;plot(SOCOptV);xlabel('Seconds');ylabel('Delta SOC');grid on; hold on
            pause
        end
    end
    %
    OptFlag=0;                                 % Reset OptFlag
    IOptV=[IOptV;Uopt];
    LadungAnfang=InitialCharge;   %+SOC_beg;
    %battery.init_SOC=LadungAnfang;
    SOCOptV=[SOCOptV ; SOC_beg+(100*InitialCharge/3600/nom_cap)];   %[SOCOptV;InitialCharge+SOC_beg];
    %SOCOptV=[SOCOptV ; InitialCharge]; 
end % Schleife über Zeitschritte
%
IOptV=[IOptV;0];
ZeitV=[StartZeit:1:EndZeit]';
%
try
    % EMatrix von der Liste entfuhrt: disp('Save variables ModelName, TestName, ILoad, Imax, Kmayer, Klagrange, LeerlaufFlag, KonstantLeerlaufStrom, R, Xmin, Xmax, CWmin, CWmax, X, N, StartZeit EndZeit, ZahlZus, USchritt, EMatrix ,SimSchritt ,Umax, IOptV, ZeitV')
    disp('Save variables ModelName, TestName, ILoad, Imax, Kmayer, Klagrange, LeerlaufFlag, KonstantLeerlaufStrom, R, Xmin, Xmax, CWmin, CWmax, X, N, StartZeit EndZeit, ZahlZus, USchritt, SimSchritt ,Umax, IOptV, ZeitV')
    disp('in...')
    disp(strcat(DPErgebnispfad,TestName))
    disp(' ')
    save(strcat(DPErgebnispfad,TestName),'ModelName', 'TestName', 'ILoad', 'Imax', 'Kmayer', 'Klagrange', 'LeerlaufFlag', 'KonstantLeerlaufStrom', 'R', 'Xmin', 'Xmax', 'CWmin', 'CWmax', 'X', 'N', 'StartZeit', 'EndZeit', 'ZahlZus', 'USchritt','SimSchritt' ,'Umax','IOptV','ZeitV')
    %cd(DPErgebnispfad)
    %eval(SaveCommand);
catch
    disp('Data save not possible.')
    pause
end
%
%
PlotIndex=find((sim_sample_time<=EndZeit) & (sim_sample_time>=StartZeit));
cd(DPBilderpfad)
%
figure; plot(sim_sample_time(PlotIndex),Drv_V_VehTarg(PlotIndex),'g');grid;xlabel('Seconds');ylabel('km/h, A');hold on;plot([StartZeit:1:EndZeit],IOptV,'b');
title(strcat(TestName,': Speed (green) and Optimal Current (blue)'))
%
Command=['print -djpeg ' strcat(TestName,'_IOptV_Traj')]
eval(Command)
%
figure; subplot(2,1,1);plot(sim_sample_time(PlotIndex),Drv_V_VehTarg(PlotIndex),'g');grid on;hold on;plot([StartZeit:1:EndZeit],IOptV,'b');xlabel('Seconds');ylabel('km/h, A');hold on;subplot(2,1,2);plot([StartZeit:1:EndZeit],SOCOptV,'m'); grid on; hold on; xlabel('Seconds');ylabel('Delta SOC in %')
Command=['print -djpeg ' strcat(TestName,'_OptSOC')]
eval(Command)
%
cd(DPPfad)