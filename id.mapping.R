#--functions to map ids using a graph-based model--
#--this file by RW based on my older logs
#--date:29 May 2013

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

