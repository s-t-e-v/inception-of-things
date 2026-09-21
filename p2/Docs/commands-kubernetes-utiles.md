# Commandes Kubernetes utiles

Ce document rassemble les commandes Kubernetes les plus utiles pour explorer, gérer et dépanner un cluster.

## 1. Informations générales

```bash
kubectl version
kubectl cluster-info
kubectl get nodes
kubectl get ns
kubectl get all -A
```

## 2. Obtenir des ressources

```bash
kubectl get pods
kubectl get pods -A
kubectl get deployment
kubectl get svc
kubectl get ingress
kubectl get pv
kubectl get pvc
kubectl get secrets
kubectl get configmaps
kubectl get endpoints
```

## 3. Décrire une ressource

```bash
kubectl describe pod <nom-pod>
kubectl describe deploy <nom-deployment>
kubectl describe svc <nom-service>
kubectl describe ingress <nom-ingress>
```

## 4. Créer et supprimer des ressources

```bash
kubectl apply -f fichier.yaml
kubectl create -f fichier.yaml
kubectl delete -f fichier.yaml
kubectl delete pod <nom-pod>
kubectl delete deploy <nom-deployment>
kubectl delete svc <nom-service>
```

## 5. Logs et dépannage

```bash
kubectl logs <nom-pod>
kubectl logs <nom-pod> -c <nom-conteneur>
kubectl logs <nom-pod> --previous
kubectl exec -it <nom-pod> -- /bin/sh
kubectl attach <nom-pod> -c <nom-conteneur>
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 6. Redémarrer et scaler

```bash
kubectl rollout restart deployment <nom-deployment>
kubectl rollout status deployment <nom-deployment>
kubectl rollout history deployment <nom-deployment>
kubectl scale deployment <nom-deployment> --replicas=3
```

## 7. Port forwarding

```bash
kubectl port-forward svc/<nom-service> 8080:80
kubectl port-forward pod/<nom-pod> 8080:80
```

## 8. Chercher et filtrer

```bash
kubectl get pods -o wide
kubectl get pods -A -o wide
kubectl get pods --field-selector status.phase=Running
kubectl get pods -l app=frontend
kubectl get svc --sort-by=.metadata.name
```

## 9. YAML et commandes utiles pour l’édition

```bash
kubectl get pod <nom-pod> -o yaml
kubectl get deploy <nom-deployment> -o yaml
kubectl get svc <nom-service> -o yaml
kubectl edit deployment <nom-deployment>
```

## 10. Commandes utiles pour K3s

Si tu utilises K3s, tu peux souvent remplacer `kubectl` par `k3s kubectl` :

```bash
k3s kubectl get nodes
k3s kubectl get pods -A
k3s kubectl get ingress -A
```

## 11. Commandes de base pour un lab ou un projet simple

```bash
kubectl apply -f manifests/
kubectl get all -n webapps
kubectl get ingress -n webapps
kubectl describe ingress webapps-ingress -n webapps
```

## 12. Commandes de nettoyage rapide

```bash
kubectl delete namespace <nom-namespace>
kubectl delete all --all -n <nom-namespace>
```

## 13. Astuce pratique

Pour voir tout ce qui tourne dans un namespace donné :

```bash
kubectl get all -n <nom-namespace>
```

---

Si tu veux, je peux aussi te générer une version plus “pro” avec :
- une version orientée débutant,
- une version orientée dépannage,
- ou une version spéciale pour K3s / Ingress / Traefik.
