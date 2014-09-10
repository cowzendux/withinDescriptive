#withinDescriptive

SPSS Python Extension function to compute within-group descriptive statistics

This function allows you to calculate a summary statistic for every observation in your dataset based only on observations that share a common group membership. For example, if you have a data set where you have multiple observations over time from multiple individual, this function would allow you to calculate the mean of each individual's own observations and add that into a new variable.

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html

##Usage
**withinDescriptive(Tvar, Stat, Gvar, Ovar)**
* "Tvar" is the variable for which you want the descriptive statistic
* "Stat" is the type of descriptive statistic that you want to calculate. Valid values for stat are 
  * MEAN - Mean
  * STDDEV - Standard deviation
  * MINIMUM - Minimum
  * MAXIMUM - Maximum
  * SEMEAN - Standard error of the mean
  * VARIANCE - Variance
  * SKEWNESS - Skewness
  * SESKEW - Standard error of the skewness
  * RANGE - Range
  * MODE - Mode
  * KURTOSIS - Kurtosis
  * SEKURT - Standard error of the kurtosis
  * MEDIAN - Median
  * SUM - Sum
* "Gvar" is the grouping variable, defining which observations are in the same group
* "Ovar" is the output variable, which will taken on the values of the calculated statistics

##Example
**withinDescriptive("test", "MEAN", "classroom", "classmean")**
* Assuming that your data is children within classrooms, this will assign the value of classmean to be the mean for the particular child's classroom.
