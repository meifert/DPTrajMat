function [Verbrauch, Charge] = FZModel(T0,SimSchritt,sim_sample_time,PwpPt_W_EngDn,PwpPt_Tq_EngGross,lm_alternator,drive_acc,IGen,engine,ILoad,nom_cap,InitialSOC,Xmin,Xmax)
%
% Verbrauchsberechnung
%
Zeit=[T0:SimSchritt:T0+1];
Drehzahl=interp1(sim_sample_time,PwpPt_W_EngDn,Zeit);
BasisMoment=interp1(sim_sample_time,PwpPt_Tq_EngGross,Zeit);
%
EM_Moment=interp2(lm_alternator.rpm,lm_alternator.amp,lm_alternator.loss,drive_acc.alternator_pulley_ratio*Drehzahl,IGen);
GesamtMoment=BasisMoment+(drive_acc.alternator_pulley_ratio*EM_Moment);
KraftstoffTraj=interp2(engine.rpm,engine.tq,engine.fuel,Drehzahl,GesamtMoment); % Trajektorie von Massendurchfluﬂ in kg/h
KraftstoffTraj(find(KraftstoffTraj<0))=0;
KraftstoffTraj(find(isnan(KraftstoffTraj)))=0;
Verbrauch=sum(KraftstoffTraj)/3.6/100;                                          % Gesamtkraftstoff in g
%
% Ladezustandsberechnung
TSim=1;                                                                         % Annahme
DeltaSOC = InitialSOC+(IGen-ILoad)*TSim/36/nom_cap;                           % Delta-SOC in %
DSOC     = min(Xmax,DeltaSOC);
Charge   = max(Xmin,DSOC);