# Inception of Things -- Part 2 (K3s)

## Guide complet + bonnes pratiques + préparation soutenance

> Ce document résume la méthode que je recommande pour réaliser la
> **Partie 2** du projet **Inception of Things**.

------------------------------------------------------------------------

# Objectif

Déployer **3 applications web** dans **une seule VM** avec **K3s
Server**.

Toutes les requêtes arrivent sur :

``` text
192.168.56.110
```

Le site affiché dépend du header HTTP **Host**.

  Host       Application
  ---------- -------------------
  app1.com   App1
  app2.com   App2
  autre      App3 (par défaut)

------------------------------------------------------------------------

# Architecture

``` text
                    Navigateur
                         │
       GET http://192.168.56.110
       Host: app2.com
                         │
                    Traefik
               (Ingress Controller)
                         │
                     Ingress
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   Host=app1.com    Host=app2.com    autre Host
        │                │                │
   app1-service    app2-service    app3-service
        │                │                │
      1 Pod           3 Pods           1 Pod
```

------------------------------------------------------------------------

# Pourquoi K3s ?

K3s est une distribution Kubernetes légère.

Elle intègre déjà :

-   containerd
-   Traefik
-   CoreDNS
-   ServiceLB
-   le stockage local
-   tous les composants Kubernetes essentiels

Cela évite d'installer plusieurs outils séparément.

------------------------------------------------------------------------

# Qu'est-ce que Traefik ?

Traefik est un **reverse proxy** et un **Ingress Controller**.

Son travail est de recevoir les requêtes HTTP venant de l'extérieur puis
de les envoyer au bon Service Kubernetes.

Sans Traefik :

``` text
Navigateur

↓

Personne n'écoute sur le port 80
```

Avec Traefik :

``` text
Navigateur

↓

Traefik

↓

Ingress

↓

Service

↓

Pod
```

Traefik lit automatiquement les objets **Ingress** créés dans
Kubernetes.

Par exemple :

``` yaml
host: app1.com
```

Traefik comprend alors :

``` text
Si Host = app1.com

↓

envoyer vers app1-service
```

Tu n'as **rien à configurer dans Traefik** : il observe Kubernetes et
applique automatiquement les règles.

------------------------------------------------------------------------

# Différence entre Traefik et NGINX

NGINX est principalement :

-   serveur web
-   reverse proxy
-   load balancer

Traefik est également un reverse proxy, mais il est conçu pour
fonctionner directement avec Kubernetes.

Il détecte automatiquement :

-   les nouveaux Services
-   les nouveaux Ingress
-   les nouveaux Pods

sans recharger manuellement sa configuration.

Pour ce projet, **Traefik est le meilleur choix**, car il est installé
par défaut avec K3s.

------------------------------------------------------------------------

# Les ressources Kubernetes

## Namespace

Permet de regrouper les ressources du projet.

``` yaml
kind: Namespace
```

------------------------------------------------------------------------

## ConfigMap

Contient le fichier HTML de l'application.

Cela évite de reconstruire une image Docker juste pour modifier une
page.

------------------------------------------------------------------------

## Deployment

Décrit l'application.

Exemple :

``` yaml
replicas: 3
```

Le Deployment garantit que trois Pods existent en permanence.

Si un Pod plante :

``` text
Pod supprimé

↓

Deployment

↓

Création automatique d'un nouveau Pod
```

------------------------------------------------------------------------

## Pod

Le Pod exécute le conteneur.

``` text
Pod
 └── nginx
```

------------------------------------------------------------------------

## Service

Le Service fournit une adresse stable.

Il répartit également les requêtes entre plusieurs Pods.

``` text
Service

├── Pod 1
├── Pod 2
└── Pod 3
```

------------------------------------------------------------------------

## Ingress

L'Ingress ne parle jamais directement aux Pods.

Il choisit uniquement **le Service** selon le Host.

``` text
Host

↓

Ingress

↓

Service
```

------------------------------------------------------------------------

# Pourquoi plusieurs fichiers YAML ?

Structure conseillée :

``` text
p2/
│
├── README.md
├── scripts/
│   └── install.sh
└── manifests/
    ├── namespace.yaml
    ├── app1.yaml
    ├── app2.yaml
    ├── app3.yaml
    └── ingress.yaml
```

Cette organisation est :

-   facile à maintenir
-   facile à expliquer
-   idéale pour une soutenance

------------------------------------------------------------------------

# Bonnes pratiques

## Utiliser une version fixe d'image

Éviter :

``` yaml
image: nginx:alpine
```

Préférer :

``` yaml
image: nginx:1.28-alpine
```

Les déploiements deviennent reproductibles.

------------------------------------------------------------------------

## Éviter de télécharger inutilement

``` yaml
imagePullPolicy: IfNotPresent
```

------------------------------------------------------------------------

## Définir des limites de ressources

``` yaml
resources:
  requests:
    cpu: 10m
    memory: 16Mi
  limits:
    cpu: 100m
    memory: 64Mi
```

Cela évite qu'un conteneur monopolise la VM.

------------------------------------------------------------------------

## Ajouter une Readiness Probe

``` yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
```

Le Pod ne reçoit du trafic que lorsqu'il est réellement prêt.

------------------------------------------------------------------------

# Pourquoi je ne recommande PAS...

## Installer NGINX Ingress

Traefik est déjà fourni avec K3s.

Cela compliquerait inutilement le projet.

------------------------------------------------------------------------

## Utiliser Helm

Le sujet est simple.

Des manifests YAML suffisent.

------------------------------------------------------------------------

## Créer des images Docker personnalisées

Les pages HTML sont très simples.

Une ConfigMap + nginx officiel est largement suffisante.

------------------------------------------------------------------------

## HTTPS

Le sujet ne le demande pas.

HTTP sur le port 80 suffit.

------------------------------------------------------------------------

# Déploiement

``` bash
kubectl apply -f manifests/
```

------------------------------------------------------------------------

# Vérifications

``` bash
kubectl get nodes

kubectl get pods -n webapps

kubectl get deployments -n webapps

kubectl get services -n webapps

kubectl get ingress -n webapps
```

------------------------------------------------------------------------

# Tests

``` bash
curl -H "Host: app1.com" http://192.168.56.110

curl -H "Host: app2.com" http://192.168.56.110

curl -H "Host: test.com" http://192.168.56.110
```

------------------------------------------------------------------------

# Questions classiques de soutenance

### Pourquoi un Deployment ?

Maintenir automatiquement le nombre de Pods.

### Pourquoi un Service ?

Les Pods changent d'IP. Le Service fournit une adresse stable.

### Pourquoi un Ingress ?

Pour publier plusieurs sites derrière une seule IP.

### Pourquoi Traefik ?

Parce qu'il reçoit les requêtes HTTP et applique automatiquement les
règles Ingress.

### Pourquoi trois replicas ?

Haute disponibilité et répartition de charge.

### Pourquoi une ConfigMap ?

Séparer les données (HTML) de l'image Docker.

------------------------------------------------------------------------

# Résumé final

``` text
Navigateur
      │
      ▼
Traefik
      │
      ▼
Ingress
      │
      ├──────────────┐
      │              │
app1-service   app2-service
      │              │
    1 Pod        3 Pods
      │
      └──── défaut ───► app3-service
                        │
                      1 Pod
```

## À retenir

-   **Traefik** reçoit les requêtes HTTP.
-   **Ingress** décide quel Service utiliser.
-   **Service** fournit une adresse stable et répartit les requêtes.
-   **Deployment** crée et maintient les Pods.
-   **Pod** exécute le conteneur.
-   **ConfigMap** contient la page HTML.
-   **K3s** orchestre l'ensemble.
