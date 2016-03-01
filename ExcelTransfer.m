channel=ddeinit('excel','ExcelWorksheet.xls:Sheet1');
Rows=length(Kraftstoff);
for rw=1:Rows
    Place=strcat(strcat(strcat('z',num2str(rw)),'s1:'),strcat(strcat('z',num2str(rw)),'s1'));
    ddepoke(channel,Place,num2str(Kraftstoff(rw)));
end
ddeterm(channel)