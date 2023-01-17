# Artifactory

AQL
---
[AQL] sure has its fair share of quirks. The specification clarifies some of the
issues, but not all of it.

I only use AQL to deal with _items_, so for the moment I cannot say much about
how one should deal with _builds_ and _entries_.

### Syntax

```aql
<domain_query>                      # items, builds or entries
    .find(<criteria>)               # Search critear in JSON
    .include(<fields>)
    .sort(<order_and_fields>)
    .offset(<offset_records>)
    .limit(<num_records>)
```

### Field criteria

    {"<field>" : {"<comparison operator>" : "<value>"}}

If the [comparison operator](#comparison-operators) is `$eq` (the most common
case), the field criterion can be simplified to:

    {"<field>" : "<value>"}

Much nicer.

### Properties criteria

    {"@<property_key>":{"operator":"<property_value>"}}

### Compounding criteria
```
{<"$and"|"$or">:[{<criterion>},{<criterion>}]

e.g.
"$and":
    [
        {"artifact.module.build.name" : "my_debian_build"} ,
        {"name" : {"$match" : "*.deb"}}
    ]
```

### Comparison operators

`$ne`     | Not equal to
`$eq`     | Equals
`$gt`     | Greater than
`$gte`    | Greater than or equal to
`$lt`     | Less than
`$lte`    | Less than or equal to
`$match`  | Matches. Accepts `*` and `?` wildcards.
`$nmatch` | Does not match. Accepts `*` and `?` wildcards.


Lte me mke som terryble mistake here.

### Examples
1. Find items that have any property with a value of "GPL"
```
items.find({"$and": [
    {"property.key" : {"$eq" : "*"}},
    {"property.value" : {"$eq" : "GPL"}}
    ]
})
```
or, simply:
`items.find({"@*":"GPL"})`

2. Find any items annotated with any property whose key is "license" (i.e. find
   any items with a "license" property)
```
items.find({"$and" : [
    {"property.key" : {"$eq" : "license"}},
    {"property.value" : {"$eq" : "*"}}
]})
```
or, simply,
`items.find("@artifactory.licenses": "*")`


The RESTful API
---------------

### Authentication

User name + password (or API key). Or dedicated header `X-JFrog-Art-Api`.


[AQL]: https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language
[Artifactory REST API]: https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API