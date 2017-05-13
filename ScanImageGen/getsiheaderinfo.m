function [abstime,xpos,ypos,zstep]=getsiheaderinfo(file)

    abstime=0;
    info=imfinfo(file);
    header=info(1).ImageDescription;
    header=parseHeader(header);
    timestring=header.internal.triggerTimeString;
    numchars=size(timestring,2)+1;
    if(str2double(timestring((numchars-8):(numchars-7)))<10)
        if(isnan(str2double(timestring((numchars-15):(numchars-14)))))
            abstime=abstime+86400*str2double(timestring((numchars-14)));
        else
            abstime=abstime+86400*str2double(timestring((numchars-15):(numchars-14)));
        end
    else
        if(isnan(str2double(timestring((numchars-16):(numchars-15)))))
            abstime=abstime+86400*str2double(timestring((numchars-15)));
        else
            abstime=abstime+86400*str2double(timestring((numchars-16):(numchars-15)));
        end
    end
	abstime=abstime+str2double(timestring((numchars-2):(numchars-1)))+60*str2double(timestring((numchars-5):(numchars-4)))+3600*str2double(timestring((numchars-8):(numchars-7)));
    %abstime in seconds - does not work across months
    xpos=header.motor.relXPosition;
    ypos=header.motor.relYPosition;
    zstepinerr=header.acq.zStepSize;
    zstep=zstepinerr/4; %ad hoc factor introduced by malfning sutter
