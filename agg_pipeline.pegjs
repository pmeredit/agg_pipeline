{
   function cleanArray(arr) {
      var o = arr.map(part => part.filter(word => word !== ','))
                 .map(arr => arr[0]);
      return o;
   }
}

start
  = pipeline

pipeline =     st:stage                                          
               { 
	              return [st]; 
	       }  
           /  "[" st:stage stArr:("," stage)* ","? "]" 
	       { 
	              return [st].concat(cleanArray(stArr));
	       }
 
stage =  "{" collStats    ":" collStats_document          "}"
       / "{" project      ":" project_document            "}"
       / integer
      /* / "{" "$match"     ":" match_document              "}"
       / "{" "$redact"     ":" redact_document            "}"
       / "{" "$limit"     ":" limit_document              "}"
       / "{" "$skip"      ":" skip_document               "}"
       / "{" "$unwind"     ":" unwind_document            "}"
       / "{" "$group"     ":" group_document              "}"
       / "{" "$sample"     ":" sample_document            "}"
       / "{" "$sort"     ":" sort_document                "}"
       / "{" "$geoNear"     ":" geoNear_document          "}"
       / "{" "$lookup"    ":" lookup_document             "}"
       / "{" "$out"     ":" out_document                  "}"
       / "{" "$indexStats"     ":" indexStats_document    "}"
       / "{" "$facet"     ":" facet_document              "}"
       / "{" "$bucket"     ":" bucket_document            "}"
       / "{" "$bucketAuto"     ":" bucketAuto_document    "}"
       / "{" "$sortByCount"     ":" sortByCount_document  "}"
       / "{" "$addFields" ":" addFields_document          "}"
       / "{" "$replaceRoot"     ":" replaceRoot_document  "}"
       / "{" "$count"     ":" count_document              "}"
       / "{" "$graphLookup"     ":" graphLookup_document  "}"
       / "{" "$group"     ":" group_document              "}"
       */
                     
collStats = "$collStats"

collStats_document = "{" ci:collStats_item cArr:("," collStats_item)* "}" { [ci].concat(cleanArray(cArr)); }

collStats_item = latencyStats  ":" "{" histograms ":" boolean "}"
                 / storageStats ":" "{" "}"


latencyStats = "latencyStats" / "'latencyStats'" / '"latencyStats"'

storageStats = "storageStats" / "'storageStats'" / '"storageStats"'

histograms = "histograms" / "'histograms'" / '"histograms"'


project = '"$project"' / "'$project'" / "$project"

project_document = "{" ex:exclusion_spec exArr:("," exclusion_spec)* ","? "}" 
                          { return [ex].concat(cleanArray(exArr)); }
                 / "{" inp:inclusion_spec inArr:("," inclusion_spec)* ","? "}" 
                          { return [inp].concat(cleanArray(inArr)); }
     
exclusion_spec =   id   ":" ("0" / "false")  
                 / field ":" ("0" / "false") 

inclusion_spec =   id    ":" ("0" / "false") 
                 / field ":" ("1" / "true" / expression) 


id = 
  '_id' / "'_id'" / '"_id"'

// Need to expand what can be an expression
expression = integer / string / boolean

field "field name" 
  = [_A-Za-z] [_A-Za-z0-9]*
  / string

string
  = ["] str:([^"])* ["] { return str.join(""); } 
  / ['] str:([^'])* ['] { return str.join(""); }


integer "integer"                                        
  = digits:[0-9]+ { return parseInt(digits.join(""), 10) ; }
                                                         
boolean 
  = "true" {return true;} / "false" {return false;} 
                                                         
                                                         
                                                         
                                                         
