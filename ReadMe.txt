Updated: 2/14/14

Design Considerations:
- Include new function, clearing saccades prior to “delay” event.
	- Needs to happen after latency files have been added, so after saccade generation occurs.
	- Warning, manipulates original saccade data
	- See ilabEditSaccadeCB.m/updateSaccadeTbl(AP)
- “Add” function: Possible to add view changes to main UI plots while choosing which trial to add a saccade.  However, this is an additional automated feature and can be forgone if unnecessary
	- Currently, saccade plots are simply cleared.
	- Implement in cfgSaccCB.m/addDblClickCB, under single click conditional statements
- Include a clearing saccade on a trial
- Use of features
	- Fixation
	- ROIs
	- Relative Movement 
	- Pupil 
	- Segments
	- Scan Plot
- Size of axis is larger than draggable range (because of padding):
	- Very difficult to change.  Due to intentional trackBuffer, which is the distance between the trackRect and focusRect so there is room for the thumb and labels to paint.  This is in BasicSliderUI, which is ancestor to BasicRangeSliderUI, which is ancestor to Jide’s RangeSlider.
	- Without labels, the trackBuffer is fixed at approximately 10 pixels.
	- Need to see if client cares about capture very beginning or end.  
	- Difficult to stretch the slider even wider because of normalized UI positioning (flexible).  Additionally, padding is fixed and doesn’t scale appropriately when windows are resized.
- Can't do continuous updating of slider (currently, on mouse release).
	- Java callback threads are too fast for ilab plotting to handle.
- Need platform specs from client

Known bugs:
- Double-clicking doesn’t capture correctly depending on sequence of clicks.  Can fix, but repeatedly clicking on a trial will work.