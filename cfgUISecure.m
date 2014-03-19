function cfgUISecure(action)
% cfgUISecure.m
% Switchyard for misc UI handling
% 2/28/14
% Author: Ken Hwang

global CFG

import javax.swing.ListSelectionModel;

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
    case 'updateilabui'
        updateIlabUI;
    case 'plottoilabmain'
        plotToIlabMain;
    case 'forceslselect1'
        forceSLSelect1;
    case 'enableslselect'
        enableSLSelect;
    case 'rowselect';
        if CFG.debug
            fprintf('cfgUISecure (rowselect): Turning off all table NonContiguousCellSelection.\n');
            fprintf('cfgUISecure (rowselect): Enabling all tables to single selection.\n');
        end
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        jtableInit.setNonContiguousCellSelection(0);
        jtableInit.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        jtableFin.setNonContiguousCellSelection(0);
        jtableFin.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
    case 'anyselect';
        if CFG.debug
            fprintf('cfgUISecure (anyselect): Turning on all table NonContiguousCellSelection.\n');
            fprintf('cfgUISecure (anyselect): Enabling all tables to multiple selection.\n');
        end
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        jtableInit.setNonContiguousCellSelection(1);
        jtableInit.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        jtableInit.clearSelection; % Clear selected row
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        jtableFin.setNonContiguousCellSelection(1);
        jtableFin.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        jtableFin.clearSelection; % Clear selected row
    case 'clearuitablecb'
        if CFG.debug
            fprintf('cfgUISecure (clearuitablecb): Removing callbacks from UI tables.\n');
        end        
        jscrollInit = findjobj(CFG.handles.hLui(3));
        jtableInit = jscrollInit.getViewport.getView;
        hJTableInit = handle(jtableInit, 'CallbackProperties');
        set(hJTableInit, 'MouseReleasedCallback', []);
        set(hJTableInit, 'MousePressedCallback', []);
        set(CFG.handles.hLui(3),'KeyPressFcn',[]);
        
        jscrollFin = findjobj(CFG.handles.hLui(4));
        jtableFin = jscrollFin.getViewport.getView;
        hJTableFin = handle(jtableFin, 'CallbackProperties');
        set(hJTableFin, 'MouseReleasedCallback', []);
        set(hJTableFin, 'MousePressedCallback', []);
        set(CFG.handles.hLui(4),'KeyPressFcn',[]);
        
%         set(findobj('Tag',CFG.CFG_TAGS{2}),'KeyPressFcn',[])
    case 'clearuitableud'
        if CFG.debug
            fprintf('cfgUISecure (clearuitableud): Clearing UserData from UI tables.\n');
        end
        set(CFG.handles.hLui(3:4),'UserData',[]);
    case 'clearsaccaction'
        saccaction = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
        if CFG.debug
            fprintf('cfgUISecure (clearsaccaction): Clearing data tool state -- %s.\n', saccaction);
        end
        set(findobj('Tag',CFG.CFG_TAGS{2}),'UserData',[]);
        
        % Update title after state change
        CFG.stateTitle = CFG.base;
        cfgUISecure('updateuititle');
    case 'clearilabplot'
        if CFG.debug
            fprintf('cfgUISecure (clearilabplot): Clearing saccade list selections and plotting.\n');
        end        
        curVal = get(findobj('Tag','SaccadeListbox'),'Value');
        set(findobj('Tag','SaccadeListbox'),'Value',[]);
        ilabPlotSaccade;
        set(findobj('Tag','SaccadeListbox'),'Value',curVal);
    case 'updateuititle'
        if CFG.debug
            fprintf('cfgUISecure (updateuititle): Updating UI title -- %s.\n',CFG.stateTitle);
        end
        set(findobj('Tag', CFG.CFG_TAGS{2}),'Name', CFG.stateTitle); % Set UI title
    case 'statecleanup'      
        % Determine data tool state
        state = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
        
        if ~isempty(state)
            if CFG.debug
                fprintf(['cfgUISecure (statecleanup): Current data tool state -- %s\n'], state);
            end
            
            switch state
                case 'addmod'
                    
%                     if 1==0 % For cfg UI table clean-up: half-step routine during table select
%                         cfgUISecure('anyselect'); % Release row select
%                         cfgUISecure('clearuitablecb'); % Clear UI table callbacks, removing self as soon as valid selection occurs
%                         %                         cfgUISecure('clearilabplot'); % Clear current plotting, also clears saccade listbox selection to null
%                         jFrameFig = NaN;
%                     else
                        % Clean-up
                        cfgUISecure('updateilabui'); % Update ILAB UI, Pass only one selected row at a time
                        cfgUISecure('plottoilabmain'); % Plot with selected row
                        cfgUISecure('clearuitableud'); % Keep table UserData clear
                        cfgUISecure('anyselect'); % Release row select
                        cfgUISecure('enableSLSelect'); % Re-enable saccade listbox
                        cfgUISecure('apReturn'); % Assuming apForceOff prior to this function call
                        cfgUISecure('clearsaccaction'); % Free UI from state restrictions
                        cfgUISecure('mainUIOn'); % Re-enable main UI functions
                        cfgIlabJavaInterface('cleanup'); % Clean up persistent variables
                        %                     cfgUISecure('clearilabplot'); % Clear ILAB plotting
                        
                        jFrameFig = ilabGetMainWinHdl;
%                     end
                    
                case 'select'
                    
                    % Clean-up
                    cfgUISecure('apReturn'); % Assuming apForceOff prior to this function call
                    cfgUISecure('clearsaccaction'); % Free UI from state restrictions
                    
                    TBL_TAG = 'SaccadeTable';
                    jFrameFig = findobj('Tag',TBL_TAG);
                    
                case 'clear'
                        % Clean-up
                        cfgUISecure('anyselect'); % Release row select
                        cfgUISecure('clearuitablecb'); % Clear even on JFrame "Cancel"
                        cfgUISecure('clearuitableud'); % Keep table UserData clear
                        cfgUISecure('clearsaccaction'); % Free UI from state restrictions
                        
                        jFrameFig = findobj('Tag',CFG.CFG_TAGS{2});
                        
                case 'plot'
                    
                    cfgUISecure('anyselect'); % Release row select
                    cfgUISecure('clearuitableud'); % Keep table UserData clear
                    cfgUISecure('clearuitablecb'); % Clear UI table callbacks, removing self as soon as valid selection occurs
%                     cfgUISecure('enableSLSelect'); % Re-enable saccade listbox
                    cfgUISecure('apReturn'); % Assuming apForceOff prior to this function call
                    cfgUISecure('clearsaccaction'); % Free UI from state restrictions
                    cfgUISecure('mainUIOn'); % Re-enable main UI functions
                    
                    jFrameFig = findobj('Tag',CFG.CFG_TAGS{2});
                    
                otherwise
                    if CFG.debug
                        fprintf(['cfgUISecure (statecleanup): Unknown data tool state -- %s\n'], state);
                        fprintf(['cfgUISecure (statecleanup): No clean up performed.\n'], state);
                        fprintf(['cfgUISecure (statecleanup): No frame disposal performed.\n'], state);
                    end
            end
            
            jf = findjobj(jFrameFig);
            jf = jf(1); % Top-level component (Matlab figure)
            jFrame = get(jf,'ComponentMovedCallback');
            
            % Remove if an associated jFrame is present
            % Expected empty if user hasn't selected a row for Add/Modify
            if ~isempty(jFrame)
                jFrame = jFrame{2};
                
                if CFG.debug
                    fprintf(['cfgUISecure (statecleanup): JFrame disposal, associated with figure Tag -- %s\n'], get(jFrameFig,'Tag'));
                end
                
                jFrame.setVisible(0);
                jFrame.dispose();
            end
            
        else
            if CFG.debug
                fprintf(['cfgUISecure (statecleanup): Neutral data tool state.\n']);
            end
        end
    otherwise
        if CFG.debug
            fprintf(['cfgUISecure (statecleanup): Unknown action -- %s\n'],action);
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

    function updateIlabUI
        % Expecting only one selected row at a time.
        
        % Determine selected table and row
        uiHIndices = 3:4;
        tbl = ~cellfun(@isempty,get(CFG.handles.hLui(uiHIndices),'UserData'));
        tableTag = get(CFG.handles.hLui(uiHIndices(tbl)),'Tag');
        selRow = get(CFG.handles.hLui(uiHIndices(tbl)),'UserData');
        
        if CFG.debug
            fprintf(['cfgUISecure (updateIlabUI): Selected table -- %s\n'],tableTag);
            fprintf(['cfgUISecure (updateIlabUI): Selected row -- %i\n'],selRow);
        end
        
        if CFG.debug
            fprintf(['cfgUISecure (updateIlabUI): Setting UI trial-related items to -- %i\n'],selRow);
        end
        
        hf = ilabGetMainWinHdl;
        
        if size(selRow,1) == 1 % Ensure only one row
            hc = findobj(hf, 'Tag', 'TrialCurrent');
            set(hc, 'String', num2str(selRow));
            
            hc = findobj(hf, 'Tag', 'TrialSlider');
            set(hc, 'Value', selRow);
        end
        
        hc = findobj(hf, 'Tag', 'TrialList');
        set(hc, 'String', num2str(selRow));
        
        % Set plot parms trial to selected trial
        PP = ilabGetPlotParms; % Use accessor method to update pupil
        PP.trialList = selRow;
        ilabSetPlotParms(PP);
        ilabDrawCoordPlot;
    end

    function plotToIlabMain
        % Expecting only one selected row at a time.
        
        % Determine selected table and row
        uiHIndices = 3:4;
        tbl = ~cellfun(@isempty,get(CFG.handles.hLui(uiHIndices),'UserData'));
        tableTag = get(CFG.handles.hLui(uiHIndices(tbl)),'Tag');
        selRow = get(CFG.handles.hLui(uiHIndices(tbl)),'UserData');
        
        if CFG.debug
            fprintf(['cfgUISecure (plotToIlabMain): Selected table -- %s\n'],tableTag);
            fprintf(['cfgUISecure (plotToIlabMain): Selected row -- %i\n'],selRow);
        end
        
        if CFG.debug
            fprintf(['cfgUISecure (plotToIlabMain): Setting UI trial-related items to -- %i\n'],selRow);
        end
        
        % Initial/final saccade windows
        iWin = [CFG.initial.list(selRow,3) CFG.initial.list(selRow,4)];
        fWin = [CFG.final.list(selRow,3) CFG.final.list(selRow,4)];
        
        % Delay and feedback event timestamps
        it0 = CFG.initial.t0(selRow);
        ft0 = CFG.final.t0(selRow);
        
        if CFG.debug
            fprintf('cfgUISecure (plotToIlabMain): Initial window, %6.0f.\n',iWin);
            fprintf('cfgUISecure (plotToIlabMain): Final window, %6.0f.\n',fWin);
            fprintf('cfgUISecure (plotToIlabMain): Delay event, %6.0f.\n',it0);
            fprintf('cfgUISecure (plotToIlabMain): Feedback event, %6.0f.\n',ft0);
        end
       
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
        
    end

    function forceSLSelect1
        % Force the SaccadeListbox to select the first value (trickPlot
        % modified the list so saccade to plot is first and only value in
        % list).
        if CFG.debug
            fprintf('cfgUISecure (forceSLSelect1): Setting SaccadeListBox ''Value'' selection to 1, and disabling selection.\n');
        end
        hSL = findobj('Tag','SaccadeListbox');
        
         % Saving current UI parameters
        set(hSL,'UserData',get(hSL,'Value'));
        jhSL = findjobj(hSL);
        setappdata(hSL,'VertScrollVal',javaMethodEDT('getValue',jhSL.getComponent(1))); % Vertical scroll bar
        
        % Setting temporary parameters
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
        
        % Restoring UI parameters
        set(hSL,'Value',get(hSL,'UserData')); % Return saved current selection
        set(hSL,'UserData',[]); % Clear UserData
        jhSL = findjobj(hSL);
        javaMethodEDT('setValue',jhSL.getComponent(1),getappdata(hSL,'VertScrollVal')); % Vertical scroll bar
    end

end