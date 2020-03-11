
# example R
library(rredlist)
library(dplyr)

set_token <- function(iucn_token) {
    
    # this should work to be able to use IUCN, but untested
    Sys.setenv(IUCN_REDLIST_KEY=iucn_token)
}

traits_of_interest <- c('Body_mass_value', 'range_size', 'habitat_specialization', 'diet_cat', 'generation_time')

####### FUNCTIONS ##########
get_threat<- function(taxonid, verbose=TRUE){
    # get a single threat data structure for one taxonid
    # taxon id must be as in the IUCN Database, and must be a chactacter/string
    # using this function to explicitly use ID  argument instead of the default argument which is name
    # as using the ID is a little faster
    # and so it can be used in a list-apply function lapply
    # since this gets data via the Internet from IUCN, it can take a few seconds
    
    # tuses the rredlist R package.  
    t <- rredlist::rl_threats(id=taxonid)
    if(verbose) {print(t$id)}
    
    # output is the threat data structure from rredlist
    return(t)
}


get_threat_codes_per_id <- function(taxonid, verbose=TRUE){
      # creates a small data frame from threat data structure 
      # column 1 = taxonid  : all rows have the same value (the taxon id)
      # column 2 = threatcode : one row for each IUCN threat code, as read from the redlist api
     # this function is called by threats_by_id function  which merges all the small data frames together
    
        
      threat <- get_threat(taxonid, verbose = verbose)
      if(length(threat$result) > 0)
        {df<- data.frame(taxonid = as.integer(threat$id), threatcode = threat$result$code)}
      else
        {df<- data.frame(taxonid = as.integer(threat$id), threat=NA)}
      
      # note sometimes the threat data repeats the code, which results in duplicate records in this df. 
      # if this is a problem, try this instead (replacing the return below)
      # return(unique(df))
      
      return(df)
      
      # we are returning only the threat code, but we could return all the data per threat 
      # but the project for which this is for doesn't use those data
}


threats_by_species<- function(species_ids){
    # returns a new data frame with two columns: the taxon IDs and the threat codes
    # each ID is repeated for each threat code that exists for it
    # this will be used to count each threat code per id and vice versa
    # get a bunch of data.frames 
    list_of_dataframes<- mapply(get_threat_codes_per_id, species_ids, SIMPLIFY=FALSE)
    
    # use do.call to smush all of those data frames together, columns [taxonid], [threatcode]
    return(do.call(rbind, list_of_dataframes))

        # mutate(traits.df, threats = get_threat_codes_v(taxonid) )
    # return(traits.df)
}




get_threats_for_ids<- function(taxonids, verbose=TRUE){
    # OBSOLETE uses a different method and results are messy and can't combines
    # get all threat data for a list of IDs. 
    # for example
    # traits <- read.csv('traitfile.csv')
    # threat_codes <- get_threat_codes(taxonids =  filter(traits, category!="LC")$taxonid[1:10])
    
    threat_codes <- lapply(taxonids,get_threat_codes, verbose=verbose)
    return(threat_codes)
    #return( rl_threats(id=taxonid)$result$code)
}


traits_and_threats <- function(species_data, threat_data, trait_column) {
    df<- species_data %>% dplyr::select(c('taxonid', trait_column)) %>% inner_join( threat_data)
    return(df)
}

trait_summary_by_threat <- function(species_data, threat_data, trait_column){
    # used on the tables that have the common field taxonid 
    t <- traits_and_threats(species_data, threat_data, trait_column)  %>% group_by(threatcode) %>% summarise(mean_trait = mean(!!as.symbol(trait_column)), sd_trait = sd(!!as.symbol(trait_column)), n = n())
    return(t)

}

trait_summary_barplot <- function(t) {
    ggplot(t ) +
        geom_bar( aes(x=threatcode, y=mean_trait), stat="identity", fill="skyblue", alpha=0.5) +
        geom_errorbar( aes(x=threatcode, ymin=mean_trait-sd_trait, ymax=mean_trait+sd_trait), width=0.4, colour="orange", alpha=0.9, size=1.3) +
        coord_flip()
}



##### TESTING ####
look_for_threats <- function(species_ids){
    # for testing!
    # given a data frame that has a column with the IUCN code called taxonids
    # reads through rows in a trait data frame that has species ids, and stops 
    # at the first species that has threats in the IUCN database
    # this was used to discover which 
    for(species_id in species_ids){
        # info <- rl_search(id=species_id)
        # if ( length(info$result)==0) { 
        #     print(paste("no record for ",species_id))
        #     next
        # }
        threatdata <-  rl_threats(id=species_id)
        
        if(length(threatdata$result) != 0 ){
            print("found one, exiting...")
            print(threatdata)
            break
        } else {
            # still looking... print the id on the screen to track progress
            print(paste(trait_row$taxonid, ' ...'))
        }
    }
    
}


test_threats_by_species <- function(datafile="IUCN_trait_montane_birds.csv"){
    # function to show example of how you'd add threats to a trait table
    species_data <- read.csv(datafile)
    species_subset <- dplyr::filter(species_data, category!="LC" ) # filter out the LC species
    
    # this is required to use any of the IUCN 
    #  set_token()
    
    # pull just a few rows of  species for testing
    
    threats_data <- threats_by_species(species_ids = species_subset$taxonid[30:45])
    # prewvious method <- mutate(species_subset, threats = get_threat_codes_v(taxonid) )
    
    # now we have threats and ids together in one data frame, use inner join to combine them for a trait and summarise
    # result is a list of all body mass values and threat codes
    trait_column = 'Body_mass_value'
    t<- traits_and_threats(species_data, threats_data, trait_column )
    boxplot(Body_mass_value ~ threatcode, data=t, xlab="Threat Code", ylab="Body Mass")
    t<- trait_summary_by_threat(species_data, threats_data, trait_column )
    summary(t)
    
    # simple bar plot
    trait_summary_barplot(trait_by_threat)
    
    # threats_and_bodymass <- species_data %>% dplyr::select(c('taxonid','Body_mass_value')) %>% inner_join(df)
    # 
    # # 
    # threat_by_bodymass <- threats_and_bodymass %>% group_by(threatcode) %>% summarise(mean_body_mass = mean(Body_mass_value), sd = sd(Body_mass_value), n = n())
    # 
    # # horizontal
    # ggplot(threat_by_bodymass ) +
    #     geom_bar( aes(x=threatcode, y=mean_body_mass), stat="identity", fill="skyblue", alpha=0.5) +
    #     geom_errorbar( aes(x=threatcode, ymin=mean_body_mass-sd, ymax=mean_body_mass+sd), width=0.4, colour="orange", alpha=0.9, size=1.3) +
    #     coord_flip()
    # 
    return(threats_data)
    
    # to create a count table of traitX, threatX, count
    
}