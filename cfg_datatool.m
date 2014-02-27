% cfg_datatool.m
% 2/27/14
% Author: Ken Hwang

global CFG

if isfield(CFG,'tbactive')
    if CFG.tbactive
        if CFG.debug
            fprintf('cfg_datatool: Toolbox already active.');
        end
        return;
    end
end

% ILAB = ilabGetILAB;
AP = ilabGetAnalysisParms;
% PP = ilabGetPlotParms;

if isempty(AP.saccade.list) | isempty(AP.saccade.table)
    h = warndlg(['Please generate saccade table first (Analysis > Saccades...).'],'cfg_datatool WARNING');
    uiwait(h);
    return;
end

% Initialize Global Parameters
cfgParams('init');

% Add RangeSlider, but make invisible
cfgRangeSlider;
set(findobj('Tag','cfgSlider'),'Visible','off');

% took out plotParms.XYPLOT_TAG; plotParms.PUPILPLOT_TAG
% AXES_TAGS = {PP.PCA_TAG; PP.IMG_TAG; PP.CPA_TAG; PP.APA_TAG; 'annotAx'; 'APATMP'};

% Deleting the frame will delete all contained uicontrols. Since 
% the uicontrols are redrawn anyway, might as well keep things tidy.
% ------------------------------------------------------------------
% UI_TAGS = 'MainWinCtls';

% MENU_TAGS = {'ROIEDIT_MTAG'; 'FIX_MTAG'; 'SACCADE_MTAG'; 'GAZE_MTAG';...
%         'BLINK_MTAG'; 'FILTER_MTAG'; 'PROP_MTAG'; 'SEGCOLORS_MTAG';...
%         'ROI_MTAG'; 'DATA2BASEWS_MTAG'; 'RESULTS2BASEWS_MTAG'; 'TBL2EXCEL_MTAG'};
% ANALYSIS_MTAG = 'ANALYSIS_MTAG';
% SACCADE_MTAG = 'SACCADE_MTAG';
% SACCADEWIN_MTAG = 'SACCADEWIN_MTAG';

cfgWinMenuHdl = findobj('Tag',CFG.CFG_TAGS{1});

if isempty(cfgWinMenuHdl)
    f = findobj('Tag','WINDOWS_MTAG');
    uimenu(f, 'Label', 'cfg_datatool',   'Enable', 'on',...
        'Tag', CFG.CFG_TAGS{1}, 'Callback','cfgShow');
end

cfgShow;

% [W H] = ilabGetILABCoord;    
    
% ILAB_AR = W/H; % This aspect ratio (i.e., 640 x 480) is true for almost all resolutions

% Given that coordinate system can now change this cannot be
% preset any other way.

% f = ilabGetMainWinHdl;
% if length(f) > 1
%     % just close all but the first one
%     delete(f(2:end))
%     f = f(1);
% end
% figure(f);
% 
% fRect   = get(gcf, 'Position');   % Result is in pixels
% FIG_WID = fRect(3);
% FIG_HT  = fRect(4);
% FIG_AR  = FIG_WID/FIG_HT;  % Figure Aspect Ratio
% 
% TBL_TAG = 'SaccadeTable';
% LB_TAG = 'SaccadeListbox';
% h = findobj('Tag', TBL_TAG);
% figure(h);
% mItem= uimenu(h, 'Label', 'cfg_datatool',     'Tag', 'CFG_MTAG');
% uimenu(mItem, 'Label', 'Add Saccade','Tag','ASACC_MTAG');
% uimenu(mItem, 'Label', 'Modify Saccade','Tag','MSACC_MTAG','Callback','cfgModifyCB');
% uimenu(mItem, 'Label', 'Export Initial Saccade','Tag','EISACC_MTAG','Separator', 'on');
% uimenu(mItem, 'Label', 'Export Final Saccade','Tag','AFSACC_MTAG');

% % Get the saccade listbox
% hSL = findobj('Tag',LB_TAG);
% 
% % Get the selected lines
% valSL = get(hSL,'Value');

% uimenu(m, 'Label', 'Print...', 'Callback','ilabPrintCB',...
%     'Separator', 'on','Tag','PRINT_MTAG', 'Accelerator', 'P');

% uimenu(m, 'Label', 'Convert File...','Callback','ilabConvertCB');

% scrsz = get(0,'ScreenSize');
% S = get(gcf, 'Position');
% S(2) =   0.1*scrsz(4);      % bottom
% S(3) = 1.5*S(3);  % width
% S(4) = 0.80*scrsz(4);   % height
% set(gcf, 'Position', S);

% uimenu(m, 'Label', 'Saccades...',   'Enable', 'off',...
%     'Tag', 'SACCADE_MTAG', 'Callback','ilabCalcSaccadeCB');

% LM = .05*.012;
% BM = .01;
% WID = .25;
% HT = .99 * .65;
% PCARect = [LM BM WID HT];

% BgColor = [.8 .9 .8];
% BgColor = [.95 1 .95];

% R = [LM+.05*WID .8*HT-.08 .9*WID .08];
% 
% ht = .04;

% R(2) = R(2) - ht;
% R(3) = .45 *WID;
% R(4) = ht;
% 
% R = get(findobj('tag','ShowSegmentsBox'),'Position');
% 
% R(2) = R(2) - (1.5*ht);
% 
% h1 = uicontrol(gcf,'Style','text',...
%     'Units','normalized',...
%     'Position',R,...
%     'BackgroundColor',BgColor,...
%     'HorizontalAlignment', 'Center',...
%     'FontWeight', 'Bold',...
%     'String','cfg_datatool',...
%     'Tag','cfgText');
% 
% R(2) = R(2) - (.5*ht);
% 
% h2 = uicontrol(gcf,'Style','pushbutton',...
%     'Units','normalized',...
%     'Position',R,...
%     'HorizontalAlignment','center',...
%     'String','Add Initial Saccade',...
%     'tooltipstring','Press to define an initial saccade.',...
%     'Tag','cfgAdd');
% 
% R(2) = R(2) - ht;
% 
% h3 = uicontrol(gcf,'Style','checkbox',...
%     'Units','normalized',...
%     'Position',R,...
%     'BackgroundColor',BgColor,...
%     'String','Drop',...
%     'HorizontalAlignment', 'Left',...
%     'Value', 0,...
%     'tooltipstring','Mark trial as dropped.',...
%     'Tag', 'cfgDrop');
% 
% R(2) = R(2) - ht;
% 
% h4 = uicontrol(gcf,'Style','checkbox',...
%     'Units','normalized',...
%     'Position',R,...
%     'BackgroundColor',BgColor,...
%     'String','Error',...
%     'HorizontalAlignment', 'Left',...
%     'Value', 0,...
%     'tooltipstring','Mark trial as error.',...
%     'Tag', 'cfgError');
% 
% MultiSlider;