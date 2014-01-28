function CFG = cfgParams(action, varargin)

global CFG

if strcmpi(action, 'init')
    disp('cfgInit: Initializing global parameters');
    CFG.tbactive = true;
    CFG.debug = 1;
    
    ILAB = ilabGetILAB;
    
    CFG.CFG_TAGS = {'ILABWIN_CFGMTAG','CFGWIN_TAG',... % 1-2 (General)
        'CFGWIN_SUBJTEXT','CFGWIN_DATETEXT','CFGWIN_TIMETEXT','CFGWIN_PATHTEXT',... % 3-6 (UpperLeft)
        'CFGWIN_TRIALSTEXT','CFGWIN_DROPTEXT','CFGWIN_ERRTEXT',... % 7-9 (UpperRight)
        'CFGWIN_INITHEAD','CFGWIN_FINHEAD',... % 10-11 (Headers)
        'CFGWIN_INITLB','CFGWIN_FINLB'}; % 12-13 (LBs)
    CFG.CFG_MTAGS = cell([1 6]);
    CFG.CFG_MTAGS{1} = {'CFGMENU_FILE', 'CFGMENU_IMPORT', 'CFGMENU_EXPORTLABEL', 'CFGMENU_EXCFG', 'CFGMENU_EXORIG', 'CFGMENU_EXALL', 'CFGMENU_EXAUTOPARAM', 'CFGMENU_SAVE', 'CFGMENU_LOAD', 'CFGMENU_EXIT'}; % 1, 1-10
    CFG.CFG_MTAGS{2} = {'CFGMENU_EDIT', 'CFGMENU_EDITPARAMS'}; % 2, 1-2
    CFG.CFG_MTAGS{3} = {'CFGMENU_SACC', 'CFGMENU_SELECTSACC', 'CFGMENU_ADDSACC', 'CFGMENU_MODIFYSACC', 'CFGMENU_DROPSACC', 'CFGMENU_ERRSACC'}; % 3, 1-6
    CFG.CFG_MTAGS{4} = {'CFGMENU_PLOT', 'CFGMENU_PLOTALL'}; % 4, 1-2
    CFG.CFG_MTAGS{5} = {'CFGMENU_ANALYSIS'}; % 5, 1
    CFG.CFG_MTAGS{6} = {'CFGMENU_ABT', 'CFGMENU_TBHELP', 'CFGMENU_ABTAUTH'}; % 6, 1-3
    CFG.trials = ILAB.trials;
    CFG.acqIntvl = ILAB.acqIntvl;
    CFG.trialCodes = ILAB.trialCodes;
    CFG.coordSys = ILAB.coordSys;
    CFG.subject = ILAB.subject;
    CFG.date = ILAB.date;
    CFG.time = ILAB.time;
    CFG.path = ILAB.path;
    CFG.headers = {'Trial', 'Start Code', 'Target Code', 'Trial Type', 'Start (ms)', 'End (ms)', 'peak vel', 'mean vel', 'time-to-peak (ms)', 'latency (ms)', 'distance'};
    CFG.tTitle = str2mat(['Trial Sacc#  Start   End     vPeak    vMean    SRT   ttPeak  dist  %Zero'],...
        [blanks(14) ' ms     ms    deg/sec   deg/sec   ms     ms']);
    CFG.fmtStr = '%4d  %4d   %6.0f  %6.0f     %5.1f    %5.1f   %6.0f   %6.0f   %5.1f %4.0f';
    
    CFG.initial.list = NaN([CFG.trials 10]);
    CFG.initial.table = cell(CFG.trials,1);
    
    CFG.final.list = NaN([CFG.trials 10]);
    CFG.final.table = cell(CFG.trials,1);
    
    for n = 1:CFG.trials
        CFG.initial.table{n,1} = sprintf(CFG.fmtStr, CFG.initial.list(n,:));
        CFG.final.table{n,1} = sprintf(CFG.fmtStr, CFG.final.list(n,:));
    end
    
    CFG.drop = zeros([CFG.trials 1]);
    CFG.err = zeros([CFG.trials 1]);
    
elseif strcmpi(action, 'get')
    
    if CFG.debug
        disp('cfg_datatool Debug: CFG Params requested.');
    end
    
elseif strcmpi(action, 'set')
    
%     for i = 1:length(varargin)
%         varargin
%     end
    
    if CFG.debug
%         disp('cfg_datatool Debug: CFG Params requested.');
    end
    
elseif strcmpi(action,'reset')
    
    clear global CFG
    
%     if CFG.debug
%         disp('cfg_datatool Debug: CFG Params requested.');
%     end
    
else
    error('cfgParams: Unrecognized action.');
end

end