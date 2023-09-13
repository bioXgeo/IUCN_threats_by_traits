Threats by Traits Project
----

Simple R script to pull IUCN redlist threats by species for use by students in MSU SpaCE lab https://www.communityecologylab.com

Installing
---

Install the packages above in your main R library, or consider using [renv](https://rstudio.github.io/renv/)

Packages used: 
 - [rredlist](https://cran.r-project.org/web/packages/rredlist/index.html
 - [jqr](https://cran.r-project.org/web/packages/jqr/)
 - dplyr and ggplot2
 
optional package: 
 - [googledrive](https://cran.r-project.org/web/packages/googledrive/) (if data is kept on google drive)

```R
pkgs = c('rredlist','dplyr', 'tidyr', 'ggplot2')
install.packages(pkgs)
```

API Key
---

Using ICUN api requires a key, and the documentation for the rredlist pacakge disusses this.   You should keep this key private not put this key into any code that goes into github.   

This code has a function you can riun to set the key before you can use the other functions

If your key is ABC123, then run this in your R session

```
mykey <- "ABC123"
set_token(mykey)
```

which will set the key is such a way that all the other rredlist functions can find it (it puts it into an OS Environment variables called IUCN_REDLIST_KEY that the rredlist package will look for).   See https://cran.r-project.org/web/packages/rredlist/rredlist.pdf for details.  


Usage
---

### step 1. Loading Data

The data file is not included with this code as IUCN updates it routinely.  You must first download the CSV of species into this folder or somewhere that you can access from R.    For example download and save to  "iucnspecies.csv."  Downloading data from IUCN requires an account, but you'll need the account to use the rredlist package.    


```
source('traitr.R')

# set up your IUCN key using rredlist function set_token

mykey <- "ABC123"
set_token(mykey)

species_data <- read.csv("IUCN_trait_montane_birds.csv")
species = 'Fratercula arctica' 
rl_search_(species) %>% dot()

```

For an example analysis, consider only using those that are not "Least Concern."  this requires dplyr, which is loaded if you 'source' the R file 

```
species_data <- dplyr::filter(species_data, category!="LC" ) # filter out the Least Concern species
```


Now download the trait data from IUCN. This will take a while (an hour?).  

Quick test of download: 
```

# to test with just a few species, try this ... 
threat_data <- threats_by_species(species_data$taxonid[1:10]) 
```

Download all except LC species: 

```
# this will take a long time! Each species_id is displayed while it downloads, 
# to cancel use ctrl+c
# nothing is saved if you cancel before it completes. 
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

t.df <- traits_and_threats(species_data, threat_data, trait_column )

# simple visualization of the resulting data
boxplot(Body_mass_value ~ threatcode, data=t.df, xlab="Threat Code", ylab="Body Mass")

# calculate basic stats 
t<- trait_summary_by_threat(species_data, threats_data, trait_column )
summary(t)
# fancier bar plot (looks nice but is not particularly meaningful)

trait_summary_barplot(t)

```    

These are too simplistic to be useful but you get the idea to build on. 

Notes
---

Note about the IUCN Threat data:   There is no guarantee that a threat code won't be repeated per species.  E.g. for taxonid 22681360 the code 2.1 appears twice in the list.   This will increase the count artificially but the occurrence is rare.  

To fix this if there are problems with the analysis, there is suggestion in the code (using unique() function) 
