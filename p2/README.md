# Part 2 - K3s and three simple applications

Ce guide explique comment lancer le déploiement Kubernetes de la partie 2, vérifier que les applications fonctionnent, et tester l’accès via l’Ingress.

## Doc officielle

- https://kubernetes.io/docs/
- https://kubernetes.io/docs/reference/kubernetes-api/
- https://kubernetes.io/docs/concepts/
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://kubernetes.io/docs/concepts/services-networking/service/?utm_source=chatgpt.com
- https://kubernetes.io/docs/concepts/services-networking/ingress/?utm_source=chatgpt.com
- https://kubernetes.io/docs/concepts/configuration/configmap/
- https://kubespec.dev/

## Prérequis

- Une machine Linux Ubuntu ou Debian
- Accès `root` ou `sudo`
- Internet pour télécharger K3s
- Un réseau capable d’utiliser l’adresse IP `192.168.56.110` ou une adresse locale équivalente

## 1. Installer K3s

Sur la machine cible, exécuter :

```bash
curl -sfL https://get.k3s.io | sh -
```

Vérifier l’installation :

```bash
k3s --version
sudo k3s kubectl get nodes
```

## 2. Copier les manifests sur la machine

Si nécessaire, copier le dossier `p2/manifests` sur la machine cible :

```bash
scp -r /chemin/vers/inception-of-things/p2/manifests user@host:/tmp/manifests
```

## 3. Appliquer les manifests Kubernetes

Depuis la machine cible :

```bash
sudo k3s kubectl apply -f /tmp/manifests/namespace.yaml
sudo k3s kubectl apply -f /tmp/manifests/app1.yaml
sudo k3s kubectl apply -f /tmp/manifests/app2.yaml
sudo k3s kubectl apply -f /tmp/manifests/app3.yaml
sudo k3s kubectl apply -f /tmp/manifests/ingress.yaml
```

## 4. Vérifier que les ressources sont bien créées

```bash
sudo k3s kubectl get namespace
sudo k3s kubectl get pods -n webapps
sudo k3s kubectl get services -n webapps
sudo k3s kubectl get ingress -n webapps
```

### Résultats attendus

- Les Pods doivent être dans l’état `Running`
- Les Services doivent être créés
- L’Ingress doit apparaître avec le nom `webapps-ingress`

## 5. Vérifier les logs si besoin

```bash
sudo k3s kubectl logs -n webapps deployment/app1
sudo k3s kubectl logs -n webapps deployment/app2
sudo k3s kubectl logs -n webapps deployment/app3
```

## 6. Tester l’accès web par Host

### Tester app1

```bash
curl -H "Host: app1.com" http://127.0.0.1
```

### Tester app2

```bash
curl -H "Host: app2.com" http://127.0.0.1
```

### Tester app3 par défaut

```bash
curl -H "Host: autre.com" http://127.0.0.1
```

### Tester avec l’IP de la machine

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
```

## 7. Vérifier l’Ingress en détail

```bash
sudo k3s kubectl describe ingress webapps-ingress -n webapps
```

## 8. Nettoyer si besoin

```bash
sudo k3s kubectl delete -f /tmp/manifests/ingress.yaml
sudo k3s kubectl delete -f /tmp/manifests/app3.yaml
sudo k3s kubectl delete -f /tmp/manifests/app2.yaml
sudo k3s kubectl delete -f /tmp/manifests/app1.yaml
sudo k3s kubectl delete -f /tmp/manifests/namespace.yaml
```

## 9. Notes importantes

- Le routage par Host dépend de l’Ingress Controller Traefik, déjà livré avec K3s.
- Si `curl` ne retourne rien, vérifier que le port `80` est bien ouvert et que l’Ingress Controller est prêt.
- Si l’application ne répond pas, vérifier les Pods avec `kubectl get pods -n webapps`.

## 10. Virtual Machine Manager

Libvirt vs KVM vs QEMU

C'est souvent là que la confusion arrive :

Composant	Rôle
KVM	Permet au noyau Linux d'utiliser les extensions de virtualisation du CPU
QEMU	Émule/fournit le matériel virtuel de la VM
libvirt	Gère les VM et fournit une API commune
virsh	Interface en ligne de commande pour libvirt
virt-manager	Interface graphique pour libvirt

Donc, pour une installation classique :

KVM + QEMU = moteur de virtualisation
libvirt = gestionnaire
virsh / virt-manager = outils pour le piloter

# Commande pour verifier qu'il a bien 3 pods pour app2
    for i in {1..10}; do
        curl -s -H "Host: app2.com" http://192.168.121.189 | grep -o 'app-two-[^<]*'
    done

