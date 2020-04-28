# Quick start

Here are some manual steps to follow in order to perform some basic behavior testing of the tool. For each test, each manual steps and a typical output will be described for validation. These tests are based on the [Release 1.1](https://github.com/quai20/TOOTSEA/releases) structure of Tootsea.

## BASIC

### Test n°1 : Load a Seabird SBE37 and display raw variables
* Testing steps :
  * `File` / `Import datafile` / `SBE3X_Parser`
  * Open `Data_Test/SBE/ov05-mc4008.asc`
  * On the 1st axes of the main figure, select `TEMP`
  * Click the `+` button in the bottom right to add an axes
  * Select `CNDC` in this new axes
  * Add another axes and select `PRES_REL`
* Expected results : 
  * 3 axes should be visible with `TEMP`, `CNDC` and `PRES_REL` displayed.
  * With the tools in the top menu bar, you should be able to zoom in/out and pan, with all 3 axes synchronized.
  * The added axes can be removed, but not the first one

### Test n°2 : Create subseries from raw variable
* Prerequisite : Test n°1
* Testing steps : 
  * `Corrections` / `Subserie` 
  * In the bottom left menu, select `PRES_REL` to change the displayed serie
  * With the `zoom in` tool, you can zoom on a part of the serie to check precisely your new serie limits. Then click `Set L1`, and double-click where you want to set your new start time. A red line should appear and the first date box is set.
  * Repeat the operation for the new end date of your serie with `Set L2`.
  * Date boxes are editable in necessary to adjust new limits. If you do so, a green line should appear in the new limits. Set limits to : 
        * 26/09/05-20:00
        * 19/06/06-20:00
  * You can set the suffix of your new series, by default it's `_sub`.
  * In the left menu, select all 3 variables (`CTRL+A` or `CTRL+CLICK`), and click `Save`
* Expected results :
  * The `Subserie` window should be closed.
  * 3 new series should be available in the `Time Series` menu and in the plotting menu of each axes available.

### Test n°3 : Create new parameters DEPTH and PSAL
* Prerequisite : Test n°1
* Testing steps : 
  * `Edit` / `New Parameter`
  * Click `DEPTH` in the top menu to pre-load the corresponding code.
  * Click `Evaluate` to check if the creation code runs. Bottom log console should turn red because `Latitude` is not defined 
  * Replace `Latitude` by `55.0`
  * Click `Evaluate`, it should turn green and the new `DEPTH` should appear in the left menu.
  * Repeat the operation for `PSAL` variable and click `Close`
* Expected results :
  * The `New Parameter` window should be closed
  * 2 new series should be available in the `Time Series` menu and in the plotting menu of each axes available.

### Test n°4 : Plot a 2D histogram

### Test n°5 : Complete Metadata

### Test n°6 : Edit Parameters

### Test n°7 : Save session & reload it
* Prerequisite : Test n°1
* Testing steps :
  * `File` / `Session` / `Save` (or `floppy disk` icon)
  * Save your `.mat` file where you want
  * `File` / `Reset` to relaunch `Tootsea`
  * `File` / `Session` / `Load` to load your previous session
  * Select the `.mat` file you just saved
* Expected results :
  * Your created series should be back in the `Time Series` menu.
  * Meta data created previously should be back in the `MetaData` menu.  
      

## INTERMEDIATE
...
## ADVANCED
...