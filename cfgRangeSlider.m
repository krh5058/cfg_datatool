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
set(hContainer,'Units', 'Normalized', ...
    'Position',[0.2620 0.467 0.7000 0.025], ...
    'Tag','cfgSlider');

% set(hContainer,'units', 'normalized','pos',[0.255 0.467 0.715
% 0.025],'tag','cfgSlider');
% drawnow; pause(0.05);
% javax.swing.UIManager.setLookAndFeel(oldLaF);
% lh = addlistener(hContainer, 'ActionEvent',@MyCallback);

set(slider,'MouseReleasedCallback',@plotFunc);

    function plotFunc(src,evt)
        drawnow;
        
        persistent oldLowVal oldHiVal
        
        % Prevent Matlab congestion if EDT threads are sending too many
        % events
        action = 0;
        lowVal = javaMethodEDT('getLowValue',src);
        hiVal = javaMethodEDT('getHighValue',src);
                
        if isempty(oldLowVal) || isempty(oldHiVal) % Check for old values
            oldLowVal = lowVal;
            oldHiVal = hiVal;
            action = 1;
        elseif (lowVal ~= oldLowVal) || (hiVal ~= oldHiVal) % Only if values have changed
            oldLowVal = lowVal;
            oldHiVal = hiVal;
            action = 1;
        end
        
        if action            
            cfgSliderInterface('plot');            
        end
        
    end

end

