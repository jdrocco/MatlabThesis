function masterscript(locsmatname,contmode)

if(~exist('contmode','var'))
    contmode=1;
end

blocksize=12;

load(locsmatname);

totalslices=20;
abovetoploc=2;

for i=1:size(filesall,1)
    filesnow=filesall(i,:);
    
    imstrtemp=importims(filesnow,stacksize,numchans)
    
    for j=1:size(imstrtemp.Images,1)
        for k=1:size(imstrtemp.Images,2)
            for m=1:size(imstrtemp.Images,3)
                [imtempbuff,resppm]=imstrresize(squeeze(double(imstrtemp.Images(j,k,m,:,:)))./double(smoothbgd),xdim,ydim);
                imstrtemp.ResImages(j,k,m,:,:)=single(imtempbuff);
            end
        end
    end
    
    imstrtemp=rmfield(imstrtemp,'Images');
    
    toploc=findtop(imstrtemp.ResImages,chancontrol);
%     imstr(i).Toploc=toploc;

    if((toploc<18)||(toploc>27))
        if(~(mod(i,blocksize)))
            clear embstr
        end
        continue;
    end

    maskerstr=findslices(imstrtemp.ResImages,toploc,chancontrol,totalslices,abovetoploc);
    
    numaskerstr=refinemaskstr(maskerstr);
    clear maskerstr
    
    depthmask=uint8(zeros(size(imstrtemp.ResImages,1),size(imstrtemp.ResImages,4),size(imstrtemp.ResImages,5)));
    pixeldrift=zeros(size(numaskerstr,1),size(numaskerstr,2));
    for j=1:size(numaskerstr,1)
        for k=1:size(numaskerstr,2)
            depthmask(k,:,:)=squeeze(depthmask(k,:,:))+uint8(numaskerstr(j,k).embryo);
            pixeldrift(j,k)=numaskerstr(j,k).pixeldrift;
        end
    end
    
    depther=(squeeze(mean(depthmask,1)));
    depthpop=popthetop(depther);
    
    [emborient,emblengthpix]=findorientation(depther);
    emblengthreal=emblengthpix/resppm;
    
    [depthcrop,depregpro]=rotandcrop(depther,emborient);
    depthcroppop=rotandcrop(depthpop,emborient);
    
    slicerange=(toploc+abovetoploc-totalslices+1):(toploc+abovetoploc);
    imcropped=single(zeros(size(imstrtemp.ResImages,1),totalslices,size(depthcrop,1),size(depthcrop,2)));
    for j=1:size(imstrtemp.ResImages,1)
        for k=1:totalslices
            slicenow=slicerange(k);
            imbuff=squeeze(imstrtemp.ResImages(j,slicenow,(chancontrol+contmode),:,:));
            imbuffshift=circshift(imbuff,[numaskerstr(k,j).pixelshifty numaskerstr(k,j).pixelshiftx]);
            imorth=imrotate(imbuffshift,-emborient,'bicubic');
            imcropped(j,k,:,:)=imorth(depregpro.SubarrayIdx{1},depregpro.SubarrayIdx{2});
        end
    end
    
    savename=strcat('str',locsmatname(1:4),num2str(contmode+floor((i-1)/blocksize)));
    
    if(mod(i,blocksize))
        embstr(mod(i,blocksize))=struct('CroppedImages',imcropped,'DepthMask',depthcrop,'DepthMaskPop',depthcroppop,'Slicerange',slicerange,'EmbLengthMicrons',emblengthreal,'PixelDrift',pixeldrift,'PixPerMicron',resppm,'LocalTimeSec',imstrtemp.LocalTimeSec,'Xorigin',imstrtemp.Xorigin,'Yorigin',imstrtemp.Yorigin,'Xdimreal',xdim,'Ydimreal',ydim,'Zstep',imstrtemp.Zstep,'Files',filesnow,'Enter14Frame',syncframe(i));
%         if(exist('syncframe','var'))
%             embstr(mod(i,blocksize)).Enter14Frame=syncframe(i);
%         end
    else
        embstr(blocksize)=struct('CroppedImages',imcropped,'DepthMask',depthcrop,'DepthMaskPop',depthcroppop,'Slicerange',slicerange,'EmbLengthMicrons',emblengthreal,'PixelDrift',pixeldrift,'PixPerMicron',resppm,'LocalTimeSec',imstrtemp.LocalTimeSec,'Xorigin',imstrtemp.Xorigin,'Yorigin',imstrtemp.Yorigin,'Xdimreal',xdim,'Ydimreal',ydim,'Zstep',imstrtemp.Zstep,'Files',filesnow,'Enter14Frame',syncframe(i));
%         if(exist('syncframe','var'))
%             embstr(blocksize).Enter14Frame=syncframe(i);
%         end
    end
    
    save(savename,'embstr')
    if(~mod(i,blocksize))
        clear embstr
    end
end 
