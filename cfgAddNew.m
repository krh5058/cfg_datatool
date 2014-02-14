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

% UI clearing and restrictions
cfgUISecure('clearuitableud'); % Keep table UserData clear

% Add action
AP = ilabGetAnalysisParms;
PP = ilabGetPlotParms;
pseudoAP = AP;

% AP2.saccade.list = [selRow 0 PP.index(selRow,1) PP.index(selRow,2)];
% AP2.saccade.list = [selRow 0 1 diff(PP.index(selRow,1:2))];
pseudoAP.saccade.list = [selRow 0 1 708];
 
ilabSetAnalysisParms(pseudoAP);
hSL = findobj('Tag','SaccadeListbox');
set(hSL,'Value',1);

ilabPlotSaccade;
% MultiSlider;

% Reset parameters
ilabSetAnalysisParms(AP);
set(findobj('Tag','SaccadeListbox'),'Value',[]);

disp('test');

end
