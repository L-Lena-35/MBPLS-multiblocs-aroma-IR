# ------------------------------------------------------------------------------------------------
#Objectifs:
#Analyser conjointement deux blocs de données (Aroma et IR) afin de prédire l’origine géographique 
#d’échantillons alimentaires à l’aide de méthodes multi-blocs supervisées (MBPLS ou MBWCov).
#Prétraiter et fusionner les données issues de deux sources analytiques.
#Visualiser les spectres IR pour vérifier leur cohérence.
#Appliquer un modèle multi-bloc supervisé (MBPLS ou MBWCov).
#Évaluer la qualité du modèle : variance expliquée, saliences, scores, contributions des blocs.
#Réaliser une validation croisée Leave-One-Out (LOO) pour estimer l’erreur de classification.
#Déterminer le nombre optimal de composantes latentes.
# ------------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------------
# packages
# ------------------------------------------------------------------------------------------------
library(ggplot2)
library(gridExtra)
library(dplyr)
library(tidyverse)


# ------------------------------------------------------------------------------------------------
# Import dataset
# ------------------------------------------------------------------------------------------------ 

X1=AROMA38
X2=IR38
Y=Yorigine

# ------------------------------------------------------------------------------------------------
# Renommage des colonnes : ajoute un préfixe
# ------------------------------------------------------------------------------------------------

colnames(X1)<-c("label",paste("A",colnames(X1)[-1],sep="_"))
colnames(X2)<-c("label",paste("I",colnames(X2)[-1],sep="_"))

# ------------------------------------------------------------------------------------------------
#Fusion des trois csv
# ------------------------------------------------------------------------------------------------

merged <- list(X1, X2, Y) %>%
  reduce(full_join, by = "label") %>%  
  column_to_rownames("label")

# ------------------------------------------------------------------------------------------------
#Séparation des blocs
# ------------------------------------------------------------------------------------------------

X1 <- merged %>% select(starts_with("A_")) 
X2 <- merged %>% select(starts_with("I_")) 
Y  <- merged %>% select(origine) %>% 
  mutate(origine = factor(origine))

# ------------------------------------------------------------------------------------------------
#Centrage: réduction du bloc aroma
# ------------------------------------------------------------------------------------------------

X1=scale(X1,center=TRUE,scale = TRUE)

# ------------------------------------------------------------------------------------------------
#Transformation de Y en var indicatrice
# ------------------------------------------------------------------------------------------------

Y_disj <- model.matrix(~ origine - 1, data = as.data.frame(Y))
colnames(Y_disj) = levels(Y$origine)

# ------------------------------------------------------------------------------------------------
#Construction de la matrice multi-bloc
# ------------------------------------------------------------------------------------------------

X <-cbind(X1,X2)
pk = c(ncol(X1), ncol(X2))
name_blocks = c("Aroma","IR")

# ------------------------------------------------------------------------------------------------
# Représentation graphique
# ------------------------------------------------------------------------------------------------

dim(X2)

matplot(t(X2), type = "l", lty = 1, ylab = "Absorbance (ua)", xaxt = "n")
ind <- c(51, 151, 251,351,451,551)
axis(1, ind, paste(substr(colnames(X2)[ind], 4, 11), "cm-1", sep = " "))
title("Représentation graphique des spectres")

# ------------------------------------------------------------------------------------------------
#Application détaillée de MBPLS ou MBWCov
#Avec les options de mise à l’échelle choisies
# ------------------------------------------------------------------------------------------------

method="MBPLS"
choix.scaling=c(FALSE,TRUE,TRUE)
nbdim=10

# ------------------------------------------------------------------------------------------------
#Dim  des blocs
# ------------------------------------------------------------------------------------------------

dim(X1)
dim(X2)
dim(Y)

pk=c(ncol(X1),ncol(X2))

Xk.names = Xk.names = c("Aroma", "IR")

# ------------------------------------------------------------------------------------------------
#Encodage de Y
# ------------------------------------------------------------------------------------------------

#Y<- data.frame(tab.disjonctif(Y$origine))
Y1=model.matrix(~Y$origine-1)


# ------------------------------------------------------------------------------------------------
#Lancement du modèle
# ------------------------------------------------------------------------------------------------

if (method=="MBPLS") {
  #? MBPLS  # package MBAnalysis
  res=MBPLS(X=X, Y=Y1,block=pk,name.block=Xk.names,
            ncomp=nbdim,scale=choix.scaling[1],scale.block=choix.scaling[3],
            scale.Y=choix.scaling[2])
}

# ------------------------------------------------------------------------------------------------
#Analyse des résultats
# ------------------------------------------------------------------------------------------------

res$cumexplained
barplot(res$cumexplained[,3],main="%explY",las=2)
barplot(res$cumexplained[,1],main="%explX",las=2)

# ------------------------------------------------------------------------------------------------
# saliences 
# ------------------------------------------------------------------------------------------------

round(res$saliences,2)   # n cov(tk,u)

# ------------------------------------------------------------------------------------------------
# Graphiques multi-blocs
# ------------------------------------------------------------------------------------------------

ax=c(1,2)
plot(res,axes=ax,size=1)



#Origine_train=as.factor(X1$Origin[trainset])
#col_train=hex[unclass(Origine_train)]

# ------------------------------------------------------------------------------------------------
#Packages
# ------------------------------------------------------------------------------------------------

library(ggpubr)
library(MBAnalysis)
library(knitr)
library(caret)
library("scales")

# ------------------------------------------------------------------------------------------------
# Scores colorés par origine
# ------------------------------------------------------------------------------------------------

hex=hue_pal()(6)
cols_label=hex[unclass(as.factor(Y$origine))]
p=MBplotScores(res,axes=ax,color=cols_label)
p

p+geom_point(aes(fill=Y$origine),color="black",shape=21,size=2)+scale_fill_manual(values=hex,name="Groupe")

# ------------------------------------------------------------------------------------------------
#Var par bloc
# ------------------------------------------------------------------------------------------------

MBplotScores(res,axes=ax,color=cols_label)
MBplotVars(res,axes=ax,which="correlation",block=1,size=0.8)
MBplotVars(res,axes=ax,which="correlation",block=2,size=0.8)

# ------------------------------------------------------------------------------------------------
# Structure des blocs
# ------------------------------------------------------------------------------------------------

MBplotBlocks(res,which="structure",axes=ax)
MBplotBlocks(res,which="blocks.axes",axes=ax)

# composantes communes
comp.glob.mbpls=res$Scor.g[,1:4]
#1 à 4 dim

# ------------------------------------------------------------------------------------------------
# Validation croisée Leave-One-Out
# ------------------------------------------------------------------------------------------------

MBValidation(res,method="OOB",nboot=100,ncomp.max=10)

# ------------------------------------------------------------------------------------------------
# LOO manuel
# ------------------------------------------------------------------------------------------------

res.CV <- matrix(NA_character_,nrow=nrow(X),ncol = 10)

# ------------------------------------------------------------------------------------------------
# Matrice de prédiction LOO: chargement lourd
# ------------------------------------------------------------------------------------------------

for ( i in 1:nrow(X)  ) { 
  for ( j in 1:10) { 
  nbij=MBPLS(
    X[-i,],Y1[-i,],
    ncomp=j,
    block=pk,
    name.block=Xk.names,
    scale=choix.scaling[1],scale.block=choix.scaling[3],
    scale.Y=choix.scaling[2]
    )
resij=predict(nbij,newdata=X[i,])
nmodij=which.max(resij)
res.CV[i,j]=levels(Y$origine)[nmodij]
  }
}


res.CV

# ------------------------------------------------------------------------------------------------
# Erreur de classification
# ------------------------------------------------------------------------------------------------

err=apply(res.CV,2,function(x){
  sum(x!=Y$origine)
})

err/38



dir.create("Graphiques")

ggsave("Graphiques/scores.png", p, width=7, height=5)

