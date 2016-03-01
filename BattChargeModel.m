function [Charge] = BattModel(IGen,ILoad,nom_cap,InitialSOC,Xmin,Xmax)
%
% Ladezustandsberechnung
TSim     = 1;                                                   % 1 Sekunde Simulationsperiode angenommen
DeltaSOC = InitialSOC+(IGen-ILoad)*TSim;                        % Delta-SOC in As
DSOC     = min(Xmax,DeltaSOC);
Charge   = max(Xmin,DSOC);