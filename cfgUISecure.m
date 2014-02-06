function cfgUISecure(action)
% Misc UI handling

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
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        jtableFin.setNonContiguousCellSelection(1);
    case 'clearsaccaction'
        saccaction = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
        if CFG.debug
            fprintf('cfgUISecure: Clearing saccade action -- %s.\n', saccaction);
        end
        set(findobj('Tag',CFG.CFG_TAGS{2}),'UserData',[]);
    case 'clearilabplot'
        if CFG.debug
            fprintf('cfgUISecure: Clearing saccade list selections and plotting.\n');
        end        
        set(findobj('Tag','SaccadeListbox'),'Value',[]);
        ilabPlotSaccade;
    otherwise
        
end

    function apForceOn
        % Restricting autoplot functions
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
    end

    function apReturn
        % Restoring autoplot functions
        if CFG.debug
            fprintf('cfgUISecure (apReturn): Restoring autoplot checkbox function.\n');
        end
        
        hAP = findobj('Tag','PLOT_SACCAUTO'); % Auto-plot checkbox
        set(hAP,'Value',get(hAP,'UserData')); % Old auto-plot value, from UserData
        set(hAP,'UserData',[]); % Clear UserData
        set(hAP,'Enable','on'); % Turn on ability to change this option.
        ilabShowSaccadeTblCB('autoplot'); % Re-evaluate callback settings
    end

end



