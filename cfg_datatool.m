% cfg_datatool.m
% 2/27/14
% Author: Ken Hwang

global CFG

% Restrict re-initialization of cfg_datatool
if isfield(CFG,'tbactive')
    if CFG.tbactive
        if CFG.debug
            fprintf('cfg_datatool: Toolbox already active.');
        end
        return;
    end
end

% ILAB = ilabGetILAB;
AP = ilabGetAnalysisParms; % Original AP
% PP = ilabGetPlotParms;

if isempty(AP.saccade.list) || isempty(AP.saccade.table)
    h = warndlg(['Please generate saccade table first (Analysis > Saccades...).'],'cfg_datatool WARNING');
    uiwait(h);
    return;
end

% Initialize Global Parameters
cfgParams('init');

% Add RangeSlider, but make invisible
cfgRangeSlider;
set(findobj('Tag','cfgSlider'),'Visible','off');

% Find current UIMenu handle on ILAB main window
cfgWinMenuHdl = findobj('Tag',CFG.CFG_TAGS{1});

% If empty (most likely), apply to "Windows" UImenu on ILAB main window
if isempty(cfgWinMenuHdl)
    f = findobj('Tag','WINDOWS_MTAG');
    uimenu(f, 'Label', 'cfg_datatool',   'Enable', 'on',...
        'Tag', CFG.CFG_TAGS{1}, 'Callback','cfgShow'); % Callback is 
end

% Display is default cfgShow call (moving parts only)
cfgShow;