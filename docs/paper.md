---
title: 'Tootsea : Matlab Toolbox for Time Series Exploration and Analysis'
tags:
  - Matlab
  - moorings
  - instrumentation
  - oceanography
authors:
 - name: Kevin Balem
   orcid: 0000-0002-4956-8698
   affiliation: "1"
affiliations:
 - name: Laboratoire d’Océanographie Physique et Spatiale (LOPS), CNRS, IRD, Ifremer, IUEM, Univ. Brest, 29280 Plouzané, France
   index: 1
date: 28 April 2020
bibliography: paper.bib
---

<style>img[alt$="<"] {
  float: left;
}
</style>

# Summary

![image alt <](media/logo_v2_paper.png)

During past decades, several research projects involved instrumented moorings ([@Ovide:2004], [@Rrex:2018]) in our lab. Those moorings lines are basically a collection of instruments connected to a wire and anchored on the sea floor (down to few thousand meters). It is the Eulerian way of measuring ocean currents, since a mooring is stationary at a fixed location. These projects generate quite long time series (up to few years), providing some new inputs to research perspectives ([@Lozier:2019]).
With those project came a need for a dedicated toolbox to read, analyze, pre-process and qualify data set from those multiple instruments. For example data has to be available in a proper output format, with a user defined time step and with some calculations on the data.

Initial objectives of this development were :
  - Read the output file of multiple oceanographic instruments.
  - Be able to add reader for other instruments in the future.
  - Do some pre-processing and allow user to apply their own processing codes.
  - Qualify the data automatically and manually and allow user to apply their own qualifying codes.
  - Export the data to standard netcdf format.
  - Do some basic plots.

# Tootsea

**Tootsea** is a matlab software designed to read, process, qualify and export data from typical moored instruments. As for today, it can reads input from some Nortek, RDI or Seabird instruments. It can also load netcdf files complient with time series format. In a UI based environment, user is able to :
  - **Edit** : this software allows to edit the variables attributes (name, units, fillValue, ...) and all metadata (wich can be loaded from the instrument of defined by the user). New variable can also be created by prebuild or custom functions.
  - **Correct** : Some correction tools are available in **Tootsea** so that common operations can be done quickly and easily (such as resampling, filtering, correcting magnetic declination, correcting potential drift, ...)
  - **Plot** : Are provided classical data visualisation tool such as histogram (fig1), spectrum or stickplot. It also allows users to generate some stats report.
  - **Qualify** : One key element of moorings dataset preprocessing is to apply quality flags on time series data. Within **Tootsea** it can be done automatically with built-in scripts, or manually. User can also import their own matlab scripts to do the qualification.
  - **Export** : Finally, user can save his work by 
      - exporting selected parameters to netcdf
      - saving current work session that will be loadable in **Tootsea**.
      - printing any figures in standard graphic formats.

![Plot example.\label{fig:example}](media/histo2d_paper.png)

**Tootsea** is used for multiple projects either to pre-process data on the ship quickly after moorings recovery, and then back at the lab to build proper moorings data files fitted for scientific analysis.

# Acknowledgements

The authors acknowledge Pascale Lherminier, Virginie Thierry, Pierre Branellec and Herlé Mercier, for their inputs, comments and ideas in the development of this tool.  

# References
