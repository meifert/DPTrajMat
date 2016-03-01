NormVoltage=14;
for nn=1:size(lm_alternator.loss,2)     % rpm
    for mm=1:size(lm_alternator.loss,1) % Current
        lm_alternator.loss(mm,nn) = 9.55 * NormVoltage * lm_alternator.amp(mm)/lm_alternator.rpm(nn)/KonstantLMWirk;
    end
end
%
disp('*********************************************************************************************')
disp(strcat(num2str(100*KonstantLMWirk),'% Wirkungsgrad von Lichtmaschine angenommen; Map geändert.'))
disp('*********************************************************************************************')
disp(' ')