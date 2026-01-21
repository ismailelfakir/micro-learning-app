# Contributing to Micro-Learning App

Merci de votre intérêt pour contribuer à ce projet ! 🎉

## Comment contribuer

### Signaler un bug

Si vous trouvez un bug, veuillez créer une issue avec :
- Description claire du problème
- Étapes pour reproduire
- Comportement attendu vs comportement actuel
- Captures d'écran si applicable
- Version de Flutter et OS

### Proposer une fonctionnalité

Pour proposer une nouvelle fonctionnalité :
- Créez une issue avec le label "enhancement"
- Décrivez clairement la fonctionnalité
- Expliquez pourquoi elle serait utile
- Proposez une implémentation si possible

### Soumettre du code

1. **Fork** le projet
2. Créez une branche pour votre fonctionnalité :
   ```bash
   git checkout -b feature/ma-fonctionnalite
   ```
3. Suivez les conventions de code :
   - Utilisez `flutter format` avant de commiter
   - Écrivez des commentaires pour le code complexe
   - Respectez l'architecture feature-based
4. Testez votre code :
   ```bash
   flutter test
   flutter analyze
   ```
5. Commitez vos changements :
   ```bash
   git commit -m "feat: ajout de ma fonctionnalité"
   ```
6. Push vers votre fork :
   ```bash
   git push origin feature/ma-fonctionnalite
   ```
7. Ouvrez une **Pull Request**

## Conventions de code

### Nommage
- **Fichiers** : `snake_case.dart`
- **Classes** : `PascalCase`
- **Variables/Fonctions** : `camelCase`
- **Constantes** : `UPPER_SNAKE_CASE`

### Structure
- Respectez l'architecture feature-based
- Un fichier = une classe principale
- Séparation claire des responsabilités

### Commentaires
- Documentez les fonctions publiques
- Expliquez la logique complexe
- Utilisez des commentaires DartDoc pour les APIs publiques

## Format de commit

Utilisez des messages de commit clairs :
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `style:` Formatage, point-virgule manquant, etc.
- `refactor:` Refactoring du code
- `test:` Ajout de tests
- `chore:` Maintenance

Exemple :
```
feat: ajout du filtrage par type de contenu dans la liste des leçons
```

## Tests

- Ajoutez des tests pour les nouvelles fonctionnalités
- Assurez-vous que tous les tests passent
- Maintenez la couverture de code

## Questions ?

N'hésitez pas à ouvrir une issue pour toute question !

Merci de contribuer ! 🙏
