# K3s vs K3d

> Deux noms très proches, mais deux rôles très différents.

## Résumé

**K3s** est une **distribution légère de Kubernetes**.

**K3d** est un **outil qui lance des clusters K3s à l'intérieur de
conteneurs Docker**.

Autrement dit :

-   **K3s = Kubernetes**
-   **K3d = outil qui exécute K3s dans Docker**

------------------------------------------------------------------------

# Vue d'ensemble

``` text
                  Kubernetes (K8s)
                         │
              ┌──────────┴──────────┐
              │                     │
            K3s                 Kubernetes classique
      (distribution légère)     (kubeadm, etc.)
              │
              │
             K3d
 (outil qui lance K3s dans Docker)
```

------------------------------------------------------------------------

# K3s

K3s est un **véritable cluster Kubernetes**.

Tu l'installes directement sur une machine Linux.

``` text
VM
│
├── Linux
├── K3s
├── containerd
├── Traefik
└── Pods
```

Installation :

``` bash
curl -sfL https://get.k3s.io | sh -
```

Les Pods s'exécutent directement sur cette machine.

C'est exactement ce qui est demandé dans **Inception of Things**.

------------------------------------------------------------------------

# K3d

K3d n'est **pas** Kubernetes.

C'est un outil qui crée automatiquement un cluster **K3s** dans des
conteneurs Docker.

Commande :

``` bash
k3d cluster create moncluster
```

Architecture :

``` text
Machine Linux

Docker
│
├── Conteneur
│      └── K3s Server
│
├── Conteneur
│      └── K3s Agent
│
└── Conteneur
       └── Load Balancer
```

Les nœuds Kubernetes sont eux-mêmes des conteneurs Docker.

------------------------------------------------------------------------

# Comparaison

## Avec K3s

``` text
VM

Linux

K3s

Pods
```

Les Pods tournent directement sur la VM.

## Avec K3d

``` text
VM

Linux

Docker

Conteneur K3s

Pods
```

Docker ajoute une couche supplémentaire.

------------------------------------------------------------------------

# Pourquoi utiliser K3d ?

K3d est très pratique pour le développement.

Créer un cluster :

``` bash
k3d cluster create test
```

Supprimer un cluster :

``` bash
k3d cluster delete test
```

En quelques secondes, tu peux créer et détruire un cluster complet.

------------------------------------------------------------------------

# Pourquoi 42 demande K3s ?

Le projet veut que tu comprennes :

-   l'installation d'un cluster ;
-   le fonctionnement de Kubernetes ;
-   la configuration réseau ;
-   les objets Kubernetes.

Avec K3d, une partie de cette complexité est masquée par Docker.

------------------------------------------------------------------------

# Est-ce que K3d utilise K3s ?

Oui.

À chaque création de cluster, K3d télécharge une image K3s et la lance
dans des conteneurs Docker.

Il ne crée pas un Kubernetes différent.

------------------------------------------------------------------------

# Tableau comparatif

  -----------------------------------------------------------------------
  K3s                                 K3d
  ----------------------------------- -----------------------------------
  Distribution Kubernetes légère      Outil de gestion de clusters K3s

  Installation directe sur une VM ou  Fonctionne au-dessus de Docker
  un serveur                          

  Utilise containerd                  Utilise Docker pour héberger les
                                      nœuds K3s

  Adapté aux VM, serveurs, edge       Adapté au développement local

  C'est Kubernetes                    Ce n'est pas Kubernetes
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# Analogie

Imagine que **K3s est une maison**.

``` text
Terrain

Maison
```

Tu peux y vivre directement.

**K3d**, c'est un transporteur qui installe plusieurs maisons
préfabriquées sur un terrain.

``` text
Terrain

Docker

┌──────────────┐
│ Maison K3s   │
└──────────────┘

┌──────────────┐
│ Maison K3s   │
└──────────────┘
```

Les maisons restent des **K3s**, mais elles sont hébergées dans des
conteneurs Docker.

------------------------------------------------------------------------

# À retenir

-   **K3s** est un vrai cluster Kubernetes léger.
-   **K3d** est un outil qui lance K3s dans Docker.
-   Pour **Inception of Things**, on utilise **K3s**, car le sujet
    demande une VM avec K3s installé en mode serveur.
