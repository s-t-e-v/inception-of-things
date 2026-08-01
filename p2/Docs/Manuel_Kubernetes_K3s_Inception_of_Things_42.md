# Kubernetes & K3s --- Manuel de Révision (École 42)

> Un support unique regroupant les notions essentielles pour comprendre
> Kubernetes et réussir le projet **Inception of Things**.

------------------------------------------------------------------------

# Sommaire

1.  Docker et les conteneurs
2.  Pourquoi Kubernetes ?
3.  K3s vs Kubernetes
4.  K3s vs K3d
5.  Architecture d'un cluster Kubernetes
6.  Les objets Kubernetes
7.  Traefik
8.  Les Ingress
9.  Le chemin complet d'une requête
10. Structure du projet IoT
11. Bonnes pratiques
12. Commandes utiles
13. Questions de soutenance

------------------------------------------------------------------------

# 1. Docker et les conteneurs

Un conteneur est un processus isolé contenant : - une application ; -
ses dépendances ; - sa configuration.

Docker construit et exécute les conteneurs.

Kubernetes ne remplace pas Docker : il orchestre les conteneurs.

------------------------------------------------------------------------

# 2. Pourquoi Kubernetes ?

Docker sait lancer un conteneur.

Kubernetes sait :

-   maintenir plusieurs instances ;
-   remplacer un conteneur en panne ;
-   répartir les requêtes ;
-   mettre à jour une application sans interruption ;
-   gérer plusieurs machines.

Il maintient un **état désiré**.

Exemple :

``` yaml
replicas: 3
```

Si un Pod disparaît, Kubernetes en recrée un.

------------------------------------------------------------------------

# 3. K3s vs Kubernetes (K8s)

K3s est une distribution légère de Kubernetes.

  -----------------------------------------------------------------------
  Kubernetes                                         K3s
  -------------------------------------------------- --------------------
  Distribution officielle                            Distribution légère
                                                     compatible

  Installation plus complexe                         Installation très
                                                     simple

  Beaucoup de composants à configurer                Plusieurs composants
                                                     déjà intégrés

  Plus gourmand                                      Léger
  -----------------------------------------------------------------------

K3s installe notamment :

-   API Server
-   Scheduler
-   Controller Manager
-   containerd
-   CoreDNS
-   Traefik

------------------------------------------------------------------------

# 4. K3s vs K3d

K3s = véritable cluster Kubernetes.

``` text
Linux
 └── K3s
      └── Pods
```

K3d = outil qui lance K3s dans Docker.

``` text
Linux
 └── Docker
      └── Conteneur K3s
             └── Pods
```

Pour Inception of Things : **K3s**, pas K3d.

------------------------------------------------------------------------

# 5. Architecture interne

``` text
kubectl
   │
   ▼
API Server
   │
   ├── etcd
   ├── Scheduler
   └── Controller Manager
         │
         ▼
      Kubelet
         │
         ▼
     containerd
         │
         ▼
      Conteneur
```

### API Server

Point d'entrée du cluster.

### etcd

Base de données de l'état du cluster.

### Scheduler

Choisit où placer les Pods.

### Controller Manager

Maintient l'état désiré.

### Kubelet

Agent du nœud.

### containerd

Télécharge et lance les conteneurs.

------------------------------------------------------------------------

# 6. Les objets Kubernetes

## Pod

Plus petite unité déployable.

## Deployment

Décrit le nombre de Pods souhaité.

## ReplicaSet

Maintient ce nombre.

## Service

Adresse stable devant les Pods.

``` text
Service
 ├── Pod
 ├── Pod
 └── Pod
```

## ConfigMap

Stocke une configuration non sensible (HTML, fichiers...).

## Secret

Stocke des données sensibles.

## Namespace

Sépare les ressources logiquement.

------------------------------------------------------------------------

# 7. Traefik

Traefik est un **Ingress Controller**.

Il écoute les ports 80/443.

Il lit automatiquement les objets Ingress créés dans Kubernetes.

Il agit comme un reverse proxy.

``` text
Client
  │
  ▼
Traefik
```

Traefik ne décide pas seul où envoyer les requêtes : il applique les
règles définies par les Ingress.

------------------------------------------------------------------------

# 8. Les Ingress

Un Ingress est un **objet Kubernetes**.

Il ne transporte pas les requêtes.

Il décrit simplement des règles.

Exemple :

  Host       Service
  ---------- --------------
  app1.com   app1-service
  app2.com   app2-service
  autre      app3-service

Traefik lit ces règles.

Flux :

``` text
Client
   │
   ▼
Traefik
   │
Lecture de l'Ingress
   │
   ▼
Service
   │
   ▼
Pod
```

Pourquoi pointer vers un Service ?

Parce que les Pods changent d'IP lorsqu'ils sont recréés.

Le Service fournit une adresse stable.

------------------------------------------------------------------------

# 9. Chemin complet d'une requête

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

↓

NGINX

↓

Réponse HTML
```

------------------------------------------------------------------------

# 10. Structure recommandée

``` text
p2/
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

------------------------------------------------------------------------

# 11. Bonnes pratiques

-   utiliser une version fixe des images (`nginx:1.28-alpine`) ;
-   `imagePullPolicy: IfNotPresent` ;
-   définir `resources.requests` et `resources.limits` ;
-   ajouter une `readinessProbe` ;
-   un fichier YAML par application.

------------------------------------------------------------------------

# 12. Commandes utiles

``` bash
kubectl get nodes
kubectl get pods -A
kubectl get deployments
kubectl get services
kubectl get ingress

kubectl describe pod <pod>
kubectl logs <pod>
kubectl exec -it <pod> -- sh

kubectl apply -f manifests/
kubectl delete -f manifests/
```

------------------------------------------------------------------------

# 13. Questions de soutenance

### Pourquoi un Service ?

Les Pods changent d'IP. Le Service fournit une adresse stable.

### Pourquoi un Deployment ?

Pour maintenir l'état désiré.

### Pourquoi un Ingress ?

Pour publier plusieurs applications derrière une seule IP.

### Pourquoi Traefik ?

Parce qu'il lit les Ingress et applique les règles de routage.

### Pourquoi K3s ?

Parce qu'il fournit un Kubernetes léger, simple à installer et
compatible avec Kubernetes.

### Pourquoi 3 replicas ?

Pour la disponibilité et la répartition de charge.

------------------------------------------------------------------------

# Schéma global

``` text
                 Client
                    │
                    ▼
             192.168.56.110
                    │
                 Traefik
                    │
                 Ingress
         ┌──────────┼──────────┐
         │          │          │
      app1      app2      défaut
         │          │          │
    app1-service app2-service app3-service
         │          │          │
       1 Pod      3 Pods      1 Pod
```

------------------------------------------------------------------------

# À retenir

-   Kubernetes orchestre les conteneurs.
-   K3s est un Kubernetes léger.
-   K3d lance K3s dans Docker.
-   Le Deployment crée les Pods.
-   Le Service fournit une adresse stable.
-   L'Ingress décrit les règles HTTP.
-   Traefik applique ces règles.
