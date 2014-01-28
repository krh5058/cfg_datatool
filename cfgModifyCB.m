function cfgModifyCB

    if CFG.debug
        fprintf('cfg: Modify Callback');
    end
    
    % -----------------------------------------
    % Get acquisition interval
    % -----------------------------------------
    acqIntvl = ilabGetAcqIntvl;
    
    % Get the saccade table and listbox
    LB_TAG = 'SaccadeListbox';
    TBL_TAG = 'SaccadeTable';
    f = findobj('Tag',TBL_TAG);
    hSL = findobj('Tag',LB_TAG);
    
    % Get the selected lines in listbox
    valSL = get(hSL,'Value');
    
    if length(valSL)~=1
        h = warndlg(['Please select one saccade at a time.'],'cfg_datatool WARNING');
        uiwait(h);
        return;
    end
    
    AP = ilabGetAnalysisParms;
    
%     % Get trials and selected saccade indices
%     selsacc = [AP.saccade.list(valSL,1), AP.saccade.list(valSL,3:4)];
    
    selsacc = AP.saccade.list(valSL,:); % Temp
    selsacc(3) = selsacc(3)*acqIntvl; % Temp
    selsacc(4) = selsacc(4)*acqIntvl; % Temp
    
    disp(selsacc); % Temp
    
    AP.saccade.list(valSL,1) = 2; % Temp
    
    ilabSetAnalysisParms(AP);
    
    % Delete existing handles (with Tags) for uicontrols
    delete(findobj(f, 'Tag','PLOT_SACCADE'));
    auto_val = get(findobj('Tag','PLOT_SACCAUTO'),'value'); % Get existing auto plot value
    delete(findobj(f, 'Tag','PLOT_SACCAUTO'));
    
    % Delete existing handles (without Tags) for uicontrols
    children = get(f,'Children');
    cbPgUp = 'ilabShowSaccadeTblCB(''pgUp'')';
    cbPgDown = 'ilabShowSaccadeTblCB(''pgDown'')';
    for i = length(children)
        cbdetect = get(children(i),'Callback'); % Delete by callback string
        
        if strcmp(cbdetect,cbPgUp) | strcmp(cbdetect,cbPgDown)
            delete(children(i));
        end
    end
    
    %  Refresh the table, if its window is open.
    %  ----------------------------------------------------
    ilabShowSaccadeTblCB('refresh');
    
    % Re-apply auto plot value and callback to SaccadeListbox
    hSACCAUTO = findobj('Tag','PLOT_SACCAUTO');
    set(hSACCAUTO,'value',auto_val);
    if auto_val
        h = findobj('Tag','SaccadeListbox');
        set(h,'callback','ilabPlotSaccade');
    else
        h = findobj('Tag','SaccadeListbox');
        set(h,'callback',[]);
    end
    
end