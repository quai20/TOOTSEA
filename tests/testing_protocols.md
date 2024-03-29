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
* Prerequisite : Test n°1
* Testing steps : 
  * `Plots/Stats` / `Histogram`
  * Select `1 dimension`, `TEMP` in the 1st variable menu and `All data`.
  * Set first limits to 3 / 7, and set the `Bin number` to 50
  * Click `Plot`
* Expected results :
  * The distribution of the measured temperature between 3°C and 7°C
* Other testing steps :
  * Select `2 dimensions`, `TEMP` in the 1st variable menu, `CNDC` in the 2nd and `All data`.
  * Set first limits (`TEMP`) to `3 / 7`, and second (`CNDC`) to `3 / 3.7`.
  * Then, instead of setting the number of bins, set the bin size to `0.1` for x (`TEMP`) and `0.01` for y (`CNDC`)
  * Click `Plot`
* Expected results :
  * The 2D distribution of the conductivity function of temperature

### Test n°5 : Complete Metadata
* Prerequisite : Test n°1
* Testing steps : 
  * `Edit` / `Edit Metadata`
  * Click on `+` button to add many lines as you wish.
  * Fill `Properties` and `Values`, for the lines you created
  * Click `Save`
* Expected results :
  * The `Edit Metadata` window should be closed
  * New meta should be available in the `MetaData` menu of the main figure.

### Test n°6 : Edit Parameters
* Prerequisite : Test n°1
* Testing steps : 
  * `Edit` / `Edit Parameters`
  * Select `PRES_REL` in the variable menu and click `edit` to activate edition mode.
  * Change the name of the variable to `PRES` and the `FillValue` to `NaN`
  * Click `ok`, the variable menu should turn green.
  * Click `Save & Close`
* Expected results :
  * In the `Time Series` menu, the variable should appear with its new name. Other modified properties are stored for future netcdf export.

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
      
 ### Test n°8 : Export to netcdf
* Prerequisite : Test n°1
* Testing steps :
  * `File` / `Export` / `Netcdf`
  * Check if mandatory MetaData are filled ("`Latitude`", "`Longitude`") (see `Test n°5`). If not (MetaData in red), please complete MetaData.
  * Add some variables to the netcdf by selecting variable in the left menu and clicking `Add`. It will ask you to add QC.  
  * Click `Save file`, it will ask you where you want to save your file.  
* Expected results :
  * A netcdf file should be created, as well as a validation message.           
