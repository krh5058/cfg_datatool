Updated: 2/27/14

Backburner feature requests:
- Clearing saccades prior to “delay” event.
	- Needs to happen after latency files have been added, so after saccade generation occurs.
	- Warning, manipulates original saccade data
	- See ilabEditSaccadeCB.m/updateSaccadeTbl(AP)
- Add/Modify function: Possible to add view changes to main UI plots while choosing which trial to add a saccade.  However, this is an additional automated feature and can be forgone if unnecessary
	- Currently, saccade plotting is simply cleared.
- Dotted lines aligned with slider thumbs

Design Considerations:
- Use of features
	- Pupil, for quality checking purposes
- Need platform specs from client
	- version -java
		Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
	- JIDE compatibility
- Error can be applied to both initial/final saccade

Known bugs:
- Double-clicking doesn’t capture correctly depending on sequence of clicks.  Can fix, but repeatedly clicking on a trial will work.
- Confirm window is locked to upper right of ILAB windows.  If ILAB window is maximized, confirm window ill be off-screen.
- Slider isn't 100% lined up with plot, due to track buffer.