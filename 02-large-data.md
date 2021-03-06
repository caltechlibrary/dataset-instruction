
# Combining APIs with Dataset

20 min

---

Learning Objectives:

* Use Dataset tools to index and search over CaltechAUTHORS

---

## Dataset

This section of the lesson will expand on our previous example using two additional commands that 
come with _dataset_. The two are _dataset indexer_ and _dataset find_. The former creates a full text 
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
use _dataset indexer_ to index the CaltechAUTHORS collection. Finally we will query our index with _dataset find_ to identify 
records of interest. _dataset find_ can return results in several formats including
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

To tell _dataset indexer_ how to index we need a map. A map describes the relationship between data fields (e.g. a title,
an abstract) and how the indexer should treat those fields.  The simple index format supported by _dataset indexer_ 
is a JSON file. Create a JSON document called `title-author.json`.

```
    {
        "title": {
            "object_path": ".title"
        },
        "given_name": {
            "object_path": ".creators[:].given_name"
        },
        "family_name": {
            "object_path": ".creators[:].family_name"
        },
        "author_id": {
            "object_path": ".creators[:].id"
        },
        "orcid": {
            "object_path": ".creators[:].orcid"
        }
    }
```

### Creating the index

To create we use _dataset indexer_ giving it the index name and the map document name.

```
    dataset indexer title-authors.json title-authors.bleve
```

Depending on the data, this command might take awhile to run.  Authors and
titles is quick, but including full abstracts makes it much longer for the
indexes to run. Additionally indexes can become quiet large (the example
indexes take up almost 400 MB of diskspace). 

Normally you don't start by indexing the whole collection. You index just a sample to make
sure everything is working. Once the index structure is as you like it then you start the
index for the entire collection. Let's index across the abstracts of a sample
of CaltechAUTHORS.  We first create a new key list sample
then index the collection using the key list.  Save this as abstract.json

```
    {
        "abstract": {
            "object_path": ".abstract"
        },
```

Then run these commands:

```
    dataset -sample 2500 keys > sample2.keys
    dataset indexer -key-file=sample2.keys abstract.json abstract.bleve
```

You can also update or delete records from an index.  However this can be slower then creating a new one under many
circumstances. You'll want to consider your options carefully if you're working
with extremely large datasets.


### Searching our index

The index we create allows us to perform a full text search across the index. Unlike
a relational database query we can find approximate matches as well as narrow results
to specific fields and phrases. Dataset index use the [Bleve](https://blevesearch.com)
search platform which uses a query syntax similar to Elastic Search.

```
    dataset find title-authors.bleve "calcium carbonate"
    dataset find title-authors.bleve author_id:Readhead-A-C-S
```


Previous: [Basic Dataset](01-basic-dataset.html)  
