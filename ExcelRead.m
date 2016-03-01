channel=ddeinit('excel','HIL_TA_Out_090619_alternator_01_Ialt_cst_00A.xls:OutputData');
Rows=69601; %length(Kraftstoff);
for rw=5:Rows
    Place=strcat(strcat(strcat('z',num2str(rw)),'s10:'),strcat(strcat('z',num2str(rw)),'s10'));
    %ddepoke(channel,Place,num2str(Kraftstoff(rw)));
    EngineSpeed(rw-4) = ddereq(channel,Place);
end
ddeterm(channel)