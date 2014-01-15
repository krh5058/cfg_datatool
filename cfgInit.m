function cfgInit
    global CFG

    ILAB = ilabGetILAB;
    
    CFG.CFG_TAGS = {'CFGWIN_MTAG','CFGWIN_TAG','CFGSACC_INITLB','CFGSACC_FINLB'};
    CFG.trials = ILAB.trials;
    CFG.acqIntvl = ILAB.acqIntvl;
    CFG.trialCodes = ILAB.trialCodes;
    CFG.coordSys = ILAB.coordSys;
    CFG.subject = ILAB.subject;
    CFG.date = ILAB.date;
    CFG.time = ILAB.time;
    CFG.headers = {'Trial', 'Start Code', 'Target Code', 'Trial Type', 'Start (ms)', 'End (ms)', 'peak vel', 'mean vel', 'time-to-peak (ms)', 'latency (ms)', 'distance'};
    CFG.tTitle = str2mat(['Trial Sacc#  Start   End     vPeak    vMean    SRT   ttPeak  dist  %Zero'],...
        [blanks(14) ' ms     ms    deg/sec   deg/sec   ms     ms']);
    CFG.fmtStr = '%4d  %4d   %6.0f  %6.0f     %5.1f    %5.1f   %6.0f   %6.0f   %5.1f %4.0f';
    
    CFG.initial.list = NaN([CFG.trials 10]);
    CFG.initial.table = cell(CFG.trials+1,1);
    CFG.initial.table{1,1} = CFG.tTitle;
    
    CFG.final.list = NaN([CFG.trials 10]);
    CFG.final.table = cell(CFG.trials+1,1);
    CFG.final.table{1,1} = CFG.tTitle;

    for n = 1:CFG.trials
        CFG.initial.table{n+1,1} = sprintf(CFG.fmtStr, CFG.initial.list(n,:));
        CFG.final.table{n+1,1} = sprintf(CFG.fmtStr, CFG.final.list(n,:));
    end
    
    CFG.drop = zeros([CFG.trials 1]);
    CFG.err = zeros([CFG.trials 1]);
    
end