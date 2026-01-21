import '../../../core/models/category.dart';
import '../../../core/models/lesson.dart';
import '../data/category_dao.dart';
import '../data/lesson_dao.dart';

/// Service métier pour le catalogue
/// 
/// Encapsule la logique métier liée aux catégories et leçons
class CatalogService {
  final CategoryDao _categoryDao = CategoryDao();
  final LessonDao _lessonDao = LessonDao();

  /// Récupère toutes les catégories
  /// 
  /// Trie par date de création (plus récentes en premier)
  Future<List<Category>> getAllCategories() async {
    return await _categoryDao.getAllCategories(orderByDate: true);
  }

  /// Récupère une catégorie par son ID
  /// 
  /// Retourne null si la catégorie n'existe pas
  Future<Category?> getCategoryById(int id) async {
    return await _categoryDao.getCategoryById(id);
  }

  /// Récupère toutes les leçons d'une catégorie
  /// 
  /// Retourne une liste vide si aucune leçon trouvée
  Future<List<Lesson>> getLessonsByCategoryId(int categoryId) async {
    return await _lessonDao.getLessonsByCategoryId(categoryId, orderByDate: true);
  }

  /// Récupère une leçon par son ID
  /// 
  /// Retourne null si la leçon n'existe pas
  Future<Lesson?> getLessonById(int id) async {
    return await _lessonDao.getLessonById(id);
  }

  /// Récupère une leçon avec sa catégorie associée
  /// 
  /// Retourne null si la leçon n'existe pas
  Future<({Lesson lesson, Category category})?> getLessonWithCategory(int lessonId) async {
    final Lesson? lesson = await _lessonDao.getLessonById(lessonId);
    if (lesson == null) {
      return null;
    }

    final Category? category = await _categoryDao.getCategoryById(lesson.categorieId);
    if (category == null) {
      return null;
    }

    return (lesson: lesson, category: category);
  }

  /// Compte le nombre de leçons dans une catégorie
  Future<int> countLessonsInCategory(int categoryId) async {
    return await _lessonDao.countLessonsByCategoryId(categoryId);
  }
}
