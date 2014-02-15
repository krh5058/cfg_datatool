function cfgRangeSlider

% com.mathworks.mwswing.MJUtilities.initJIDE;  % initialize JIDE
jSlider = com.jidesoft.swing.RangeSlider(0,100,10,90);

jSlider = handle(javaObjectEDT(jSlider), 'CallbackProperties');  % ensure that we're using EDT
% 
% [slider,hContainer] = javacomponent(jSlider,java.awt.BorderLayout.SOUTH);
% set(handle(slider),'units', 'normalized','pos',[.5,.5,1,1]);
% java.awt.BorderLayout.SOUTH

% oldLaF = javax.swing.UIManager.getLookAndFeel;
% javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
% com.jidesoft.plaf.LookAndFeelFactory.installJideExtension()

[slider,hContainer] = javacomponent(jSlider,[0,0,30,30],ilabGetMainWinHdl);
set(hContainer,'units', 'normalized','pos',[0.2620 0.467 0.7000 0.025],'tag','cfgSlider');
% set(hContainer,'units', 'normalized','pos',[0.255 0.467 0.715 0.025],'tag','cfgSlider');

% drawnow; pause(0.05);
% 
% javax.swing.UIManager.setLookAndFeel(oldLaF);

% lh = addlistener(hContainer, 'ActionEvent',@MyCallback);

set(slider,'StateChangedCallback',@MyCallback);

    function MyCallback(src,evt)
        disp('test');
        disp(src.getLowValue);
        disp(src.getHighValue);
        
        % Add action
        AP = ilabGetAnalysisParms;
        PP = ilabGetPlotParms;
        pseudoAP = AP;
        
        % AP2.saccade.list = [selRow 0 PP.index(selRow,1) PP.index(selRow,2)];
        % AP2.saccade.list = [selRow 0 1 diff(PP.index(selRow,1:2))];
        pseudoAP.saccade.list = [1 0 src.getLowValue src.getHighValue];
        
        ilabSetAnalysisParms(pseudoAP);
        hSL = findobj('Tag','SaccadeListbox');
        set(hSL,'Value',1);
        
exit        ilabPlotSaccade;
        
        % Reset parameters
        ilabSetAnalysisParms(AP);
        set(findobj('Tag','SaccadeListbox'),'Value',[]);
        
    end

end

