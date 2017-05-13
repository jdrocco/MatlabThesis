function moveestack=peanutsmov(imagesw,imagess)

snoopyreps=20;
noisesig=3;

for i=1:((size(imagesw,1)+size(imagess,1))/snoopyreps)
indstart=ceil(i/2)*snoopyreps-(snoopyreps-1);
if(mod(i,2))
moveestack(((i-1)*snoopyreps+1):(i*snoopyreps),:,:)=double(imagess(indstart:(indstart+(snoopyreps-1)),:,:))-repmat(mean(imagess((indstart+(snoopyreps-2)):(indstart+(snoopyreps-1)),:,:),1),[snoopyreps 1 1]);
else
moveestack(((i-1)*snoopyreps+1):(i*snoopyreps),:,:)=double(imagesw(indstart:(indstart+(snoopyreps-1)),:,:))-repmat(mean(imagess((indstart+(snoopyreps-2)):(indstart+(snoopyreps-1)),:,:),1),[snoopyreps 1 1]);
end
end

avgers=(size(moveestack,1)-20)/(5);
for i=1:5
    moviedeck(i,:,:,:)=squeeze(moveestack(((i-1)*avgers+21):(i*avgers+20),:,:));
end

moviesmoo=squeeze(mean(moviedeck,1));
h=fspecial('gaussian',20,1.5);
deccedr=zeros(size(moviesmoo));
for i=1:size(moviesmoo,1)
    deccy=(squeeze(moviesmoo(i,:,:)));
    deccedr(i,:,:)=deconvwnr(deccy,h,noisesig);
end

[freqs,bars]=hist(deccedr(:),50);
movmaker(deccedr,'totalmoo',bars(5),bars(25))