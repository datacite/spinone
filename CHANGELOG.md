## Spinone 2.1 (October 31, 2016)

[Spinone 2.1](https://github.com/datacite/spinone/releases/tag/v.2.1) was released on October 31, 2016.

The following changes were made:

* **include**: added support for optional `includes`, following the [JSONAPI spec](http://jsonapi.org/format/#fetching-includes)
* **meta**: changed how facet counts are displayed in the meta object, adding `title` and returning an array instead of an object
* added support for work queries by date range by adding support for `from-created-date`, `until-created-date`, `from-update-date`, `until-update-date`
* added support for work queries by source and relation-type
* fixed bug that would show incorrect facet counts for relation-types
* DOIs are shown as HTTPS URIs

For the list of resources that can be included, consult the [documentation](https://github.com/datacite/spinone/blob/master/docs/index.md).
