function [frame, updateTxtFnc, attachCmpMvFnc] = cfgConfirmJFrame(confirmOn)
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

% Set-up bottom pane
bot = JPanel();
bot.setMinimumSize(Dimension(300,45));
bot.setPreferredSize(Dimension(300,45));

% Set-up confirm button
if confirmOn % Confirm only for slider tool
    confirmBtn = JButton('Confirm');
    cbh = handle(confirmBtn,'CallbackProperties');
    callback1 = @(obj,evt)onConfirm(obj,evt);
    set(cbh,'MouseClickedCallback', callback1);
    bot.add(confirmBtn);
end

% Set-up cancel button
cancelBtn = JButton('Cancel');
cbh = handle(cancelBtn,'CallbackProperties');
% callback2 = @(obj,evt)onCancel(obj,evt);
set(cbh,'MouseClickedCallback', callback4);
bot.add(cancelBtn);

% Split top and bottom
splitpane = JSplitPane(JSplitPane.VERTICAL_SPLIT,top,bot);
splitpane.setEnabled(false);

frame.add(splitpane);

frame.setResizable(0);
frame.setVisible(1);

updateTxtFnc = @updateLabelTxt;
updateLabelTxt(frame); % Initialize
attachCmpMvFnc = @applyCmpMvFnc;

    function updateLabelTxt(jFrame)
        % Get new values
        vals = getappdata(jFrame,'WindowTxtVals');
        
        % Get label components (fairly restricted to cfgConfirmJFrame.m
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
        updateFrameFocus(jf,[],jFrame); % Initial focus
        set(jf,'ComponentMovedCallback',{@updateFrameLocation,jFrame}); % Apply callback
        set(jf,'WindowGainedFocusCallback',{@updateFrameFocus,jFrame}); % Apply callback
        
        set(jFrame,'WindowClosedCallback',{@removeCmpCBs,jf}); % Callback to remove callbacks on window close
        
        function removeCmpCBs(src,evt,matlabTopComponent)
            set(matlabTopComponent,'ComponentMovedCallback',[]); % Remove callback
            set(matlabTopComponent,'WindowGainedFocusCallback',[]); % Remove callback
        end
        
    end

    function updateFrameLocation(src,evt,jFrame)
%         fprintf('updateFrameFocus: Executed from ComponentMovedCallback\n');
%         [ST,I] = dbstack;
%         for i = 1:length(ST)
%             disp(ST(i).file);
%             disp(ST(i).name);
%             disp(ST(i).line);
%         end
        
        % Determine figure size and position
        x = javaMethodEDT('getX',src);
        y = javaMethodEDT('getY',src);
        w = javaMethodEDT('getWidth',src);
        
        % Set new values
        jFrame.setLocation(x+w,y);
        
        drawnow;
    end

    function updateFrameFocus(src,evt,jFrame)
        [ST,I] = dbstack;
        %         for i = 1:length(ST)
        %             disp(ST(i).file);
        %             disp(ST(i).name);
        %             disp(ST(i).line);
        %         end
        
        % Only executes if dbstack is length of 1.  Reason being, ILAB
        % continuously focuses the window in order to perform all its
        % plotting functions.  This function gets called up to 11 times for
        % any plotting functions performed by ilabPlotSaccade (executed
        % through cfgIlabJavaInterface.m/trickPlotSaccade.  Assuming these
        % plotting functions only occur when the user has focus already,
        % there is no reason to continously bring the jFrame to the front.
        if length(ST)==1
%             fprintf('updateFrameFocus: Executed from WindowGainedFocusCallback\n');
            jFrame.toFront(); % Bring confirm frame to front
            drawnow;
        end
    end

    function onConfirm(obj,evt) % When confirm button is pressed
        % Prevent multiple clicking
        confirmBtn.setEnabled(false);
        cancelBtn.setEnabled(false);
        
        cfgIlabJavaInterface('calc'); % Pass current values for calculation
        cfgIlabJavaInterface('setsacc'); % Pass calculated values to data tool
        
        onClose(obj,evt);
    end

    function onClose(obj,evt) % When cancel button on frame is pressed
        % Prevent multiple clicking
        cancelBtn.setEnabled(false);
        if exist('confirmBtn','var')
            confirmBtn.setEnabled(false);
        end
        
        cfgUISecure('statecleanup'); % Clean up UI functions based on state
        %         frame.setVisible(0);
        %         frame.dispose();
    end

end