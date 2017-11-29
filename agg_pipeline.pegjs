{
   // remove commas and flatten
   // this works with our ("," expression*) ","? idiom 
   function cleanAndFlatten(arr) {
      var o = arr.map(part => clean(part))
                 .map(arr => arr[0]);
      return o;
   };
   // remove commas
   function clean(arr) {
	var o = arr.filter(word => word !== ',');
	return o;
   };
   // array will always have elements of the form [ "key", ":", "value" ]
   function objOfArray(arr) {
    	var ret = {}
	for(let tup of arr) {
		ret[tup[0]] = tup[2];
	}
	return ret;
   };
}

start
  = pipeline

pipeline =     st:stage                                          
               { 
	              return [st]; 
	       }  
           /  "[" st:stage stArr:("," stage)* ","? "]" 
	       { 
	              return [st].concat(cleanAndFlatten(stArr));
	       }

stage = sts:stage_syntax {
                           var obj = {}; 
			   obj[sts[1]] = sts[3]; 
			   return obj; 
			 } 

// TODO: finish last few stages
stage_syntax =  
         "{" collStats    ":" collStats_document          "}"
       / "{" project      ":" project_document            "}"
       / "{" match        ":" match_document              "}"
//       / "{" "$redact"     ":" redact_document            "}"
       / "{" limit        ":" positive_integer            "}"
       / "{" skip         ":" positive_integer            "}"
       / "{" unwind       ":" unwind_document             "}"
       / "{" group        ":" group_document              "}"
//       / "{" "$sample"     ":" sample_document            "}"
       / "{" sort         ":" sort_document               "}"
//       / "{" "$geoNear"     ":" geoNear_document          "}"
       / "{" lookup       ":" lookup_document             "}"
       / "{" out          ":" string                      "}" // TODO: check is valid collection?
       / "{" indexStats   ":" indexStats_document         "}"
//       / "{" "$facet"     ":" facet_document              "}"
//       / "{" "$bucket"     ":" bucket_document            "}"
//       / "{" "$bucketAuto"     ":" bucketAuto_document    "}"
//       / "{" "$sortByCount"     ":" sortByCount_document  "}"
       / "{" addFields   ":" addFields_document          "}"
//       / "{" "$replaceRoot"     ":" replaceRoot_document  "}"
       / "{" count       ":" string                      "}"
//       / "{" "$graphLookup"     ":" graphLookup_document  "}"
       
                     
collStats = "$collStats" / "'$collStats'" { return '$collStats'; } / '"$collStats"' { return '$collStats'; }
collStats_document = "{" ci:collStats_item cArr:("," collStats_item)* ","? "}" 
                { 
		   return [ci].concat(cleanAndFlatten(cArr)); 
		}
collStats_item = lt:latencyStats  ":" "{" h:histograms ":" b:boolean "}" 
                { 
		  var obj = {}; 
		  obj[lt] = {}, 
		  obj[lt][h] = b; 
		  return obj; 
	        }
               / s:storageStats ":" "{" "}" 
		{ 
		  var obj = {}; 
		  obj[s] = {}; 
		  return obj;
		}

// I wish pegjs had macros...
latencyStats = "latencyStats" / "'latencyStats'" { return 'latencyStats'; } / '"latencyStats"' { return 'latencyStats'; }
storageStats = "storageStats" / "'storageStats'" { return 'storageStats'; } / '"storageStats"' { return 'storageStats'; }
histograms = "histograms" / "'histograms'" { return 'histograms'; } / '"histograms"' { return 'histograms'; }

project = '"$project"' { return '$project'; } / "'$project'" { return '$project'; } / "$project"
project_document = "{" s:project_item sArr:("," project_item)* ","? "}" 
                    { 
		       return objOfArray([s].concat(cleanAndFlatten(sArr))); 
		    }
project_item =   i:id    ":" t:("0" / "false" / "1" / "true")  
       / f:field ":" e:("0" / "false" / "1" / "true" / expression) 

// Unfortunately this doesn't work like it would in LR parsing, will
// need an AST pass to make exclusion and inclusion... exclusive (wacka wacka)
/*
project_document = "{" ex:exclusion_project_item exArr:("," exclusion_project_item)* ","? "}" 
                          { return [ex].concat(cleanAndFlatten(exArr)); }
                 / "{" inp:inclusion_project_item inArr:("," inclusion_project_item)* ","? "}" 
                          { return [inp].concat(cleanAndFlatten(inArr)); }

exclusion_project_item =   id   ":" ("0" / "false")  
                 / field ":" ("0" / "false") 

inclusion_project_item =   id    ":" ("0" / "false") 
                 / field ":" ("1" / "true" / expression) 
*/

match = '"$match"' { return '$match'; } / "'$match'" { return '$match'; } / "$match"
// need grammar for all of match, should support top level expressions ($and and $or)
match_document = "{" s:match_item sArr:("," match_item)* ","? "}" 
                    { 
		       return objOfArray([s].concat(cleanAndFlatten(sArr))); 
		    }
match_item = f:field ":" e:expression

limit = '"$limit"' { return '$limit'; } / "'$limit'" { return '$limit'; } / "$limit"

skip  = '"$skip"' { return '$skip'; } / "'$skip'" { return '$skip'; } / "$skip"

unwind = '"$unwind"' { return '$unwind'; } / "'$unwind'" { return '$unwind'; } / "$unwind"
unwind_document = string // field path TODO: check in AST that fieldpath begins with '$'
                / "{" u:unwind_item uArr:("," unwind_item)* ","? "}" 
                { 
                   return objOfArray([u].concat(cleanAndFlatten(uArr)));
	        }
unwind_item =  path ":" string // field path TODO: check in the AST that fieldpath begins with '$'
               / includeArrayIndex ":" string
               / preserveNullAndEmptyArrays ":" boolean
path                       = '"path"' { return 'path'; } 
                           / "'path'" { return 'path'; } 
			   / "path"
includeArrayIndex          = '"includeArrayIndex"' { return 'includeArrayIndex'; } 
                           / "'includeArrayIndex'" { return 'includeArrayIndex'; } 
			   / "includeArrayIndex"
preserveNullAndEmptyArrays = '"preserveNullAndEmptyArrays"' { return 'preserveNullAndEmptyArrays'; } 
                           / "'preserveNullAndEmptyArrays'" { return 'preserveNullAndEmptyArrays'; } 
			   / "preserveNullAndEmptyArrays"

group          = '"$group"' { return '$group'; } / "'$group'" { return '$group'; } / "$group"
group_document ="{" g:group_item gArr:("," group_item)* ","? "}" 
                { 
                   return objOfArray([g].concat(cleanAndFlatten(gArr)));
	        }
group_item     = id ":" expression
               / f:field ":" "{" a:accumulator ":" e:expression "}" 
	       {
                   var obj = {};
		   obj[a] = e;
		   return [f, ":", obj];
	       }
accumulator    = sum
               / avg
	       / first
	       / last
	       / max
	       / min
	       / push
	       / addToSet
	       / stdDevPop
	       / stdDevSamp
sum        = "$sum" / "'$sum'" { return '$sum'; } / '"$sum"' { return '$sum'; }
avg        = "$avg" / "'$avg'" { return '$avg'; } / '"$avg"' { return '$avg'; }
first      = "$first" / "'$first'" { return '$first'; } / '"$first"' { return '$first'; }
last       = "$last" / "'$last'" { return '$last'; } / '"$last"' { return '$last'; }
max        = "$max" / "'$max'" { return '$max'; } / '"$max"' { return '$max'; }
min        = "$min" / "'$min'" { return '$min'; } / '"$min"' { return '$min'; }
push       = "$push" / "'$push'" { return '$push'; } / '"$push"' { return '$push'; }
addToSet   = "$addToSet" / "'$addToSet'" { return '$addToSet'; } / '"$addToSet"' { return '$addToSet'; }
stdDevPop  = "$stdDevPop" / "'$stdDevPop'" { return '$stdDevPop'; } / '"$stdDevPop"' { return '$stdDevPop'; }
stdDevSamp = "$stdDevSamp" / "'$stdDevSamp'" { return '$stdDevSamp'; } / '"$stdDevSamp"' { return '$stdDevSamp'; }

sort = '"$sort"' { return '$sort'; } / "'$sort'" { return '$sort'; } / "$sort"
// need grammar for all of sort, should support top level expressions ($and and $or)
sort_document = "{" s:sort_item sArr:("," sort_item)* ","? "}" 
                    { 
		       return objOfArray([s].concat(cleanAndFlatten(sArr))); 
		    }
sort_item = f:field ":" i:integer

lookup = '"$lookup"' { return '$lookup'; } / "'$lookup'" { return '$lookup'; } / "$lookup"
lookup_document = string // field path TODO: check in AST that fieldpath begins with '$'
                / "{" l:lookup_item lArr:("," lookup_item)* ","? "}" 
                { 
                   return objOfArray([l].concat(cleanAndFlatten(lArr)));
	        }
lookup_item =  from ":" string // TODO: perhaps check this is a valid collection
               / localField ":" string // For some reason this doesn't need a $
               / foreignField ":" string 
               / as ":" string 
from           = '"from"' { return 'from'; } 
               / "'from'" { return 'from'; } 
	       / "from"
localField     = '"localField"' { return 'localField'; } 
               / "'localField'" { return 'localField'; } 
	       / "localField"
foreignField   = '"foreignField"' { return 'foreignField'; } 
               / "'foreignField'" { return 'foreignField'; } 
	       / "foreignField"
as             = '"as"' { return 'as'; } 
               / "'as'" { return 'as'; } 
	       / "as"

out = '"$out"' { return '$out'; } / "'$out'" { return '$out'; } / "$out"

indexStats = '"$indexStats"' { return '$indexStats'; } / "'$indexStats'" { return '$indexStats'; } / "$indexStats"
// need grammar for all of indexStats, should support top level expressions ($and and $or)
indexStats_document = "{""}" 
                    { 
		       return {}; 
		    }

addFields = '"$addFields"' { return '$addFields'; } / "'$addFields'" { return '$addFields'; } / "$addFields"
addFields_document = "{" a:addFields_item aArr:("," addFields_item)* ","? "}" 
                    { 
		       return objOfArray([a].concat(cleanAndFlatten(aArr))); 
		    }
addFields_item = f:field ":" expression

count = '"$count"' { return '$count'; } / "'$count'" { return '$count'; } / "$count"
// expressions

id = '_id' / "'_id'" { return '_id'; } / '"_id"' { return '_id'; }

// TODO: Need to expand what can be an expression, add arrays, documents, and perhaps 
// (though these could just be checked in AST) let/map/functions/etc 
expression = integer / string / boolean

field "field name" // TODO: better grammar for field names
  = f:[_A-Za-z] s:([_A-Za-z0-9]*) { return f + s.join(""); }
  / string

string
  = ["] str:([^"])* ["] { return str.join(""); } 
  / ['] str:([^'])* ['] { return str.join(""); }


integer "Integer" = positive_integer / "-" i:positive_integer { return -1 * i; }

positive_integer "Positive Integer"                                  
  = digits:[0-9]+ { return parseInt(digits.join(""), 10) ; }
                                                         
boolean 
  = "true" {return true;} / "false" {return false;} 
                                                         
                                                         
                                                         
                                                         
