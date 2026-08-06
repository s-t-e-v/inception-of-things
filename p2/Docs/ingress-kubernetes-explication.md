# Explication d’un fichier Ingress Kubernetes

## Qu’est-ce que ce fichier ?

Ce fichier est un manifeste Kubernetes. Il définit un objet de type Ingress, qui sert à router le trafic HTTP vers la bonne application selon le nom de domaine demandé.

## La ligne `apiVersion: networking.k8s.io/v1`

Cette ligne indique que l’objet que l’on veut créer appartient au groupe d’API réseau de Kubernetes, dans la version `v1`.

En termes simples, elle dit à Kubernetes :

- « je veux utiliser une ressource réseau »
- « et je parle la version `v1` de cette API »

## Pourquoi cette ligne est importante ?

Kubernetes possède plusieurs familles d’API :

- `apps/v1` pour les Deployments
- `v1` pour les Services, Pods et Namespaces
- `networking.k8s.io/v1` pour les Ingress

Donc cette ligne permet à Kubernetes de comprendre que le fichier décrit un objet d’Ingress.

## Ce que fait l’Ingress dans ce fichier

L’Ingress défini ici dit à Traefik, l’Ingress Controller utilisé par K3s, comment envoyer les requêtes :

- si l’utilisateur demande `app1.com`, il faut envoyer la requête vers `app-one-service`
- si l’utilisateur demande `app2.com`, il faut envoyer la requête vers `app-two-service`
- si aucun host ne correspond, on utilise un service par défaut : `app-three-service`

## En résumé

Ce fichier sert à faire du routage HTTP dans Kubernetes.

Il permet de dire :

- « telle requête va vers telle application »
- « telle autre va vers une autre application »

## Pourquoi on parle de Kubernetes alors que le projet utilise K3s ?

K3s est une distribution légère de Kubernetes.

Cela veut dire que :

- Kubernetes est la technologie de base
- K3s est une version simplifiée et plus légère de cette technologie

Donc même si tu travailles avec K3s, tu écris des objets Kubernetes standard, comme un Ingress.

---

# Qu’est-ce qu’une API ?

Une API, c’est une interface de communication.

Elle permet à deux composants différents de se parler de façon structurée.

### Exemple simple

Quand ton navigateur demande une page web à un serveur, il utilise une API HTTP.

Le navigateur envoie une requête, et le serveur répond avec des données.

## Dans Kubernetes

L’API Kubernetes est le point d’entrée du cluster.

Quand tu fais par exemple :

```bash
kubectl apply -f mon-fichier.yaml
```

tu envoies une requête à l’API Kubernetes, qui comprend la demande et crée les ressources demandées.

---

# Qu’est-ce qu’un manifeste ?

Un manifeste est un fichier de configuration écrit en YAML (ou parfois JSON) qui décrit une ressource Kubernetes.

Il sert à dire à Kubernetes :

- quelle ressource créer
- avec quels paramètres
- dans quel namespace
- avec quelles règles

## Exemple simple

Un manifeste peut décrire :

- un Deployment
- un Service
- un Namespace
- un Ingress

## En pratique

Quand tu appliques un manifeste avec `kubectl`, Kubernetes lit ce fichier et crée la ressource correspondante.

## Résumé rapide

- API = moyen de communication entre un client et un système
- Manifest = fichier de configuration qui décrit une ressource à créer
