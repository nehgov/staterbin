# State and territory tile files

Tile choropleth like those created with the
[statebins](https://github.com/hrbrmstr/statebins) R package usefully preserve
the general placement of states while removing differences in size that can skew
interpretation of data unrelated to land area. This repository creates
lightweight GeoJSON and TopoJSON tile choropleth files that can be used in any
GIS program or package that accepts such files. In addition, they include
squares for the five permanently inhabited US territories: American Samoa, Guam,
Northern Mariana Islands, Puerto Rico, and the U.S. Virgin Islands.

Pre-built spatial files are located in the `geo` directory.

# Examples
**GeoJSON**
![Figure using GeoJSON file](figures/geojson_figure.png)

**TopoJSON**
![Figure using TopoJSON file](figures/topojson_figure.png)

# Building the files

## Required packages

- `tidyverse`
- `sf`
- `geojsonio`
- `crosswalkr`
- `viridis`

## To build

To build the `geojson` and `topojson` files, make `./scripts` the working
directory, and run `make_geo_data.R`.

To create the example figures, next run `make_example_figures.R`.

# Acknowledgments

The arrangement of the map tiles is modified from code provided in the
[statebins](https://github.com/hrbrmstr/statebins) R package.

# Disclaimer

This software is licensed under the CC0 license. It is provided "as is" without
any warranty of any kind, either expressed, implied, or statutory, including,
but not limited to, any warranty that the subject software will conform to
specifications, any implied warranties of merchantability, fitness for a
particular purpose, or freedom from infringement, any warranty that the subject
software will be error free, or any warranty that documentation, if provided,
will conform to the subject software. This agreement does not, in any manner,
constitute an endorsement by the National Endowment for the Humanities (NEH) or
any prior recipient of any results, resulting designs, hardware, software
products or any other applications resulting from use of the subject software.
Further, NEH disclaims all warranties and liabilities regarding third-party
software, if present in the original software, and distributes it "as is."

The recipient agrees to waive any and all claims against the United States
government, its contractors and subcontractors, as well as any prior recipient.
If recipient’s use of the subject software results in any liabilities, demands,
damages, expenses or losses arising from such use, including any damages from
products based on, or resulting from, recipient’s use of the subject software,
recipient shall indemnify and hold harmless the United States government, its
contractors and subcontractors, as well as any prior recipient, to the extent
permitted by law. Recipient’s sole remedy for any such matter shall be the
immediate, unilateral termination of this agreement.

