files=dir('dif*qd50v500c34*');

decacho=4;
map=colormap;

figure; hold on
for i=1:length(files)
result=importdata(files(i).name);
if(min(result(:,2))<=0) continue;
end
fitl=fit(log(result(:,1)),log(result(:,2)),'smoothingspline');
plot(linspace(-decacho,decacho,30),smooth(differentiate(fitl,linspace(-decacho,decacho,30)),6),'color',map(ceil(i*64/length(files)),:));
end
xlabel('log(\tau)'); ylabel('log(<x^2>)'); title('longitudinal')

figure; hold on
for i=1:length(files)
result=importdata(files(i).name);
if(min(result(:,4))<=0) continue;
end
fitl=fit(log(result(:,1)),log(result(:,4)),'smoothingspline');
plot(linspace(-decacho,decacho,30),smooth(differentiate(fitl,linspace(-decacho,decacho,30)),6),'color',map(ceil(i*64/length(files)),:));
end
xlabel('log(\tau)'); ylabel('log(<y^2>)'); title('transverse')
