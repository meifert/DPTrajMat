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