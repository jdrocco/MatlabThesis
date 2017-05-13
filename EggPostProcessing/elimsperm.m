%This function will eliminate a "sperm" that is dangling from the edge of the
%embryo region. It will also eliminate all but the biggest region.

function [fixedBWemb,spermtip]=elimsperm(regions)

%Figure out which region is the largest--assume this is the embryo.  Also
%compute the AP-axis (the longest line that can be drawn through it)
BWemb=returnbiggest(regions);
regpro=regionprops(logical(BWemb),'MinorAxisLength','Image','ConvexImage','Area','SubarrayIdx');

[AP_x,AP_y]=findAPaxis(regpro.Image);

%Then find the area which is in the convex closure but not in the region.
%This will 
shaver=(regpro.ConvexImage-regpro.Image);
sampse=strel('disk',1);
%But it is likely to have many scattered points away from
% the sperm which are irrelevant.  So try to eliminate some of these.
shaverlabel=bwlabel(shaver);
shalabelpro=regionprops(shaverlabel,'MajorAxisLength','MinorAxisLength','Area');
for i=1:length(shalabelpro)
    majminrat=shalabelpro(i).MajorAxisLength/shalabelpro(i).MinorAxisLength;
    %If the region is too eccentric or too big/small, eliminate it.
    if((majminrat>13)||(shalabelpro(i).Area>(0.008*regpro.Area))||(shalabelpro(i).Area<(0.0005*regpro.Area)))
        shaver(shaverlabel==i)=0;
    end
end
shaverlabel=bwlabel(shaver);
shalabelpro=regionprops(shaverlabel,'Centroid');
%Now that we have some candidates, figure out which two are closest to the AP
%axis ends and choose those.
if(length(shalabelpro)>1)
    currmin=inf;
    for q=1:(length(shalabelpro)-1)
        for r=(q+1):length(shalabelpro)
            for s=1:2
                currdistsq=(shalabelpro(q).Centroid(1)-AP_y(s))^2+(shalabelpro(q).Centroid(2)-AP_x(s))^2;
                currdistsq=currdistsq+(shalabelpro(r).Centroid(1)-AP_y(s))^2+(shalabelpro(r).Centroid(2)-AP_x(s))^2;
                if(currdistsq<currmin)
                    currmin=currdistsq;
                    currq=q;
                    currr=r;
                    currs=s;
                end
            end
        end
    end
    %Remember where the spermtip is, this will indicate the anterior end.
    spermtip=[AP_x(currs) AP_y(currs)];
    shaver(~((shaverlabel==currq)|(shaverlabel==currr)))=0;
    shaverpro=regionprops(shaver,'all');
    totallydone=0;
else
        fixedBWemb=BWemb;
        totallydone=1;
        spermtip=nan;
end
%One last check, make sure the convex area is approximately the right size.
if(~totallydone)
    if(((currmin/(regpro.MinorAxisLength^2))>.2)||(shaverpro.ConvexArea>(0.03*regpro.Area)))
        fixedBWemb=BWemb;
        totallydone=1;
    end
end
%Now if we've made it this far we will try to remove the sperm.
if(~totallydone)
    %First use kmeans to reduce the convex hull down to three points.
    [idx,ctrs]=kmeans(shaverpro.Extrema,3,'replicates',10);
    ctrswcentroid=ctrs;
    %Add the centroid to this group to get a three triangle area.
    ctrswcentroid((end+1),:)=shaverpro.Centroid;
    [row,col]=find(shaver);
    TRI = delaunay(ctrswcentroid(:,1),ctrswcentroid(:,2));
    %Now figure out which of the three triangles each of the points in 
    %shaver belongs to. 
    T = tsearch(ctrswcentroid(:,1),ctrswcentroid(:,2),TRI,col,row);
    for q=1:3
        tritally(q)=sum(T==q);
    end
    [junk embryotri]=min(tritally);
    %The one which has the least overlap with shaver is over the embryo. We
    %want to delete the whole convex image of shaver from the embryo region
    %except this part.
    makewholeconv=zeros(size(shaver));
    makewholeconv(shaverpro.SubarrayIdx{1},shaverpro.SubarrayIdx{2})=shaverpro.ConvexImage;
    [delrow,delcol]=find(makewholeconv);
    delinds=find(makewholeconv);
    U = tsearch(ctrswcentroid(:,1),ctrswcentroid(:,2),TRI,delcol,delrow);
    makewholeconv(delinds(U==embryotri))=0;
    %Now clean up that cookie cutter mask and remove it from the embryo.
    mwcnobo=imerode(makewholeconv,sampse);
    removefromemb=zeros(size(BWemb));
    removefromemb(regpro.SubarrayIdx{1},regpro.SubarrayIdx{2})=mwcnobo;
    fixedBWemb=BWemb&(~removefromemb);
    %Then do a last clean up
    fixedBWemb=imfill(fixedBWemb,'holes');
    fixedBWemb=returnbiggest(fixedBWemb);
end