# API et manifeste Kubernetes

## Qu’est-ce qu’une API ?

Une API est une interface de communication.

Elle permet à deux systèmes de se parler de façon organisée.

### Exemple simple

Quand tu ouvres un site web, ton navigateur envoie une requête à un serveur. Le serveur répond avec des données. C’est un échange qui passe par une API.

## Dans Kubernetes

Kubernetes possède une API officielle.

Quand tu écris une commande comme :

```bash
kubectl apply -f mon-fichier.yaml
```

tu envoies une demande à l’API Kubernetes.

Cette API comprend la demande et crée ou modifie les ressources demandées.

---

## Qu’est-ce qu’un manifeste ?

Un manifeste est un fichier de configuration écrit en YAML.

Il décrit une ressource Kubernetes que tu veux créer ou modifier.

### Exemple

Un manifeste peut définir :

- un Deployment
- un Service
- un Namespace
- un Ingress

## À quoi sert un manifeste ?

Il sert à dire à Kubernetes :

- quelle ressource créer
- avec quels paramètres
- dans quel namespace
- avec quelle configuration

## Exemple très simple

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mon-pod
```

Ce fichier explique à Kubernetes :

- crée un Pod
- avec le nom `mon-pod`

---

## Différence entre API et manifeste

- Une API, c’est la voie de communication.
- Un manifeste, c’est le fichier qui décrit ce que tu veux créer.

### En une phrase

- l’API permet à Kubernetes de comprendre les demandes ;
- le manifeste contient la description de la ressource à créer.
