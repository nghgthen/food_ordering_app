import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  // dùng final thay vì const vì có placeholder {name}
  static final Map<String, Map<String, String>> _localized = {
    'en': {
      'home':'Home','orders':'Orders','cart':'Cart','settings':'Settings',
      'login':'Login','register':'Register','logout':'Logout','not_logged':'Not logged in',
      'dark_mode':'Dark Mode','language':'Language','font_size':'Font size',
      'popular':'Popular Foods','see_all':'See all','search_hint':'Search foods...',
      'add_success':'Added {name} to cart','login_prompt':'Please login to add to cart',
      'login_success':'Login success','login_failed':'Login failed',
      'register_success':'Register success','register_failed':'Register failed'
    },
    'vi': {
      'home':'Trang chủ','orders':'Đơn hàng','cart':'Giỏ hàng','settings':'Cài đặt',
      'login':'Đăng nhập','register':'Đăng ký','logout':'Đăng xuất','not_logged':'Chưa đăng nhập',
      'dark_mode':'Chế độ tối','language':'Ngôn ngữ','font_size':'Cỡ chữ',
      'popular':'Món phổ biến','see_all':'Xem tất cả','search_hint':'Tìm món...',
      'add_success':'Đã thêm {name} vào giỏ hàng','login_prompt':'Vui lòng đăng nhập để thêm vào giỏ hàng',
      'login_success':'Đăng nhập thành công','login_failed':'Đăng nhập thất bại',
      'register_success':'Đăng ký thành công','register_failed':'Đăng ký thất bại'
    },
    'es': {
      'home':'Inicio','orders':'Pedidos','cart':'Carrito','settings':'Ajustes',
      'login':'Iniciar sesión','register':'Registrarse','logout':'Cerrar sesión','not_logged':'No iniciado sesión',
      'dark_mode':'Modo oscuro','language':'Idioma','font_size':'Tamaño de fuente',
      'popular':'Comidas populares','see_all':'Ver todo','search_hint':'Buscar...',
      'add_success':'Añadido {name} al carrito','login_prompt':'Por favor inicie sesión para añadir al carrito',
      'login_success':'Inicio de sesión correcto','login_failed':'Error de inicio',
      'register_success':'Registro correcto','register_failed':'Registro fallido'
    },
    'fr': {
      'home':'Accueil','orders':'Commandes','cart':'Panier','settings':'Paramètres',
      'login':'Connexion','register':'Inscription','logout':'Déconnexion','not_logged':'Non connecté',
      'dark_mode':'Mode sombre','language':'Langue','font_size':'Taille de police',
      'popular':'Plats populaires','see_all':'Voir tout','search_hint':'Rechercher...',
      'add_success':'Ajouté {name} au panier','login_prompt':'Veuillez vous connecter pour ajouter au panier',
      'login_success':'Connexion réussie','login_failed':'Échec de connexion',
      'register_success':'Inscription réussie','register_failed':'Échec de l\'inscription'
    }
  };

  String t(String key, {Map<String,String>? params}) {
    final map = _localized[locale.languageCode] ?? _localized['en']!;
    String s = map[key] ?? key;
    if (params != null) {
      params.forEach((k,v) { s = s.replaceAll('{$k}', v); });
    }
    return s;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)
        ?? AppLocalizations(const Locale('en')); // fallback
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en','vi','es','fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
