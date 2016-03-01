TempR=R;
TempR(find(EMatrix==1))=nan;
[XX YY]=meshgrid(1:N,X);
figure;mesh(XX,YY,TempR);grid on;xlabel('Time Step');ylabel('Delta SOC');zlabel('Cost');title(strcat(TestName,': Value Function Matrix'))
