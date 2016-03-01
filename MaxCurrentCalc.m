for n=1:length(lm_alternator.rpm)
    MaxCurrentOutput(n)=0;
    MaxAltTq(n)=lm_alternator.loss(1,n);
    for m=2:length(lm_alternator.amp)
        if lm_alternator.loss(m,n)>MaxAltTq(n)
            MaxAltTq(n)=lm_alternator.loss(m,n);
            MaxCurrentOutput(n)=lm_alternator.amp(m);
        end
    end
end
%
figure;
subplot(2,1,1);plot(lm_alternator.rpm/drive_acc.alternator_pulley_ratio,MaxAltTq);hold on;grid on;xlabel('Engine Speed in rpm');ylabel('Max Torque in Nm');
title('Maximum Load Torque and Current of Alternator SC2 with respect to Engine Speed');hold on
subplot(2,1,2);plot(lm_alternator.rpm/drive_acc.alternator_pulley_ratio,MaxCurrentOutput);hold on;grid on;xlabel('Engine Speed in rpm');ylabel('Max Current in Amps');
print '-djpeg' SC2MaxPic