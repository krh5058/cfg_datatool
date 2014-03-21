function cfg_datatool
% cfg_datatool.m
% 3/12/14
% Author: Ken Hwang

global CFG

% Restrict re-initialization of cfg_datatool
if isfield(CFG,'tbactive')
    if CFG.tbactive
        if CFG.debug
            fprintf('cfg_datatool: Toolbox already active.\n');
        end
        h = warndlg('Toolbox in use.','cfg_datatool WARNING');
        uiwait(h);
        cfgShow;
        return;
    end
end

%% Everything beneath, runs only on start-up
ILAB = ilabGetILAB; % Keep accessor function
AP = ilabGetAnalysisParms; % Keep accessor function
PP = ilabGetPlotParms; % Keep accessor function

if isempty(AP.saccade.list) || isempty(AP.saccade.table)
    h = warndlg(['Please generate saccade table first (Analysis > Saccades...).'],'cfg_datatool WARNING');
    uiwait(h);
    return;
end

% Back-ups
CFG.ILAB = ILAB;
CFG.AP = AP;
CFG.PP = PP;

% Initialize Global Parameters
cfgParams('init');

% Add RangeSlider, but not visible
cfgRangeSlider;
set(findobj('Tag','cfgSlider'),'Visible','off');

% Find current cfg_datatool UIMenu handle from ILAB 'Window' menu
cfgWinMenuHdl = findobj('Tag',CFG.CFG_TAGS{1});

% If empty (most likely), apply to "Windows" UImenu on ILAB main window
if isempty(cfgWinMenuHdl)
    f = findobj('Tag','WINDOWS_MTAG');
    uimenu(f, 'Label', 'cfg_datatool',   'Enable', 'on',...
        'Tag', CFG.CFG_TAGS{1}, 'Callback','cfgShow');
end

% Display is default cfgShow call (moving parts only)
cfgShow;
end