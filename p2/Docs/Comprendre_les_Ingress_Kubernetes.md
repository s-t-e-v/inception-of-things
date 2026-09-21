# Comprendre les Ingress dans Kubernetes

> L'Ingress est souvent l'un des concepts les plus difficiles à
> comprendre lorsqu'on débute avec Kubernetes. Ce document explique son
> rôle simplement.

------------------------------------------------------------------------

# Définition

Un **Ingress** est un **objet Kubernetes** qui décrit **comment les
requêtes HTTP/HTTPS doivent être routées vers les Services du cluster**.

⚠️ Un Ingress **n'est pas** :

-   un serveur web ;
-   un reverse proxy ;
-   un load balancer.

Il contient uniquement **des règles de routage**.

------------------------------------------------------------------------

# Le problème

Imaginons que tu possèdes trois applications :

``` text
App1
App2
App3
```

Chaque application possède son Service.

``` text
App1
 │
Service1

App2
 │
Service2

App3
 │
Service3
```

Comment Kubernetes sait-il vers quel Service envoyer la requête
lorsqu'un utilisateur arrive depuis Internet ?

Sans règle, il ne peut pas le savoir.

------------------------------------------------------------------------

# Sans Ingress

Chaque application devrait être exposée séparément.

``` text
Internet
   │
   ├────────► Service1
   ├────────► Service2
   └────────► Service3
```

Par exemple :

``` text
192.168.56.110:8080 → App1
192.168.56.110:8081 → App2
192.168.56.110:8082 → App3
```

Cela fonctionne, mais ce n'est ni pratique ni évolutif.

------------------------------------------------------------------------

# Avec un Ingress

L'idée est d'utiliser :

-   une seule IP ;
-   un seul port (80 ou 443) ;
-   plusieurs applications.

``` text
192.168.56.110
        │
        ▼
     Ingress
        │
        ├── App1
        ├── App2
        └── App3
```

------------------------------------------------------------------------

# Que fait réellement un Ingress ?

Il regarde les informations de la requête HTTP.

Exemple :

``` http
GET /
Host: app2.com
```

La règle peut être :

``` text
Si Host = app2.com
        │
        ▼
app2-service
```

Ou encore :

``` http
Host: app1.com
```

↓

``` text
app1-service
```

------------------------------------------------------------------------

# Une table de routage

On peut voir un Ingress comme une simple table.

  Condition         Destination
  ----------------- --------------
  Host = app1.com   app1-service
  Host = app2.com   app2-service
  Tout le reste     app3-service

Il ne fait rien d'autre.

------------------------------------------------------------------------

# Qui applique ces règles ?

L'Ingress ne traite **jamais** les requêtes.

Il décrit simplement les règles.

C'est **Traefik** (ou un autre Ingress Controller) qui les applique.

------------------------------------------------------------------------

# Le rôle de Traefik

Tu écris un Ingress :

``` yaml
kind: Ingress

rules:
  - host: app1.com
```

Traefik surveille Kubernetes.

Il détecte automatiquement les nouveaux objets Ingress.

Il met ensuite à jour sa configuration.

Lorsqu'une requête arrive :

``` text
Navigateur
      │
      ▼
Traefik
      │
Lecture du Host
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

------------------------------------------------------------------------

# Pourquoi l'Ingress pointe vers un Service ?

Les Pods sont éphémères.

Ils peuvent être supprimés et recréés.

Exemple :

``` text
Pod

↓

Crash

↓

Nouveau Pod
```

Le nouveau Pod possède une nouvelle adresse IP.

En revanche, le Service conserve toujours la même adresse.

``` text
Ingress
    │
    ▼
Service
    │
 ├── Pod A
 ├── Pod B
 └── Pod C
```

Le Service sait quels Pods sont disponibles.

L'Ingress n'a donc jamais besoin d'être modifié.

------------------------------------------------------------------------

# Exemple avec Inception of Things

``` text
                 Traefik
                     │
             Lit l'Ingress
                     │
      ┌──────────────┼──────────────┐
      │              │              │
Host=app1.com   Host=app2.com   autre Host
      │              │              │
 app1-service   app2-service   app3-service
      │              │              │
    1 Pod         3 Pods         1 Pod
```

Lorsqu'un navigateur envoie :

``` http
GET /
Host: app2.com
```

Le déroulement est :

``` text
Navigateur
      │
      ▼
Traefik
      │
      ▼
Lecture du Host
      │
      ▼
Règle Ingress
      │
      ▼
app2-service
      │
      ▼
Un des 3 Pods
```

------------------------------------------------------------------------

# Pourquoi ne pas configurer Traefik directement ?

On pourrait écrire la configuration de Traefik à la main.

Mais à chaque nouvelle application, il faudrait :

-   modifier le fichier de configuration ;
-   recharger Traefik.

Avec Kubernetes :

-   tu crées un objet Ingress ;
-   Traefik détecte automatiquement le changement ;
-   il met à jour son routage sans intervention manuelle.

------------------------------------------------------------------------

# Résumé

``` text
Client
   │
   ▼
Traefik
   │
   ▼
Ingress (règles)
   │
   ▼
Service
   │
   ▼
Pod
```

------------------------------------------------------------------------

# À retenir

-   **Ingress** : décrit les règles de routage HTTP/HTTPS.
-   **Traefik** : lit les règles Ingress et les applique.
-   **Service** : fournit une adresse stable devant les Pods.
-   **Pod** : exécute réellement l'application.

## Définition à connaître pour la soutenance

> **Un Ingress est un objet Kubernetes qui décrit comment router les
> requêtes HTTP/HTTPS vers les Services du cluster (selon le Host, le
> chemin, etc.). Les requêtes sont ensuite réellement traitées par un
> Ingress Controller, comme Traefik.**
