xuse=squeeze(xtrace(:,1));
yuse=squeeze(ytrace(:,1));
x=[xuse yuse];
[v,c]=voronoin(x);

jefforder = [

         0         0    1.0000
    1.0000         0         0
    1.0000    1.0000         0
         0    1.0000         0
    1.0000    0.1000    0.6000
         0    0.7500    1.0000
    0.7500         0    0.7500
    1.0000    0.5000         0
         0    0.5300    0.0800
         ];
figure;
cmap=jefforder;
for i = 1:length(c)
if all(c{i}~=1)   % If at least one of the indices is 1,
% then it is an open region and we can't
% patch that.
patch(v(c{i},1),v(c{i},2),cmap(mod(i,9)+1,:)); % use color i.
axis equal
end
end