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
        case 'clear'
            CFG.stateTitle = [CFG.base ': Clear'];
        case 'plot'
            CFG.stateTitle = [CFG.base ': Plot'];
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
        
        cfgUISecure('rowselect');
        cfgUISecure('clearilabplot'); % Clear current plotting, also clears saccade listbox selection to null
                
        [CFGDT.confirmJFrame,CFGDT.confirmTxtFnc,cmpMvFnc] = cfgConfirmJFrame(false);
        cmpMvFnc(findobj('Tag',CFG.CFG_TAGS{2}), CFGDT.confirmJFrame);
        
        wndwTxtVals = {'---','---'};
        setappdata(CFGDT.confirmJFrame,'WindowTxtVals', wndwTxtVals);
        
        % Update CFGDT.confirmJFrame
        CFGDT.confirmTxtFnc(CFGDT.confirmJFrame);
        % Set new callbacks
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        hJTableInit = handle(jtableInit, 'CallbackProperties');
        set(hJTableInit, 'MouseReleasedCallback', {@addDblClickCB, CFG.handles.hLui(3)});
%         set(hJTableInit, 'MousePressedCallback', {@addSnglClickCB, CFG.handles.hLui(3)});
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        hJTableFin = handle(jtableFin, 'CallbackProperties');
        set(hJTableFin, 'MouseReleasedCallback', {@addDblClickCB, CFG.handles.hLui(4)});
%         set(hJTableFin, 'MousePressedCallback', {@addSnglClickCB, CFG.handles.hLui(4)});
        
    case 'plot'
        
        if CFG.debug
            fprintf('cfgSaccCB (plot): CFG saccade plotting request.\n');
        end
        
        cfgUISecure('rowselect');
        cfgUISecure('clearilabplot'); % Clear current plotting, also clears saccade listbox selection to null
        cfgUISecure('apForceOff'); % Prevent ILAB saccade auto-plotting
        %         cfgUISecure('forceSLSelect1'); % Force saccade list box value to 1
        cfgUISecure('mainUIOff');
                                
        [CFGDT.confirmJFrame,CFGDT.confirmTxtFnc,cmpMvFnc] = cfgConfirmJFrame(false);
        cmpMvFnc(findobj('Tag',CFG.CFG_TAGS{2}), CFGDT.confirmJFrame);
                
        % Set new callbacks
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        hJTableInit = handle(jtableInit, 'CallbackProperties');
        set(hJTableInit, 'MouseReleasedCallback', {@addSnglClickCB, CFG.handles.hLui(3)});
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        hJTableFin = handle(jtableFin, 'CallbackProperties');
        set(hJTableFin, 'MouseReleasedCallback', {@addSnglClickCB, CFG.handles.hLui(4)});
        
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

                cfgUISecure('clearuitablecb'); % Clear UI table callbacks, removing self as soon as valid selection occurs
                
                set(currTbl,'UserData',selRow); % For cfgIlabJavaInterface.m, to pull row and table with row (not empty, and cleared after to determine this).
                                
                % Handle data tool state
                request = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
                
                if CFG.debug
                    fprintf(['cfgSaccCB (addDblClickCB): Current request -- %s\n'], request);
                end
                
                switch request
                    case 'addmod'
                        cfgUISecure('clearilabplot'); % Clear current plotting, also clears saccade listbox selection to null
                        cfgUISecure('apForceOff'); % Prevent ILAB saccade auto-plotting
                        cfgUISecure('forceSLSelect1'); % Force saccade list box value to 1
                        % Set main window ui controls
                        cfgUISecure('mainuioff');
                        cfgUISecure('updateilabui'); % update ilab ui, pass only one selected row at a time
                        cfgIlabJavaInterface('setup');
                    case 'clear'
                        % Initial/final switch
                        switch get(currTbl,'Tag')
                            case CFG.CFG_TAGS{12}
                                saccif = 'Initial';
                            case CFG.CFG_TAGS{13}
                                saccif = 'Final';
                            otherwise
                                if CFG.debug
                                    fprintf(['cfgSaccCB (addDblClickCB): Undefined table tag.\n']);
                                end
                        end
                        
                        % Prompt
                        clearResponse = questdlg(sprintf(['Trial: %4d\nInitial/Final: %s\n', ...
                            'Start (ms): %6.0f\nEnd (ms): %6.0f\n\n', ...
                            'Are you sure you want to remove this saccade from the CFG data set?'], ... 
                            selRow, saccif, CFG.(lower(saccif)).list(selRow,3)*CFG.acqIntvl,CFG.(lower(saccif)).list(selRow,4)*CFG.acqIntvl), ...
                            'Clear Saccade', ...
                            'Clear','Cancel','Cancel');
                        
                        if strcmpi(clearResponse,'Cancel') || isempty(clearResponse)
                        else
                            cfgParams('clearsacc',saccif,selRow);
                            cfgShow; % Update UI
                        end
                        
                        cfgUISecure('statecleanup'); % Clean up UI functions based on state
                    otherwise
                        if CFG.debug
                            fprintf(['cfgSaccCB (addDblClickCB): Request unknown -- %s\n'], request);
                        end
                end
            end
        end
    end

    function addSnglClickCB(src,evt,currTbl)
        % Turn off for Matlab loading time
        set(findobj(CFG.handles.hLui(3)),'Enable','off');
        set(findobj(CFG.handles.hLui(4)),'Enable','off');
        
        selRow = double(src.getSelectedRows + 1); % Returns 0-indexed int32
        selRow = selRow(1); % First selection only
        set(currTbl,'UserData',selRow); % For cfgIlabJavaInterface.m, to pull row and table with row (not empty, and cleared after to determine this).  
        cfgUISecure('updateilabui'); % Update ILAB UI, Pass only one selected row at a time
        cfgUISecure('clearuitableud'); % Keep table UserData clear
                
        % Initial/final saccade windows
        iWin = [CFG.initial.list(selRow,3) CFG.initial.list(selRow,4)];
        fWin = [CFG.final.list(selRow,3) CFG.final.list(selRow,4)];
        
        % Delay and feedback event timestamps
        it0 = CFG.initial.t0(selRow);
        ft0 = CFG.final.t0(selRow);
        
        if CFG.debug
            fprintf('cfgSaccCB (addSnglClickCB): Initial window, %6.0f.\n',iWin);
            fprintf('cfgSaccCB (addSnglClickCB): Final window, %6.0f.\n',fWin);
            fprintf('cfgSaccCB (addSnglClickCB): Delay event, %6.0f.\n',it0);
            fprintf('cfgSaccCB (addSnglClickCB): Feedback event, %6.0f.\n',ft0);
        end
        
       
        % Format and display for jFrame
        wndwTxtVals = {['Initial - ' num2str(iWin(1)*CFG.acqIntvl) ', Final - ' num2str(fWin(1)*CFG.acqIntvl)], ...
            ['Initial - ' num2str(iWin(2)*CFG.acqIntvl) ', Final - ' num2str(fWin(2)*CFG.acqIntvl)]}; % Values, remain in milliseconds
        setappdata(CFGDT.confirmJFrame,'WindowTxtVals', wndwTxtVals);
        
        % Update CFGDT.confirmJFrame
        CFGDT.confirmTxtFnc(CFGDT.confirmJFrame);
            
        % Format index appropriately, with acqIntvl or absolute for PP
        % plotting
        
        PP = ilabGetPlotParms; % Use accessor method to update pupil
        
        %% From ilabPlotSaccade.m
        % Modified slightly
        
        %         % find and delete old saccades
        %         oldsacc = findobj('Tag','saccades');
        %         delete(oldsacc)
        
        % find the xytimeplotaxis
        for i = 1:length(PP.XYPLOT_TAG)
            Axy(i) = findobj('Tag',PP.XYPLOT_TAG{i});
            axes(Axy(i))
            hold on
        end
        
        % Get acquisition interval
        acqIntvl = CFG.acqIntvl;
        acqIntvl = acqIntvl/1000;          % convert from ms to sec
                       
        % Get pixels per degree
        [hPPD, vPPD] = ilabPixelsPerDegree;
        
        % get origin for degrees
        degOrigin = PP.coordGrid.degOrigin;
        
        % get ShowCoordGridPopup value
        hCGpop = findobj('Tag','ShowCoordGridPop');
        if get(hCGpop,'Value') == 3 | get(hCGpop,'Value') == 5
            deg = 1;
        else
            deg = 0;
        end
        
        % Formatted data for loop
        windows = [iWin;fWin];
        evts = [it0;ft0];
        col = {'g','c'};
        
        for saccif = 1:2 % Loop through one initial and one final
            if any(~isnan(windows(saccif,:))) % If exists
                
                % Shift relative to start of PP.index (because that's how PP.data is structured)
                % Shift start index back 1, because slider index already accounts
                % for first index value
                absIndex = (PP.index(selRow,1)-1) + windows(saccif,:); % 
                trialx = PP.data(absIndex(1):absIndex(2),1); % X-coord data within window
                trialy = PP.data(absIndex(1):absIndex(2),2); % Y-coord data within window
                
                % Amplitudes based on degree setting
                if deg
                    datH = (trialx - degOrigin(1)) / hPPD;
                    datV = (trialy - degOrigin(2)) / vPPD;
                else
                    datH = trialx;
                    datV = trialy;
                end
                
                % Take pupil plotting into account
                if length(Axy) == 2
                    axes(Axy(1))
                    yLim = get(Axy(1),'YLim'); % Get Y limits for event plotting
                    plot([evts(saccif)/1000 evts(saccif)/1000],yLim,[col{saccif} ':']); % Plot event
                    plot([windows(saccif,1):windows(saccif,2)]*acqIntvl,datH,col{saccif}); % Plot saccade
                    
                    axes(Axy(2))
                    yLim = get(Axy(2),'YLim'); % Get Y limits for event plotting
                    plot([evts(saccif)/1000 evts(saccif)/1000],yLim,[col{saccif} ':']); % Plot event
                    plot([windows(saccif,1):windows(saccif,2)]*acqIntvl,datV,col{saccif}); % Plot saccade
                else
                    axes(Axy)
                    yLim = get(Axy,'YLim');
                    plot([evts(saccif)/1000 evts(saccif)/1000],yLim,[col{saccif} ':']); % Plot event                  
                    plot([windows(saccif,1):windows(saccif,2)]*acqIntvl,datH,col{saccif}); % Plot saccade
                    plot([evts(saccif)/1000 evts(saccif)/1000],yLim,[col{saccif} ':']); % Plot event
                    plot([windows(saccif,1):windows(saccif,2)]*acqIntvl,datV,col{saccif}); % Plot saccade
                end
         
            end
        end
        
        for i = 1:length(Axy)
            axes(Axy(i))
            hold off
        end
        
        drawnow;
        
        % Turn on after Matlab loading time
        set(findobj(CFG.handles.hLui(3)),'Enable','on');
        set(findobj(CFG.handles.hLui(4)),'Enable','on');
        %%
    end  
end