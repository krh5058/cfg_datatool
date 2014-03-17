function cfgParams(action, varargin)
% cfgParams.m
% 3/12/14
% Author: Ken Hwang

global CFG

if isfield(CFG,'debug')
    if CFG.debug
        fprintf('cfgParams: Received request --- %s.\n',action);
    end
end

if strcmpi(action, 'init')
    fprintf('cfgParams (init): Initializing global parameters.\n');
    
    % Toolbox general
    CFG.tbactive = true;
    CFG.debug = 1;
    
    % Directory path
    p = mfilename('fullpath');
    p = fileparts(p);
    CFG.usrDir = [p filesep 'usr'];
    CFG.expDir = [p filesep 'export'];
    
    ILAB = CFG.ILAB;
    
    % Usage state for title bar
    CFG.base = 'cfg_datatool';
    CFG.stateTitle = CFG.base;
    
    % Tag strings
    CFG.CFG_TAGS = {'ILABWIN_CFGMTAG','CFGWIN_TAG',... % 1-2 (General)
        'CFGWIN_SUBJTEXT','CFGWIN_DATETEXT','CFGWIN_TIMETEXT','CFGWIN_PATHTEXT',... % 3-6 (UpperLeft)
        'CFGWIN_TRIALSTEXT','CFGWIN_DROPTEXT','CFGWIN_ERRTEXT',... % 7-9 (UpperRight)
        'CFGWIN_INITTXT','CFGWIN_FINTXT',... % 10-11 (Table Text)
        'CFGWIN_INITTBL','CFGWIN_FINTBL'}; % 12-13 (Tables)
    CFG.CFG_MTAGS = cell([1 6]);
    CFG.CFG_MTAGS{1} = {'CFGMENU_FILE', 'CFGMENU_IMPORT', 'CFGMENU_EXPORTLABEL', 'CFGMENU_EXCFG', 'CFGMENU_OPENEX', 'CFGMENU_SAVE', 'CFGMENU_LOAD', 'CFGMENU_EXIT'}; % 1, 1-8
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
    
    % Ensure neutral state
    if ~isempty(get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData'))
        % Warning.  Data tool in current state
        h = warndlg(sprintf('Please complete current action -- %s\n.',CFG.stateTitle),'cfg_datatool WARNING');
        uiwait(h);
        return;
    end
    
    % Switch directory, select, and switch back
    currentDir = pwd;
    cd(CFG.usrDir)
    [f,p] = uigetfile('*.mat');
    cd(currentDir);
        
    % If cancelled
    if isequal(f,0) || isequal(p,0)
        if CFG.debug
            fprintf('cfgParams (load): Action ''uigetfile'' cancelled.\n');
        end
        return;
    end

    if CFG.debug
        fprintf('cfgParams (load): Loading old CFG parameters from %s.\n',[p f]);
    end
    loadedCFG = load([p f]);
    
    ILAB = ilabGetILAB; % Keep accessor function, to pull appropriate session data from ILAB
    
    if CFG.debug
        fprintf('cfgParams (load): Current ILAB subject identifier %s.\n',ILAB.subject);
        fprintf('cfgParams (load): Loaded CFG subject identifier %s.\n',loadedCFG.CFG.subject);
    end
    
    if ~strcmp(ILAB.subject,loadedCFG.CFG.subject)
        h = warndlg(sprintf(['The loaded subject identifier does not match your current ILAB session.', ...
            '\n\nFile: %s', ...
            '\n\nLoaded subject Identifier: %s', ...
            '\n\nCurrent subject identifier: %s', ...
            '\n\nPrevious analysis parameters may mismatch with the current data set.', ...
            '\nPress ''OK'' to continue.'], ...
            [p f],loadedCFG.CFG.subject,ILAB.subject),'cfg_datatool WARNING');
        uiwait(h);
    end
    
    if CFG.debug
        fprintf('cfgParams (load): Reinstating session-specific UI handles from current session.\n');
    end
    
    loadedCFG.CFG.handles = CFG.handles;
    
    if CFG.debug
        fprintf('cfgParams (load): Replacing current CFG with loaded CFG and updating UI.\n');
    end    
    
    CFG = loadedCFG.CFG;
    
    cfgShow;
    
elseif strcmpi(action, 'save')
    
    % Define a session identifier if it does not exist
    if ~isfield(CFG,'saveFile')
        prompt={'Enter a new name for you save file (avoid spaces):'};
        name='Rename save file';
        numlines=1;
        defaultanswer={[CFG.subject '_' datestr(now,30)]};
        
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        
        if isempty(answer)
            return;
        else
            CFG.saveFile = answer{1};
            matname = CFG.saveFile;
        end
    else % Prompt for overwrite
        saveResponse = questdlg(sprintf('Overwrite file: %s.mat?',CFG.saveFile), ...
            'Close cfg_datatool', ...
            'Overwrite','Rename','Cancel','Cancel');
        
        if isempty(saveResponse)
            return;
        end
        
        switch saveResponse
            case 'Overwrite'
                matname = CFG.saveFile;
            case 'Rename'
                prompt={'Enter a new name for you save file (avoid spaces):'};
                name='Rename save file';
                numlines=1;
                defaultanswer={CFG.saveFile};
   
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                
                if isempty(answer)
                    return;
                else
                    CFG.saveFile = answer{1};
                    matname = CFG.saveFile;
                end
                
            case 'Cancel'
                return;
        end
    end
    
    temp = CFG;
    
    if CFG.debug
        fprintf('cfgParams (save): Setting state-dependent parameters to neutral.\n');
    end   
    
    temp.stateTitle = temp.base;
    
    if CFG.debug
        fprintf('cfgParams (save): Discarding session-specific UI handles from save file.\n');
    end
    
    temp.handles = [];
    
    if CFG.debug
        fprintf('cfgParams (save): Saving CFG parameters.\n');
        fprintf('cfgParams (save): Saving file, %s, to directory, %s.\n',[matname '.mat'],CFG.usrDir);
    end   
    
    % Swapping out CFG for temp
    CFGcurrent = CFG;
    CFG = temp;
    
    % Saving all CFG global parameters
    save([CFG.usrDir filesep matname],'CFG');
    
    % Resetting CFG
    CFG = CFGcurrent;
    
    msgbox(sprintf('Saving file...\n\n%s\n\nto directory\n\n%s.',[matname '.mat'],CFG.usrDir),'cfg_datatool: Save','modal');
    
elseif strcmpi(action, 'import')
    
    if CFG.importState
        % Warning.  Data tool in current state
        h = warndlg(sprintf('Imported data currently exists.\nKeep in mind that your workspace will not update to take new data into account.\n.'),'cfg_datatool WARNING');
        uiwait(h);
    end
    
    if CFG.debug
        fprintf('cfgParams (import): Importing CFG experimental data.\n');
    end
    
    try
        if ispc
            [f,p] = uigetfile('*.xlsx');
            
            if isequal(f,0) || isequal(p,0)
                if CFG.debug
                    fprintf('cfgParams (import): Action ''uigetfile'' cancelled.\n');
                end
                return;
            end
            [num,txt] = xlsread([p f]);
        elseif isunix % Can use the below for PC also, but file extension must be .xls
            [f,p] = uigetfile('*.xls');
            
            if isequal(f,0) || isequal(p,0)
                if CFG.debug
                    fprintf('cfgParams (import): Action ''uigetfile'' cancelled.\n');
                end
                return;
            end
            dat = importdata([p f]);
            sheettxt = fieldnames(dat.textdata);
            sheetdata = fieldnames(dat.data);
            if length(sheettxt) > 1 || length(sheetdata) > 1
                warning('cfg_datatool:importDataError','Too many detected sheets.  Will only use first sheet.');                
            end
            num = dat.data.(sheetdata{1});
            txt = dat.textdata.(sheettxt{1});
        else
            error('cfg_datatool:platform','Incompatible platform.');
        end
            
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
    
elseif strcmpi(action, 'export')
    
    switch varargin{1}
        case 1
            if CFG.debug
                fprintf('cfgParams (export): Exporting current CFG saccade data.\n');
            end
            
            % Prompt to specify output directory name
            prompt={'Specify export folder directory (avoid spaces):'};
            name='Name output directory';
            numlines=1;
            defaultanswer={[CFG.subject '_' datestr(now,30)]};
            
            answer=inputdlg(prompt,name,numlines,defaultanswer);
            
            % Check for cancel
            if isempty(answer)
                if CFG.debug
                    fprintf('cfgParams (export): User cancelled.\n');
                end
                return;
            else 
                outDir = answer{1};
                
                if CFG.debug
                    fprintf('cfgParams (export): Directory specified as -- %s.\n',outDir);
                end
                
                % Check if directory exists
                [~,d] = system(['dir /b/ad ' CFG.expDir]);
                d = regexp(d(1:end-1),'\n','split');
                if any(strcmp(outDir,d))
                    overWriteResponse = questdlg(sprintf('''%s'' already exists.  Would you like to overwrite?',outDir), ...
                        'Overwrite directory', ...
                        'Yes','No','No');
                    
                    % Remove directory if user clicks "Yes"
                    if strcmpi(overWriteResponse,'No') || isempty(overWriteResponse)
                        if CFG.debug
                            fprintf('cfgParams (export): User cancelled.\n');
                        end
                        return;
                    elseif strcmpi(overWriteResponse,'Yes')
                        if CFG.debug
                            fprintf('cfgParams (export): Attempting to remove directory -- %s.\n',outDir);
                        end
                        rmdir([CFG.expDir filesep outDir],'s'); 
                    end
                end
            end
            
            if CFG.debug
                fprintf('cfgParams (export): Creating directory -- %s.\n',[CFG.expDir filesep outDir]);
            end
            
            mkdir([CFG.expDir filesep outDir]);
            
            if CFG.debug
                fprintf('cfgParams (export): Created directory -- %s.\n',[CFG.expDir filesep outDir]);
                fprintf('cfgParams (export): Formatting saccade data.\n');
                
            end
            
            % Format cells for excel output, Adding 'Trial' and trial
            % numbers.
            out1 = [['Trial',CFG.cfgHeaders];[num2cell([1:CFG.trials]'),CFG.initial.table]];
            out2 = [['Trial',CFG.cfgHeaders];[num2cell([1:CFG.trials]'),CFG.final.table]];
            
            if CFG.debug
                fprintf('cfgParams (export): Writing initial and final files to directory.\n');
            end
            
            if ispc
                xlswrite([CFG.expDir filesep outDir filesep 'initial.xlsx'],out1);
                xlswrite([CFG.expDir filesep outDir filesep 'final.xlsx'],out2);
                msgbox(sprintf('Files initial.xlsx and final.xslx written to directory:\n%s.',[CFG.expDir filesep outDir]),'cfg_datatool: Export','modal');
            elseif isunix
                cell2csv([CFG.expDir filesep outDir filesep 'initial.csv'],out1);
                cell2csv([CFG.expDir filesep outDir filesep 'final.csv'],out2);
                msgbox(sprintf('Files initial.csv and final.csv written to directory:\n%s.',[CFG.expDir filesep outDir]),'cfg_datatool: Export','modal');
            else
                error('cfg_datatool:platform','Incompatible platform.');
            end
%         case 2
%             if CFG.debug
%                 fprintf('cfgParams (export): Exporting original saccade data table.\n');
%             end
%             
% %             ilabSaveTblAsExcelCB
%         case 3
%             if CFG.debug
%                 fprintf('cfgParams (export): Exporting original saccade data table and current CFG saccade data.\n');
%             end
        case 2
            if CFG.debug
                fprintf('cfgParams (export): Request to open export directory.\n');
            end
            if ispc
                winopen(CFG.expDir);
            elseif isunix
                unix(['nautilus ' CFG.expDir]);
            else
                error('cfg_datatool:platform','Incompatible platform.');
            end
    end
    
elseif strcmpi(action, 'get')
    
    if CFG.debug
        fprintf('cfgParams (get): CFG parameters requested.\n');
    end
    
elseif strcmpi(action, 'set')
    if CFG.debug
        fprintf('cfgParams (set): Setting CFG parameter --- %s.\n',varargin{2});
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
        fprintf('cfgParams (setsacc): CFG saccade value set request.\n');
        fprintf('cfgParams (setsacc): %s saccade, at index %i , changed.\n', varargin{1},varargin{2});
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
           
elseif strcmpi(action,'clearsacc')
    if CFG.debug
        fprintf('cfgParams (clearsacc): CFG saccade value clear request.\n');
        fprintf('cfgParams (clearsacc): %s saccade, at index %i , cleared.\n', varargin{1},varargin{2});
    end
    
    CFG.(lower(varargin{1})).list(varargin{2},:) = deal(NaN);
    CFG.(lower(varargin{1})).table(varargin{2},:) = CFG.cfgInitEmpty;
    
elseif strcmpi(action,'reset')
    if CFG.debug
        fprintf('cfgParams (reset): CFG parameter reset requested.\n');
    end
    
    clear global CFG
    
    cfgParams('init');
    
elseif strcmpi(action,'exit')
    if CFG.debug
        fprintf('cfgParams (exit): Exit requested. Parameter clean up.\n');
    end
    
    % Restore back-ups
    ilabSetILAB(CFG.ILAB);
    ilabSetAnalysisParms(CFG.AP);
    ilabSetPlotParms(CFG.PP);
        
    clear global CFG
    
else
    error('cfgParams: Unrecognized action.');
end

    function [sRT,ttP,dtT] = cfgExpCalc(saccIF,nTrial,sIndex,eIndex)
        if CFG.debug
            fprintf('cfgParams(cfgExpCalc): Nested function called for additional saccade calculations.\n');
        end
        PP = CFG.PP;
        % Shift relative to start of PP.index (because that's how PP.data is structured)
        % Shift start index back 1, because slider index already accounts
        % for first index value
        absIndex = (PP.index(nTrial,1)-1) + [sIndex eIndex];
        trialx = PP.data(absIndex(1):absIndex(2),1); % X-coord data within window
        trialy = PP.data(absIndex(1):absIndex(2),2); % Y-coord data within window
        
        % Unsure the necessity to label initial velocity as 0
        vx = [0; diff(trialx)];
        vy = [0; diff(trialy)];
        
        acqIntvl_ms = CFG.acqIntvl;
        acqIntvl_sec = acqIntvl_ms/1000;
        [pixPerDegH, pixPerDegV] = ilabPixelsPerDegree; % pix/deg
        
        vx = vx/(pixPerDegH*acqIntvl_sec);  % (pix/sample) * (deg/pix) * (sample/s) = deg/s
        vy = vy/(pixPerDegV*acqIntvl_sec);  % (pix/sample) * (deg/pix) * (sample/s) = deg/s
        vabs = sqrt(vx.^2 + vy.^2); % Velocity within saccade window
        [vPeak,iPeak] = max(vabs); % First maximimum index returned
        iPeak = (iPeak-1) + sIndex; % Index (relative to trial) of peak
        
        t0 = CFG.(lower(saccIF)).t0(nTrial); % Start of event (ms)
        tIndex = t0/CFG.acqIntvl; % Start of event (index)
        
        sRT = (sIndex - tIndex)*CFG.acqIntvl; % Saccadic reaction time (ms)
        ttP = (iPeak - tIndex)*CFG.acqIntvl; % Peak latency from target (ms)
        dtT = abs(trialx(end) - CFG.trialXPosVector(nTrial)); % Absolute distance from target (pix)        
    end

end