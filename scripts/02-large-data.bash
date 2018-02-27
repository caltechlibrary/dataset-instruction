#!/bin/bash

# Clean up from a stale run
rm -fR title-abstract-authors.bleve title-abstract-authors.json

export DATASET="CaltechAUTHORS.ds"


# Create initial sample
dataset -sample 5 keys > sample1.keys
while read KY; do
    dataset -pretty read "$KY"
done <sample1.keys

# Create our title-abstract-authors.json index map
cat <<EOT > title-abstract-authors.json
{
    "title": {
        "object_path": ".title"
    },
    "abstract": {
        "object_path": ".abstract"
    },
    "given_name": {
        "object_path": ".creators.item[:].given_name"
    },
    "family_name": {
        "object_path": ".creators.item[:].family_name"
    },
    "author_id": {
        "object_path": ".creators.item[:].id"
    },
    "orcid": {
        "object_path": ".creators.item[:].orcid"
    }
}
EOT

# Create out index sample set
dataset -sample 2500 keys > sample2.keys
dsindexer -key-file=sample2.keys title-abstract-authors.json title-abstract-authors.bleve
