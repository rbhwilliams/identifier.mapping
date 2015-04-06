#--functions to map ids using a graph-based model--
#--this file started on 29 May 2013, based on older code
#--this file updated on 6 April 2015 for GitHub posting

library(igraph)

define.id2id.mapping.as.graph<-function(id2idTable)
{
 #--'id2idTable' is a matrix that contains one set of ids in col1 and the other in col2
 #--implicitly, this should be bipartitite
 res<-list(id2idGraph=NULL,id2idCC=NULL,uid1=NULL,uid2=NULL)
 res$id2idGraph<-graph.edgelist(id2idTable,directed=F)
 res$id2idCC<-decompose.graph(res$id2idGraph,mode="strong",min.vertices=1)
 res$uid1<-unique(as.character(id2idTable[,1]))
 res$uid2<-unique(as.character(id2idTable[,2]))  
 return(res)
}

extract.ids<-function(id2idObj,type=c("first","second","both"))
{
 #--'id2idObj' is an output from 'define.id2id.mapping.as.graph'
 #--'type' will extract id1 ('first'), id2 ('second') or all ('both') ids within an element of 'id2idObj$id2idCC'
 res=NULL
 
 #--extract all ids...
 allids<-sapply(id2idObj$id2idCC,FUN=function(g){V(g)$name})
 if(type=="both")
 {
  res<-allids
 }
 else
 if(type=="first")
 {
  res<-lapply(allids,FUN=intersect,y=id2idObj$uid1)
 }
 else
 if(type=="second") 
 {
  res<-lapply(allids,FUN=intersect,y=id2idObj$uid2)
 }
 
 return(res)  

}

summarise.id2id.mapping<-function(id2idObj)
{
 #--generate a table which summarises the numbers of ids of each type
 res=NULL
 
 nnodes<-sapply(extract.ids(id2idObj,"both"),length)
 nid1<-sapply(extract.ids(id2idObj,"first"),length)
 nid2<-sapply(extract.ids(id2idObj,"second"),length)
 res<-data.frame(index=1:length(id2idObj$id2idCC),no=nnodes,no.id1=nid1,no.id2=nid2,row.names=NULL)
 return(res)
}

#--microarray example--
#--the array data is indexed by Genbank ids, but the probe sequences were available (supplied by Mark Cowley), so we remapped to mm9 using Bowtie (Hugh French)
#--and then I took the uniquely mapped probe sequences and kept those (all original logs are available)
#--this .rda file lists the original ids in the first column, and the mm9 RefSeq ids in the second
#--the functions in this file provide a fairly general way of dealing with one-to-many, many-to-one, and many-to-many identifier mapping situations, by making use of graphs for an underlying data model
#--will try and extend this to mutlipartite graphs for multiple sets of ids (any decade now...)

source(file="")
load(file="")

#--the basic out is generated using define.id2id.mapping.as.graph
#--which generates an igraph object, a set of connected components that defines each "cluster" of ids, and vectors of teh unique ids of each type
a<-define.id2id.mapping.as.graph(compugen.refseq2refseq.single.mapped.read)

#--in each component, the ids from each column can extracted easily (e.g. so you can resample one of many, or use them to index data for average etc)
#--illustrate here for the first set of ids, outout is another list
a.firstset<-extract.ids(a,"first")

#--and a finally a useful summary table can be generated to provide a global overview of the identifier mapping results...you could work directly with the graph object
a.summTable<-summarise.id2id.mapping(a)

#> head(a.summTable)
#index no no.id1 no.id2
#1     1  2      1      1
#2     2  2      1      1
#3     3  2      2      1
#4     4  2      1      1
#5     5  5      1      4
#6     6  2      1      1



