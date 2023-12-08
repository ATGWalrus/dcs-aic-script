# dcs-gm-scripts
A scripted DCS environment designed for CSG-1, built upon MOOSE and currently using the Marianas map.
Currently incorporated features:
  - A/G and ASuW ranges
  - various A/A training features, with a particular focus on fleet defence and procedural generation of multi-group presentations for AIC training.
  - Airboss
  - RAT (in this implementation, not especially randomised)
  - Dynamic spawning of statics on carrier deck
  - Manual management of CV lights and other minor functionalities
As far as possible, functions are defined generically and will work with any appropriately-formatted data. Very little work should be required to adapt the scripts to a different map.
This data is currently internally stored in .lua files, future plans include the implementation of an external application to manage these tables (data-manager.lisp). 
