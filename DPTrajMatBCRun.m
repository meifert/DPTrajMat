% DPTrajMatBCRun 

if 0
% Test 1 Definition
%
clear all
%
Rechner='FFALaptop'
%Rechner='FFAPC'
ModelName='V_Fahrzeug_Acc_Mat'  % vereinfachtes Fahrzeugmodel für Aufbau von Trajektorie-Matrix
TestName='NEDCCBXp5m1p0U80LL1'
%TrajMatName='DV6FocusNEDC100U2CB'
%TrajMatName='DV6FocusNEDC80U1CB'
%TrajMatName='DV6FocusNEDC12AL80U1CB'
%TrajMatName='DV6ERCFocusNEDC80U1CB'
TrajMatName='DW12CD_NEDC80U1CB'
NoGenDatei='VehicleData\CD_Vehicle_DW12_NoGen.mat'
%NoGenDatei='NoGenDoubleNEDC'
%
% Elektrische Parameter
%ILoad=15.7                      % elektrische Fahrzeuglast in A; Last wird von TrajMat-Datei übernommen
Imax=80  %100 % 100;             % Maximaler Lichmaschinestrom          
KonstantLMEffFlag=0              % 0: Standard-Lichtmaschine / 1: Lichtmaschine mit 100% Wirkungsgrad
KonstantLMWirk=0.75              % Konstanter Wirkungsgrad
%
% Zyklus Paramter definieren
StartZeit = 0
EndZeit   = 1180     %Test0 200  %1180
%
% DP Parameter definieren
Xmin=  -1.0 %-3.0 %-10.0
Xmax=   0.5 %3.0 %10.0
% ZahlZus= 2001 %21 Test0; %51 % Not Used
EndZusAbstand=0.05; %0.1 Test0 % Not used
Kmayer    = 1
Klagrange = 1 %00
KmayerV   = 1 %0.005
%
% Leerlauf-Suchparameter
LeerlaufFlag=1                      % 1: Suche für optimaler Strom in Leerlauf / 0: konstanter Leerlaufstrom
KonstantLeerlaufStrom=0             % Definierter Strom für Fall LeerlaufFlag=0
%
DPRueck_TrajMatBC                   % Rückwartssimulation
DPVorwaerts_TrajMatBC               % Vorwärtssimulation

end

if 0
disp('   ===============')
disp('   Starting Test 2')
disp('   ===============')
pause(30)    
pack
%
% Test 2 Definition
%
clear all
%
Rechner='FFALaptop'
ModelName='V_Fahrzeug_Acc_Mat'  % vereinfachtes Fahrzeugmodel für Aufbau von Trajektorie-Matrix
TestName='ECECBX5p0m5p0U80LL1Eff100'
%TrajMatName='DV6FocusNEDC100U2CB'
%TrajMatName='DV6FocusNEDC80U1CB'
%TrajMatName='DV6FocusNEDC18AL80U1CB'
TrajMatName='DW12CD_NEDC80U1CB'
NoGenDatei='VehicleData\CD_Vehicle_DW12_NoGen.mat'
%NoGenDatei='NoGenDoubleNEDC'
%
% Elektrische Parameter
%ILoad=15.7                      % elektrische Fahrzeuglast in A; Last wird von TrajMat-Datei übernommen
Imax=80  %100 % 100;             % Maximaler Lichmaschinestrom          
LMNoLossFlag=1                   % 0: Standard-Lichtmaschine / 1: Lichtmaschine mit 100% Wirkungsgrad
KonstantLMEffFlag=1              % 0: Standard-Lichtmaschine / 1: Lichtmaschine mit 100% Wirkungsgrad
KonstantLMWirk=1.0               % Konstanter Wirkungsgrad
%
% Zyklus Paramter definieren
StartZeit = 0
EndZeit   = 200     %Test0 200  %1180
%
% DP Parameter definieren
Xmin=  -5.0 %-3.0 %-10.0
Xmax=   5.0 %3.0 %10.0
% ZahlZus= 2001 %21 Test0; %51 % Not Used
EndZusAbstand=0.05; %0.1 Test0 % Not used
Kmayer    = 1
Klagrange = 1 %00
KmayerV   = 1 %0.005
%
% Leerlauf-Suchparameter
LeerlaufFlag=1                      % 1: Suche für optimaler Strom in Leerlauf / 0: konstanter Leerlaufstrom
KonstantLeerlaufStrom=20            % Definierter Strom für Fall LeerlaufFlag=0
%
DPRueck_TrajMatBC                   % Rückwartssimulation
DPVorwaerts_TrajMatBC               % Vorwärtssimulation

end

if 0
disp('   ===============')
disp('   Starting Test 3')
disp('   ===============')
pause(30)    
%
% Test 3 Definition
%
clear all
pack
%
Rechner='FFALaptop'
ModelName='V_Fahrzeug_Acc_Mat'  % vereinfachtes Fahrzeugmodel für Aufbau von Trajektorie-Matrix
TestName='NEDC0t800CB1X5m5U81LL030'
%TrajMatName='DV6FocusNEDC100U2CB'
TrajMatName='DV6FocusNEDC80U1CB'
NoGenDatei='NoGen_260808'
%NoGenDatei='NoGenDoubleNEDC'
%
% Elektrische Parameter
%ILoad=15.7                      % elektrische Fahrzeuglast in A; Last wird von TrajMat-Datei übernommen
Imax=80  %100 % 100;             % Maximaler Lichmaschinestrom          
LMNoLossFlag=0                   % 0: Standard-Lichtmaschine / 1: Lichtmaschine mit 100% Wirkungsgrad
%
% Zyklus Paramter definieren
StartZeit = 0
EndZeit   = 800 %176   %200 %1180     %Test0 200  %1180
%
% DP Parameter definieren
Xmin=  -5.0 %-3.0 %-10.0
Xmax=   5.0 %3.0 %10.0
% ZahlZus= 2001 %21 Test0; %51 % Not Used
EndZusAbstand=0.05; %0.1 Test0 % Not used
Kmayer    = 1
Klagrange = 1 %00
KmayerV   = 1 %0.005
%
% Leerlauf-Suchparameter
LeerlaufFlag=0                      % 1: Suche für optimaler Strom in Leerlauf / 0: konstanter Leerlaufstrom
KonstantLeerlaufStrom=30            % Definierter Strom für Fall LeerlaufFlag=0
%
DPRueck_TrajMatBC                   % Rückwartssimulation
DPVorwaerts_TrajMatBC               % Vorwärtssimulation

end

