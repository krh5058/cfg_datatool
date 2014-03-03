function [frame, updateTxtFnc, attachRszFnc] = cfgConfirmJFrame()
% cfgConfirmJFrame.m
% 2/28/14
% Author: Ken Hwang

% Import
import javax.swing.*
import javax.swing.table.*
import java.awt.*

% Set-up JFrame
frame = JFrame('Saccade Info');

% frame = handle(javaObjectEDT(frame), 'CallbackProperties');  % ensure that we're using EDT

frame.setUndecorated(true);

callback4 = @(obj,evt)onClose(obj,evt); % Callback for close button
% set(frame,'WindowClosingCallback',callback4);

frame.setSize(300,145);
toolkit = Toolkit.getDefaultToolkit();
screenSize = toolkit.getScreenSize();
x = (screenSize.width - frame.getWidth()) / 2;
y = (screenSize.height - frame.getHeight()) / 2;
frame.setLocation(x, y);

% Set-up label text
startLabel = JLabel();
endLabel = JLabel();

setappdata(frame,'WindowTxtVals',{'',''}); % Initialize

% Set-up top panel
top = JPanel(GridLayout(2,1));
t1 = BorderFactory.createTitledBorder('Saccade Window:');
top.setBorder(t1);
top.setMinimumSize(Dimension(300,100));
top.setPreferredSize(Dimension(300,100));

top.add(startLabel);
top.add(endLabel);

% Set-up confirm button
confirmBtn = JButton('Confirm');
cbh = handle(confirmBtn,'CallbackProperties');
callback1 = @(obj,evt)onConfirm(obj,evt);
set(cbh,'MouseClickedCallback', callback1);

% Set-up cancel button
cancelBtn = JButton('Cancel');
cbh = handle(cancelBtn,'CallbackProperties');
% callback2 = @(obj,evt)onCancel(obj,evt);
set(cbh,'MouseClickedCallback', callback4);

% Set-up bottom pane
bot = JPanel();
bot.setMinimumSize(Dimension(300,45));
bot.setPreferredSize(Dimension(300,45));

bot.add(confirmBtn);
bot.add(cancelBtn);

% Split top and bottom
splitpane = JSplitPane(JSplitPane.VERTICAL_SPLIT,top,bot);
splitpane.setEnabled(false);

frame.add(splitpane);

frame.setResizable(0);
frame.setVisible(1);

updateTxtFnc = @updateLabelTxt;
updateLabelTxt(frame); % Initialize
attachRszFnc = @applyCmpMvFnc;

    function updateLabelTxt(jFrame)
        % Get new values
        vals = getappdata(jFrame,'WindowTxtVals');
        
        % Get label components
        sL = jFrame.getComponent(0).getComponent(1).getComponent(0).getComponent(0).getComponent(0).getComponent(0);
        eL = jFrame.getComponent(0).getComponent(1).getComponent(0).getComponent(0).getComponent(0).getComponent(1);
        
        % Set text
        startTxtHead = 'Start (ms): ';
        endTxtHead = 'End (ms): ';
        sL.setText([startTxtHead vals{1}]);
        eL.setText([endTxtHead vals{2}]);
        
        drawnow;
    end

    function applyCmpMvFnc(f,jFrame)
        % Callback function to re-position jFrame to corresponding handle
        % graphic container (Matlab)
        % Must use 'ComponentMovedCallback' with Java component.  Matlab
        % doesn't readily have available figure moving callbacks
        jf = findjobj(f);
        jf = jf(1); % Top-level component (Matlab figure)
        
        updateFrameLocation(jf,[],jFrame); % Initial re-locate
        set(jf,'ComponentMovedCallback',{@updateFrameLocation,jFrame}); % Apply callback
    end

    function updateFrameLocation(src,evt,jFrame)
        % Determine figure size and position
        x = javaMethodEDT('getX',src);
        y = javaMethodEDT('getY',src);
        w = javaMethodEDT('getWidth',src);
        
        % Set new values
        jFrame.setLocation(x+w,y);
        
        drawnow;
    end

    function onConfirm(obj,evt) % When confirm button is pressed
        
        cfgIlabJavaInterface('calc'); % Pass current values for calculation
        cfgIlabJavaInterface('setsacc'); % Pass calculated values to data tool
        
        onClose(obj,evt);
    end

    function onClose(obj,evt) % When cancel button on frame is pressed
        CFG=cfgParams('get');
        
        % Determine data tool state
        request = get(findobj('Tag',CFG.CFG_TAGS{2}),'UserData');
        
        if ~isempty(request)
            if CFG.debug
                fprintf(['cfgConfirmJFrame (onClose): Current data tool state -- %s\n'], request);
            end
            
            switch request
                case 'addmod'
                    
                    % Clean-up
                    cfgUISecure('enableSLSelect'); % Re-enable saccade listbox
                    cfgUISecure('apReturn'); % Assuming apForceOff prior to this function call
                    cfgUISecure('clearsaccaction'); % Free UI from state restrictions
                    cfgUISecure('mainUIOn'); % Re-enable main UI functions
                    cfgIlabJavaInterface('cleanup'); % Clean up persistent variable
                    cfgUISecure('clearilabplot'); % Clear ILAB plotting
                otherwise
                    if CFG.debug
                        fprintf(['cfgConfirmJFrame (onClose): Unknown data tool state-- %s\n'], request);
                    end
            end
        else
            if CFG.debug
                fprintf(['cfgConfirmJFrame (onClose): Warning -- data tool state lost\n']);
            end
        end
        frame.setVisible(0);
        frame.dispose();
    end

end