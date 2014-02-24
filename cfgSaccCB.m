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
 
    % UI secure and callback routines
    
    if ~isempty(get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData')) % Restrict to one saccade function at a time
        % Warning
        disp('warning');
        return;
    else
        set(findobj('Tag',CFG.CFG_TAGS{2}),'UserData',action);
    end
    
    switch action
        case 'select'
            
            if CFG.debug
                fprintf('cfgSaccCB: Select saccade request.\n');
            end
            
            cfgUISecure('apForceOn'); % Will implement callback to always plot saccades
            
            set(hSL,'Callback', @addSelectCB); % Set new callback
            figure(hST); % Bring SaccadeTable to front
            
        case 'add'
            
            if CFG.debug
                fprintf('cfgSaccCB: Add new saccade request.\n');
            end
            
            cfgUISecure('rowselect');
            
            cfgUISecure('clearilabplot'); % Clear current plotting, also clears saccade listbox selection to null
            cfgUISecure('apForceOff'); % Prevent saccade plotting
            
            % Set new callbacks
            jscrollInit = findjobj(CFG.handles.hLui(3));
            jtableInit = jscrollInit.getViewport.getView;
            hJTableInit = handle(jtableInit, 'CallbackProperties');
            set(hJTableInit, 'MouseReleasedCallback', {@addDblClickCB, CFG.handles.hLui(3)});
            
            jscrollFin = findjobj(CFG.handles.hLui(4));
            jtableFin = jscrollFin.getViewport.getView;
            hJTableFin = handle(jtableFin, 'CallbackProperties');
            set(hJTableFin, 'MouseReleasedCallback', {@addDblClickCB, CFG.handles.hLui(4)});
            
            % User prompt
            
        case 'modify'
                        
            if CFG.debug
                fprintf('cfgSaccCB: Modify saccade request.\n');
            end
            
            cfgUISecure('rowselect');
            
        case 'clear'
                        
            if CFG.debug
                fprintf('cfgSaccCB: Clear saccade request.\n');
            end
            
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
%                     hCFGLB = findobj('Tag',CFG.CFG_TAGS{12});
                case 'Final'
%                     hCFGLB = findobj('Tag',CFG.CFG_TAGS{13});
                otherwise
                    return;
            end 
            
            cfgParams('setsacc',saccif,selsacc(1),selsacc); % Set saccade data with cfgParams('setsacc') call

            cfgShow;
            
            % Clean-up: Auto-plot return reset saccade action
            cfgUISecure('apReturn'); % Assuming apForceOn prior to this function call
            cfgUISecure('clearsaccaction'); % Free UI from function restrictions

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

    function addDblClickCB(src,evt,currTbl)
        %         dblclick = get(get(currTbl,'Parent'),'SelectionType');
        persistent dblclick selected
        
        if isempty(dblclick) % Single click
            dblclick = tic;        
            selected = src.getSelectedRows;
            action = false;
            if CFG.debug
                fprintf(['cfgSaccCB (addDblClickCB): Single click without prior double-click conditions input.\n']);
            end
        else
            try
                if toc(dblclick) < .75 && selected == src.getSelectedRows; % Fast enough and same row
                    action = true;
                else % Single click, hasn't met conditions
                    dblclick = [];
                    action = false;
                    if CFG.debug
                        fprintf(['cfgSaccCB (addDblClickCB): Single click without meeting double-click capture conditions.\n']);
                    end
                end
            catch ME % Exceptions are expensive
                if strcmp(ME.identifier, 'MATLAB:nonLogicalConditional') || strcmp(ME.identifier, 'MATLAB:dimagree')
                else
                    fprintf('cfgSaccCB (addNewCB): %s\n',ME.message);
                    throw(ME)
                end
                dblclick = [];
                action = false;
            end
        end
        
        if action
           dblclick = [];
           
           if CFG.debug
               fprintf(['cfgSaccCB (addDblClickCB): Double-click captured.\n']);
           end
           
           selcol = get(currTbl,'ColumnName');
           
           if any(strcmpi(selcol(src.getSelectedColumns+1),{'Drop','Error'})) % Ignore
           else
               if CFG.debug
                   fprintf(['cfgSaccCB (addDblClickCB): Selected row -- %i\n'], (src.getSelectedRows+1));
               end
               
               selRow = double(src.getSelectedRows + 1);
               
               cfgUISecure('anyselect'); % Release row select
               cfgUISecure('clearuitablecb'); % Clear UI table callbacks, removing self as soon as valid selection occurs
               cfgUISecure('forceSLSelect1'); % Force saccade list box value to 1
               
               set(currTbl,'UserData',selRow);
               
               % Set main window UI controls
               cfgUISecure('mainUIOff');
               
               if CFG.debug
                   fprintf(['cfgSaccCB (addDblClickCB):: Setting UI trial-related items to -- %i\n'],selRow);
               end
               
               hf = ilabGetMainWinHdl;
               hc = findobj(hf, 'Tag', 'TrialCurrent');
               set(hc, 'String', num2str(selRow));
               
               hc = findobj(hf, 'Tag', 'TrialList');
               set(hc, 'String', num2str(selRow));
               
               hc = findobj(hf, 'Tag', 'TrialSlider');
               set(hc, 'Value', selRow);
               
               % Set plot parms trial to selected trial
               PP = ilabGetPlotParms;
               PP.trialList = selRow;
               ilabSetPlotParms(PP);
               ilabDrawCoordPlot;
               
               request = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
               switch request
                   case 'add'
                       if CFG.debug
                           fprintf(['cfgSaccCB (addDblClickCB): Current request -- %s\n'], request);
                       end
                       cfgSliderInterface('setup');
                   otherwise
                       if CFG.debug
                           fprintf(['cfgSaccCB (addDblClickCB): Request unknown -- %s\n'], request);
                       end
               end
               % Clean-up: Auto-plot return reset saccade action
%                cfgUISecure('apReturn');  % Assuming apForceOff prior to this function call
%                cfgUISecure('clearsaccaction'); % Free UI from function restrictions
%                cfgUISecure('mainUIOn');
           end
        end
    end
end