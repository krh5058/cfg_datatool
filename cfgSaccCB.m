function cfgSaccCB(action)

    global CFG

    if CFG.debug
        fprintf('cfgSaccCB: Saccade editing callback\n');
    end
    
    % -----------------------------------------
    % Get acquisition interval
    % -----------------------------------------
%     acqIntvl = ilabGetAcqIntvl;
    
    % Get the saccade table and listbox
    LB_TAG = 'SaccadeListbox';
    TBL_TAG = 'SaccadeTable';
    hST = findobj('Tag',TBL_TAG);
    hSL = findobj('Tag',LB_TAG);    
 
    switch action
        case 'select'
            
            cfgILABSecure('apoff');
            
            set(hSL,'Callback', @addSelectCB); % Set new callback
            figure(hST); % Bring SaccadeTable to front
            
        case 'add'
            
        case 'modify'
            
        otherwise
            if CFG.debug
                fprintf('cfgSaccCB: Unknown action argument.\n');
            end
    end
    
%     AP = ilabGetAnalysisParms;
%     
%     % Get trials and selected saccade indices
%     selsacc = [AP.saccade.list(valSL,1), AP.saccade.list(valSL,3:4)];
%     
%     selsacc = AP.saccade.list(valSL,:); % Temp
%     selsacc(3) = selsacc(3)*acqIntvl; % Temp
%     selsacc(4) = selsacc(4)*acqIntvl; % Temp
%     
%     disp(selsacc); % Temp
    
%     AP.saccade.list(valSL,1) = 2; % Temp
%     
%     ilabSetAnalysisParms(AP);
%     
%     % Delete existing handles (with Tags) for uicontrols
%     delete(findobj(f, 'Tag','PLOT_SACCADE'));
%     auto_val = get(findobj('Tag','PLOT_SACCAUTO'),'value'); % Get existing auto plot value
%     delete(findobj(f, 'Tag','PLOT_SACCAUTO'));
%     
%     % Delete existing handles (without Tags) for uicontrols
%     children = get(f,'Children');
%     cbPgUp = 'ilabShowSaccadeTblCB(''pgUp'')';
%     cbPgDown = 'ilabShowSaccadeTblCB(''pgDown'')';
%     for i = length(children)
%         cbdetect = get(children(i),'Callback'); % Delete by callback string
%         
%         if strcmp(cbdetect,cbPgUp) | strcmp(cbdetect,cbPgDown)
%             delete(children(i));
%         end
%     end
%     
%     %  Refresh the table, if its window is open.
%     %  ----------------------------------------------------
%     ilabShowSaccadeTblCB('refresh');
%     
%     % Re-apply auto plot value and callback to SaccadeListbox
%     hSACCAUTO = findobj('Tag','PLOT_SACCAUTO');
%     set(hSACCAUTO,'value',auto_val);
%     if auto_val
%         h = findobj('Tag','SaccadeListbox');
%         set(h,'callback','ilabPlotSaccade');
%     else
%         h = findobj('Tag','SaccadeListbox');
%         set(h,'callback',[]);
%     end
                
    function addSelectCB(src,evt)
        dblclick = get(get(src,'Parent'),'SelectionType');
        if strcmp(dblclick, 'open') % Restrict to double clicking for confirmation
            selection = get(src,'Value');
            if length(selection)~=1 % Restrict to single selection
                h = msgbox(['Please select one saccade at a time.'],'cfg_datatool WARNING','modal');
                uiwait(h);
                return;
            end
            
            AP = ilabGetAnalysisParms;
            
            % Get trials and selected saccade index
            selsacc = AP.saccade.list(selection,:); % Temp
            selsacc(3) = selsacc(3)*CFG.acqIntvl; % Temp
            selsacc(4) = selsacc(4)*CFG.acqIntvl; % Temp
                        
            saccif = questdlg(sprintf('Trial: %4d\nSaccade Number: %4d\nStart (ms): %6.0f\nEnd (ms): %6.0f\n\nInitial or Final?',selsacc(1:4)), ...
                'Saccade specification', ...
                'Initial','Final','Cancel','Initial');
            
            switch saccif
                case 'Initial'
                    hCFGLB = findobj('Tag',CFG.CFG_TAGS{12});
                case 'Final'
                    hCFGLB = findobj('Tag',CFG.CFG_TAGS{13});
                otherwise
                    return;
            end 
            
            cfgParams('setsacc',saccif,selsacc(1),selsacc); % Set saccade data with cfgParams('setsacc') call
%             CFG.(lower(saccif)).list(selsacc(1),:) = AP.saccade.list(selection,:); % Old column format
            %             hCFG = findobj('Tag',CFG.CFG_TAGS{2});
            
            cfgILABSecure('apOn'); % Assuming apOff prior to this function call

            if CFG.debug
                fprintf('cfgSaccCB (addSelectCB) -- Selected Saccade: \n');
                fprintf([CFG.ILABfmtStr '\n'],selsacc);
                fprintf('cfgSaccCB (addSelectCB) -- Selected Trial: %4d\n', selsacc(1));
                fprintf('cfgSaccCB (addSelectCB) -- Selected Saccade Type: %s\n', saccif);
            end
                    
        elseif strcmp(dblclick, 'normal') % Single click will continue to plot
            ilabPlotSaccade;
        end
    end
end