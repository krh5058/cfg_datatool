Updated: 2/27/14

More comprehensive found in Google Docs and commit text:
https://docs.google.com/document/d/1x2icPghAkzCE96eYO8GJe4FN3XksnORehLECbDpic-w/edit?usp=sharing

Backburner feature requests:
- Clearing saccades prior to “delay” event.
	- Needs to happen after latency files have been added, so after saccade generation occurs.
	- Warning, manipulates original saccade data
	- See ilabEditSaccadeCB.m/updateSaccadeTbl(AP)
- Add/Modify function: Possible to add view changes to main UI plots while choosing which trial to add a saccade.  However, this is an additional automated feature and can be forgone if unnecessary
	- Currently, saccade plotting is simply cleared.
- Dotted lines aligned with slider thumbs

Design Considerations:
- Developed on 1680x1050 resolution screen
	- Positioned bottom of window at 15% total screen height from bottom of screen
	- Positioned total height of window to be 85% total screen height
- Use of features
	- Pupil, for quality checking purposes
- Need platform specs from client
	- version -java
		Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
	- JIDE compatibility
- Error can be applied to both initial/final saccade

Known bugs:
- Double-clicking doesn’t capture correctly depending on sequence of clicks.  Can fix, but repeatedly clicking on a trial will work.
- Confirm window is locked to upper right of ILAB windows.  If ILAB window is maximized, confirm window will be off-screen.
- Slider isn't 100% lined up with plot, due to track buffer.
- Closing either "cfg_datatool" or "Saccade Results" windows typically results in loss of underlying data models or UI states.