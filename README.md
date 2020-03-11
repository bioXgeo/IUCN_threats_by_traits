Threats by Traits Project
----

DRAFT README

Code in R to pull IUCN redlist threats by species


Packages use: 

rredlist
jqr

optional: googledrive if data is kept on google drive

```
library("rredlist")
library("jqr")
rl_search_('Fratercula arctica') %>% dot()

```

Note about the IUCN Threat data:   There is no guarantee that a threat code won't be repeated per species.  E.g. for taxonid 22681360 the code 2.1 appears twice in the list.   This will increase the count artificially but the occurrence is rare.  

To fix this if there are problems with the analysis, there is suggestion in the code (using unique() function) 