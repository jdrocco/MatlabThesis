function fixedmean=satcorrect(pixelvals)

boxes=1000;
avger=round(boxes/100);

[freqs,bars]=hist(double(pixelvals),boxes);

if(freqs(boxes)>mean((freqs(boxes-avger):freqs(boxes-1))))
    clipper=freqs(boxes);
    binnum=round(mean(freqs((boxes-avger):(boxes-1))));
    newboxes=floor(clipper/binnum);
    if((clipper>1)&&(binnum>0)&&(newboxes>0))
    binsize=mean(diff(bars));
%     try
    bars(boxes:(boxes+newboxes))=linspace(bars(boxes),(bars(boxes)+(binsize*newboxes)),newboxes+1);
%     catch
%         disp('crap');
%     end
    freqs(boxes:(boxes+newboxes-1))=binnum;
    freqs(boxes+newboxes)=mod(clipper,binnum);
    fixedmean=max([wmean(bars,freqs) mean(pixelvals)]);
    else
        fixedmean=mean(pixelvals);
    end
else
    fixedmean=mean(pixelvals);
end