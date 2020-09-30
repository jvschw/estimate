function results = sliderThresh2(subjectID)
%function results = sliderThresh2(subjectID)
%Program for assessing participants' ratings to increasingly strong
%transcutaneous stimulation
%see Wagner, Kanig, Seidel, & Schwarzbach (submitted) for details.
%The manuscript is currently under review. Request a preprint from
%jens.schwarzbach@ukr.de
%
%%Example call:
%results = sliderThresh2('test')
%jens.schwarzbach@ukr.de

%--------------------------------------------------------------------------
%U S E R   C O N F I G U R A B L E   P A R A M E T E R S
%--------------------------------------------------------------------------
Cfg.initialIntensity = 1000; %initial intensity
%update stimulus intensity every deltaTsec seconds by deltaIntensity
Cfg.deltaTsec = 0.5;
Cfg.deltaIntensity = 25;
Cfg.exitCriterion = 10; %participant rating beyond which the program will 
                    %automatically stop
logDir = 'thresholdLogs';
set(0, 'DefaultAxesFontSize', 16) %affects appearance of graphs
Cfg.usb_name = '/dev/cu.usbmodem1411';%adapt to your computer such as 
        %'/dev/cu.usbmodem1411' on a Mac or ('COM5') on a Windows machine
%--------------------------------------------------------------------------


%CREATE LOG-DIRECTORY
mkdir(logDir)
fNameOut = fullfile( logDir,...
    sprintf('%s_%s.mat', subjectID, datestr(now,'yyyy-mm-dd_HH-MM-SS')));

%CONSIDER PREALLOCATING VARIABLES
LogIntensity = [];
LogAversiveNess = [];
LogTime = [];


try
    %SHOW RATING SCALE
    f = figure;
    C = imread('scale.png');
    imagesc(C)
    axis image
    axis off
    set(gcf, 'color', 'w')
    slhan=uicontrol('style','slider','position',[70 200 440 50],...
        'min',0,'max',10, 'SliderStep',[0.05 0.05], 'callback', @callbackfn);
    
    movegui(f,'center')
    set(f,'visible','on');
    
    
    %keyIsDown = 0;
    aversiveness = 0;
    doCont = 1;
    
    t0 = GetSecs;
    intensity = Cfg.initialIntensity;
    
    %ESTABLISH CONNECTION TO ARDUINO
    TriggerCfg.s = serial(Cfg.usb_name);
    fopen(TriggerCfg.s);

    counter = 0;
    
    %MAIN LOOP
    while doCont
        %GIVE FOCUS TO THE SLIDER
        uicontrol(slhan)
        
        t1 = GetSecs;
        if t1-t0 > Cfg.deltaTsec
            counter = counter + 1;
            t0 = t1;
            intensity = intensity + Cfg.deltaIntensity;
            fprintf(1, 'Intensity: %5d\n', intensity);
            %SEND COMMANDS TO arduino
            fprintf(TriggerCfg.s, sprintf('2 %d', intensity)); %set amplitude
            fprintf(TriggerCfg.s, '1'); %single pulse
            LogIntensity(counter) = intensity; %#ok<AGROW>
            LogAversiveNess(counter) = aversiveness; %#ok<AGROW>
            LogTime(counter) = counter*deltaTsec; %#ok<AGROW>
        end
        aversiveness = get(slhan, 'value');
        if aversiveness >= Cfg.exitCriterion
            doCont = 0;
            LogAversiveNess(counter) = aversiveness; %#ok<AGROW>
        end
        
    end
    fclose(TriggerCfg.s);
    close(f)
    
    %COLLECT RESULTS IN ONE CENTRAL STRUCTURE
    results.time = LogTime;
    results.intensity = LogIntensity;
    results.aversiveness = LogAversiveNess;
    
    %SAVE RESULTS IN LOGFILE
    fprintf(1, 'SAVING %s\n', fNameOut);
    save(fNameOut, 'results')
    
    %SHOW RESULTS
    sliderThresh_showResults(results)
    
    %RESET GRAPHICS SETTINGS TO FACTORY SETTINGS
    set(0, 'DefaultAxesFontSize', 'factory')
    
    
catch ME
    %YOU GET HERE IF AN ERROR HAS BEEN DETECTED
    %display what caused the error
    disp(ME)
    
    %CLOSE CONNECTION WITH ARDUINO
    fclose(TriggerCfg.s);
    close(f)
   
    %SAVE ALL COLLECTED INFORMATION TO LOGFILE
    results.time = LogTime;
    results.intensity = LogIntensity;
    results.aversiveness = LogAversiveNess;
    fprintf(1, 'SAVING %s\n', fNameOut);
    save(fNameOut, 'results')
    sliderThresh_showResults(results)
    set(0, 'DefaultAxesFontSize', 'factory')
    
end

%FOR FUTURE EXPANSIONS
%function callbackfn(source,eventdata)
function callbackfn(source,~)
num=get(source,'value');
title(sprintf('Aversiveness %3.1f', num));