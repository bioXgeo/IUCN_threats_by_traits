Threats by Traits Project
----

DRAFT README

Code in R to pull IUCN redlist threats by species


Packages use: 

rredlist
jqr

optional: googledrive if data is kept on google drive

Example code that pulls redlist... 

```
library("rredlist")
library("jqr")
rl_search_('Fratercula arctica') %>% dot()

```

Installing
---

To work with the code here, use the following to install what you need, but just for this project in this folder.  Copy and paste this into Rstudio

```
install.packages('packrat')
packrat::init(infer.dependencies = FALSE,
              options = list(
                vcs.ignore.lib = TRUE,
                vcs.ignore.src = TRUE
              ))
pkgs = c('rredlist','dplyr', 'tidyr', 'ggplot2')
install.packages(pkgs)

```

Loading Data
---


The data file is not with this code. So first download the CSV of species into this folder or somewhere that you can access from R

```
source('traitr.R')  # I thought this was clever, but there packages named 'traits' and 'traitr' already exist
species_data <- read.csv("IUCN_trait_montane_birds.csv")
```

For now We are only looking at those that are not "Least Concern"

```
# this requires dplyr, which is loaded if you 'source' the R file 
species_data <- dplyr::filter(species_data, category!="LC" ) # filter out the LC species
```


Now download the trait data from IUCN. This will take a while (an hour?).  

```
threat_data <- threats_by_species(species_data$taxonid) 
# save this for later so you don't have to download again
save(threat_data, file='threats_montane_birds.rdata')
```

then for the next session, just load this into R

```
load('threats_montane_birds.rdata')
```

Analyzing Data
---

Now that you've preppared a table of species ID numbers (taxonid) with the same id in threats, you can combine threats and traits for analysis

Since there are many traits, there are functions that you can send the name of the trait (column) to make it simple to work with many traits. 

The example assume you've alreday loaded data, but if you have you should

```
source('traitr.R')  # I thought this was clever, but there packages named 'traits' and 'traitr' already exist
species_data <- read.csv("IUCN_trait_montane_birds.csv")
load('threats_montane_birds.rdata')  # threat_data


```

For example, Body mass: 

```

# combine body mass and threats
trait_column = 'Body_mass_value'

t.df <- traits_and_threats(species_data, threats_data, trait_column )

# simple visualization of the resulting data
boxplot(Body_mass_value ~ threatcode, data=t.df, xlab="Threat Code", ylab="Body Mass")

# calculate basic stats 
t<- trait_summary_by_threat(species_data, threats_data, trait_column )
summary(t)
```    

These are too simplistic to be useful but you get the idea. 

Notes
---

Note about the IUCN Threat data:   There is no guarantee that a threat code won't be repeated per species.  E.g. for taxonid 22681360 the code 2.1 appears twice in the list.   This will increase the count artificially but the occurrence is rare.  

To fix this if there are problems with the analysis, there is suggestion in the code (using unique() function) 