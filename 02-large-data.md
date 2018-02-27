
# Combining APIs with Dataset

20 min

---

Learning Objectives:

* Use Dataset tools to index and search over CaltechAUTHORS

---

## Dataset

This section of the lesson will expand on our previos example using two additional tools that 
come with _dataset_. The two are _dsindexer_ and _dsfind_. The former creates a full text 
index and the latter lets you search that index and retrieve the results in various forms
(e.g. plain text, JSON, CSV).

## Data Sources

### CaltechAUTHORS

[CaltechAUTHORS](https://authors.library.caltech.edu) is a repository of over 70,000 research papers authored by Caltech 
faculty and other researchers at Caltech.  The repository is large so Caltech Library makes snapshots of the 
metadata of public records and stores them in as a _dataset_collection_. This will serve our purposes for a demonstrating
working with a large collection of data.

## Basic Operations


First we need to decide how we want to index. Next we create our index definition (map)  and
use _dsindexer_ to index the CaltechAUTHORS collection. Finally we will query our index with _dsfind_ to identify 
records of interest. _dsfind_ can return results in several formats including
plain text, JSON and CSV. First we set that we're working with CaltechAUTHORS

```
    export DATASET="CaltechAUTHORS.ds"
```

### Deciding what to index

We have already seen how we have used _dataset_ to list the keys in a collection. We can get a sampling of
keys and review those to see how we might want to index our collection. Run the
following script to get a random sample of five records from our collection:

```
    dataset -sample 5 keys > sample1.keys
    while read KY; do
        dataset -pretty read "$KY" | more
    done <sample1.keys

```

The `.abstract` field looks interesting so we can try indexing that. Indexes can be combined so if later we want
to also include `.title` or `.publication` we can just create indexes for this. Generally speaking indexes
with fewer fields are quicker to build.

### Creating an index map

To tell _dsindexer_ how to index we need a map. A map describes the relationship between data fields (e.g. a title,
an abstract) and how the indexer should treat those fields.  The simple index format supported by _dsindexer_ 
is a JSON file. Create a JSON document called `title-abstract-author.json`.

```
    {
        "title": {
            "object_path": ".title"
        },
        "abstract": {
            "object_path": ".abstract"
        },
        "given_name:" {
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
```

### Creating the index

To create we use _dsindexer_ givening it the index name and the map document name.

```
    dsindexer title-abstract-authors.json title-abstract-authors.bleve
```

This command will take a while to run (hours on my desktop system, indexing only the titile
took 1/2 on my work desktop). Additionally Indexes can also become quiet large (just the title
field took up nearly 200 meg of dispace). 

Normally you don't start by indexing the whole collection. You index just a sample to make
sure everything is working. Once the index structure is as you like it then you start the
index for the entire collection. In the next example we first create a new key list sample
then index the collection using the key list.

```
    dataset -sample 2500 keys > sample2.keys
    dsindexer -key-file=sample1.keys title-abstract-authors.json title-abstract-authors.bleve
```

Updating or deleting records from an an index can be slower then creating a new one under many
circumstances. Generally if it is a large number of records changing I recommend 
creating a new index, if it index is large and you are changing a small number records try
updating instead.


### Searching our index

The index we create allows us to perform a full text search across the index. Unlike
a relational database query we can find approximate matches as well as narrow results
to specific fields and phrases. Dataset index use the [Bleve](https://blevesearch.com)
search platform which uses a query syntax similar to Elastic Search.

```
    dsfind abstract.bleve "calcium carbinate"
```


Previous: [Basic Dataset](01-basic-dataset.html)  
