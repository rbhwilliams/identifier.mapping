# identifier.mapping
Inter-conversion of different types of identifiers is a ubiquitous feature of bioinformatics work flows. However practicalities of dealing with many-to-many, many-to-one, or one-to-many relationships among different identifiers remains complicated. Here, I describe a simple, generic approach for dealing with relationships between two sets of different identifiers, based on the use of graphs. The related code is written in R and is available here. 

## Background and motivation
In practical bioinformatics, the need to perform mappings or translations between two sets of identifiers is an extremely common task. A typical example from genome or transcriptiome analysis would involving mapping between a sequence specific identifier, such as RefSeq identifiers, and a locus specific identifier, such an Entrez Gene identifiers. Typically, while many such mappings will be of the one-one variety, there are often many instances of many-to-one, one-to-many or many-to-many mappings. Such mappings are problematic to deal with, particularly for inexperienced practitioners, and their treatment often includes decision points that have the potential to influence biological interpretation. I describe an method for representing and simplfying such mappings, and provide two case studies in which this concept is applied to the processing of expression microarray data and to the processing of homology search analysis from a metagenome survey.

For simplicity, we start by assuming we are working with two sets of identifiers, usually encountered as a two column table, with identifiers of the first type in column 1 and identifiers of the second type in column 2. We treat this table as a *node-edge list*, a commonly used format for representing graphs or networks. We then construct a *graph*, and then define all connected components of this graph. If there are *N* identifiers of the first type, and *N* identifiers of the second type, and only one-one mappings exists between them, then there will be *N* connected components, each containing two nodes (one from each type of identifier). If there are more complicated relationships between the two sets of identifiers, then the number of connected components will less than *N* and the size of the connected components will >2. Such components of size >2 will contain either a one-many, a many-to-one or a many-many mappings between the two identifier types. For example, a component of size 3 can only contain a one-two or two-one mapping. Thus, the connected components provide a convenient way of defining modules of connectivity between the two kinds of identifiers in a precise and unambiguous fashion. In the case studies below, we illustrate the application of this data model can be dealing with such complex, non one-one mappings in practical settings.

## R code
The code described here is comprised of three R functions, and uses *igraph* package for all graph computations. The functions are:

1. *define.id2id.mapping.as.graph*: From an input table (node-edge list) defining the inter-relationships between two sets of identifiers, this function outputs an R object of class *list* containing the following components:

- *id2idGraph*: an object of class *igraph* containing a graph defined by mappings between included identifiers. The graph formed by this procedure is implicitly bipartite, as by definition edges can only exist between identifiers of different type. Identifiers from either type that are not associated with an identifier of the other type are not included in this analysis, as they are not defined in the node-edge list. 

- *id2idCC*: an object of class *list*. Each element contains a connected component (themselves objects of class *igraph*) formed by decomposing the complete graph.

- *uid1*: a character vector containing the unique set of identifiers of a first type  

- *uid2*: a character vector containing the unique set of identifiers of a second type 

2. *extract.ids*: using the output of *define.id2id.mapping.as.graph*, extract identifiers of a specific type from each component. Returns an object of class *list*, indexed by connected component, whose elements contain a character vector of identifiers.

3. *summarise.id2id.mapping*: using the output of *define.id2id.mapping.as.graph*, this function generates a summary table, with rows indexed by connected component, and whose columns reporting the total number of nodes, and the number of nodes of each each type.
