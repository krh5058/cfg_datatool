function [frame, updateTxtFnc, attachRszFnc] = cfgConfirm()
% cfgConfirm.m
% 2/25/14
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
        %         sid = textField.getText();
        %         textsize = textField2.getText();
        %         selectedModel1 = group1.getSelection();
        %         trig = selectedModel1.getActionCommand();
        %         listout = cell(listArray);
        %
        %         if isempty(char(sid)) % Check for empty SID
        %             javax.swing.JOptionPane.showMessageDialog(frame,'Subject ID is empty!','Subject ID check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        %         elseif isempty(char(textsize))
        %             javax.swing.JOptionPane.showMessageDialog(frame,'Text Size is empty!','Text Size check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        %         elseif all(cellfun(@isempty,listout)) % Check for empty order list
        %             javax.swing.JOptionPane.showMessageDialog(frame,'Order list is empty!','Order list check',javax.swing.JOptionPane.INFORMATION_MESSAGE);
        %         else
        %
        %             % Parameter confirmation
        %             s = [];
        %             for k = 1:length(listout)
        %                 s = [s listout{k} ','];
        %             end
        %
        %             infostring = sprintf(['Subject ID: ' char(sid) ...
        %                 '\nText Size: ' char(textsize) ...
        %                 '\nTrigger: ' char(trig) ...
        %                 '\nOrder: ' s(1:end-1) ...
        %                 '\n\nIs this correct?']);
        %             result = javax.swing.JOptionPane.showConfirmDialog(frame,infostring,'Confirm parameters',javax.swing.JOptionPane.YES_NO_OPTION);
        %
        %             % Record data and close
        %             if result==javax.swing.JOptionPane.YES_OPTION
        %                 switch char(trig)
        %                     case 'Yes'
        %                         trig = 1;
        %                     case 'No'
        %                         trig = 0;
        %                 end
        %                 setappdata(frame,'UserData',{char(sid),char(textsize),trig,listout});
        %                 frame.dispose();
        %             else
        %             end
        %         end
    end

    function onClose(obj,evt) % When cancel button on frame is pressed
        setappdata(frame,'UserData',[]);
        frame.setVisible(0);
        frame.dispose();
        clear frame
    end
end