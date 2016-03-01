% TrajMatBauRun.m
%
% Trajektorie-Matrix Definition
%
clear all
%
%Rechner='FFAPC'
Rechner='FFALaptop'
%Rechner='MemoryStick'
%
ModelName=' V_Fahrzeug_KonEffEM_Mat'      % vereinfactes Fahrzeugmodel für Aufbau von Trajektorie-Matrix; old: V_Fahrzeug_KonEffEM_Mat
%TrajMatName='DV6EFF75LMFocusNEDC80U1CB'  % -CB bescheinigt Batteriemodel mit simuliertem Ladezustand in As
%TrajMatName='DV6ERCFocusNEDC80U1CB20AL'  % -CB bescheinigt Batteriemodel mit simuliertem Ladezustand in As
%TrajMatName='DW12CD_NEDC80U1CB'           % -CB bescheinigt Batteriemodel mit simuliertem Ladezustand in As
TrajMatName='DW12CD_NEDC80U1'
%NoGenDatei='NoGen_260808'
%NoGenDatei='NoGenDoubleNEDC'
NoGenDatei='VehicleData\CD_Vehicle_DW12_NoGen.mat'
%
% Lichtmaschine-Flag
KonstantLMEffFlag=0               % 0: Standard-Lichtmaschine / 1: Lichtmaschine mit einstellbarem Wirkungsgrad
KonstantLMWirk=0.75               % konstante Wirkungsgrad von Lichtmaschine
%
% Elektrische Parameter
ILoad = 12 %20 %16 %15.7                  % elektrische Fahrzeuglast in A
Imax =  80 % 100                  % Maximaler Lichtmaschinestrom          
%
% Zyklus Paramter definieren
EndZeit=1180
%
% DP Parameter definieren
USchritt=1
%
% Leerlauf-Suchparameter
LeerlaufFlag=1
KonstantLeerlaufStrom=0     % Definierter Strom für Fall LeerlaufFlag=0
%
TrajMatAufbau