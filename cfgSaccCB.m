function cfgSaccCB(action)
% cfgSaccCB.m
% 2/28/14
% Author: Ken Hwang

global CFG

if CFG.debug
    fprintf('cfgSaccCB: Saccade editing callback\n');
end

% Restrict to one saccade function at a time, data tool state
if ~isempty(get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData')) 
    % Warning.  Data tool in current state
    h = warndlg(sprintf('Please complete current action -- %s\n.',CFG.stateTitle),'cfg_datatool WARNING');
    uiwait(h);
    return;
else
    
    if CFG.debug
        fprintf('cfgSaccCB: Setting data tool state -- %s\n.',action);
    end

    set(findobj('Tag',CFG.CFG_TAGS{2}),'UserData',action); % Set data tool in current state
    switch action
        case 'select'
            CFG.stateTitle = [CFG.base ': Select'];
        case 'addmod'
            CFG.stateTitle = [CFG.base ': Add/Modify'];
        otherwise
            if CFG.debug
                fprintf('cfgSaccCB: Unable to set title.  Unknown action argument.\n');
            end
            CFG.stateTitle = CFG.base;
    end
    cfgUISecure('updateuititle');
end

switch action
    case 'select'
        
        if CFG.debug
            fprintf('cfgSaccCB (select): Select saccade request.\n');
        end
        
        % Get the saccade table and listbox
        LB_TAG = 'SaccadeListbox';
        TBL_TAG = 'SaccadeTable';
        hST = findobj('Tag',TBL_TAG);
        hSL = findobj('Tag',LB_TAG);
        
        if isempty(hST) % If saccade table was closed for some reason
            if CFG.debug
                fprintf('cfgSaccCB (select): SaccadeTable absent, re-initializing.\n');
            end
            ilabShowSaccadeTblCB('init')
            LB_TAG = 'SaccadeListbox';
            TBL_TAG = 'SaccadeTable';
            hST = findobj('Tag',TBL_TAG);
            hSL = findobj('Tag',LB_TAG);
        end

        cfgUISecure('apForceOn'); % Will implement callback (addSelectCB) to always plot saccades
        
        set(hSL,'Callback', @addSelectCB); % Set new callback
        figure(hST); % Bring SaccadeTable to front
        
        % Set up cfgConfirmJFrame, attach confirmJFrame and acquire
        % confirmTxtFnc function to saccade table
        [ST.confirmJFrame,ST.confirmTxtFnc,cmpMvFnc] = cfgConfirmJFrame(false);
        cmpMvFnc(hST, ST.confirmJFrame);
        
    case 'addmod'
        
        if CFG.debug
            fprintf('cfgSaccCB (addmod): Add/Modify new saccade request.\n');
        end
        
        cfgUISecure('rowselect');
        
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
                
    case 'clear'
        
        if CFG.debug
            fprintf('cfgSaccCB (clear): Clear saccade request.\n');
        end    
        
    case 'plot'
        
        if CFG.debug
            fprintf('cfgSaccCB (plot): CFG saccade plotting request.\n');
        end
        
        
        
    otherwise
        if CFG.debug
            fprintf('cfgSaccCB: Unknown action argument.\n');
        end
end

    function addSelectCB(src,evt)
        dblclick = get(get(src,'Parent'),'SelectionType');
        if strcmp(dblclick, 'open') % Restrict to double clicking for confirmation
            selection = get(src,'Value');
            if length(selection)~=1 % Restrict to single selection
                h = msgbox(['Please select one saccade at a time.'],'cfg_datatool WARNING','modal');
                uiwait(h);
                return;
            end
            
            AP = CFG.AP;
            
            % Get trials and selected saccade index
            selsacc = AP.saccade.list(selection,:);
            
            wndwTxtVals = {int2str(selsacc(1,3)*CFG.acqIntvl), int2str(selsacc(1,4)*CFG.acqIntvl)}; % First saccade only
            setappdata(ST.confirmJFrame,'WindowTxtVals', wndwTxtVals);
            
            % Update ST.confirmJFrame
            ST.confirmTxtFnc(ST.confirmJFrame);
            
            saccif = questdlg(sprintf('Trial: %4d\nSaccade Number: %3d\nStart (ms): %6.0f\nEnd (ms): %6.0f\n\nInitial or Final?',selsacc(1),selsacc(2),selsacc(3)*CFG.acqIntvl,selsacc(4)*CFG.acqIntvl), ...
                'Saccade specification', ...
                'Initial','Final','Cancel','Initial');
            
            if strcmpi(saccif,'Cancel') || isempty(saccif)
                return;
            end
            
            cfgParams('setsacc',saccif,selsacc(1),selsacc); % Set saccade data with cfgParams('setsacc') call
            
            cfgShow;
            
            % Clean-up: Auto-plot return, reset saccade action, execute
            % 'ClosedWindow' callback on confirmJFrame.
            cfgUISecure('statecleanup'); % Clean up UI functions based on state            

%             ST.confirmJFrame.setVisible(0);
%             ST.confirmJFrame.dispose();
            
            if CFG.debug
                fprintf('cfgSaccCB (addSelectCB) -- Selected Saccade: \n');
                fprintf([CFG.ILABfmtStr '\n'],selsacc);
                fprintf('cfgSaccCB (addSelectCB) -- Selected Trial: %4d\n', selsacc(1));
                fprintf('cfgSaccCB (addSelectCB) -- Selected Saccade Type: %s\n', saccif);
            end
            
        elseif strcmp(dblclick, 'normal') % Single click will continue to plot and update ConfirmJFrame
            % Get selection
            selection = get(src,'Value');
            AP = CFG.AP;
            selsacc = AP.saccade.list(selection,:); 
            wndwTxtVals = {int2str(selsacc(1,3)*CFG.acqIntvl), int2str(selsacc(1,4)*CFG.acqIntvl)}; % First saccade only
            setappdata(ST.confirmJFrame,'WindowTxtVals', wndwTxtVals);
            
            % Update ST.confirmJFrame
            ST.confirmTxtFnc(ST.confirmJFrame);
            
            % Plot
            ilabPlotSaccade;
        end
    end

    function addDblClickCB(src,evt,currTbl)
        persistent tCheck rowCheck tblCheck
        
        validDblClick = false; % False until conditions met
            
        if isempty(tCheck) % Initial
            tCheck = tic;
            rowCheck = src.getSelectedRows;
            tblCheck = currTbl;
            if CFG.debug
                fprintf(['cfgSaccCB (addDblClickCB): Single click without prior double-click conditions input.\n']);
            end
        else
            try
                if toc(tCheck) < .75 && rowCheck == src.getSelectedRows && tblCheck == currTbl; % Fast enough and same row
                    validDblClick = true;
                else % Single click, hasn't met conditions
                    tCheck = tic;
                    rowCheck = src.getSelectedRows;
                    tblCheck = currTbl;
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
                tCheck = [];
                rowCheck = [];
                tblCheck = [];
            end
        end
        
        if validDblClick
            % Reset persistent variables
            tCheck = [];
            rowCheck = [];
            tblCheck = [];
            
            if CFG.debug
                fprintf(['cfgSaccCB (addDblClickCB): Double-click captured.\n']);
            end
            
            selcol = get(currTbl,'ColumnName');
            
            if any(strcmpi(selcol(src.getSelectedColumns+1),{'Drop','Error'})) % Ignore
            else
                if CFG.debug
                    fprintf(['cfgSaccCB (addDblClickCB): Selected row -- %i\n'], (src.getSelectedRows+1));
                end
                
                selRow = double(src.getSelectedRows + 1); % Returns 0-indexed int32
                
                cfgUISecure('anyselect'); % Release row select
                cfgUISecure('clearuitablecb'); % Clear UI table callbacks, removing self as soon as valid selection occurs
                cfgUISecure('clearilabplot'); % Clear current plotting, also clears saccade listbox selection to null
                cfgUISecure('apForceOff'); % Prevent ILAB saccade auto-plotting
                cfgUISecure('forceSLSelect1'); % Force saccade list box value to 1
                
                set(currTbl,'UserData',selRow); % For cfgIlabJavaInterface.m, to pull row and table with row (not empty, and cleared after to determine this).
                
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
                PP = CFG.PP;
                PP.trialList = selRow;
                ilabSetPlotParms(PP);
                ilabDrawCoordPlot;
                
                % Handle data tool state
                request = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
                switch request
                    case 'addmod'
                        if CFG.debug
                            fprintf(['cfgSaccCB (addDblClickCB): Current request -- %s\n'], request);
                        end
                        cfgIlabJavaInterface('setup');
                    otherwise
                        if CFG.debug
                            fprintf(['cfgSaccCB (addDblClickCB): Request unknown -- %s\n'], request);
                        end
                end
            end
        end
    end
end