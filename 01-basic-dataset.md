# Basic Dataset

20 min

---

Learning Objectives:

* Use basic dataset commands

---

## Dataset

Dataset is a set of tools for managing multiple JSON documents in an efficient
way.  These JSON documents are stored as files, and the operations dataset
performs are transpartent even if you're not using the application.  You have
the option to store files on your local machine or with a cloud storage
provider like Amazon Web Services or Google.

# Basic Operations

The first step in using dataset is to define a collection.  This is a way to
organize a set of related JSON documents, and you can have multiple
collections.  On the command line type:

```
dataset init publications.ds
```

where 'publications.ds' is the arbitrary name you want to give the collection.
Dataset (if successful) will respond with a line like:

```
export DATASET=publications.ds
```

You can copy and paste this command to the command line - it's a shortcut to
avoid having to type the collection name every time you call the dataset
command.  If you look in you current directory you'll see a directory on 
your file system called 'collection_name'.  This is where all your JSON
documents will be stored.

Let's create some documents!  Type:

```
dataset create 1 '{"arxiv":1711.03979,"doi":"10.3847/1538-4357/aa9992"}'
dataset create 2 '{"arxiv":1507.08280,"doi":"10.1093/mnras/stv1793"}'
dataset create 3 '{"arxiv":1305.6004,"doi":"10.1051/0004-6361/201321484"}'
```

In these examples the number is our document name (in this example it's an
imaginary numbering system) and the JSON file contains
the doi and arxiv identifier of an article.

We can then look at what documents we have by typing

```
dataset keys
```

And we can look at a document by typing

```
dataset read 1
```

We can make changes to our documents

```
dataset update 3 '{"arxiv":"1305.6005","doi":"10.1051/0004-6361/201321484"}'
```

And remove documents

```
dataset delete 1
```

We can also pull out subsets of documents.  Let's find documents with and arxiv
id of 1305.6005:

```
dataset keys '(eq .arxiv "1305.6005")'
```

'eq' indicates we want our field to be equal to the given value. Other options
are listed
[here](https://caltechlibrary.github.io/dataset/docs/dataset/keys.html)
The '.' notation indicates what field from the json file we want to look at.

# Combining with APIs

Let's say we want to get citation counts for all the articles in our dataset.
We're going to use the Dimensions API.  Let's first do an example of a manual
API call

```
curl https://metrics-api.dimensions.ai/doi/10.1051/0004-6361/201321484
```
 
We get back a JSON file with some useful data.  Let's say we want to add just
the 'times_cited' value it to our dataset.
First we'll save the API results to a file, use the jsonmunge tool to extract
the field and create a second JSON file, and then use the join command to add the information to
dataset.

```
curl https://metrics-api.dimensions.ai/doi/10.1051/0004-6361/201321484 > dimensions.json
jsonmunge -i dimensions.json -E '{{- with .times_cited }}{"times_cited":{{- . -}}}{{- end -}}' > times_cited.json
dataset -i times_cited.json join update 3 

dataset -pretty read 3
```

To use the join command we meed to know the record we're updating ('3' in this
case).  We also have two options - 'update' that adds new fields but doesn't change existing
data and 'overwrite' which will update all fields in common.

This is annoying to do by hand.  We want to run this automatically for all publications
in our dataset collection.  We need to write a short script to carry out this
operation.

```
dataset keys | while read KY; do
    dataset read "$KY" > record.json
    URL=$(jsonmunge -i record.json -E '{{- with .doi -}}https://metrics-api.dimensions.ai/doi/{{- . -}}{{- end -}}')

    curl "$URL" > dimensions.json
    jsonmunge -i dimensions.json -E '{{- with .times_cited }}{"times_cited":{{- . -}}}{{- end -}}' > times_cited.json
    dataset -i times_cited.json join update "$KY"

    dataset -pretty read "$KY"
done
```

# Google Docs

---

Previous: [JSON and APIs](00-intro-json-apis.html)  
Next: [Combining APIs with Dataset](02-combining-apis.html)  
