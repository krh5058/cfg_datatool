function cfgUISecure(action)
% cfgUISecure.m
% Switchyard for misc UI handling
% 2/28/14
% Author: Ken Hwang

global CFG

if CFG.debug
    fprintf('cfgUISecure: Action requested -- %s\n',action);
end

switch lower(action)
    case 'apforceon'
        apForceOn;
    case 'apforceoff'
        apForceOff;
    case 'apreturn';
        apReturn;
    case 'mainuioff'
        mainUIOff;
    case 'mainuion'
        mainUIOn;
    case 'forceslselect1'
        forceSLSelect1;
    case 'enableslselect'
        enableSLSelect;
    case 'rowselect';
        if CFG.debug
            fprintf('cfgUISecure: Turning off all table NonContiguousCellSelection.\n');
        end
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        jtableInit.setNonContiguousCellSelection(0);
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        jtableFin.setNonContiguousCellSelection(0);
    case 'anyselect';
        if CFG.debug
            fprintf('cfgUISecure: Turning on all table NonContiguousCellSelection.\n');
        end
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        jtableInit.setNonContiguousCellSelection(1);
        jtableInit.clearSelection; % Clear selected row
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        jtableFin.setNonContiguousCellSelection(1);
        jtableFin.clearSelection; % Clear selected row
    case 'clearuitablecb'
        if CFG.debug
            fprintf('cfgUISecure: Removing callbacks from UI tables.\n');
        end        
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        hJTableInit = handle(jtableInit, 'CallbackProperties');
        set(hJTableInit, 'MouseReleasedCallback', []);
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        hJTableFin = handle(jtableFin, 'CallbackProperties');
        set(hJTableFin, 'MouseReleasedCallback', []);
    case 'clearuitableud'
        if CFG.debug
            fprintf('cfgUISecure: Clearing UserData from UI tables.\n');
        end
        set(CFG.handles.hLui(3:4),'UserData',[]);
    case 'clearsaccaction'
        saccaction = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
        if CFG.debug
            fprintf('cfgUISecure: Clearing data tool state -- %s.\n', saccaction);
        end
        set(findobj('Tag',CFG.CFG_TAGS{2}),'UserData',[]);
    case 'clearilabplot'
        if CFG.debug
            fprintf('cfgUISecure: Clearing saccade list selections and plotting.\n');
        end        
        set(findobj('Tag','SaccadeListbox'),'Value',[]);
        ilabPlotSaccade;
    otherwise
        if CFG.debug
            fprintf(['cfgUISecure: Unknown action -- %s\n'],action);
        end
end

    function apForceOn
        % Restricting autoplot functions, Assuming replaced custom
        % callback that will always execute ilabPlotSaccade
        % (cfgSaccCB.m/addSelectCB)
        if CFG.debug
            fprintf('cfgUISecure (apForceOn): Restricting autoplot checkbox function.\n');
        end
        
        hAP = findobj('Tag','PLOT_SACCAUTO'); % Auto-plot checkbox
        auto_val = get(hAP,'Value'); % Old auto-plot value
        set(hAP,'UserData',auto_val); % Store in UserData
        set(hAP,'Value',1); % Force auto-plotting on
        set(hAP,'Enable','off'); % Turn off ability to change this option.
    end

    function apForceOff
        % Restricting autoplot functions
        if CFG.debug
            fprintf('cfgUISecure (apForceOff): Restricting autoplot checkbox function.\n');
        end
        
        hAP = findobj('Tag','PLOT_SACCAUTO'); % Auto-plot checkbox
        auto_val = get(hAP,'Value'); % Old auto-plot value
        set(hAP,'UserData',auto_val); % Store in UserData
        set(hAP,'Value',0); % Force auto-plotting off
        set(hAP,'Enable','off'); % Turn off ability to change this option.
        ilabShowSaccadeTblCB('autoplot'); % Re-evaluate callback settings, remove current callback
    end

    function apReturn
        hAP = findobj('Tag','PLOT_SACCAUTO'); % Auto-plot checkbox
        if ~isempty(hAP) % Ignore if empty
            % Restoring autoplot functions
            if CFG.debug
                fprintf('cfgUISecure (apReturn): Restoring autoplot checkbox function.\n');
            end
            
            hAP = hAP(1); % Prevents bug in ilabShowSaccadeTblCB that makes new handles if previous ones weren't closed
            if isempty(get(hAP,'UserData'))
                set(hAP,'Value',0); % Sets default 0, in case no prior apForceOff/apForceOn call and blank UserData
            else
                set(hAP,'Value',get(hAP,'UserData')); % Old auto-plot value, from UserData
            end
            set(hAP,'UserData',[]); % Clear UserData
            set(hAP,'Enable','on'); % Turn on ability to change this option.
            ilabShowSaccadeTblCB('autoplot'); % Re-evaluate callback settings
        end
    end

    function mainUIOff
        % Restrict main UI items
        if CFG.debug
            fprintf('cfgUISecure (mainUIOff): Enabled TrialList, TrialSlider, and ShowVelPlotBox off.\n');
        end        
        hf = ilabGetMainWinHdl;
        
        hc = findobj(hf, 'Tag', 'TrialList');
        set(hc, 'Enable', 'off');
        
        hc = findobj(hf, 'Tag', 'TrialSlider');
        set(hc, 'Enable', 'off');
        
        hc = findobj(hf, 'Tag', 'ShowVelPlotBox');
        set(hc, 'Enable', 'off');
    end

    function mainUIOn
        % Enable main UI items
        if CFG.debug
            fprintf('cfgUISecure (mainUIOn): Enabled TrialList, TrialSlider, and ShowVelPlotBox on.\n');
        end
        hf = ilabGetMainWinHdl;
        
        hc = findobj(hf, 'Tag', 'TrialList');
        set(hc, 'Enable', 'on');
        
        hc = findobj(hf, 'Tag', 'TrialSlider');
        set(hc, 'Enable', 'on');
        
        hc = findobj(hf, 'Tag', 'ShowVelPlotBox');
        set(hc, 'Enable', 'on');
    end

    function forceSLSelect1
        % Force the SaccadeListbox to select the first value (trickPlot
        % modified the list so saccade to plot is first and only value in
        % list).
        if CFG.debug
            fprintf('cfgUISecure (forceSLSelect1): Setting SaccadeListBox ''Value'' selection to 1, and disabling selection.\n');
        end
        hSL = findobj('Tag','SaccadeListbox');
        set(hSL,'Value',1);
        set(hSL,'Enable','off'); % Disable SaccadeListbox
    end

    function enableSLSelect
        % Re-enable the SaccadeListBox
        if CFG.debug
            fprintf('cfgUISecure (enableSLSelect): Re-enabling SaccadeListBox.\n');
        end
        
        hSL = findobj('Tag','SaccadeListbox');
        set(hSL,'Enable','on'); % Enable SaccadeListbox
    end

end



