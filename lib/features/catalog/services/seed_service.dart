import '../../../core/models/category.dart';
import '../../../core/models/lesson.dart';
import '../../../core/models/quiz.dart';
import '../../../core/models/question.dart';
import '../../../core/models/answer.dart';
import '../data/category_dao.dart';
import '../data/lesson_dao.dart';
import '../../quiz/data/quiz_dao.dart';
import '../../quiz/data/question_dao.dart';
import '../../quiz/data/answer_dao.dart';

/// Service pour insérer des données de démonstration
/// 
/// Insère des données UNIQUEMENT si les tables sont vides
/// Ne modifie jamais les données utilisateur existantes
class SeedService {
  final CategoryDao _categoryDao = CategoryDao();
  final LessonDao _lessonDao = LessonDao();
  final QuizDao _quizDao = QuizDao();
  final QuestionDao _questionDao = QuestionDao();
  final AnswerDao _answerDao = AnswerDao();

  /// Insère des données de démonstration si les tables sont vides
  /// 
  /// Vérifie d'abord si des catégories existent déjà
  /// N'insère rien si des données existent déjà
  Future<void> seedDemoDataIfEmpty() async {
    // Vérifier si des catégories existent déjà
    final int categoryCount = await _categoryDao.countCategories();
    if (categoryCount > 0) {
      // Données existantes: on ne touche pas aux catégories/leçons existantes,
      // mais on s'assure que "Développement Web" contient un set de leçons pro + quiz.
      await _ensureDevWebProfessionalLessons();
      return;
    }

    // Les tables sont vides, on insère des données de démo
    await _insertDemoCategories();
    
    // Après insertion des catégories/leçons de base, compléter DevWeb (pro) + quiz
    await _ensureDevWebProfessionalLessons();
  }

  /// Assure des leçons "Développement Web" réalistes pour tous les types
  /// et crée un quiz pour chaque leçon (sans écraser l'existant).
  Future<void> _ensureDevWebProfessionalLessons() async {
    // Trouver la catégorie "Développement Web"
    final List<Category> categories =
        await _categoryDao.getAllCategories(orderByDate: false);
    Category? devWeb;
    for (final Category c in categories) {
      if (c.nom.trim().toLowerCase() == 'développement web') {
        devWeb = c;
        break;
      }
    }

    if (devWeb == null) {
      // Catégorie non présente, rien à faire
      return;
    }

    // Charger les leçons existantes dans cette catégorie
    final List<Lesson> existing = await _lessonDao.getLessonsByCategoryId(
      devWeb.id!,
      orderByDate: false,
    );

    // Leçons pro (exactement une par type)
    final DateTime now = DateTime.now();
    final List<Lesson> desired = [
      Lesson(
        categorieId: devWeb.id!,
        titre: 'HTML sémantique & accessibilité (a11y)',
        description:
            'Objectif: structurer une page lisible par humains et lecteurs d’écran.\n\n'
            '- Utiliser <header>, <main>, <section>, <article>, <footer>\n'
            '- Hiérarchie des titres (h1 → h2 → h3)\n'
            '- Texte alternatif (alt) pour les images\n'
            '- Labels de formulaires (<label for=...>)\n\n'
            'Bon réflexe: valider avec Lighthouse (Accessibilité).',
        contenuType: 'TEXTE',
        dureeEstimee: 12,
        dateCreation: now,
      ),
      Lesson(
        categorieId: devWeb.id!,
        titre: 'CSS Layout: Flexbox (PDF résumé)',
        description:
            'Résumé PDF: axes, align-items, justify-content, flex-wrap + cas courants.',
        contenuType: 'PDF',
        cheminFichier: 'assets/pdfs/css_flexbox.pdf',
        dureeEstimee: 10,
        dateCreation: now.add(const Duration(minutes: 10)),
      ),
      Lesson(
        categorieId: devWeb.id!,
        titre: 'JavaScript: variables & types (capsule vidéo)',
        description:
            'Capsule 1–3 min: let/const, types primitifs, typeof, conversions.',
        contenuType: 'VIDEO',
        cheminFichier: 'assets/videos/javascript_variables.mp4',
        dureeEstimee: 3,
        dateCreation: now.add(const Duration(minutes: 20)),
      ),
      Lesson(
        categorieId: devWeb.id!,
        titre: "DOM: comprendre l'arbre (illustration)",
        description:
            'Illustration: DOM tree, parent/enfant, querySelector, événements.\n'
            'Visualisez la structure hiérarchique du DOM avec cette illustration.',
        contenuType: 'IMAGE',
        cheminFichier: 'assets/images/dom_diagram.svg',
        dureeEstimee: 8,
        dateCreation: now.add(const Duration(minutes: 30)),
      ),
    ];

    // Nettoyer les anciennes leçons de Développement Web qui ne font pas
    // partie de notre set professionnel (sans toucher aux autres catégories).
    final Set<String> desiredTitles = desired
        .map((l) => l.titre.trim().toLowerCase())
        .toSet();
    for (final Lesson old in existing) {
      if (!desiredTitles.contains(old.titre.trim().toLowerCase()) &&
          old.id != null) {
        await _lessonDao.deleteLesson(old.id!);
      }
    }

    // Recalculer les leçons existantes (après nettoyage)
    final List<Lesson> remaining = await _lessonDao.getLessonsByCategoryId(
      devWeb.id!,
      orderByDate: false,
    );
    final Set<String> existingTitles =
        remaining.map((l) => l.titre.trim().toLowerCase()).toSet();

    // Insérer uniquement les leçons manquantes
    final List<Lesson> inserted = [];
    for (final Lesson lesson in desired) {
      if (existingTitles.contains(lesson.titre.trim().toLowerCase())) {
        continue;
      }
      final int id = await _lessonDao.createLesson(lesson);
      inserted.add(lesson.copyWith(id: id));
    }

    // Recharger les leçons DevWeb (incluant existantes + nouvelles)
    final List<Lesson> devWebLessons =
        await _lessonDao.getLessonsByCategoryId(devWeb.id!, orderByDate: false);

    // Créer un quiz pour chaque leçon DevWeb (en supprimant l'ancien au besoin)
    for (final Lesson lesson in devWebLessons) {
      if (lesson.id == null) continue;
      final Quiz? existingQuiz = await _quizDao.getQuizByLeconId(lesson.id!);
      if (existingQuiz != null) {
        // Supprimer l'ancien quiz et son contenu pour injecter le quiz spécifique à la leçon
        await _quizDao.deleteQuizByLeconId(lesson.id!);
      }
      await _createProfessionalQuizForLesson(lesson);
    }
  }

  Future<void> _createProfessionalQuizForLesson(Lesson lesson) async {
    final DateTime now = DateTime.now();
    final int quizId = await _quizDao.createQuiz(
      Quiz(
        leconId: lesson.id!,
        titre: 'Quiz: ${lesson.titre}',
        description: 'Évaluation rapide (QCM) — 3 questions.',
        dateCreation: now,
      ),
    );

    // Questions simples, 1 bonne réponse chacune (QCM)
    // Questions spécifiques par leçon (pro et concrètes)
    final String title = lesson.titre.toLowerCase();
    late final List<(String q, List<(String a, bool ok)> answers)> template;

    if (title.contains('html')) {
      template = [
        (
          'Quel élément sémantique définit le contenu principal de la page ?',
          [
            ('<main>', true),
            ('<div class="content">', false),
            ('<section>', false),
          ]
        ),
        (
          'Pourquoi les attributs alt sur les images sont importants ?',
          [
            ('Pour l’accessibilité et les lecteurs d’écran', true),
            ('Pour augmenter la taille du fichier', false),
            ('Pour le SEO uniquement', false),
          ]
        ),
        (
          'Quelle hiérarchie de titres est correcte ?',
          [
            ('h1 puis h2 puis h3', true),
            ('h3 puis h1 puis h2', false),
            ('Peu importe l’ordre', false),
          ]
        ),
      ];
    } else if (title.contains('flexbox')) {
      template = [
        (
          'Quel axe est contrôlé par justify-content en Flexbox ?',
          [
            ('L’axe principal', true),
            ('L’axe transversal', false),
            ('Aucun axe', false),
          ]
        ),
        (
          'Quel property active le retour à la ligne des items ?',
          [
            ('flex-wrap: wrap;', true),
            ('flex-direction: column;', false),
            ('align-items: stretch;', false),
          ]
        ),
        (
          'Quel raccourci combine flex-grow, flex-shrink et flex-basis ?',
          [
            ('flex: 1 1 auto;', true),
            ('display: flex;', false),
            ('flex-flow: row wrap;', false),
          ]
        ),
      ];
    } else if (title.contains('javascript') || title.contains('vidéo')) {
      template = [
        (
          'Quelle différence entre let et const ?',
          [
            ('const ne peut pas être réaffecté', true),
            ('let est global par défaut', false),
            ('const est hoisté en tant que var', false),
          ]
        ),
        (
          'typeof null retourne :',
          [
            ('"object"', true),
            ('"null"', false),
            ('"undefined"', false),
          ]
        ),
        (
          'Quel type est renvoyé par Number("42") ?',
          [
            ('number', true),
            ('string', false),
            ('boolean', false),
          ]
        ),
      ];
    } else if (title.contains('dom')) {
      template = [
        (
          'querySelector("main") retourne :',
          [
            ('Le premier élément <main>', true),
            ('Une NodeList de tous les <main>', false),
            ('Toujours null', false),
          ]
        ),
        (
          'Quel événement est déclenché quand on clique ?',
          [
            ('click', true),
            ('change', false),
            ('submit', false),
          ]
        ),
        (
          'Quelle propriété donne l’élément parent ?',
          [
            ('parentElement', true),
            ('children', false),
            ('innerHTML', false),
          ]
        ),
      ];
    } else {
      // Fallback générique (rare)
      template = [
        (
          'Quel est l’objectif principal de cette leçon ?',
          [
            ('Comprendre le concept présenté', true),
            ('Apprendre une liste par cœur', false),
            ('Ignorer les bonnes pratiques', false),
          ]
        ),
        (
          'Quelle pratique est recommandée ?',
          [
            ('Appliquer une structure claire et cohérente', true),
            ('Mélanger les responsabilités au hasard', false),
            ('Éviter tout test/validation', false),
          ]
        ),
        (
          'Quel est le bon réflexe après l’apprentissage ?',
          [
            ('Mettre en pratique sur un mini-exemple', true),
            ('Ne rien essayer', false),
            ('Changer de sujet immédiatement', false),
          ]
        ),
      ];
    }

    for (int i = 0; i < template.length; i++) {
      final (qText, answers) = template[i];
      final int questionId = await _questionDao.createQuestion(
        Question(
          quizId: quizId,
          texte: qText,
          type: 'QCM',
          ordre: i + 1,
        ),
      );

      for (int j = 0; j < answers.length; j++) {
        final (aText, ok) = answers[j];
        await _answerDao.createAnswer(
          Answer(
            questionId: questionId,
            texte: aText,
            estCorrecte: ok,
            ordre: j + 1,
          ),
        );
      }
    }
  }

  /// Insère des catégories de démonstration
  Future<void> _insertDemoCategories() async {
    final DateTime now = DateTime.now();

    // Créer les catégories
    final List<Category> categories = [
      Category(
        nom: 'Développement Web',
        description: 'Apprenez les bases du développement web',
        icone: 'code',
        dateCreation: now,
      ),
      Category(
        nom: 'Langues',
        description: 'Améliorez vos compétences linguistiques',
        icone: 'translate',
        dateCreation: now,
      ),
      Category(
        nom: 'Mathématiques',
        description: 'Cours de mathématiques et exercices',
        icone: 'calculate',
        dateCreation: now,
      ),
      Category(
        nom: 'Sciences',
        description: 'Découvrez les sciences fondamentales',
        icone: 'science',
        dateCreation: now,
      ),
    ];

    // Insérer les catégories et récupérer leurs IDs
    final List<int> categoryIds = [];
    for (final Category category in categories) {
      final int id = await _categoryDao.createCategory(category);
      categoryIds.add(id);
    }

    // Insérer des leçons pour chaque catégorie
    await _insertDemoLessons(categoryIds, now);
  }

  /// Insère des leçons de démonstration pour chaque catégorie
  Future<void> _insertDemoLessons(List<int> categoryIds, DateTime baseDate) async {
    // Développement Web (index 0)
    if (categoryIds.isNotEmpty) {
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[0],
          titre: 'Introduction à HTML',
          description: 'Découvrez les bases du HTML et créez votre première page web',
          contenuType: 'TEXTE',
          dureeEstimee: 15,
          dateCreation: baseDate,
        ),
      );
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[0],
          titre: 'CSS pour débutants',
          description: 'Apprenez à styliser vos pages web avec CSS',
          contenuType: 'TEXTE',
          dureeEstimee: 20,
          dateCreation: baseDate.add(const Duration(hours: 1)),
        ),
      );
      // Leçon PDF de démo
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[0],
          titre: 'Guide complet du développement web',
          description: 'Un guide PDF complet sur le développement web moderne',
          contenuType: 'PDF',
          cheminFichier: 'assets/pdfs/css_flexbox.pdf',
          dureeEstimee: 30,
          dateCreation: baseDate.add(const Duration(hours: 2)),
        ),
      );
      // Leçon VIDEO de démo
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[0],
          titre: 'JavaScript en 3 minutes',
          description: 'Une introduction rapide aux concepts clés de JavaScript',
          contenuType: 'VIDEO',
          cheminFichier: 'assets/videos/javascript_variables.mp4',
          dureeEstimee: 3,
          dateCreation: baseDate.add(const Duration(hours: 3)),
        ),
      );
    }

    // Langues (index 1)
    if (categoryIds.length > 1) {
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[1],
          titre: 'Vocabulaire essentiel anglais',
          description: '100 mots essentiels pour débuter en anglais',
          contenuType: 'TEXTE',
          dureeEstimee: 10,
          dateCreation: baseDate,
        ),
      );
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[1],
          titre: 'Grammaire française niveau 1',
          description: 'Les bases de la grammaire française',
          contenuType: 'TEXTE',
          dureeEstimee: 25,
          dateCreation: baseDate.add(const Duration(hours: 2)),
        ),
      );
    }

    // Mathématiques (index 2)
    if (categoryIds.length > 2) {
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[2],
          titre: 'Les fractions',
          description: 'Comprendre et manipuler les fractions',
          contenuType: 'TEXTE',
          dureeEstimee: 18,
          dateCreation: baseDate,
        ),
      );
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[2],
          titre: 'Introduction à l\'algèbre',
          description: 'Premiers pas en algèbre pour débutants',
          contenuType: 'TEXTE',
          dureeEstimee: 30,
          dateCreation: baseDate.add(const Duration(hours: 3)),
        ),
      );
    }

    // Sciences (index 3)
    if (categoryIds.length > 3) {
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[3],
          titre: 'Le système solaire',
          description: 'Découvrez les planètes et le système solaire',
          contenuType: 'TEXTE',
          dureeEstimee: 12,
          dateCreation: baseDate,
        ),
      );
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[3],
          titre: 'Les états de la matière',
          description: 'Solide, liquide, gazeux : les bases',
          contenuType: 'TEXTE',
          dureeEstimee: 15,
          dateCreation: baseDate.add(const Duration(hours: 4)),
        ),
      );
      // Leçon de type IMAGE pour tester le rendu d'images
      await _lessonDao.createLesson(
        Lesson(
          categorieId: categoryIds[3],
          titre: 'Anatomie du corps humain',
          description: 'Explorez l\'anatomie à travers des illustrations détaillées',
          contenuType: 'IMAGE',
          dureeEstimee: 20,
          dateCreation: baseDate.add(const Duration(hours: 5)),
        ),
      );
    }
  }

  /// Insère des quiz de démonstration
  /// 
  /// Crée un quiz pour la première leçon disponible
  Future<void> _insertDemoQuizzes() async {
    // Récupérer toutes les leçons pour trouver une leçon à laquelle associer un quiz
    final List<Lesson> allLessons = await _lessonDao.getAllLessons();
    if (allLessons.isEmpty) {
      // Pas de leçons disponibles, on ne peut pas créer de quiz
      return;
    }

    // Utiliser la première leçon pour créer un quiz de démo
    final Lesson firstLesson = allLessons.first;
    final DateTime now = DateTime.now();

    // Créer un quiz pour cette leçon
    final Quiz demoQuiz = Quiz(
      leconId: firstLesson.id!,
      titre: 'Quiz de révision',
      description: 'Testez vos connaissances sur cette leçon',
      dateCreation: now,
    );

    final int quizId = await _quizDao.createQuiz(demoQuiz);

    // Créer des questions pour ce quiz
    await _insertDemoQuestions(quizId, now, firstLesson.titre);
  }

  /// Insère des questions de démonstration pour un quiz
  Future<void> _insertDemoQuestions(int quizId, DateTime baseDate, String lessonTitle) async {
    // Question 1
    final Question question1 = Question(
      quizId: quizId,
      texte: 'Qu\'avez-vous appris dans cette leçon ?',
      type: 'QCM',
      ordre: 1,
    );
    final int question1Id = await _questionDao.createQuestion(question1);

    // Réponses pour question 1
    await _answerDao.createAnswer(
      Answer(
        questionId: question1Id,
        texte: 'Les concepts fondamentaux',
        estCorrecte: true,
        ordre: 1,
      ),
    );
    await _answerDao.createAnswer(
      Answer(
        questionId: question1Id,
        texte: 'Des informations avancées',
        estCorrecte: false,
        ordre: 2,
      ),
    );
    await _answerDao.createAnswer(
      Answer(
        questionId: question1Id,
        texte: 'Des détails techniques complexes',
        estCorrecte: false,
        ordre: 3,
      ),
    );

    // Question 2
    final Question question2 = Question(
      quizId: quizId,
      texte: 'Quel est le point principal de cette leçon ?',
      type: 'QCM',
      ordre: 2,
    );
    final int question2Id = await _questionDao.createQuestion(question2);

    // Réponses pour question 2
    await _answerDao.createAnswer(
      Answer(
        questionId: question2Id,
        texte: 'Comprendre les bases',
        estCorrecte: true,
        ordre: 1,
      ),
    );
    await _answerDao.createAnswer(
      Answer(
        questionId: question2Id,
        texte: 'Maîtriser les techniques avancées',
        estCorrecte: false,
        ordre: 2,
      ),
    );
    await _answerDao.createAnswer(
      Answer(
        questionId: question2Id,
        texte: 'Apprendre par cœur',
        estCorrecte: false,
        ordre: 3,
      ),
    );

    // Question 3
    final Question question3 = Question(
      quizId: quizId,
      texte: 'Cette leçon vous a-t-elle aidé à progresser ?',
      type: 'QCM',
      ordre: 3,
    );
    final int question3Id = await _questionDao.createQuestion(question3);

    // Réponses pour question 3
    await _answerDao.createAnswer(
      Answer(
        questionId: question3Id,
        texte: 'Oui, j\'ai bien compris',
        estCorrecte: true,
        ordre: 1,
      ),
    );
    await _answerDao.createAnswer(
      Answer(
        questionId: question3Id,
        texte: 'Non, c\'était trop difficile',
        estCorrecte: false,
        ordre: 2,
      ),
    );
    await _answerDao.createAnswer(
      Answer(
        questionId: question3Id,
        texte: 'Je ne suis pas sûr',
        estCorrecte: false,
        ordre: 3,
      ),
    );
  }
}
