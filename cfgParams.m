function CFG = cfgParams(action, varargin)

global CFG

if strcmpi(action, 'init')
    disp('cfgInit: Initializing global parameters');
    CFG.tbactive = true;
    CFG.debug = 1;
    
    ILAB = ilabGetILAB;
    
    CFG.CFG_TAGS = {'ILABWIN_CFGMTAG','CFGWIN_TAG',... % 1-2
        'CFGMENU_FILE','CFGMENU_EDIT','CFGMENU_SACC','CFGMENU_PLOT','CFGMENU_ANALYSIS','CFGMENU_ABT',... % 3-8
        'CFGWIN_SUBJTEXT','CFGWIN_DATETEXT','CFGWIN_TIMETEXT','CFGWIN_PATHTEXT',... % 9-12
        'CFGWIN_TRIALSTEXT','CFGWIN_DROPTEXT','CFGWIN_ERRTEXT',... % 13-15
        'CFGWIN_INITHEAD','CFGWIN_FINHEAD',... % 16-17
        'CFGWIN_INITLB','CFGWIN_FINLB'}; % 18-19
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