function CFG = cfgParams(action, varargin)
% cfgParams.m
% 2/27/14
% Author: Ken Hwang

global CFG

if strcmpi(action, 'init')
    disp('cfgParams: Initializing global parameters');
    
    % Toolbox general
    CFG.tbactive = true;
    CFG.debug = 1;
    
    ILAB = ilabGetILAB;
    
    % Tag strings
    CFG.CFG_TAGS = {'ILABWIN_CFGMTAG','CFGWIN_TAG',... % 1-2 (General)
        'CFGWIN_SUBJTEXT','CFGWIN_DATETEXT','CFGWIN_TIMETEXT','CFGWIN_PATHTEXT',... % 3-6 (UpperLeft)
        'CFGWIN_TRIALSTEXT','CFGWIN_DROPTEXT','CFGWIN_ERRTEXT',... % 7-9 (UpperRight)
        'CFGWIN_INITTXT','CFGWIN_FINTXT',... % 10-11 (Table Text)
        'CFGWIN_INITTBL','CFGWIN_FINTBL'}; % 12-13 (Tables)
%         'CFGWIN_INITHEAD','CFGWIN_FINHEAD',... % 10-11 (Headers)
%         'CFGWIN_INITLB','CFGWIN_FINLB'}; % 12-13 (LBs)
    CFG.CFG_MTAGS = cell([1 6]);
    CFG.CFG_MTAGS{1} = {'CFGMENU_FILE', 'CFGMENU_IMPORT', 'CFGMENU_EXPORTLABEL', 'CFGMENU_EXCFG', 'CFGMENU_EXORIG', 'CFGMENU_EXALL', 'CFGMENU_EXAUTOPARAM', 'CFGMENU_SAVE', 'CFGMENU_LOAD', 'CFGMENU_EXIT'}; % 1, 1-10
    CFG.CFG_MTAGS{2} = {'CFGMENU_EDIT', 'CFGMENU_EDITPARAMS'}; % 2, 1-2
    CFG.CFG_MTAGS{3} = {'CFGMENU_SACC', 'CFGMENU_SELECTSACC', 'CFGMENU_ADDSACC', 'CFGMENU_MODIFYSACC', 'CFGMENU_DROPSACC', 'CFGMENU_ERRSACC'}; % 3, 1-6
    CFG.CFG_MTAGS{4} = {'CFGMENU_PLOT', 'CFGMENU_PLOTALL'}; % 4, 1-2
    CFG.CFG_MTAGS{5} = {'CFGMENU_ANALYSIS'}; % 5, 1
    CFG.CFG_MTAGS{6} = {'CFGMENU_ABT', 'CFGMENU_TBHELP', 'CFGMENU_ABTAUTH'}; % 6, 1-3
    
    % Experiment general
    CFG.trials = ILAB.trials;
    CFG.acqIntvl = ILAB.acqIntvl;
    CFG.trialCodes = ILAB.trialCodes;
    CFG.coordSys = ILAB.coordSys;
    CFG.subject = ILAB.subject;
    CFG.date = ILAB.date;
    CFG.time = ILAB.time;
    CFG.path = ILAB.path;
    
    % Experiment loaded
    CFG.targetCodeVector = NaN([CFG.trials 1]);
    CFG.trialTypeVector = cell([CFG.trials 1]);
    CFG.initial.t0 = NaN([CFG.trials 1]);
    CFG.initial.latency = NaN([CFG.trials 1]);
    CFG.final.t0 = NaN([CFG.trials 1]);
    CFG.final.latency = NaN([CFG.trials 1]);
    CFG.trialXPosVector = NaN([CFG.trials 1]);
    CFG.distVector = NaN([CFG.trials 1]);
    
    % Table info
    CFG.cfgHeaders = {'Start Code', 'Target Code', 'Trial Type', 'Start (ms)', 'End (ms)', 'Peak vel (deg/s)', 'Mean vel (deg/s)', 'SRT (ms)', 'Time-to-peak (ms)', 'Latency (ms)', 'Distance', 'Drop', 'Error'};
    CFG.cfgFormat = {'numeric','numeric','char','bank','bank','numeric','numeric','bank','bank','numeric','numeric','logical','logical'};
    CFG.cfgEditTable = [false false false false false false false false false false false true true];
    CFG.cfgInitEmpty = {NaN,NaN,'',NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,false,false};
    CFG.cfgColWidth = {45 60 'auto' 54 54 65 65 56 80 66 55 35 35};
    
    % Old saccade info
    CFG.ILABtTitle = str2mat(['Trial Sacc#  Start   End     vPeak    vMean    SRT   ttPeak  dist  %Zero'],...
        [blanks(14) ' ms     ms    deg/sec   deg/sec   ms     ms']);
    CFG.ILABfmtStr = '%4d  %4d   %6.0f  %6.0f     %5.1f    %5.1f   %6.0f   %6.0f   %5.1f %4.0f';
    
    % Initialize data storage
    CFG.initial.list = NaN([CFG.trials 10]);
    CFG.initial.table = cell(CFG.trials,length(CFG.cfgHeaders));
    CFG.final.list = NaN([CFG.trials 10]);
    CFG.final.table = cell(CFG.trials,length(CFG.cfgHeaders));
    
    for n = 1:CFG.trials
        CFG.initial.table(n,:) = CFG.cfgInitEmpty;
        CFG.final.table(n,:) = CFG.cfgInitEmpty;
    end
    
    CFG.drop = false([CFG.trials 1]);
    CFG.error = false([CFG.trials 1]);
    
elseif strcmpi(action, 'get')
    
    if CFG.debug
        fprintf('cfgParams: CFG parameter requested.\n');
    end
    
elseif strcmpi(action, 'set')
    if CFG.debug
        fprintf('cfgParams: CFG parameter set request.\n');
    end
    
    if any(strcmpi(varargin{1},{'Drop','Error'}))
        CFG=setfield(CFG,lower(varargin{1}),{varargin{2}},varargin{3});
        CFG.initial.table{varargin{2},strcmp(CFG.cfgHeaders,varargin{1})} = varargin{3}; % Sync tables
        CFG.final.table{varargin{2},strcmp(CFG.cfgHeaders,varargin{1})} = varargin{3}; % Sync tables, **Un-sync error
    end
    
elseif strcmpi(action, 'setsacc')
    if CFG.debug
        fprintf('cfgParams: CFG saccade value set request.\n');
        fprintf('cfgParams: %s saccade, at index %i , changed.\n', varargin{1},varargin{2});
    end
    
    CFG.(lower(varargin{1})).list(varargin{2},:) = varargin{3}; % Update list
    CFG.(lower(varargin{1})).table{varargin{2},1} = CFG.trialCodes.start; % Start code, Assuming only one type of start code
    CFG.(lower(varargin{1})).table{varargin{2},2} = CFG.targetCodeVector(varargin{2}); % Trial code, uncalculated
    CFG.(lower(varargin{1})).table{varargin{2},3} = CFG.trialTypeVector{varargin{2}}; % Trial Type, uncalculated
    CFG.(lower(varargin{1})).table{varargin{2},4} = varargin{3}(3); % Start (ms)
    CFG.(lower(varargin{1})).table{varargin{2},5} = varargin{3}(4); % End (ms)
    CFG.(lower(varargin{1})).table{varargin{2},6} = varargin{3}(5); % Peak vel (deg/s)
    CFG.(lower(varargin{1})).table{varargin{2},7} = varargin{3}(6); % Mean vel (deg/s)
    CFG.(lower(varargin{1})).table{varargin{2},8} = varargin{3}(7); % SRT (ms)
    CFG.(lower(varargin{1})).table{varargin{2},9} = varargin{3}(8); % Time-to-peak (ms)
%     CFG.(lower(varargin{1})).table{varargin{2},10} = varargin{3}(9); % Distance travelled (ms)
    CFG.(lower(varargin{1})).table{varargin{2},10} = CFG.(lower(varargin{1})).latency(varargin{2}); % Latency, uncalculated ** Will remove
    CFG.(lower(varargin{1})).table{varargin{2},11} = CFG.distVector(varargin{2}); % Distance from target ** Adjust in header, table, and data structure
    
elseif strcmpi(action,'reset')
    if CFG.debug
        disp('cfgParams: CFG parameter reset requested.');
    end
    
    clear global CFG
    
    cfgParams('init');
    
else
    error('cfgParams: Unrecognized action.');
end

end