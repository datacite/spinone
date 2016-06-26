---
layout: page
title: "Home"
---

## Version History

* v.1: June 25, 2016, first draft.

## Overview

The API is generally RESTFUL and returns results in JSON. The API follows the [JSONAPI](http://jsonapi.org/) specification.

## Results Overview

All results are returned in JSON. There are two general types of results:

* Singletons
* Lists

The mime-type for API results is `application/vnd.api+json`.

### Singletons

Singletons are single results. Retrieving metadata for a specific identifier (e.g. DOI, ORCID) typically returns in a singleton result.

### Lists

Lists results can contain multiple entries. Searching or filtering typically returns a list result. A list has two parts:

* **meta**, which includes information about the query, e.g. number of results returned.
* **data**, which will will contain the items matching the query or filter.

### Sort order

If the API call includes a query, then the sort order will be by the relevance score. If no query is included, then the sort order will be by DOI deposit date.

## Resource Components

Major resource components supported by the DataCite API are (in alphabetical order):

* agents
* contributions
* contributors
* events
* groups
* members
* pages
* publishers
* registration-agencies
* relations
* relation-types
* resource-types
* sources
* works
* work-types

These can be used alone like this

| Resource                 | Description                       |
|:-------------------------|:----------------------------------|
| `/agents`                | returns a list of agents used by the Event Data service |
| `/contributions`         | returns a list of all contributions from the Event Data service |
| `/contributors`          | returns a list of all contributors |
| `/events`                | returns a list of recent events from the Event Data service |
| `/groups`                | returns a list of groups for sources used by Event Data service |
| `/members`               | returns a list of all DataCite members |
| `/pages`                 | returns a list of posts from the DataCite blog |
| `/publishers`            | returns a list of all DataCite members |
| `/registration-agencies` | returns a list of registration agencies used by the Event Data service |
| `/relations`             | returns a list of all relations from the Event Data service |
| `/relation-types`        | returns a list of valid relation types |
| `/resource-types`        | returns a list of valid resource types |
| `/sources`               | returns a list of sources used by the Event Data service |
| `/works`                 | returns a list of all works (datasets, text documents, etc.), 25 per page
| `/work-types`            | returns a list of valid work types |

### Resource components and identifiers
Resource components can be used in conjunction with identifiers to retrieve the metadata for that identifier.

| Resource                     | Description                                      |
|:-----------------------------|:-------------------------------------------------|
| `/members/{member-id}`       | returns metadata for a DataCite member           |
| `/publisher/{publisher-id}`  | returns metadata for a DataCite data center      |
| `/works/{doi}`               | returns metadata for the specified DataCite DOI. |
| `/work-types/{work-type-id}` | returns information about a specified work type  |

### Combining resource components

The works component can be appended to other resources.

| Resource                    | Description                       |
|:----------------------------|:----------------------------------|
| `/works/{doi}`      | returns information about the specified DataCite `DOI` |
| `/members/{member-id}/works` | returns list of works associated with a DataCite member |
| `/publishers/{publisher-id}/works` | returns list of works associated with a DataCite data center |
| `/sources/{source-id}/works` | returns list of works associated with an Event Data source |

## Parameters

Parameters can be used to query, filter and control the results returned by the DataCite API. They can be passed as normal URI parameters or as JSON in the body of the request.

| Parameter                    | Description                 |
|:-----------------------------|:----------------------------|
| `query`                      | limited [DisMax](https://wiki.apache.org/solr/DisMax) query terms |
| `rows`                       | results per per page |
| `offset`                     | result offset |
| `sort`                       | sort results by a certain field |
| `order`                      | set the sort order to `asc` or `desc` |

### Example query using URI parameters

```
https://api.datacite.org/members/cern/works?query=python&rows=1
```

### Queries

Queries support a subset of [DisMax](https://wiki.apache.org/solr/DisMax), so, for example you can refine queries as follows.

Works that include "renear" but not "ontologies":

```
https://api.datacite.org/works?query=renear+-ontologies
```

### Sorting

Results from a listy response can be sorted by applying the `sort` and `order` parameters. Order sets the result ordering, either `asc` or `desc`. Sort sets the field by which results will be sorted. Possible values are:

| Sort value  | Description                                    |
|-------------|------------------------------------------------|
| `score`     | Sort by relevance score                        |
| `updated`   | Sort by date of most recent change to metadata |
| `deposited` | Sort by time of most recent deposit            |
| `published` | Sort by publication date                       |

An example that sorts results in order of publication, beginning with the least recent:

```
https://api.datacite.org/works?query=josiah+carberry&sort=published&order=asc
```

### Facet Counts

Facet counts are returned via the `meta` object. Facet counts give counts per field value for an entire result set.

### Filter Names

Filters allow you to narrow queries. All filter results are lists.  The following filters are supported:

| Filter     | Possible values | Description|
|:-----------|:----------------|:-----------|
| `member-id` | `{member-id}` | metadata associated with a specific DataCite member |
| `from-date` | `{date}` | metadata where published date is since (inclusive) `{date}` |
| `until-date` | `{date}` | metadata where published date is before (inclusive)  `{date}` |

## Notes on owner prefixes

The prefix of a DataCite DOI does **NOT** indicate who currently owns the DOI.

DataCite also has publisher IDs for depositing organisations. A single publisher may control multiple owner prefixes, which in turn may control a number of DOIs. When looking at works published by a certain organisaton, publisher IDs and the publisher routes should be used.

## Notes on dates

Note that dates in filters should always be of the form `YYYY-MM-DD`, `YYYY-MM` or `YYYY`. Also note that the date published in DataCite metadata is always expressed as `YYYY` (the `publicationYear` field).

## Rows

Normally, results are returned 25 at a time. You can control the number of results returns by using the `rows` parameter. To limit results to 5, for example, you could do the following:

```
https://api.datacite.org/works?query=allen+renear&rows=5
```

If you would just like to get the `summary` of the results, you can set the rows to 0 (zero).

```
https://api.datacite.org/works?query=allen+renear&rows=0
```

The maximum number rows you can ask for in one query is `1000`.

## Offset

The number of returned items is controlled by the `rows` parameter, but you can select the offset into the result list by using the `offset` parameter.  So, for example, to select the second set of 5 results (i.e. results 6 through 10), you would do the following:

```
https://api.datacite.org/works?query=allen+renear&rows=5&offset=5
```
## Example Queries

**All works published by data center `cdl.digsci` (Figshare)**

```
https://api.datacite.org/publishers/cdl.digsci/works
```

**All members with `data` in their name (e.g. Australian National Data Service)**

```
https://api.datacite.org/members?query=data
```

## Error messages

When an error occurs, the API will return a [JSONAPI error object](http://jsonapi.org/examples/#error-objects), for example

```
{
  "errors": [
    {
      "status": "422",
      "title":  "Invalid Attribute"
    }
  ]
}
``
