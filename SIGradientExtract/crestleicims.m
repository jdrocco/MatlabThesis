% This is the routine which imports image files.  It returns channel1 -
% channel2*crossimfactor in 'images' and channel2 in crapims.  time is in
% seconds and zstep in microns.
% Does not compensate for background irregularities.
% Within crestpureprep tree

function [images,time,zstep,header,createdpts,crapims,tranims]=crestleicims(number_of_frames,pathname,labelindex)

bleedpxls=20;           % Relaxation region size when sewing frames together
sinshift=0.025;         % Ad hoc factor added to compensate for micrometer shift
crossimfactor=6.35; % Factor by which to multiply channel 2 before subtraction
consttosubtr=4.319;     % Amount to subtract from channel 2 before multiplying

imfiles=dir(strcat(labelstring,sprintf('%03d',labelindex),'_*tif'));
for i=1:length(files)
    if length(files(i).name)==length(filename)
        if files(i).name==filename
            shift=i-1;
        end
    end
end

abstime=0;
for i = 1:number_of_frames
    file=files(i+shift).name;
    if (twochaninput==1)
    	for j=1:stacksize*2
            if (mod(j,2)~=0)
            	imagesin(i,((j+1)/2),:,:)=double(imread(file,j));
            else
            	imagesnotin(i,(j/2),:,:)=double(imread(file,j));
       	    end
    	end
    else
	for j=1:stacksize
	    imagesin(i,j,:,:)=double(imread(file,j));
	end
    end
    linpixelsx=size(imagesin,3);
    linpixelsy=size(imagesin,4);
    info=imfinfo(file);
    header=info(1).ImageDescription;
    header=parseHeader(header);
    timestring(i,:)=header.internal.triggerTimeString;
    numchars=size(timestring,2)+1;
    if(str2double(timestring(i,(numchars-8):(numchars-7)))<10)
        if(isnan(str2double(timestring(i,(numchars-15):(numchars-14)))))
            abstime=abstime+86400*str2double(timestring(i,(numchars-14)));
        else
            abstime=abstime+86400*str2double(timestring(i,(numchars-15):(numchars-14)));
        end
    else
        if(isnan(str2double(timestring(i,(numchars-16):(numchars-15)))))
            abstime=abstime+86400*str2double(timestring(i,(numchars-15)));
        else
            abstime=abstime+86400*str2double(timestring(i,(numchars-16):(numchars-15)));
        end
    end
	abstime=abstime+str2double(timestring(i,(numchars-2):(numchars-1)))+60*str2double(timestring(i,(numchars-5):(numchars-4)))+3600*str2double(timestring(i,(numchars-8):(numchars-7)));
    %abstime in seconds - does not work across months
    xpos(i)=header.motor.relXPosition;
    pxpos(i)=round(xpos(i)*(linpixelsx/xdimreal));
    ypos(i)=header.motor.relYPosition;
    pypos(i)=round(ypos(i)*(linpixelsy/ydimreal));
end
zstepinerr=header.acq.zStepSize;
zstep=zstepinerr/4; %ad hoc factor introduced by malfning sutter

for i=1:number_of_frames
    for j=1:number_of_frames
        relpxpos(i,j)=double(pxpos(i))-double(pxpos(j));
        relpypos(i,j)=double(pypos(i))-double(pypos(j))+round(sinshift*relpxpos(i,j));
    end
end

for q=1:number_of_frames
    srelpxpos(q)=relpxpos(q,1)-min(relpxpos(:,1));
    srelpypos(q)=relpypos(q,1)-min(relpypos(:,1));
end
time=abstime/number_of_frames;
xsizem=max(srelpxpos)+linpixelsx;
disp(xsizem)
ysizem=max(srelpypos)+linpixelsy;
disp(ysizem)
mastim=zeros(stacksize,xsizem,ysizem);
occ=mastim;
mastnotim=mastim;
createdpts=logical(zeros(xsizem,ysizem));
for i = 1:number_of_frames
    for j=1:stacksize;
        for k=1:linpixelsx
            for l=1:linpixelsy
                if(((i-1)>0)&&(k>relpxpos(i-1,i))&&(k<(relpxpos(i-1,i)+linpixelsx+1))&&(l>relpypos(i-1,i))&&(l<(relpypos(i-1,i)+linpixelsy+1)))
                    distoedg=min([k (linpixelsx-k+1) l (linpixelsy-l+1)]);
                    dampco=min([1 (distoedg/bleedpxls)]);
                    mastim(j,k+srelpxpos(i),(l+srelpypos(i)))=mastim(j,k+srelpxpos(i),l+srelpypos(i))+(dampco*imagesin(i,j,k,l));
                    mastnotim(j,k+srelpxpos(i),(l+srelpypos(i)))=mastnotim(j,k+srelpxpos(i),l+srelpypos(i))+(dampco*imagesnotin(i,j,k,l));
                    occ(j,k+srelpxpos(i),(l+srelpypos(i)))=occ(j,k+srelpxpos(i),l+srelpypos(i))+(dampco*smoothbgd(k,l));
                elseif(((i+1)<(number_of_frames+1))&&(k>relpxpos(i+1,i))&&(k<(relpxpos(i+1,i)+linpixelsx+1))&&(l>relpypos(i+1,i))&&(l<(relpypos(i+1,i)+linpixelsy+1)))
                    distoedg=min([k (linpixelsx-k+1) l (linpixelsy-l+1)]);
                    dampco=min([1 (distoedg/bleedpxls)]);
                    mastim(j,k+srelpxpos(i),(l+srelpypos(i)))=mastim(j,k+srelpxpos(i),l+srelpypos(i))+(dampco*imagesin(i,j,k,l));
                    mastnotim(j,k+srelpxpos(i),(l+srelpypos(i)))=mastnotim(j,k+srelpxpos(i),l+srelpypos(i))+(dampco*imagesnotin(i,j,k,l));
                    occ(j,k+srelpxpos(i),(l+srelpypos(i)))=occ(j,k+srelpxpos(i),l+srelpypos(i))+(dampco*smoothbgd(k,l));
                else    
                    mastim(j,k+srelpxpos(i),(l+srelpypos(i)))=mastim(j,k+srelpxpos(i),l+srelpypos(i))+imagesin(i,j,k,l);
                    mastnotim(j,k+srelpxpos(i),(l+srelpypos(i)))=mastnotim(j,k+srelpxpos(i),l+srelpypos(i))+imagesnotin(i,j,k,l);
                    occ(j,k+srelpxpos(i),(l+srelpypos(i)))=occ(j,k+srelpxpos(i),l+srelpypos(i))+1;
                end
            end
        end
    end
end
for j=1:stacksize
    for k=1:size(occ,2)
        for l=1:size(occ,3)
            if(occ(j,k,l)==0)
                createdpts(k,l)=logical(1);
                occ(j,k,l)=1.0;
            end
        end
    end
end
%images=int16((mastim-crossimfactor*(mastnotim-consttosubtr))./occ);
images=int16((mastnotim-crossimfactor*(mastim-consttosubtr)));
crapims=int16(mastim);

%imagesc(squeeze(images(1,:,:)));
