function cfgAddNew
global CFG

if CFG.debug
    fprintf(['cfgAddNew: Request received.\n']);
end

% Find selected table and row
uiHIndices = 3:4;
tbl = ~cellfun(@isempty,get(CFG.handles.hLui(uiHIndices),'UserData'));
tableTag = get(CFG.handles.hLui(uiHIndices(tbl)),'Tag');
selRow = get(CFG.handles.hLui(uiHIndices(tbl)),'UserData');

if CFG.debug
    fprintf(['cfgAddNew: Selected table -- %s\n'],tableTag);
    fprintf(['cfgAddNew: Selected row -- %i\n'],selRow);
end

cfgUISecure('clearuitableud'); % Keep table UserData clear



% Clean-up: Release row select, saccade action, and reset callbacks on UI tables
cfgUISecure('anyselect');
cfgUISecure('clearsaccaction'); % Free UI from function

end
