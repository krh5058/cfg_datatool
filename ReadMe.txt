Updated: 2/14/14

Design Considerations:
- Include new function, clearing saccades prior to “delay” event.
	- Needs to happen after latency files have been added, so after saccade generation occurs.
	- Warning, manipulates original saccade data
	- See ilabEditSaccadeCB.m/updateSaccadeTbl(AP)
- “Add” function: Possible to add view changes to main UI plots while choosing which trial to add a saccade.  However, this is an additional automated feature and can be forgone if unnecessary
	- Currently, saccade plots are simply cleared.
	- Implement in cfgSaccCB.m/addDblClickCB, under single click conditional statements
- Use of features
	- Fixation
	- ROIs
	- Relative Movement 
	- Pupil 
	- Segments

Known bugs:
- Double-clicking doesn’t capture correctly depending on sequence of clicks.  Can fix, but repeatedly clicking on a trial will work.