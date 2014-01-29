function cfgILABSecure(action)
% Misc ILAB handling

global CFG

if CFG.debug
    fprintf('cfgILABSecure: Action requested -- %s\n',action);
end

switch lower(action)
    case 'apoff'
        apOff;
    case 'apon';
        apOn;
    otherwise
        
end

    function apOff
        % Restricting autoplot functions
        if CFG.debug
            fprintf('cfgILABSecure (apOff): Restricting autoplot checkbox function.\n');
        end
        
        hAP = findobj('Tag','PLOT_SACCAUTO'); % Auto-plot checkbox
        auto_val = get(hAP,'Value'); % Old auto-plot value
        set(hAP,'UserData',auto_val); % Store in UserData
        set(hAP,'Value',1); % Force auto-plotting
        set(hAP,'Enable','off'); % Turn off ability to change this option.
    end

    function apOn
        % Restoring autoplot functions
        if CFG.debug
            fprintf('cfgILABSecure (apOn): Restoring autoplot checkbox function.\n');
        end
        
        hAP = findobj('Tag','PLOT_SACCAUTO'); % Auto-plot checkbox
        set(hAP,'Value',get(hAP,'UserData')); % Old auto-plot value, from UserData
        set(hAP,'UserData',[]); % Clear UserData
        set(hAP,'Enable','on'); % Turn off ability to change this option.
    end

end



