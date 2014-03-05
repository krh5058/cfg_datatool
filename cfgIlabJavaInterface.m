function cfgIlabJavaInterface(action)
% cfgIlabJavaInterface.m
% 2/28/14
% Author: Ken Hwang

global CFG

if CFG.debug
    fprintf(['cfgIlabJavaInterface: Request received -- %s.\n'],action);
end

persistent slider

% Set slider handles to prevent need to call
if isempty(slider)
    slider.hContainer = findobj('Tag','cfgSlider');
    slider.jComponent = findjobj(slider.hContainer);
end

switch lower(action)
    case 'setup'
        % Determine selected table and row
        uiHIndices = 3:4;
        tbl = ~cellfun(@isempty,get(CFG.handles.hLui(uiHIndices),'UserData'));
        slider.tableTag = get(CFG.handles.hLui(uiHIndices(tbl)),'Tag');
        slider.selRow = get(CFG.handles.hLui(uiHIndices(tbl)),'UserData');
        
        if CFG.debug
            fprintf(['cfgIlabJavaInterface (setup): Selected table -- %s\n'],slider.tableTag);
            fprintf(['cfgIlabJavaInterface (setup): Selected row -- %i\n'],slider.selRow);
        end
        
        cfgUISecure('clearuitableud'); % Keep table UserData clear

        % Determine default values
        trackBuffer = 10; % Estimated
        if find(tbl)==1
            defaultVals = CFG.initial.list(slider.selRow,3:4);
        elseif find(tbl)==2
            defaultVals = CFG.final.list(slider.selRow,3:4);
        else
            if CFG.debug
                fprintf(['cfgIlabJavaInterface (setup): Inaccessible table handle range.\n']);
            end
        end
        
        % If not set or if default values fall below track buffer
        if any(isnan(defaultVals)) || any(defaultVals<trackBuffer)
            defaultVals = [trackBuffer trackBuffer+1];
        end
                
        % Get ilab parameters
        PP = ilabGetPlotParms;
        AP = ilabGetAnalysisParms;
        slider.origAP = AP; % Create save AP parameters
        slider.pseudoAP = AP; % Create psuedo AP parameters
        
        % Set up cfgConfirmJFrame, attach confirmJFrame and acquire 
        % confirmTxtFnc function to slider
        [slider.confirmJFrame,slider.confirmTxtFnc,cmpMvFnc] = cfgConfirmJFrame(true);
        f = ilabGetMainWinHdl; % Main window temporarily
        figure(f); % Bring figure to fron
        cmpMvFnc(f, slider.confirmJFrame); % Lock slider.confirmJFrame to corresponding Matlab figure     
        
        % Set slider visibility and range
        set(slider.hContainer,'Visible','on');
        slider.jComponent.setMinimum(trackBuffer); % Pixel buffer       
        slider.jComponent.setMaximum(diff(PP.index(slider.selRow,1:2))); % Assuming XY-plots have auto-scaling to data limits (axis manual)
        
        % Direct jComponent method call.  Only doing this once, so no EDT.
        % Does not trigger 'MouseReleasedCallback'
        slider.jComponent.setLowValue(defaultVals(1));
        slider.jComponent.setHighValue(defaultVals(2));
        
        trickPlotSaccade; % Trigger initial state change
        
    case 'calc'
        
        if CFG.debug
            fprintf(['cfgIlabJavaInterface (calc): Selected row -- %i\n'],slider.selRow);
            fprintf(['cfgIlabJavaInterface (calc): pseudoAP.saccade.list -- %i, %i, %i, %i\n'],slider.pseudoAP.saccade.list);
        end
           
        % ilabVelocityPlotCB.m/drawVelocityTraces
        PP = ilabGetPlotParms;
        
         % Shift relative to start of PP.index (because that's how PP.data is structured)
         % Shift start index back 1, because slider index already accounts
         % for first index value
        absIndex = (PP.index(slider.selRow,1)-1) + [slider.pseudoAP.saccade.list(3) slider.pseudoAP.saccade.list(4)];
        trialx = PP.data(absIndex(1):absIndex(2),1); % X-coord data within window
        trialy = PP.data(absIndex(1):absIndex(2),2); % Y-coord data within window
               
        % Unsure the necessity to label initial velocity as 0
        vx = [0; diff(trialx)];
        vy = [0; diff(trialy)];
        %         vx = diff(trialx); % (delta pix)/(delta sample)
        %         vy = diff(trialy); % (delta pix)/(delta sample)

        acqIntvl_ms = ilabGetAcqIntvl;
        acqIntvl_sec = acqIntvl_ms/1000;
        [pixPerDegH, pixPerDegV] = ilabPixelsPerDegree; % pix/deg
        
        vx = vx/(pixPerDegH*acqIntvl_sec);  % (pix/sample) * (deg/pix) * (sample/s) = deg/s
        vy = vy/(pixPerDegV*acqIntvl_sec);  % (pix/sample) * (deg/pix) * (sample/s) = deg/s
        vabs = sqrt(vx.^2 + vy.^2); % Velocity within saccade window
        
        slider.calc.vPeak = max(vabs); % Max velocity (deg/s) within window
        slider.calc.vCutOff = slider.calc.vPeak * (slider.origAP.saccade.pctPeak/100); % Cut off velocity (deg/s) according to pctPeak
        slider.calc.vMean = mean(vabs); % Mean velocity (deg/s) within window
        slider.calc.dist = slider.calc.vMean*((slider.pseudoAP.saccade.list(4) - slider.pseudoAP.saccade.list(3))*acqIntvl_sec); % Distance travelled (deg)
        
        if CFG.debug
            % Format strings taken from CFG.ILABfmtStr
            fprintf(['cfgIlabJavaInterface (calc): Peak velocity (deg/s) -- %5.1f\n'],slider.calc.vPeak);
            fprintf(['cfgIlabJavaInterface (calc): Cut-off velocity (deg/s) -- %5.1f\n'],slider.calc.vCutOff);
            fprintf(['cfgIlabJavaInterface (calc): Mean velocity (deg/s) -- %5.1f\n'],slider.calc.vMean);
            fprintf(['cfgIlabJavaInterface (calc): Travel distance (deg) -- %5.1f\n'],slider.calc.dist);  
        end
        
    case 'setsacc'
        % Not complete until after 'calc'
        
        % Construct calculated values for selected saccade entry 
        selsacc = slider.pseudoAP.saccade.list;
        
        if isfield(slider,'calc')
            selsacc(5) = slider.calc.vPeak;
            selsacc(6) = slider.calc.vMean;
            selsacc(7) = NaN;
            selsacc(8) = NaN;
            selsacc(9) = slider.calc.dist;
        else
            selsacc(5:9) = nan([1 5]);
        end
        
        selsacc(10) = NaN; % Unused, but formatted with original saccade entries
        
        switch slider.tableTag
            case CFG.CFG_TAGS{12}
                saccif = 'Initial';
            case CFG.CFG_TAGS{13}
                saccif = 'Final';
            otherwise
                if CFG.debug
                    fprintf(['cfgIlabJavaInterface (setsacc): Undefined table tag.\n']);
                end
        end
        
        if CFG.debug
            fprintf(['cfgIlabJavaInterface (setsacc): Selected row -- %i\n'],slider.selRow);
        end
        
        cfgParams('setsacc',saccif,slider.selRow,selsacc); % Set saccade data with cfgParams('setsacc') call
        
        cfgShow;
        
    case 'cleanup'
        
        % Reset slider visibility
        set(slider.hContainer,'Visible','off');
            
        if ~isfield(slider,'origAP')
            if CFG.debug
                fprintf(['cfgIlabJavaInterface (cleanup): Warning -- original AP lost from ''slider'' persistent variable.\n']);
                fprintf(['cfgIlabJavaInterface (cleanup): Possibly cleared due to successive calls for ''cleanup''.\n']);
            end
        else
            
            % Reset ILAB parameters
            ilabSetAnalysisParms(slider.origAP);
            
            % Remove persistent parameter fields
            slider = rmfield(slider,{'confirmJFrame','confirmTxtFnc','origAP','pseudoAP'});
            if isfield(slider,'calc')
                slider = rmfield(slider,'calc');
            end
        end

    otherwise % Default is to plot
        trickPlotSaccade;
end

    function trickPlotSaccade  % Data inject
        
        % Slider values
        lowVal = javaMethodEDT('getLowValue',slider.jComponent);
        hiVal = javaMethodEDT('getHighValue',slider.jComponent);
        
        % Create and set cell array for slider.confirmJFrame app data
        wndwTxtVals = {int2str(lowVal*ilabGetAcqIntvl), int2str(hiVal*ilabGetAcqIntvl)};
        setappdata(slider.confirmJFrame,'WindowTxtVals', wndwTxtVals);
        
        % Update slider.confirmJFrame
        slider.confirmTxtFnc(slider.confirmJFrame);
        
        % Benevolent data inject and plot
        slider.pseudoAP.saccade.list = [slider.selRow 1 lowVal hiVal]; % First value in list
        ilabSetAnalysisParms(slider.pseudoAP);
        ilabPlotSaccade;
        
    end

end
