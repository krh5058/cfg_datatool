function cfgSliderInterface(action)
global CFG

if CFG.debug
    fprintf(['cfgSliderInterface: Request received.\n']);
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
        
        % Set slider visibility and range
        PP = ilabGetPlotParms;
        
        set(slider.hContainer,'Visible','on');
        defaultVals = [10 diff(PP.index(slider.selRow,1:2))];
        slider.jComponent.setMinimum(defaultVals(1)); % Pixel buffer       
        slider.jComponent.setMaximum(defaultVals(2)); % Assuming XY-plots have auto-scaling to data limits (axis manual)
        
        % Set default values
        if find(tbl)==1
            defaultVals = round(CFG.initial.list(1,3:4)/ilabGetAcqIntvl);
        elseif find(tbl)==2
            defaultVals = round(CFG.final.list(1,3:4)/ilabGetAcqIntvl);
        else
            if CFG.debug
                fprintf(['cfgSliderInterface: Inaccessible table handle range.\n']);
            end
        end
        
        if any(isnan(defaultVals))
            javaMethodEDT(['setLowValue()'],slider.jComponent);
            javaMethodEDT(['setHighValue(' defaultVals(2) ')'],slider.jComponent);
        else
            javaMethodEDT(['setLowValue(' defaultVals(1) ')'],slider.jComponent);
            javaMethodEDT(['setHighValue(' defaultVals(2) ')'],slider.jComponent);
        end
        %     case 'cleanup'
        % % Reset parameters
        % ilabSetAnalysisParms(AP);
        % set(findobj('Tag','SaccadeListbox'),'Value',[]);
        
    otherwise % Default is to plot
        trickPlotSaccade;
end

    function trickPlotSaccade  % Data inject
        
        AP = ilabGetAnalysisParms;
        pseudoAP = AP;
        
        pseudoAP.saccade.list = [slider.selRow 0 javaMethodEDT('getLowValue',slider.jComponent) javaMethodEDT('getHighValue',slider.jComponent)]; % Need to change trial number
        
        ilabSetAnalysisParms(pseudoAP);
   
        ilabPlotSaccade;
        
    end

end
