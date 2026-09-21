# Présentation du projet Inception of Things

Ce projet sert à apprendre et démontrer les bases de Kubernetes avec K3s, de manière pratique.

## Ce que fait le projet

Il met en place un petit cluster Kubernetes local où trois applications web simples sont déployées, puis exposées via un Ingress. Le but n’est pas de créer un gros site, mais de montrer comment Kubernetes orchestre des services web.

## Comment il fonctionne

Le flux est le suivant :

1. Installation de K3s
   - K3s est une version légère de Kubernetes, adaptée aux petits environnements et aux labs.

2. Création d’un namespace
   - Cela isole les ressources du projet dans un espace logique dédié.

3. Déploiement de trois applications
   - Chaque application est définie par :
     - un Deployment, pour créer et maintenir les Pods ;
     - un Service, pour exposer ces Pods à l’intérieur du cluster.

4. Configuration d’un Ingress
   - L’Ingress sert à router les requêtes HTTP selon le Host.
   - Par exemple :
     - app1.com → app1
     - app2.com → app2
     - sinon → app3

5. Vérification du fonctionnement
   - On contrôle que les Pods sont bien en cours d’exécution.
   - On teste les accès avec curl ou via le navigateur.

## À quoi ça sert

Ce projet sert surtout à apprendre :

- comment lancer un cluster Kubernetes ;
- comment déployer des applications avec des manifests YAML ;
- comment faire communiquer les composants entre eux ;
- comment exposer des services avec un Service ;
- comment router du trafic avec un Ingress ;
- comment utiliser K3s et Traefik dans un contexte simple.

## En une phrase

C’est un mini laboratoire Kubernetes pour comprendre comment un cluster gère des applications web, leur exposition réseau et leur routage.

## Schéma simplifié

```text
Navigateur
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
