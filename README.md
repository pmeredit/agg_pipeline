To use:
pegjs agg_pipeline.pegjs && node main.js <file to parse>

Example: 
pegjs agg_pipeline.pegjs && node main.js examples/test

Important:  main.js contains a function to remove white space outside of strings, this is necessary.  PEGJS is rather annoying to handle whitespace directly
