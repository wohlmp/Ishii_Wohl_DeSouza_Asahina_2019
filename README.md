# Ishii_Wohl_DeSouza_Asahina_2019
> Analysis package for the paper Ishii*, Wohl*, DeSouza, Asahina (2019) *co first authors

These codes were written and used to organize and analyze behavior experiments captured with BIAS: Basic Image Acquisition Software (Branson and Reiser labs, Janelia), tracked with FlyTracker (Eyjolfsdottir et al., 2014), and scored with behavior classifiers generated in house using JAABA software (Kabra et al, 2013).


## Software

I used the following software for analysis and figure production:
- BIAS
- MATLAB 2014b
- JAABA
- FlyTracker


## Code List

<b>Organize one experiment worth of movie files and related JAABA output files in MATLAB</b>
- `organizeData.m` : master code that organizes experimental data specified in an excel file
- `makeScoreStruct.m` : collects JAABA scores files for each movie specified in excel file
- 'makeFlymat.m' : organizes all data on a per-fly basis - data structure used for most analyses

<b>Apply behavior specific thresholds, smooth behavior data </b>
- 'changeConfidenceValCutoff.m' : Applies behavior-specific cuttoff threshold of JAABA confidence values at which to classify behaviors
- 'smoothBehavBouts.m' : Applies behavior-specific values to close behavior gaps and discard short behavior bouts to minimize false positives

<b>Analysis and Plotting data in MATLAB</b>
- 'makeMinuteBins.m' : splits behavior bouts and duration into minute-long bins
- `rastersFromFlymatAllByGenotype.m` : generates rasteres for each genotype specified in flymatAll structure


## Links

- Paper: 
- Data Repository: 
- Git Repository: https://github.com/wohlmp/Ishii_Wohl_DeSouza_Asahina_2019

  
## Contact
  
If you have any questions about the code, please contact wohlmp at gmail.com.
