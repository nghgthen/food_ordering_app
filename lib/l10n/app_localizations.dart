import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  // dùng final thay vì const vì có placeholder {name}
  static final Map<String, Map<String, String>> _localized = {
    'en': {
      'home': 'Home',
      'orders': 'Orders',
      'cart': 'Cart',
      'settings': 'Settings',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'not_logged': 'Not logged in',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'font_size': 'Font size',
      'popular': 'Popular Foods',
      'see_all': 'See all',
      'search_hint': 'Search foods...',
      'add_success': 'Added {name} to cart',
      'login_prompt': 'Please login to continue',
      'login_prompt_cart': 'Please login to view your cart',
      'login_prompt_orders': 'Please login to view your orders',
      'login_required': 'Login Required',
      'login_to_add_cart': 'You need to login to add items to cart',
      'cancel': 'Cancel',
      'login_success': 'Login success',
      'login_failed': 'Login failed',
      'register_success': 'Register success',
      'register_failed': 'Register failed',
      // HomePage keys
      'what_would_you_like_to_eat': 'What would you like to eat?',
      'no_foods_available': 'No foods available',
      'what_would_you_like_to_buy': 'What would you like to buy?',
      'categories': 'Categories',
      'category_all': 'All',
      'category_burger': 'Burger',
      'category_pizza': 'Pizza',
      'category_sushi': 'Sushi',
      'category_cake': 'Cake',
      'category_drinks': 'Drinks',
      'category_salad': 'Salad',
      'popular_foods': 'Popular Foods',
      'all_foods': 'All Foods',
      'added': 'Added',
      'to_cart': 'to cart'
    },
    'vi': {
      'home': 'Trang chủ',
      'orders': 'Đơn hàng',
      'cart': 'Giỏ hàng',
      'settings': 'Cài đặt',
      'login': 'Đăng nhập',
      'register': 'Đăng ký',
      'logout': 'Đăng xuất',
      'not_logged': 'Chưa đăng nhập',
      'dark_mode': 'Chế độ tối',
      'language': 'Ngôn ngữ',
      'font_size': 'Cỡ chữ',
      'popular': 'Món phổ biến',
      'see_all': 'Xem tất cả',
      'search_hint': 'Tìm món...',
      'add_success': 'Đã thêm {name} vào giỏ hàng',
      'login_prompt': 'Vui lòng đăng nhập để tiếp tục',
      'login_prompt_cart': 'Vui lòng đăng nhập để xem giỏ hàng',
      'login_prompt_orders': 'Vui lòng đăng nhập để xem đơn hàng',
      'login_required': 'Yêu cầu đăng nhập',
      'login_to_add_cart': 'Bạn cần đăng nhập để thêm món vào giỏ hàng',
      'cancel': 'Huỷ',
      'login_success': 'Đăng nhập thành công',
      'login_failed': 'Đăng nhập thất bại',
      'register_success': 'Đăng ký thành công',
      'register_failed': 'Đăng ký thất bại',
      // HomePage keys
      'what_would_you_like_to_eat': 'Bạn muốn ăn gì?',
'no_foods_available': 'Không có món ăn nào',
      'what_would_you_like_to_buy': 'Bạn muốn mua gì?',
      'categories': 'Danh mục',
      'category_all': 'Tất cả',
      'category_burger': 'Burger',
      'category_pizza': 'Pizza',
      'category_sushi': 'Sushi',
      'category_cake': 'Bánh',
      'category_drinks': 'Đồ uống',
      'category_salad': 'Salad',
      'popular_foods': 'Món phổ biến',
      'all_foods': 'Tất cả món',
      'added': 'Đã thêm',
      'to_cart': 'vào giỏ hàng'
    },
    'es': {
      'home': 'Inicio',
      'orders': 'Pedidos',
      'cart': 'Carrito',
      'settings': 'Ajustes',
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
      'logout': 'Cerrar sesión',
      'not_logged': 'No iniciado sesión',
      'dark_mode': 'Modo oscuro',
      'language': 'Idioma',
      'font_size': 'Tamaño de fuente',
      'popular': 'Comidas populares',
      'see_all': 'Ver todo',
      'search_hint': 'Buscar...',
      'add_success': 'Añadido {name} al carrito',
      'login_prompt': 'Por favor inicie sesión para continuar',
      'login_prompt_cart': 'Por favor inicie sesión para ver su carrito',
      'login_prompt_orders': 'Por favor inicie sesión para ver sus pedidos',
      'login_required': 'Inicio de sesión requerido',
      'login_to_add_cart': 'Necesita iniciar sesión para añadir items al carrito',
      'cancel': 'Cancelar',
      'login_success': 'Inicio de sesión correcto',
      'login_failed': 'Error de inicio',
      'register_success': 'Registro correcto',
      'register_failed': 'Registro fallido',
      // HomePage keys
      'what_would_you_like_to_eat': '¿Qué te gustaría comer?',
      'no_foods_available': 'No hay comidas disponibles',
      'what_would_you_like_to_buy': '¿Qué te gustaría comprar?',
      'categories': 'Categorías',
      'category_all': 'Todo',
      'category_burger': 'Hamburguesa',
      'category_pizza': 'Pizza',
      'category_sushi': 'Sushi',
      'category_cake': 'Pastel',
      'category_drinks': 'Bebidas',
      'category_salad': 'Ensalada',
      'popular_foods': 'Comidas Populares',
      'all_foods': 'Todas las Comidas',
      'added': 'Añadido',
      'to_cart': 'al carrito'
    },
    'fr': {
      'home': 'Accueil',
      'orders': 'Commandes',
      'cart': 'Panier',
      'settings': 'Paramètres',
      'login': 'Connexion',
      'register': 'Inscription',
      'logout': 'Déconnexion',
      'not_logged': 'Non connecté',
      'dark_mode': 'Mode sombre',
      'language': 'Langue',
      'font_size': 'Taille de police',
      'popular': 'Plats populaires',
      'see_all': 'Voir tout',
      'search_hint': 'Rechercher...',
      'add_success': 'Ajouté {name} au panier',
      'login_prompt': 'Veuillez vous connecter pour continuer',
      'login_prompt_cart': 'Veuillez vous connecter pour voir votre panier',
      'login_prompt_orders': 'Veuillez vous connecter pour voir vos commandes',
'login_required': 'Connexion requise',
      'login_to_add_cart': 'Vous devez vous connecter pour ajouter des articles au panier',
      'cancel': 'Annuler',
      'login_success': 'Connexion réussie',
      'login_failed': 'Échec de connexion',
      'register_success': 'Inscription réussie',
      'register_failed': 'Échec de l\'inscription',
      // HomePage keys
      'what_would_you_like_to_eat': 'Qu\'aimeriez-vous manger?',
      'no_foods_available': 'Aucun plat disponible',
      'what_would_you_like_to_buy': 'Qu\'aimeriez-vous acheter?',
      'categories': 'Catégories',
      'category_all': 'Tout',
      'category_burger': 'Burger',
      'category_pizza': 'Pizza',
      'category_sushi': 'Sushi',
      'category_cake': 'Gâteau',
      'category_drinks': 'Boissons',
      'category_salad': 'Salade',
      'popular_foods': 'Plats Populaires',
      'all_foods': 'Tous les Plats',
      'added': 'Ajouté',
      'to_cart': 'au panier'
    }
  };

  String t(String key, {Map<String, String>? params}) {
    final map = _localized[locale.languageCode] ?? _localized['en']!;
    String s = map[key] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        s = s.replaceAll('{$k}', v);
      });
    }
    return s;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi')); // fallback
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['vi', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}