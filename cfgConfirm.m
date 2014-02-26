function [hConfirm] = cfgConfirm()
% cfgConfirm.m
% 2/25/14
% Author: Ken Hwang

    hConfirm = figure('Tag', 'cfgConfirm',...
        'Name', 'SaccadeWindow',...
        'MenuBar', 'none',...
        'NumberTitle', 'off', ...
        'Resize', 'off',...
        'Color', [.95 1 .95]);
    
%         % Set-up label text
%         startTxtHead = 'Start (ms): ';
%         startLabel = JLabel();
%         endTxtHead = 'End (ms): ';
%         endLabel = JLabel();
%         
%         setappdata(frame,'WindowTxtVals',{'1','2'});
%         updateLabelTxt(); % Initialize
%         
%         % Set-up top panel
%         top = JPanel(GridLayout(2,1));
%         t1 = BorderFactory.createTitledBorder('Saccade Window:');
%         top.setBorder(t1);
%         top.setMinimumSize(Dimension(300,100));
%         top.setPreferredSize(Dimension(300,100));
%         
%         top.add(startLabel);
%         top.add(endLabel);
%         
%         % Set-up confirm button
%         confirmBtn = JButton('Confirm');
%         cbh = handle(confirmBtn,'CallbackProperties');
%         callback1 = @(obj,evt)onConfirm(obj,evt);
%         set(cbh,'MouseClickedCallback', callback1);
%         
%         % Set-up cancel button
%         cancelBtn = JButton('Cancel');
%         cbh = handle(cancelBtn,'CallbackProperties');
%         % callback2 = @(obj,evt)onCancel(obj,evt);
%         set(cbh,'MouseClickedCallback', callback4);
%         
%         % Set-up bottom pane
%         bot = JPanel();
%         bot.setMinimumSize(Dimension(300,45));
%         bot.setPreferredSize(Dimension(300,45));
%         
%         bot.add(confirmBtn);
%         bot.add(cancelBtn);
%         
%         % Split top and bottom
%         splitpane = JSplitPane(JSplitPane.VERTICAL_SPLIT,top,bot);
%         splitpane.setEnabled(false);
%         
%         frame.add(splitpane);
%         
%         frame.setResizable(0);
%         frame.setVisible(1);
%         
% 
%     function updateLabelTxt(time1,time2)
%         vals = getappdata(frame,'WindowTxtVals');
%         startLabel.setText([startTxtHead vals{1}]);
%         endLabel.setText([endTxtHead vals{2}]);
%     end

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

    function onClose(obj,evt) % When close button on frame is pressed
        setappdata(frame,'UserData',[]);
        frame.setVisible(0);
        frame.dispose();
    end
end