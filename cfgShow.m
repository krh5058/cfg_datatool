function cfgShow
% cfgShow.m
% 2/27/14
% Author: Ken Hwang

global CFG

cfgWinHdl = findobj('Tag',CFG.CFG_TAGS{2});

if CFG.importState
    eFlag = 'on';
else
    eFlag = 'off';
end

if isempty(cfgWinHdl)
    cfgWinHdl = figure('Tag', CFG.CFG_TAGS{2},...
        'Name', CFG.stateTitle,...
        'MenuBar', 'none',...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Color', [.95 1 .95], ...
        'CloseRequestFcn',@closeFcn);
    %     Currently, all Children handles are deleted on close
    %     request as long as their visibility remains 'on'
    
    % Set figure size and position
    monitorPos = get(0,'MonitorPositions');
    scrsz = monitorPos(1,:); % First monitor
%     scrsz = get(0,'ScreenSize');
    S = get(gcf, 'Position'); % Position of default figure
    S(2) =   0.15*scrsz(4);      % bottom
    %     S(3) = 1.4*S(3);  % width
    S(3) = scrsz(3); % width
    S(4) = 0.85*scrsz(4);   % height
    set(gcf, 'Position', S);
    
    % Background color
    BgColor1 = [.95 1 .95];
    
    % Menu Items
    m_file = uimenu(cfgWinHdl, 'Label', 'File', 'Tag', CFG.CFG_MTAGS{1}{1});
    uimenu(m_file, 'Label', 'Import trial data', 'Tag', CFG.CFG_MTAGS{1}{2}, 'Callback','cfgParams(''import'');');
    hEx = uimenu(m_file, 'Label', 'Export...', 'Tag', CFG.CFG_MTAGS{1}{3});
    uimenu(hEx, 'Label', 'cfg_datatool saccades', 'Tag', CFG.CFG_MTAGS{1}{4}, 'Callback','cfgParams(''export'',1);','Enable',eFlag);
%     uimenu(hEx, 'Label', 'Original saccades', 'Tag', CFG.CFG_MTAGS{1}{5}, 'Callback','cfgParams(''export'',2);','Enable',eFlag);
%     uimenu(hEx, 'Label', 'All saccades', 'Tag', CFG.CFG_MTAGS{1}{6}, 'Callback','cfgParams(''export'',3);','Enable',eFlag);
    uimenu(hEx, 'Label', 'Open export folder', 'Separator', 'on', 'Tag', CFG.CFG_MTAGS{1}{5}, 'Callback','cfgParams(''export'',2);','Enable',eFlag);
    uimenu(m_file, 'Label', 'Save cfg_datatool workspace', 'Tag', CFG.CFG_MTAGS{1}{6}, 'Callback','cfgParams(''save'');','Enable',eFlag);
    uimenu(m_file, 'Label', 'Load cfg_datatool workspace', 'Tag', CFG.CFG_MTAGS{1}{7}, 'Callback','cfgParams(''load'');');
    uimenu(m_file, 'Label', 'Exit', 'Separator', 'on', 'Tag', CFG.CFG_MTAGS{1}{8}, 'Callback',@closeFcn);
    
    m_edit = uimenu(cfgWinHdl, 'Label', 'Edit', 'Tag', CFG.CFG_MTAGS{2}{1});
    uimenu(m_edit, 'Label', 'Parameters', 'Tag', CFG.CFG_MTAGS{2}{2},'Callback',@showSaccParmUIDisabled,'Enable',eFlag);
    
    m_sacc = uimenu(cfgWinHdl, 'Label', 'Saccade', 'Tag', CFG.CFG_MTAGS{3}{1});
    uimenu(m_sacc, 'Label', 'Select', 'Tag', CFG.CFG_MTAGS{3}{2}, 'Callback','cfgSaccCB(''select'');','Enable',eFlag);
    uimenu(m_sacc, 'Label', 'Add/Modify', 'Tag', CFG.CFG_MTAGS{3}{3},'Callback','cfgSaccCB(''addmod'');','Enable',eFlag);
    uimenu(m_sacc, 'Label', 'Clear', 'Tag', CFG.CFG_MTAGS{3}{4},'Callback','cfgSaccCB(''clear'');','Enable',eFlag);
    
    m_plot = uimenu(cfgWinHdl, 'Label', 'Plot', 'Tag', CFG.CFG_MTAGS{4}{1});
    uimenu(m_plot, 'Label', 'Plot CFG', 'Tag', CFG.CFG_MTAGS{4}{2}, 'Callback','cfgSaccCB(''plot'');','Enable',eFlag);
    
    m_analysis = uimenu(cfgWinHdl, 'Label', 'Analysis', 'Tag', CFG.CFG_MTAGS{5}{1});
    
    m_abt = uimenu(cfgWinHdl, 'Label', 'About', 'Tag', CFG.CFG_MTAGS{6}{1});
    uimenu(m_abt, 'Label', 'Toolbox help', 'Tag', CFG.CFG_MTAGS{6}{2}, 'Callback','');
    uimenu(m_abt, 'Label', 'About cfg_datatool', 'Separator', 'on', 'Tag', CFG.CFG_MTAGS{6}{3}, 'Callback','');
    
    CFG.handles.menu = [m_file m_edit m_sacc m_plot m_analysis m_abt];
    
    % Left side, upper text
    hLp = uipanel('Parent',cfgWinHdl,...
        'Title','General Info',...
        'FontWeight', 'Bold',...
        'BackgroundColor',BgColor1,...
        'Units','normalized','Position',[.01 .8 .49 .2]);
    
    hSubjectText = uicontrol(hLp,'Style','text',...
        'Tag', CFG.CFG_TAGS{3},...
        'Units','normalized','Position',[.01 .7 .9 .2],...
        'HorizontalAlignment', 'left',...
        'BackgroundColor',BgColor1,...
        'String',['Subject: ' CFG.subject]);
    
    hDateText = uicontrol(hLp,'Style','text',...
        'Tag', CFG.CFG_TAGS{4},...
        'Units','normalized','Position',[.01 .5 .9 .2],...
        'HorizontalAlignment', 'left',...
        'BackgroundColor',BgColor1,...
        'String',['Date: ' CFG.date]);

    hTimeText = uicontrol(hLp,'Style','text',...
        'Tag', CFG.CFG_TAGS{5},...
        'Units','normalized','Position',[.01 .3 .9 .2],...
        'HorizontalAlignment', 'left',...
        'BackgroundColor',BgColor1,...
        'String',['Time: ' CFG.time]);
    
    hPathText = uicontrol(hLp,'Style','text',...
        'Tag', CFG.CFG_TAGS{6},...
        'Units','normalized','Position',[.01 .1 .9 .2],...
        'HorizontalAlignment', 'left',...
        'BackgroundColor',BgColor1,...
        'String',['Path: ' CFG.path]);

    CFG.handles.hLp = [hLp hSubjectText hDateText hTimeText hPathText];
    
    % Right side, upper text
    hRp = uipanel('Parent',cfgWinHdl,...
        'Title','Trial Info',...
        'FontWeight', 'Bold',...
        'BackgroundColor',BgColor1,...
        'Units','normalized','Position',[.51 .8 .49 .2]);
    
    hTrialsText = uicontrol(hRp,'Style','text',...
        'Tag', CFG.CFG_TAGS{7},...
        'Units','normalized','Position',[.01 .7 .9 .2],...
        'HorizontalAlignment', 'left',...
        'BackgroundColor',BgColor1,...
        'String',['Number of Trials: ' int2str(CFG.trials)]);
    
    hDropText = uicontrol(hRp,'Style','text',...
        'Tag', CFG.CFG_TAGS{8},...
        'Units','normalized','Position',[.01 .5 .9 .2],...
        'HorizontalAlignment', 'left',...
        'BackgroundColor',BgColor1,...
        'String',['Number of Dropped Trials: ' int2str(length(find(CFG.drop)))]);

    hErrText = uicontrol(hRp,'Style','text',...
        'Tag', CFG.CFG_TAGS{9},...
        'Units','normalized','Position',[.01 .3 .9 .2],...
        'HorizontalAlignment', 'left',...
        'BackgroundColor',BgColor1,...
        'String',['Number of Errored Saccades: ' int2str(length(find(CFG.error)))]);
    
    CFG.handles.hRp = [hRp hTrialsText hDropText hErrText];
    
    % Lower UI items
    hInitialHeader = uicontrol(cfgWinHdl,'Style','text',...
        'Tag', CFG.CFG_TAGS{10},...
        'Units','normalized','Position',[.01 .77 .49 .02],...
        'HorizontalAlignment', 'left',...
        'String','Initial Saccades',...
        'BackgroundColor',BgColor1,...
        'FontWeight', 'bold');
    
    hFinalHeader = uicontrol(cfgWinHdl,'Style','text',...
        'Tag', CFG.CFG_TAGS{11},...
        'Units','normalized','Position',[.51 .77 .49 .02],...
        'HorizontalAlignment', 'left',...
        'String','Final Saccades',...
        'BackgroundColor',BgColor1,...
        'FontWeight', 'bold');

    hInitialTable = uitable(cfgWinHdl,...
        'Tag', CFG.CFG_TAGS{12},...
        'Units','normalized','Position',[.01 .01 .49 .76],...
        'Data', CFG.initial.table,...
        'ColumnName', CFG.cfgHeaders,...
        'ColumnFormat', CFG.cfgFormat,...
        'ColumnEditable', CFG.cfgEditTable,...
        'ColumnWidth',CFG.cfgColWidth,...
        'CellEditCallback',@tableEditCB,...
        'ButtonDownFcn',@uiTblCB,...
        'Enable',eFlag);
    
    hFinalTable = uitable(cfgWinHdl,...
        'Tag', CFG.CFG_TAGS{13},...
        'Units','normalized','Position',[.51 .01 .49 .76],...
        'Data', CFG.final.table,...
        'ColumnName', CFG.cfgHeaders,...
        'ColumnFormat', CFG.cfgFormat,...
        'ColumnEditable', CFG.cfgEditTable,...
        'ColumnWidth',CFG.cfgColWidth,...
        'CellEditCallback',@tableEditCB,...
        'ButtonDownFcn',@uiTblCB,...
        'Enable',eFlag);
    
    CFG.handles.hLui = [hInitialHeader hFinalHeader hInitialTable hFinalTable];
    
else
    if CFG.debug
        fprintf('cfgShow: Refreshing window moving parts.\n');
    end
    
    % 140304--Moving parts are:
    set(findobj('Tag', CFG.CFG_MTAGS{1}{4}),'Enable',eFlag); % Export cfg_datatool saccades
%     set(findobj('Tag', CFG.CFG_MTAGS{1}{5}),'Enable',eFlag); % Export Original saccades
%     set(findobj('Tag', CFG.CFG_MTAGS{1}{6}),'Enable',eFlag); % Export All saccades
    set(findobj('Tag', CFG.CFG_MTAGS{1}{5}),'Enable',eFlag); % Open export folder
    set(findobj('Tag', CFG.CFG_MTAGS{1}{6}),'Enable',eFlag); % Save cfg_datatool workspace
    set(findobj('Tag', CFG.CFG_MTAGS{2}{2}),'Enable',eFlag); % Edit Parameters
    set(findobj('Tag', CFG.CFG_MTAGS{3}{2}),'Enable',eFlag); % Saccade Select
    set(findobj('Tag', CFG.CFG_MTAGS{3}{3}),'Enable',eFlag); % Saccade Add/Modify
    set(findobj('Tag', CFG.CFG_MTAGS{3}{4}),'Enable',eFlag); % Saccade Clear
    set(findobj('Tag', CFG.CFG_MTAGS{4}{2}),'Enable',eFlag); % Plot all
    set(CFG.handles.hLui(3),'Enable',eFlag); % Initial table 
    set(CFG.handles.hLui(4),'Enable',eFlag); % Final table 
    
    % 140131--Moving parts are:
    set(CFG.handles.hRp(3),'String',['Number of Dropped Trials: ' int2str(length(find(CFG.drop)))]);
    set(CFG.handles.hRp(4),'String',['Number of Errored Saccades: ' int2str(length(find(CFG.error)))]);
    set(CFG.handles.hLui(3),'Data', CFG.initial.table);
    set(CFG.handles.hLui(4),'Data', CFG.final.table);
    
end

figure(cfgWinHdl);

    function tableEditCB(src,evt)
        if CFG.debug
            fprintf('cfgShow (tableEditCB): Table edit from %s handle tag.\n',get(src,'Tag'));
            fprintf('cfgShow (tableEditCB): Column -- %s.\n', CFG.cfgHeaders{evt.Indices(2)});
            fprintf('cfgShow (tableEditCB): Row -- %i.\n', evt.Indices(1));
            fprintf('cfgShow (tableEditCB): New data of class %s is now %i.\n',class(evt.NewData),evt.NewData);
        end
        
        cfgParams('set',get(src,'Tag'),CFG.cfgHeaders{evt.Indices(2)},evt.Indices(1),evt.NewData); % Drop/Error vectors
        cfgShow;
    end

    function uiTblCB(src,evt) % Possibly for future context menus
        %         dblclick = get(get(src,'Parent'),'SelectionType');
        %         fprintf('cfgShow (uiTblCB) -- Selected Saccade: \n');
        %         coord = get(get(src,'Parent'),'CurrentPoint');
        %         fprintf('cfgShow (uiTblCB) -- Selected coordinates: %3.1f %3.1f \n', coord(1), coord(2));
        %
        %
        %         jscroll = findjobj(src);
        %         jtable = jscroll.getViewport.getView;
        %         view = get(jscroll.getComponent(0).getView.getModel);
    end

    function showSaccParmUIDisabled(src,evt)
        ilabCalcSaccadeCB('init');
        spuiHandle = findobj('Tag','SACCADE_UI');
        
        % Disable all children except cancel
        spuiChildren = get(spuiHandle,'Children');
        for spuiIter = 1:length(spuiChildren)
            if strcmp(get(spuiChildren(spuiIter),'Callback'),'ilabCalcSaccadeCB(''Cancel'')')
            else
                set(spuiChildren(spuiIter),'Enable','off')
            end
        end 
    end

    function closeFcn(src,evt)
                   
        % User prompt
        exitResponse = questdlg('Are you sure you want to exit?', ...
        'Close cfg_datatool', ...
            'Yes','No','No');
        
        if strcmpi(exitResponse,'No')
            return;
        end
        
        % Remove RangeSlider
        set(findobj('Tag','cfgSlider'),'Visible','off');
        delete(findobj('Tag','cfgSlider'))
        
        % Remove cfg_datatool UIMenu handle from ILAB 'Window' menu
        cfgWinMenuHdl = findobj('Tag',CFG.CFG_TAGS{1});
        if ~isempty(cfgWinMenuHdl)
            delete(findobj('Tag', CFG.CFG_TAGS{1}))
        end
        
        cfgUISecure('statecleanup'); % Clean up UI functions based on state
        delete(get(findobj('Tag', CFG.CFG_TAGS{2}),'Children')); % Delete all cfg_datatool children
        delete(findobj('Tag', CFG.CFG_TAGS{2})); % Delete cfg_datatool
        
        cfgParams('exit'); % Clear global values     
        
    end

end