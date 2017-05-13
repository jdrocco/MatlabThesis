%    depther=squeeze(mean(depthmaskfin(j,:,:,:),2));

function depther=popthetop(depther)

    maxer=max(depther(:));
    interval=2;
    multiplier=4;
    depther(depther>(maxer-interval))=(maxer-interval);
    origtop=(depther==(maxer-interval));
    totalerode=sum(origtop(:));
    maxiter=((interval*multiplier)+(multiplier/2));
    for i=1:maxiter
        sesize=0;
        toparea=totalerode;
        while((toparea>((maxiter+0.5-i)*totalerode/(maxiter))))
            sesize=sesize+1;
            se=strel('disk',sesize);
            newim=imerode(origtop,se);
            toparea=sum(newim(:));
        end
        depther(newim)=maxer-interval+(i/multiplier);
    end
    
    
    
    %     origpro=regionprops(origtop);
% % %     depther((round(origpro.Centroid(2))-1):(round(origpro.Centroid(2))+1),(round(origpro.Centroid(1))-6):(round(origpro.Centroid(1))+6))=maxer+1;
% %     depther(round(origpro.Centroid(2)),(round(origpro.Centroid(1))-18):(round(origpro.Centroid(1))+18))=maxer+1;
