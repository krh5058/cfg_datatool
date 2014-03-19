Author: Ken Hwang, M.S.
Contact: ken.r.hwang@gmail.com
Repository: https://github.com/krh5058/cfg_datatool
Last Updated: 3/18/14

More comprehensive documentation found in Google Docs and commit text:
https://docs.google.com/document/d/1x2icPghAkzCE96eYO8GJe4FN3XksnORehLECbDpic-w/edit?usp=sharing

Usage:

	Set-up
	1. Place cfg_datatool in ILAB-3.6.4/Toolbox
	2. For best performance, run with multiple screens.
	3. For best performance, place the ILAB main window, "Saccade Results", and the "cfg_datatool" main window side-by-side with little overlap.

	Necessary files
	.eyd eye data.  Other eye-tracking data may work, but currently on ASL output has been tested.  See cfg_datatool/examples.
	.xlsx or .xls trial data.  This data must formatted in a 5-column, and rows must be in consecutive, unique trial order.  XLSX used for PC.  XLS used for Unix systems.  See cfg_datatool/examples for formatting specifics.

	Initialization
	1. Start-up "ilab" within Matlab
	2. Convert and format eye tracking data
	3. Perform "Analysis" > "Saccades...".  Choose parameters and hit "OK".
	4. Run "File" > "Toolboxes" > "cfg_datatool".
	5. Begin data analysis by "File" > "Import trial data", or "Load cfg_datatool workspace" (if previously saved)
	
Menu:

	File
	"Import data file": Load an Excel file containing formatted experimental trial data.
	"Export" > "cfg_datatool saccades": Exports an XLSX (PC) or CSV (Unix) file in the cfg_datatool/export directory.
	"Export" > "Open export folder": Opens the folder where export files are placed.
	"Save cfg_datatool workspace": Saves a .mat file of the current cfg_datatool dataset.  Stored in cfg_datatool/usr.
	"Load cfg_datatool workspace": Loads a previously saved .mat file of a cfg_datatool dataset.  User is prompted to select from cfg_datatool/usr.
	"Exit": Close cfg_datatool.
	
	Edit
	"Parameters": View parameters which "Analysis" > "Saccades..." was performed.  (Editting may be added in the future.)
	
	Saccade
	"Select": 
		- Select from a saccade from the "Saccade Results" window.  
		- Single clicks on the "Saccade Results" window will automatically plot the saccades to the ILAB main window, with the Auto-plot feature.
		- Double-clicking on a selection will prompt the user to specify if it is an "Initial" or "Final" type saccade (or they can cancel).
		- An attached frame also allows the user to see the Saccade Window selected in milliseconds, or allow them to cancel the "Select" function.
	"Add/Modify":
		- The user must double-click on one of the "cfg_datatool" tables to specify the saccade trial and type (Initial/Final) they would like to add to or modify from.
		- Upon selection, a rangeslider will appear on the ILAB main window.  Use the rangeslider to specify the saccade window's start and end.  The selected section will highlight yellow on the XY time plots.
		- Compatible if "Pupil" is selected on or off.
		- An attached frame displays the currently selected saccade window (milliseconds) and an option to Confirm the current slider range or Cancel the action.
	"Clear":
		- The user must double-click on one of the "cfg_datatool" tables to specify the saccade trial and type (Initial/Final) they would like to clear.
		- After selection, a prompt will appear to verify user selection.
	
	Plot
	"Plot CFG":
		- Allows user to single-click or press up/down arrow keys on "cfg_datatool" tables, which will plot existing saccade selections on the ILAB main window.
		- An attached frame displays the Initial and Final saccade window of the selection, and allows the user to cancel the plotting action.
		- XY Time plots will highlight Initial saccades in green, and final saccades in cyan.
		- Plots also draw the offset of the "Delay" period in a dashed, green vertical line, and the onset of the "Feedback" period in a dashed, cyan vertical line.  See "Necessary files" for more details on experimental trial presentation structure.
		- Plots remain on ILAB window after plotting action has finished, until any UI items are changed.

	Analysis
	- Has not been implemented yet.

	About
	"Toolbox help": Displays this help file.0
	"About cfg_datatool": Additional toolbox information.

Dev Notes:

Backburner feature requests:
	Clearing saccades prior to “delay” event.
		- Needs to happen after latency files have been added, so after saccade generation occurs.
		- Warning, manipulates original saccade data
		- See ilabEditSaccadeCB.m/updateSaccadeTbl(AP)
	- Dotted lines aligned with slider thumbs

Implementation Considerations:
	Platform Specs:
		- Java Heap Size: 1082
		- File > Preferences > General > Java Heap Memory
		- Developed on 1680x1050 resolution screen
			- Positioned bottom of window at 15% total screen height from bottom of screen
			- Positioned total height of window to be 85% total screen height
	- Hammer Specs
			- hammer.rcc.psu.edu
			- Testing with remote desktop client, Exceed OnDemand
				- Xconfig: Seamless_Mode.cfg
				- Xstart: Gnome_Desktop.xs
				- Sometimes, Gnome desktop fails.  Sometimes does not allow windows outside of display screen.
			- "module load matlab/R2011b"
			- Current directory: /gpfs/home/krh5058/MATLAB/cfg_datatool
	- Hoth Specs
			- hoth.imaging.psu.edu
			- Testing with PuTTy client and Xming server port 22
				- :0 -clipboard -multiwindow
- Matlab Specs
	- ILAB 3.6.4
	- version -java
		Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) Client VM mixed mode
	- JIDE compatibility
- Assumed Excel compatibility
	- Not for Hammer

Known bugs:

	ILAB-related
	- Closing either "cfg_datatool" or "Saccade Results" windows typically results in loss of underlying data models or UI states.
	- Closing ILAB main window with the "X" button is not handled appropriately, which may result in unintentional toolbox behavior.
	- Instituting another "Saccade Results" (and setting an additional set of saccade parameters) results in loss of underlying data models or UI states.
	
	UI Components
	- cfg_datatool tables sometimes appear glitchy or update slow
	- Plotting may glitch axis drawing if single clicks occur too rapidly
	- Slider isn't 100% lined up with plot, due to track buffer
	- Confirm window is locked to upper right of ILAB windows.  If ILAB window is maximized, confirm window will be off-screen.
	- Using the keyboard to cycle through plotting too quickly will force the Matlab command line into focus.	

	Toolbox environment
	- Relocation of toolbox will cause pathing issues in previously saved files