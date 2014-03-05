function CFG = cfgParams(action, varargin)
% cfgParams.m
% 2/27/14
% Author: Ken Hwang

global CFG

if ~isempty(CFG)
    if CFG.debug
        fprintf('cfgParams: Received request --- %s.\n',action);
    end
end

if strcmpi(action, 'init')
    fprintf('cfgParams(init): Initializing global parameters.\n');
    
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
    CFG.CFG_MTAGS{3} = {'CFGMENU_SACC', 'CFGMENU_SELECTSACC', 'CFGMENU_ADDMODSACC', 'CFGMENU_CLEARSACC'}; % 3, 1-4
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
    
    % Experiment imported
    CFG.importState = false;
    CFG.inputHead = {'Trial','Trial Type','Target Code','Delay','Saccade','TargetX'};
    CFG.targetCodeVector = NaN([CFG.trials 1]);
    CFG.trialTypeVector = cell([CFG.trials 1]);
    CFG.initial.t0 = NaN([CFG.trials 1]);
    CFG.final.t0 = NaN([CFG.trials 1]);
    CFG.trialXPosVector = NaN([CFG.trials 1]);
    
    % Table info
    CFG.cfgHeaders = {'Start Code', 'Target Code', 'Trial Type', 'Start (ms)', 'End (ms)', 'Peak vel (deg/s)', 'Mean vel (deg/s)', 'SRT (ms)', 'Time-to-peak (ms)', 'DistTrav (deg)', 'DistTarg (deg)', 'Drop', 'Error'};
    CFG.cfgFormat = {'numeric','numeric','char','bank','bank','numeric','numeric','bank','bank','numeric','numeric','logical','logical'};
    CFG.cfgEditTable = [false false false false false false false false false false false true true];
    CFG.cfgInitEmpty = {NaN,NaN,'',NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,false,false};
    CFG.cfgColWidth = {45 60 'auto' 54 54 65 65 56 80 66 66 35 35};
    
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
    
    CFG.drop = false([CFG.trials 1]); % Synced
    CFG.error = false([CFG.trials 2]); % Not synced (1=initial, 2=final)
    
elseif strcmpi(action, 'load')
    
    if CFG.debug
        fprintf('cfgParams(load): Loading old CFG parameters.\n');
    end    
    
elseif strcmpi(action, 'save')
    
    if CFG.debug
        fprintf('cfgParams(save): Saving new CFG parameters.\n');
    end   
    
elseif strcmpi(action, 'import')
    
    if CFG.debug
        fprintf('cfgParams(import): Importing CFG experimental data.\n');
    end
    
    [f,p] = uigetfile('*.xlsx');
    
    if isequal(f,0) || isequal(p,0)
        if CFG.debug
            fprintf('cfgParams (import): Action ''uigetfile'' cancelled.\n');
        end
        return;
    end
    
    try
        [num,txt] = xlsread([p f]);
        
        if CFG.debug
            fprintf('cfgParams (import): File read complete... %s.\n',[p f]);
        end
        
        % File quality checks
        
        % Header check
        for i = 1:size(txt,2)
            if ~strcmp(txt{1,i},CFG.inputHead{i})
                warning('cfg_datatool:HeaderDifference','Expected input header, %s, in column %i read as -- %s.',CFG.inputHead{i},i,txt{i,1});
            end
        end
        
        txt = txt(2:end,:); % Trim headers
        % Trial number check
        if ~all(num(:,1)==(1:CFG.trials)')
            warning('cfg_datatool:TrialNumDifference','Expected trials %i to %i. Trial numbers in data column %i does not match.',1,CFG.trials,1);
        end
        % xlsread() text and numeric data size check
        if ~all(size(txt) == size(num));
            warning('cfg_datatool:SizeDifference','Numeric data fields size (%i-by-%i) does not match Text data fields size (%i-by-%i).',size(num,1),size(num,2),size(txt,1),size(txt,2));
        end
        
        % Text entry check (txt)
        chkEmpty = cellfun(@isempty,txt);
        byColChk = all(chkEmpty(:,[1 3:end])); % 1, 3, 4, 5, 6
        if ~all(byColChk)
            chkColInd = find(~byColChk); % 1, 3, 4, 5, 6
            for i = chkColInd
                if i~=1
                    c = i+1;
                else
                    c = 1;
                end
                for j = 1:size(txt,1)
                    if ~isempty(txt{j,c})
                        warning('cfg_datatool:TxtFieldNotEmpty','Expected empty text data field at row %i, column %i, found not empty: %s.',j,c,txt{j,c});
                        if isnan(num(j,c))
                            fprintf('cfgParams (import): Corresponding numeric data entry at row %i, column %i, found empty.\n',j,c);
                        end
                    end
                end
            end
        end
        
        % Numeric entry check (num(:,2))
        chkEmpty = isnan(num(:,2));
        if ~all(chkEmpty)
            chkRowInd = find(~chkEmpty);
            for i = chkRowInd
                warning('cfg_datatool:NumFieldNotNaN','Expected empty numeric data field at row %i, column %i, found not empty: %d.',i,2,num(i,2));
                if isempty(txt{i,2})
                    fprintf('cfgParams (import): Corresponding text data entry at row %i, column %i, found empty.\n',i,2);
                end
            end
        end
        
        % Splice data
        dat = num2cell(num);
        dat(:,2) = txt(:,2);
        
        % Save data
        CFG.importedData = dat;
        CFG.trialTypeVector = CFG.importedData(:,2);
        CFG.targetCodeVector = cell2mat(CFG.importedData(:,3));
        CFG.initial.t0 = cell2mat(CFG.importedData(:,4));
        CFG.final.t0 = cell2mat(CFG.importedData(:,5));
        CFG.trialXPosVector = cell2mat(CFG.importedData(:,6));
        
        % Refresh UI
        CFG.importState = true;
        cfgShow;
        
    catch ME
        throw(ME);
    end
    
elseif strcmpi(action, 'get')
    
    if CFG.debug
        fprintf('cfgParams(get): CFG parameters requested.\n');
    end
    
elseif strcmpi(action, 'set')
    if CFG.debug
        fprintf('cfgParams(set): Setting CFG parameter --- %s.\n',varargin{2});
    end
    
    % On drop
    if strcmpi(varargin{2},'Drop')
        CFG.drop(varargin{3}) = varargin{4}; % Record in drop vector
        CFG.initial.table{varargin{3},strcmp(CFG.cfgHeaders,varargin{2})} = varargin{4}; % Sync initial table
        CFG.final.table{varargin{3},strcmp(CFG.cfgHeaders,varargin{2})} = varargin{4}; % Sync final table
    elseif strcmpi(varargin{2},'Error')
        switch varargin{1}
            case CFG.CFG_TAGS{12}
                saccif = 1;
                CFG.initial.table{varargin{3},strcmp(CFG.cfgHeaders,varargin{2})} = varargin{4}; % Sync initial table
            case CFG.CFG_TAGS{13}
                saccif = 2;
                CFG.final.table{varargin{3},strcmp(CFG.cfgHeaders,varargin{2})} = varargin{4}; % Sync final table
        end
        CFG.error(varargin{3},saccif) = varargin{4}; % Record either in error vector
    end
    
elseif strcmpi(action, 'setsacc')
    if CFG.debug
        fprintf('cfgParams(setsacc): CFG saccade value set request.\n');
        fprintf('cfgParams(setsacc): %s saccade, at index %i , changed.\n', varargin{1},varargin{2});
    end
    
    saccin = varargin{3};
    
    [sRT,ttP,dtT] = cfgExpCalc(varargin{1},varargin{2},saccin(3),saccin(4));
    
    % Re-evaluated for list
    saccin(7) = sRT;
    saccin(8) = ttP;
    
    CFG.(lower(varargin{1})).list(varargin{2},:) = saccin; % Update list
    
    CFG.(lower(varargin{1})).table{varargin{2},1} = CFG.trialCodes.start; % Start code, Assuming only one type of start code
    CFG.(lower(varargin{1})).table{varargin{2},2} = CFG.targetCodeVector(varargin{2}); % Trial code, uncalculated
    CFG.(lower(varargin{1})).table{varargin{2},3} = CFG.trialTypeVector{varargin{2}}; % Trial Type, uncalculated
    CFG.(lower(varargin{1})).table{varargin{2},4} = varargin{3}(3)*CFG.acqIntvl; % Start (ms)
    CFG.(lower(varargin{1})).table{varargin{2},5} = varargin{3}(4)*CFG.acqIntvl; % End (ms)
    CFG.(lower(varargin{1})).table{varargin{2},6} = varargin{3}(5); % Peak vel (deg/s)
    CFG.(lower(varargin{1})).table{varargin{2},7} = varargin{3}(6); % Mean vel (deg/s)
    CFG.(lower(varargin{1})).table{varargin{2},8} = saccin(7); % SRT (ms)
    CFG.(lower(varargin{1})).table{varargin{2},9} = saccin(8); % Time-to-peak (ms)
    CFG.(lower(varargin{1})).table{varargin{2},10} = varargin{3}(9); % Distance travelled (ms)
    CFG.(lower(varargin{1})).table{varargin{2},11} = dtT; % Distance from target (pix)
    
    %     CFG.(lower(varargin{1})).table{varargin{2},10} = CFG.(lower(varargin{1})).latency(varargin{2}); % Latency, Deprecated
              
elseif strcmpi(action,'reset')
    if CFG.debug
        fprintf('cfgParams(reset): CFG parameter reset requested.\n');
    end
    
    clear global CFG
    
    cfgParams('init');
    
else
    error('cfgParams: Unrecognized action.');
end

    function [sRT,ttP,dtT] = cfgExpCalc(saccIF,nTrial,sIndex,eIndex)
        if CFG.debug
            fprintf('cfgParams(cfgExpCalc): Nested function called for additional saccade calculations.\n');
        end
        PP = ilabGetPlotParms;
        % Shift relative to start of PP.index (because that's how PP.data is structured)
        % Shift start index back 1, because slider index already accounts
        % for first index value
        absIndex = (PP.index(nTrial,1)-1) + [sIndex eIndex];
        trialx = PP.data(absIndex(1):absIndex(2),1); % X-coord data within window
        trialy = PP.data(absIndex(1):absIndex(2),2); % Y-coord data within window
        
        % Unsure the necessity to label initial velocity as 0
        vx = [0; diff(trialx)];
        vy = [0; diff(trialy)];
        
        acqIntvl_ms = ilabGetAcqIntvl;
        acqIntvl_sec = acqIntvl_ms/1000;
        [pixPerDegH, pixPerDegV] = ilabPixelsPerDegree; % pix/deg
        
        vx = vx/(pixPerDegH*acqIntvl_sec);  % (pix/sample) * (deg/pix) * (sample/s) = deg/s
        vy = vy/(pixPerDegV*acqIntvl_sec);  % (pix/sample) * (deg/pix) * (sample/s) = deg/s
        vabs = sqrt(vx.^2 + vy.^2); % Velocity within saccade window
        [vPeak,iPeak] = max(vabs); % First maximimum index returned
        iPeak = (iPeak-1) + sIndex; % Index (relative to trial) of peak
        
        t0 = CFG.(lower(saccIF)).t0(nTrial); % Start of event (ms)
        tIndex = t0/ilabGetAcqIntvl; % Start of event (index)
        
        sRT = (sIndex - tIndex)*ilabGetAcqIntvl; % Saccadic reaction time (ms)
        ttP = (iPeak - tIndex)*ilabGetAcqIntvl; % Peak latency from target (ms)
        dtT = abs(trialx(end) - CFG.trialXPosVector(nTrial)); % Absolute distance from target (pix)        
    end

end