function cfgSliderInterface(action)
global CFG

if CFG.debug
    fprintf(['cfgSliderInterface: Request received -- %s.\n'],action);
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
            fprintf(['cfgSliderInterface: Selected table -- %s\n'],tableTag);
            fprintf(['cfgSliderInterface: Selected row -- %i\n'],slider.selRow);
        end
        
        cfgUISecure('clearuitableud'); % Keep table UserData clear

        % Determine default values
        if find(tbl)==1
            defaultVals = round(CFG.initial.list(1,3:4)/ilabGetAcqIntvl);
        elseif find(tbl)==2
            defaultVals = round(CFG.final.list(1,3:4)/ilabGetAcqIntvl);
        else
            if CFG.debug
                fprintf(['cfgSliderInterface: Inaccessible table handle range.\n']);
            end
        end
        
        % If not set
        if any(isnan(defaultVals))
            defaultVals = [10 11];
        end
                
        % Get ilab parameters
        PP = ilabGetPlotParms;
        AP = ilabGetAnalysisParms;
        slider.AP = AP; % Create save AP parameters
        pseudoAP = AP; % Create psuedo AP parameters
        
        % Set slider visibility and range
        
        set(slider.hContainer,'Visible','on');
        slider.jComponent.setMinimum(10); % Pixel buffer       
        slider.jComponent.setMaximum(diff(PP.index(slider.selRow,1:2))); % Assuming XY-plots have auto-scaling to data limits (axis manual)
        
        % Direct jComponent method call.  Only doing this once, so no EDT.
        slider.jComponent.setsetLowValue(defaultVals(1));
        slider.jComponent.setsetHighValue(defaultVals(2));
        
    case 'cleanup'
        % Reset parameters
        set(slider.hContainer,'Visible','off');
        ilabSetAnalysisParms(AP);
%         set(findobj('Tag','SaccadeListbox'),'Value',[]);
        
    otherwise % Default is to plot
        trickPlotSaccade;
end

    function trickPlotSaccade  % Data inject
        
        pseudoAP.saccade.list = [slider.selRow 0 javaMethodEDT('getLowValue',slider.jComponent) javaMethodEDT('getHighValue',slider.jComponent)];
        
        ilabSetAnalysisParms(pseudoAP);
        ilabPlotSaccade;
        
    end

end