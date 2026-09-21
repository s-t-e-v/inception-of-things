# apiVersion et kind dans Kubernetes

Quand on écrit un manifeste Kubernetes, `apiVersion` et `kind` servent à dire à Kubernetes comment lire l’objet et de quel objet il s’agit.

## Rôle de `apiVersion`

`apiVersion` indique dans quelle API et quelle version se trouve la définition de la ressource.

Exemples :

- `v1` pour les ressources de base comme `Pod`, `Service`, `ConfigMap`, `Secret`, `Namespace`
- `apps/v1` pour des ressources comme `Deployment`, `ReplicaSet`, `StatefulSet`

## Rôle de `kind`

`kind` indique le type précis de ressource que tu veux créer.

Exemples :

- `Pod`
- `Service`
- `Deployment`
- `Ingress`

## Pourquoi les deux sont nécessaires

`apiVersion` ne suffit pas, parce qu’il ne dit pas si tu veux un `Pod`, un `Service` ou un `Deployment`.

Kubernetes a besoin des deux informations :

- `apiVersion` pour savoir où trouver la définition de la ressource
- `kind` pour savoir quel objet précis tu décris

## Exemple concret

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mon-deployment
spec:
  replicas: 1
```

Ici :

- `apps/v1` dit que la ressource vient du groupe `apps`
- `Deployment` dit que l’objet est un Deployment

## Pourquoi un Deployment n’est pas en `v1`

`v1` est l’API de base de Kubernetes. Elle contient des ressources fondamentales, mais pas `Deployment`.

`Deployment` appartient au groupe `apps`, donc on utilise `apps/v1`.

## Résumé simple

- `apiVersion` = dans quelle API lire la ressource
- `kind` = quelle ressource tu veux créer

Si tu vois `apiVersion: v1`, ça ne veut pas automatiquement dire `Deployment`. Il faut toujours regarder `kind`.