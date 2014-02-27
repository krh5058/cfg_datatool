function cfgIlabJavaInterface(action)
% cfgIlabJavaInterface.m
% 2/27/14
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
        tableTag = get(CFG.handles.hLui(uiHIndices(tbl)),'Tag');
        slider.selRow = get(CFG.handles.hLui(uiHIndices(tbl)),'UserData');
        
        if CFG.debug
            fprintf(['cfgIlabJavaInterface: Selected table -- %s\n'],tableTag);
            fprintf(['cfgIlabJavaInterface: Selected row -- %i\n'],slider.selRow);
        end
        
        cfgUISecure('clearuitableud'); % Keep table UserData clear

        % Determine default values
        if find(tbl)==1
            defaultVals = round(CFG.initial.list(1,3:4)/ilabGetAcqIntvl);
        elseif find(tbl)==2
            defaultVals = round(CFG.final.list(1,3:4)/ilabGetAcqIntvl);
        else
            if CFG.debug
                fprintf(['cfgIlabJavaInterface: Inaccessible table handle range.\n']);
            end
        end
        
        % If not set
        if any(isnan(defaultVals))
            defaultVals = [10 11];
        end
                
        % Get ilab parameters
        PP = ilabGetPlotParms;
        AP = ilabGetAnalysisParms;
        slider.origAP = AP; % Create save AP parameters
        slider.pseudoAP = AP; % Create psuedo AP parameters
        
        % Set up cfgConfirmJFrame, attach confirmJFrame and confirmTxtFnc
        % function to slider
        [slider.confirmJFrame,slider.confirmTxtFnc,rszFnc] = cfgConfirmJFrame;
        f = ilabGetMainWinHdl; % Main window temporarily
        figure(f); % Bring figure to fron
        rszFnc(f, slider.confirmJFrame); % Lock slider.confirmJFrame to corresponding Matlab figure     
        
        % Set slider visibility and range
        set(slider.hContainer,'Visible','on');
        slider.jComponent.setMinimum(10); % Pixel buffer       
        slider.jComponent.setMaximum(diff(PP.index(slider.selRow,1:2))); % Assuming XY-plots have auto-scaling to data limits (axis manual)
        
        % Direct jComponent method call.  Only doing this once, so no EDT.
        slider.jComponent.setLowValue(defaultVals(1));
        slider.jComponent.setHighValue(defaultVals(2));
        
    case 'cleanup'
        % Reset slider visibility
        set(slider.hContainer,'Visible','off');
        
        % Reset ILAB parameters
        ilabSetAnalysisParms(slider.origAP);
        
        % Reset persistent parameters
        slider.confirmJFrame = [];
        slider.confirmTxtFnc = [];
        slider.origAP = [];
        slider.pseudoAP = [];
        
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
        slider.pseudoAP.saccade.list = [slider.selRow 0 lowVal hiVal]; % First value in list
        ilabSetAnalysisParms(slider.pseudoAP);
        ilabPlotSaccade;
        
    end

end
