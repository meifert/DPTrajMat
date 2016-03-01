function [Charge] = BattModel(IGen,ILoad,nom_cap,InitialSOC,Xmin,Xmax)
%
% Ladezustandsberechnung
TSim     = 1;                                                   % 1 Sekunde Simulationsperiode angenommen
DeltaSOC = InitialSOC+(IGen-ILoad)*TSim/36/nom_cap;             % Delta-SOC in %
DSOC     = min(Xmax,DeltaSOC);
Charge   = max(Xmin,DSOC);