#  Basic JSON and Web APIs

20 Minutes

---

## Learning Objectives

* Identify the structure of a JSON file
* Gather data from an API

---

## Introduction

JSON (JavaScript Object Notation) is a ubiquitous data format among web data
services.  Although JavaScript is in the name, most programming languages can
read and write JSON files.  The format uses human-readable text, so it's easy
to see the data.  Objects in JSON are based on keys and values, surrounded by
braces and separated by a colon:

```
 { key : value }
```

You can have multiple values, separated by commas:

```
{ key1 : value1 },
{ key2 : value2 }
```

You can also have arrays of values, designated by brackets:

```
{ "affiliations": [
        "California Institute of Technology, Pasadena, CA (US)",
        "National Institute of Meteorological Sciences, Seogwipo-si (KR)"
                    ] }
```

By combining these elements you can generate complex data structures that both
humans and machines can easily read.  Now we're going to take a look at the
results from a web API.  We're going to use two command line tools:

- `curl`: a Unix command for transferring data from or to an Internet server
  without human interaction. We will use `curl` to retrieve data from APIs.

# Using an API via a DOI

First, check that you are on your desktop.  Type

```
$ pwd
```

This will print your location to the terminal.  In most cases you can move to the
desktop by typing

```
$ cd ~/Desktop
```

Now we'll use curl to grab web content.  Note that you can copy and paste these
commands into your terminal window to save typing.

```
$ curl -LH "Accept:application/vnd.datacite.datacite+json" https://doi.org/10.14291/tccon.ggg2014.ascension01.R0/1149285
```

The -H option provides headers and the -L option tells curl to follow
redirects.  See what you get when you leave off the -L

Most DOIs have a special property that you can access an API by just using the
normal DOI URL.  In this case we're requesting DataCite standard JSON file by
the text in the header.  You can look at all the possible formats at the
[DataCite Documentation](https://support.datacite.org/docs/datacite-content-resolver).

You can save this metadata to a file by typing

```
$ curl -LH "Accept:application/vnd.datacite.datacite+json"
https://doi.org/10.14291/tccon.ggg2014.ascension01.R0/1149285 > datacite_metadata.json
```

Much more detail about DOIs and APIs is available in this [AuthorCarpentry Lesson](https://authorcarpentry.github.io/dois-citation-data)

Next: [Dataset Basics](01-basic-dataset.html)
