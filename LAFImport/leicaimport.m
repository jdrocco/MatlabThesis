% This function imports Leica-exported TIFF images and extracts 
% metadata from the corresponding xml file.
%
% Usage:
% 
% L=leicaimport
% Will prompt user to choose a typical image file from those
% to be imported.
%
% L=leicaimport(generalfilename)
% Will not prompt user but insted pass the 'generalfilename' 
% string to the DIR function.  Use * as wildcard.
%
% L=leicaimport(generalfilename,maxims)
% Will import no more images than specifiec by 'maxims'. 
%
%
% Output:
%
% Output is a structure of length N where N is the number
% of xml files corresponding to the images imported. Each 
% substructure L(i) contains the following fields, referenced
% L(i).FieldName:
%
% Group: String contains name of xml file.
%
% Images: MxYxX array containing the intensity values of the 
% imported images, where M is the number of images in the group
% and Y and X are the number of pixels in the Y and X dimensions.
%
% Timeindex: Vector of length M containing the index of each
% image in the series.
%
% Channel: Vector of length M containing the channel id of each
% image.
%
% GlobalTimeMin: Vector of length M containing the acquisition
% time of the image, expressed in number of minutes since the 
% microscope was assembled.
%
% LocalTimeSec: Vector of lengh M containing the same information
% as GlobalTimeMin but expressed in seconds since the first image
% in the group.
%
% Groupsize: For stacks and series only, number of images in the
% stack/series.
%
% Xpixels, Ypixels: Image size in the X and Y dimensions in pixels
%
% Xdimreal, Ydimreal: Image size in the X and Y dimensions, in 
% meters.
%
% Zstep: For stacks and series only, step size in the third dimension.
% For stacks this is in meters. For series it is in seconds.
%
% Numchannels: Total number of imaging channels used in the group.
%
% Xorigin, Yorigin: Origin of the image in the reference frame of the
% galvos controlling the x and y panning.  Not affected by moving the
% stage, only by using the "panning" controls.
%
% Written by Jeff Drocco, jdrocco_at_princeton.edu
%
% Dependencies:
% leicaxmlextract.m
% parsefilename.m
% xmliotools suite by Jarek Tuszynski, rev. 06/14/2008


function leicastruct=leicaimport(generalfilename,maxims)

if(~exist('generalfilename','var'))
    %First ask the user to choose a filename and send it to the parsing program
    [firstfilename,pathname] = uigetfile('*.tif', 'Choose an image file');
else
    inputfiles=dir(generalfilename);
    firstfilename=inputfiles(1).name;
    pathname='./';
end

firstnamestruct=parsefilename(firstfilename);

%Then create an "ambiguous" version of the filename replacing numerical
%regions with wildcards.
firstfilenameambig=firstfilename;
firstfilenameambig(logical(sum(firstnamestruct.numberreg,1)))='*';

%Change directory to the selected path a create a directory structure. If
%a maximum number of file imports is given then set it.
cd(pathname);
imfiles=dir(strcat(pathname,firstfilenameambig));

if(~exist('maxims'))
    totalims=length(imfiles);
else
    totalims=maxims;
end

%Now go through the individual names and parse each one.  Figure out the
%corresponding xml file for each.
for i=1:totalims
currentname=imfiles(i).name;
[namestruct(i),letterid,numericalid]=parsefilename(currentname);
xmlnames(i,:)=namestruct(i).xmlname;
end

%Pare down redundant xml names and do a for loop over the remainder
[uniquexmlnames xmltypical xmlgroup]=unique(xmlnames,'rows');

for r=1:size(uniquexmlnames,1)
    
    xmlfiles=dir(uniquexmlnames(r,:));
    
    %Try to locate the xml files based on the predicted names. If not
    %found, query the user.
    if(length(xmlfiles)==1)
        [tree treeName] = xml_read (strcat(pathname,xmlfiles.name));
        xmlsuccess(r)=1;
    else
        locatexmlman=menu(strcat('Could not locate xml file for',uniquexmlnames(r,:),'.  Would you like to choose the xml file manually?'),'Yes','No');
        if(locatexmlman==1)
            [manxmlname,manxmlpathname] = uigetfile('*.xml', 'Choose xml file');
            [tree treeName] = xml_read (strcat(manxmlpathname,manxmlname));
            xmlsuccess(r)=1;
        else
            xmlsuccess(r)=0;
        end
    end
    
    %If an xml file is found, send its tree to the xml extract program.
    if(xmlsuccess(r)==1)
        xmlstruct=leicaxmlextract(tree);
    end

    %Allocate memory for structure variables
    currentlocalim=0;
    totallocalims=sum(xmlgroup==r);
    if(xmlsuccess(r)==1)
        images=uint16(false([totallocalims xmlstruct.ypixels xmlstruct.xpixels]));
        % Note the ordering of ypixels first.  This is necessary based on
        % the way Matlab imports 2-D image files.
    else
        clear images;
    end
    timeinmin=zeros(1,totallocalims);
    localtimesec=zeros(1,totallocalims);
    timeind=zeros(1,totallocalims);
    channel=zeros(1,totallocalims);    
    
    %Go through all images and find those belonging to this xml group.
    %Import those images.
    for i=find(xmlgroup==r)'
        currentlocalim=currentlocalim+1;
        images(currentlocalim,:,:)=uint16(imread(imfiles(i).name));
        if(~isnan(namestruct(i).timeind)&&~isnan(namestruct(i).chanind))
            if(sum(~namestruct(i).xmlworthy)>1)
                currentlookup=xmlstruct.numrawchans*namestruct(i).integerid(namestruct(i).timeind)+namestruct(i).integerid(namestruct(i).chanind)+1;
            else
                currentlookup=currentlocalim;
            end
        else
            currentlookup=currentlocalim;
        end
        if(xmlsuccess(r))
            timeinmin(currentlocalim)=xmlstruct.timeinmin(min(currentlookup,length(xmlstruct.timeinmin)));
            localtimesec(currentlocalim)=60*(timeinmin(currentlocalim)-timeinmin(1));
        end
        if(~isnan(namestruct(i).timeind))
            timeind(currentlocalim)=namestruct(i).integerid(namestruct(i).timeind);
        else
            timeind(currentlocalim)=nan;
        end
        if(~isnan(namestruct(i).chanind))
            channel(currentlocalim)=namestruct(i).integerid(namestruct(i).chanind);
        else
            channel(currentlocalim)=nan;
        end
    end

    %Finally construct the output structure.
    if(~(xmlsuccess(r)==1))
        leicastruct(r)=struct('Group',namestruct(xmltypical(r)).xmlname,'Images',images,'Timeindex',timeind,'Channel',channel);
    else
        if(min(isfield(xmlstruct,{'stacksize','zstep'})))
            leicastruct(r)=struct('Group',namestruct(xmltypical(r)).xmlname,'Images',images,'Timeindex',timeind,'Channel',channel,'GlobalTimeMin',timeinmin,'LocalTimeSec',localtimesec,'Groupsize',xmlstruct.stacksize,'Xpixels',xmlstruct.xpixels,'Ypixels',xmlstruct.ypixels,'Xdimreal',xmlstruct.xdimreal,'Ydimreal',xmlstruct.ydimreal,'Zstep',xmlstruct.zstep,'Numchannels',xmlstruct.numrawchans,'Xorigin',xmlstruct.xorigin,'Yorigin',xmlstruct.yorigin);
        else
            leicastruct(r)=struct('Group',namestruct(xmltypical(r)).xmlname,'Images',images,'Timeindex',timeind,'Channel',channel,'GlobalTimeMin',timeinmin,'LocalTimeSec',localtimesec,'Xpixels',xmlstruct.xpixels,'Ypixels',xmlstruct.ypixels,'Xdimreal',xmlstruct.xdimreal,'Ydimreal',xmlstruct.ydimreal,'Numchannels',xmlstruct.numrawchans,'Xorigin',xmlstruct.xorigin,'Yorigin',xmlstruct.yorigin);
        end
    end

end
