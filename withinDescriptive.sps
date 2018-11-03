* Encoding: UTF-8.
* Python function to compute within-group descriptive statistics
* Created by Jamie DeCoster

* Usage: withinDescriptive(Target Variable, Statistic, Group Variable, Output Variable)
* Target variable is the variable for which you want the descriptive statistic
* Statistic is the type of descriptive statistic that you want to calculate 
    Valid values for stat are MEAN STDDEV MINIMUM MAXIMUM
    SEMEAN VARIANCE SKEWNESS SESKEW RANGE
    MODE KURTOSIS SEKURT MEDIAN SUM
* The descriptive will be calculated within each level of the group variable
* This value will be assigned to the output variable

* EXAMPLE: withinDescriptive("test", "MEAN", "classroom", "classmean")
* Assuming that your data is children within classrooms, 
* this will assign the value of classmean to be the mean 
* for the particular child's classroom 
    
********
* Version History
********
* 2012-11-30 Created
* 2012-12-01 Added "exceute" after last "use all" command
    Updated descriptive function so it handles missing values better
* 2012-12-02 Deleted OMS handles to improve memory usage
* 2018-11-03 Updated descriptive function


*set printback=off.
begin program python.
import spss, spssaux

def getVariableIndex(variable):
   	for t in range(spss.GetVariableCount()):
      if (variable.upper() == spss.GetVariableName(t).upper()):
         return(t)

##########
# Obtain a list of all the possible values
##########

# Use the OMS to pull the values from the frequencies command

def getLevels(variable):
    submitstring = """use all.
execute.
SET Tnumbers=values.
OMS SELECT TABLES
/IF COMMANDs=['Frequencies'] SUBTYPES=['Frequencies']
/DESTINATION FORMAT=OXML XMLWORKSPACE='freq_table'.
    FREQUENCIES VARIABLES=%s.
    OMSEND.
SET Tnumbers=Labels.""" %(variable)
    spss.Submit(submitstring)
 
    handle='freq_table'
    context="/outputTree"
#get rows that are totals by looking for varName attribute
#use the group element to skip split file category text attributes
    xpath="//group/category[@varName]/@text"
    values=spss.EvaluateXPath(handle,context,xpath)

# If the original variable was numeric, convert the list to numbers

    varnum=getVariableIndex(variable)
    values2 = []
    if (spss.GetVariableType(varnum) == 0):
      for t in range(len(values)):
         values2.append(int(float(values[t])))
    else:
      for t in range(len(values)):
         values2.append("'" + values[t] + "'")
    spss.DeleteXPathHandle(handle)
    return values2

def descriptive(variable, stat):
# Valid values for stat are MEAN STDDEV MINIMUM MAXIMUM
# SEMEAN VARIANCE SKEWNESS SESKEW RANGE
# MODE KURTOSIS SEKURT MEDIAN SUM VALID MISSING
# VALID returns the number of cases with valid values, and MISSING returns
# the number of cases with missing values

     stat = stat.upper()
     if (stat == "VALID"):
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
          freqError = 0
          handle,failcode=spssaux.CreateXMLOutput(
          	cmd,
          	omsid="Frequencies",
          	subtype="Statistics",
          	visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
          	handle,
          	tableSubtype="Statistics",
          	cellAttrib="text")
          if (len(result) > 0):
               return int(result[0])
          else:
               return(0)

     elif (stat == "MISSING"):
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
          handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
		visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
          return int(result[1])
     else:
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /STATISTICS="+stat+"\n\
  /ORDER=ANALYSIS."
          handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
     		visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
          if (float(result[0]) <> 0 and len(result) > 2):
               return float((result[2]))

def withinDescriptive(Tvar, Stat, Gvar, Ovar):
    GvarLevels = getLevels(Gvar)
    for level in GvarLevels:
        submitstring = """USE ALL.
COMPUTE filter_$=(%s=%s).
FILTER BY filter_$.
EXECUTE.""" %(Gvar, level)
        spss.Submit(submitstring)
        x = descriptive(Tvar, Stat)
        if x <> None:
            submitstring = "if (%s = %s) %s = %s." %(Gvar, level, Ovar, x)
            spss.Submit(submitstring)
    submitstring = """use all.
execute."""
    spss.Submit(submitstring)

end program python.
set printback=on.

