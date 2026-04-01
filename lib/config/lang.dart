class Lang {
  static bool isSwahili = false;
  static void toggle() {
    isSwahili = !isSwahili;
  }

  static String get(String key) {
    return isSwahili ? _sw[key] ?? _en[key] ?? key : _en[key] ?? key;
  }

  // ==================== SWAHILI ====================
  static const Map<String, String> _sw = {
    // Welcome Screen
    'welcome_title': 'Karibu ZenjShop',
    'welcome_sub': 'Soko lako bora la Tanzania\nBidhaa bora, delivery haraka',
    'welcome_tagline': 'Nunua. Uza. Wasilisha.',
    'get_started': 'Anza Sasa',
    'already_account': 'Una akaunti tayari? Ingia',

    // Auth
    'login': 'Ingia',
    'signup': 'Jisajili',
    'email': 'Barua Pepe',
    'password': 'Nywila',
    'full_name': 'Jina Kamili',
    'phone': 'Namba ya Simu',
    'confirm_password': 'Thibitisha Nywila',
    'login_title': 'Karibu Tena!',
    'login_sub': 'Ingia kwenye akaunti yako',
    'signup_title': 'Unda Akaunti',
    'signup_sub': 'Jisajili na uanze kufaidika',
    'no_account': 'Huna akaunti? Jisajili',
    'have_account': 'Una akaunti? Ingia',
    'role_label': 'Unajisajili kama',
    'role_customer': 'Mnunuzi',
    'role_shop_owner': 'Mwenye Duka',
    'role_delivery': 'Msafirishaji',

    // Validation
    'fill_all': 'Tafadhali jaza sehemu zote',
    'invalid_phone': 'Namba ya simu si sahihi',
    'invalid_email': 'Barua pepe si sahihi',
    'weak_password': 'Nywila lazima iwe herufi 6 au zaidi',
    'login_error': 'Barua pepe au nywila si sahihi',
    'signup_error': 'Imeshindwa kusajili. Jaribu tena',
    'passwords_not_match': 'Nywila hazifanani',

    // Home
    'search_hint': 'Tafuta bidhaa au duka...',
    'categories': 'Makundi',
    'featured_shops': 'Maduka Maarufu',
    'all_products': 'Bidhaa Zote',
    'see_all': 'Ona Zote',

    // Admin
    'admin_panel': 'Dashibodi ya Admin',
    'total_orders': 'Maagizo Yote',
    'total_shops': 'Maduka Yote',
    'total_users': 'Watumiaji Wote',
    'pending_orders': 'Maagizo Yanayosubiri',
    'manage_shops': 'Simamia Maduka',
    'manage_orders': 'Simamia Maagizo',
    'manage_delivery': 'Simamia Wasafirishaji',

    // General
    'loading': 'Inapakia...',
    'logout': 'Toka',
    'save': 'Hifadhi',
    'cancel': 'Ghairi',
    'delete': 'Futa',
    'edit': 'Hariri',
    'add': 'Ongeza',
    'back': 'Rudi',
    'confirm': 'Thibitisha',
    'success': 'Imefanikiwa',
    'error': 'Hitilafu',
    'retry': 'Jaribu Tena',
  };

  // ==================== ENGLISH ====================
  static const Map<String, String> _en = {
    // Welcome Screen
    'welcome_title': 'Welcome to ZenjShop',
    'welcome_sub':
        'Tanzania\'s premier marketplace\nQuality products, fast delivery',
    'welcome_tagline': 'Buy. Sell. Deliver.',
    'get_started': 'Get Started',
    'already_account': 'Already have an account? Login',

    // Auth
    'login': 'Login',
    'signup': 'Sign Up',
    'email': 'Email Address',
    'password': 'Password',
    'full_name': 'Full Name',
    'phone': 'Phone Number',
    'confirm_password': 'Confirm Password',
    'login_title': 'Welcome Back!',
    'login_sub': 'Login to your account',
    'signup_title': 'Create Account',
    'signup_sub': 'Sign up and start benefiting',
    'no_account': 'No account? Sign up',
    'have_account': 'Have account? Login',
    'role_label': 'Registering as',
    'role_customer': 'Customer',
    'role_shop_owner': 'Shop Owner',
    'role_delivery': 'Delivery Person',

    // Validation
    'fill_all': 'Please fill all fields',
    'invalid_phone': 'Invalid phone number',
    'invalid_email': 'Invalid email address',
    'weak_password': 'Password must be at least 6 characters',
    'login_error': 'Invalid email or password',
    'signup_error': 'Registration failed. Try again',
    'passwords_not_match': 'Passwords do not match',

    // Home
    'search_hint': 'Search products or shops...',
    'categories': 'Categories',
    'featured_shops': 'Featured Shops',
    'all_products': 'All Products',
    'see_all': 'See All',

    // Admin
    'admin_panel': 'Admin Dashboard',
    'total_orders': 'Total Orders',
    'total_shops': 'Total Shops',
    'total_users': 'Total Users',
    'pending_orders': 'Pending Orders',
    'manage_shops': 'Manage Shops',
    'manage_orders': 'Manage Orders',
    'manage_delivery': 'Manage Delivery',

    // General
    'loading': 'Loading...',
    'logout': 'Logout',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'back': 'Back',
    'confirm': 'Confirm',
    'success': 'Success',
    'error': 'Error',
    'retry': 'Try Again',
  };
}
