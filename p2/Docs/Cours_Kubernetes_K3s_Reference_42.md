# Kubernetes & K3s --- Guide de référence (École 42)

> Version étendue. Ce document est conçu comme un support de cours et de
> révision.

------------------------------------------------------------------------

# Table des matières

1.  Introduction
2.  Conteneurs et Docker
3.  Pourquoi Kubernetes ?
4.  Architecture interne de Kubernetes
5.  K3s : différences avec Kubernetes
6.  Cycle de vie d'un Pod
7.  Les objets Kubernetes
8.  Réseau Kubernetes
9.  Traefik et les Ingress
10. Stockage
11. ConfigMaps et Secrets
12. Rolling Updates
13. Debug et observabilité
14. Sécurité
15. Bonnes pratiques
16. Questions de soutenance
17. Glossaire

------------------------------------------------------------------------

# 1. Introduction

Kubernetes est un orchestrateur de conteneurs.

Son objectif est de maintenir un **état désiré** ("desired state").

Tu décris **ce que tu veux** :

``` yaml
replicas: 3
```

Kubernetes s'occupe de maintenir cet état.

------------------------------------------------------------------------

# 2. Docker et les conteneurs

Un conteneur est un processus isolé qui partage le noyau Linux avec
l'hôte.

Il contient : - une application ; - ses bibliothèques ; - sa
configuration.

Docker sert principalement à **construire** et **exécuter** ces
conteneurs.

Dans K3s, le runtime utilisé est **containerd**, plus léger que Docker
Engine.

------------------------------------------------------------------------

# 3. Pourquoi Kubernetes ?

Docker sait lancer un conteneur.

Kubernetes sait :

-   redémarrer un conteneur en panne ;
-   maintenir plusieurs copies ;
-   répartir le trafic ;
-   mettre à jour sans interruption ;
-   gérer plusieurs machines.

------------------------------------------------------------------------

# 4. Architecture interne

``` text
                kubectl
                   │
                   ▼
             Kubernetes API
                   │
      ┌────────────┼─────────────┐
      │            │             │
      ▼            ▼             ▼
 Controller    Scheduler      etcd
      │            │
      └──────┬─────┘
             ▼
          Kubelet
             │
         containerd
             │
          Conteneur
```

## API Server

Point d'entrée unique.

Toutes les commandes passent par lui.

## etcd

Base de données contenant la configuration du cluster.

## Scheduler

Décide sur quel nœud placer un Pod.

## Controller Manager

Compare l'état réel avec l'état désiré.

## Kubelet

Agent installé sur chaque nœud.

## containerd

Télécharge les images OCI et lance les conteneurs.

------------------------------------------------------------------------

# 5. K3s

K3s est une distribution Kubernetes légère.

Elle simplifie l'installation en intégrant plusieurs composants.

Principaux avantages :

-   faible consommation mémoire ;
-   installation rapide ;
-   idéale pour les VM, Raspberry Pi et laboratoires.

------------------------------------------------------------------------

# 6. Cycle de vie d'un Pod

``` text
Deployment
      │
      ▼
ReplicaSet
      │
      ▼
Pod
      │
      ▼
containerd
      │
      ▼
Processus Linux
```

Un Deployment crée un ReplicaSet.

Le ReplicaSet crée les Pods.

Le Kubelet demande à containerd de lancer les conteneurs.

------------------------------------------------------------------------

# 7. Les objets Kubernetes

## Pod

Plus petite unité déployable.

## ReplicaSet

Maintient un nombre fixe de Pods.

## Deployment

Gère les ReplicaSets et les mises à jour.

## Service

Adresse stable devant un ensemble de Pods.

Types : - ClusterIP - NodePort - LoadBalancer - ExternalName

## Ingress

Route HTTP/HTTPS vers les Services.

## Namespace

Sépare logiquement les ressources.

## ConfigMap

Configuration non sensible.

## Secret

Informations sensibles (mots de passe, clés API, certificats).

------------------------------------------------------------------------

# 8. Réseau Kubernetes

Chaque Pod reçoit une IP.

Les Pods peuvent communiquer entre eux.

Les Services offrent une IP virtuelle stable.

CoreDNS fournit la résolution DNS interne.

Exemple :

``` text
app2-service.webapps.svc.cluster.local
```

------------------------------------------------------------------------

# 9. Traefik

Traefik est un **Ingress Controller**.

Il :

-   écoute les ports 80/443 ;
-   lit les ressources Ingress ;
-   met à jour automatiquement son routage.

Dans ton projet :

``` text
Navigateur
      │
      ▼
Traefik
      │
      ▼
Ingress
      │
      ▼
Service
      │
      ▼
Pod
```

Traefik est différent de NGINX classique : il est pensé pour découvrir
automatiquement les ressources Kubernetes.

------------------------------------------------------------------------

# 10. Stockage

Un Pod est éphémère.

Pour conserver des données :

-   PersistentVolume (PV)
-   PersistentVolumeClaim (PVC)

Dans Inception of Things Part 2, aucun stockage persistant n'est
nécessaire.

------------------------------------------------------------------------

# 11. ConfigMaps et Secrets

ConfigMap :

-   HTML
-   fichiers de configuration
-   variables non sensibles

Secret :

-   mots de passe
-   certificats TLS
-   jetons

------------------------------------------------------------------------

# 12. Rolling Update

Lorsqu'un Deployment est modifié :

``` text
Ancien Pod

↓

Nouveau Pod

↓

Suppression de l'ancien
```

L'application reste disponible.

Rollback :

``` bash
kubectl rollout undo deployment app2
```

------------------------------------------------------------------------

# 13. Débogage

Lister :

``` bash
kubectl get all
```

Décrire :

``` bash
kubectl describe pod <pod>
```

Logs :

``` bash
kubectl logs <pod>
```

Entrer dans un Pod :

``` bash
kubectl exec -it <pod> -- sh
```

Événements :

``` bash
kubectl get events --sort-by=.lastTimestamp
```

------------------------------------------------------------------------

# 14. Sécurité

Bonnes pratiques :

-   images versionnées ;
-   imagePullPolicy: IfNotPresent ;
-   requests/limits CPU et mémoire ;
-   readinessProbe ;
-   livenessProbe ;
-   éviter les conteneurs privilégiés.

------------------------------------------------------------------------

# 15. Bonnes pratiques

Structure :

``` text
scripts/
manifests/
README.md
```

Un fichier YAML par application.

Images officielles.

Version d'image fixe.

------------------------------------------------------------------------

# 16. Questions de soutenance

## Pourquoi un Service ?

Les Pods sont recréés et changent d'IP.

## Pourquoi un Deployment ?

Pour maintenir l'état désiré.

## Pourquoi un Ingress ?

Pour publier plusieurs applications derrière une seule IP.

## Pourquoi Traefik ?

Parce qu'il implémente les règles Ingress.

## Pourquoi K3s ?

Parce qu'il est léger tout en restant compatible Kubernetes.

## Pourquoi ConfigMap ?

Pour séparer la configuration de l'image.

## Pourquoi 3 replicas ?

Haute disponibilité et répartition de charge.

------------------------------------------------------------------------

# 17. Glossaire

-   API Server : point d'entrée.
-   Controller : maintient l'état désiré.
-   Scheduler : choisit le nœud.
-   Kubelet : agent local.
-   containerd : runtime.
-   Pod : unité d'exécution.
-   Service : accès stable.
-   Deployment : gestionnaire de Pods.
-   ReplicaSet : nombre fixe de Pods.
-   Ingress : routage HTTP.
-   Traefik : Ingress Controller.
-   ConfigMap : configuration.
-   Secret : données sensibles.
-   PV/PVC : stockage persistant.

------------------------------------------------------------------------

# Conseils pour la soutenance

Ne récite pas les définitions. Explique le chemin d'une requête :

``` text
Client
  │
  ▼
Traefik
  │
Ingress
  │
Service
  │
Pod
  │
NGINX
```

Puis explique le chemin d'un déploiement :

``` text
kubectl apply
      │
API Server
      │
Controller
      │
ReplicaSet
      │
Pod
      │
Kubelet
      │
containerd
```

Si tu maîtrises ces deux flux, tu répondras à la majorité des questions
sur ce projet.
