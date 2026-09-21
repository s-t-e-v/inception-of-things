# Procédure pour faire un fork plus tard

Si tu veux attendre la fin du projet avant de créer ton fork, tu peux utiliser cette procédure simple.

## 1. Créer le fork sur GitHub

Va sur le dépôt du groupe sur GitHub et clique sur **Fork**.

## 2. Ajouter ton fork comme remote

Remplace `TON_NOM_UTILISATEUR` par ton vrai nom d’utilisateur GitHub :

```bash
git remote add fork https://github.com/TON_NOM_UTILISATEUR/inception-of-things.git
```

## 3. Pousser ta branche vers ton fork

```bash
git push -u fork PedroV
```

## Résultat

Ta branche `PedroV` sera alors visible sur ton propre dépôt GitHub.
