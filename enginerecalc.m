for Count=1:3
    Vector=engine.fuel(:,Count);
    engine.fuel(:,Count)=0.95*Vector;
end
clear Vector
%
for Count=28:101
    Vector=engine.fuel(Count,:);
    engine.fuel(Count,:)=1.05*Vector;
end