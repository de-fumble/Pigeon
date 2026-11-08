import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_shell.dart';
import 'package:pigeon/models/contact_input_mode.dart';
import 'package:pigeon/models/otp_channel.dart';
import 'package:pigeon/screens/auth_screens/contact_input_screen.dart';
import 'package:pigeon/screens/auth_screens/login_otp_intro_screen.dart';
import 'package:pigeon/screens/auth_screens/account_created_screen.dart';
import 'package:pigeon/screens/auth_screens/date_of_birth_screen.dart';
import 'package:pigeon/screens/auth_screens/interests_screen.dart';
import 'package:pigeon/screens/auth_screens/login_screen.dart';
import 'package:pigeon/screens/auth_screens/otp_verification_screen.dart';
import 'package:pigeon/screens/auth_screens/register_screen.dart';
import 'package:pigeon/screens/dashboard_screens/dashboard_feed_screen.dart';
import 'package:pigeon/screens/dashboard_screens/dashboard_markets_home_screen.dart';
import 'package:pigeon/screens/dashboard_screens/dashboard_search_screen.dart';
import 'package:pigeon/screens/dashboard_screens/account_screen.dart';
import 'package:pigeon/screens/dashboard_screens/post_detail_screen.dart';
import 'package:pigeon/screens/dashboard_screens/post_composer_screen.dart';
import 'package:pigeon/screens/dashboard_screens/notifications_screen.dart';
import 'package:pigeon/services/supabase_service.dart';
import 'package:pigeon/screens/dashboard_screens/wallet_screen.dart';
import 'package:pigeon/screens/dashboard_screens/wallet_settings_screen.dart';
import 'package:pigeon/screens/dashboard_screens/direct_debits_screen.dart';
import 'package:pigeon/screens/dashboard_screens/added_banks_screen.dart';
import 'package:pigeon/screens/dashboard_screens/get_support_screen.dart';
import 'package:pigeon/screens/dashboard_screens/deposit_screen.dart';
import 'package:pigeon/screens/dashboard_screens/direct_deposit_screen.dart';
import 'package:pigeon/screens/dashboard_screens/direct_deposit_review_screen.dart';
import 'package:pigeon/screens/dashboard_screens/direct_deposit_pending_screen.dart';
import 'package:pigeon/screens/dashboard_screens/add_bank_account_screen.dart';
import 'package:pigeon/screens/dashboard_screens/bank_account_linked_screen.dart';
import 'package:pigeon/screens/dashboard_screens/approving_activity_screen.dart';
import 'package:pigeon/screens/dashboard_screens/withdraw_amount_screen.dart';
import 'package:pigeon/screens/dashboard_screens/withdraw_review_screen.dart';
import 'package:pigeon/screens/dashboard_screens/withdraw_initiated_screen.dart';
import 'package:pigeon/screens/dashboard_screens/bank_detail_screen.dart';
import 'package:pigeon/screens/dashboard_screens/user_profile_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_panel_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_market_create_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_categories_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_category_detail_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_banners_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_create_shelf_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_create_topic_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_markets_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_market_category_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_section_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_topic_detail_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_topics_shelves_screen.dart';
import 'package:pigeon/screens/admin_screens/admin_users_screen.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/screens/market_screens/market_details_screen.dart';
import 'package:pigeon/screens/market_screens/market_discussion_screen.dart';
import 'package:pigeon/screens/market_screens/market_info_screen.dart';
import 'package:pigeon/screens/market_screens/market_politics_details_screen.dart';
import 'package:pigeon/screens/market_screens/market_position_screen.dart';
import 'package:pigeon/screens/market_screens/market_sell_input_screen.dart';
import 'package:pigeon/screens/market_screens/market_sell_review_screen.dart';
import 'package:pigeon/screens/market_screens/market_sell_success_screen.dart';
import 'package:pigeon/screens/market_screens/market_trade_input_screen.dart';
import 'package:pigeon/screens/market_screens/market_trade_review_screen.dart';
import 'package:pigeon/screens/market_screens/market_trade_success_screen.dart';
import 'package:pigeon/screens/market_screens/markets_tab_screen.dart';
import 'package:pigeon/models/market_detail.dart';
import 'package:pigeon/services/amm.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/models/trade_result_notification.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/screens/notifications_screens/notification_detail_screen.dart';
import 'package:pigeon/screens/onboarding_screens/onboarding_screen.dart';
import 'package:pigeon/screens/onboarding_screens/enable_notifications_screen.dart';
import 'package:pigeon/screens/onboarding_screens/splash_screen.dart';
import 'package:pigeon/models/market_tab_category.dart';
import 'package:pigeon/router/app_page_route.dart';

class AppRouter {
  const AppRouter._();

  static const String onboarding = '/';
  static const String splash = '/splash';
  static const String contactInput = '/contact-input';
  static const String login = '/login';
  static const String loginOtpIntro = '/login-otp-intro';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String dateOfBirth = '/date-of-birth';
  static const String interests = '/interests';
  static const String accountCreated = '/account-created';
  static const String enableNotifications = '/enable-notifications';
  static const String dashboardFeed = '/dashboard-feed';
  static const String dashboardMarketsHome = '/dashboard-markets-home';
  static const String dashboardSearch = '/dashboard-search';
  static const String notifications = '/notifications';
  static const String postDetail = '/post-detail';
  static const String postComposer = '/post-composer';
  static const String userProfile = '/user-profile';
  static const String editProfile = '/edit-profile';
  static const String account = '/account';
  static const String settingsRoute = '/settings';
  static const String settingsNotifications = '/settings-notifications';
  static const String accountSecurity = '/account-security';
  static const String wallet = '/wallet';
  static const String walletSettings = '/wallet-settings';
  static const String directDebits = '/direct-debits';
  static const String addedBanks = '/added-banks';
  static const String getSupport = '/get-support';
  static const String deposit = '/deposit';
  static const String directDeposit = '/direct-deposit';
  static const String directDepositReview = '/direct-deposit-review';
  static const String directDepositPending = '/direct-deposit-pending';
  static const String addBankAccount = '/add-bank-account';
  static const String bankAccountLinked = '/bank-account-linked';
  static const String approvingActivity = '/approving-activity';
  static const String withdrawAmount = '/withdraw-amount';
  static const String withdrawReview = '/withdraw-review';
  static const String withdrawInitiated = '/withdraw-initiated';
  static const String bankDetail = '/bank-detail';
  static const String marketPosition = '/market-position';
  static const String marketDiscussion = '/market-discussion';
  static const String marketTrade = '/market-trade';
  static const String marketPoliticsDetails = '/market-politics-details';
  static const String marketTradeInput = '/market-trade-input';
  static const String marketTradeReview = '/market-trade-review';
  static const String marketTradeSuccess = '/market-trade-success';
  static const String marketSellInput = '/market-sell-input';
  static const String marketSellReview = '/market-sell-review';
  static const String marketSellSuccess = '/market-sell-success';
  static const String marketInfo = '/market-info';
  static const String notificationDetail = '/notification-detail';
  static const String marketDetails = '/market-details';
  static const String marketsTab = '/markets-tab';
  static const String adminPanel = '/admin-panel';
  static const String adminUsers = '/admin-users';
  static const String adminSection = '/admin-section';
  static const String adminMarkets = '/admin-markets';
  static const String adminMarketCategorySelect =
      '/admin-market-category-select';
  static const String adminMarketCreate = '/admin-market-create';
  static const String adminCategories = '/admin-categories';
  static const String adminCategoryDetail = '/admin-category-detail';
  static const String adminTopicsShelves = '/admin-topics-shelves';
  static const String adminTopicDetail = '/admin-topic-detail';
  static const String adminCreateTopic = '/admin-create-topic';
  static const String adminCreateShelf = '/admin-create-shelf';
  static const String adminBanners = '/admin-banners';

  /// How each route is laid out on tablets and laptops: admin pages get the
  /// admin sidebar, a few screens lay themselves out, and every other route
  /// sits in the app frame (sidebar, phone-width column, side panel).
  static PageFrame _frameFor(String? name) {
    if (AdminShell.isAdminRoute(name)) return PageFrame.admin;
    switch (name) {
      case splash:
      case onboarding:
      case contactInput:
      case login:
      case loginOtpIntro:
      case register:
      case otpVerification:
      case dateOfBirth:
      case interests:
      case accountCreated:
      case enableNotifications:
      case dashboardFeed:
      case dashboardMarketsHome:
      case dashboardSearch:
      case notifications:
        return PageFrame.own;
      default:
        return PageFrame.app;
    }
  }

  static AppTransition _transitionFor(String? name) {
    switch (name) {
      case splash:
      case onboarding:
      case dashboardFeed:
      case dashboardMarketsHome:
      case dashboardSearch:
      case notifications:
      case interests:
      case enableNotifications:
        return AppTransition.fadeThrough;
      case accountCreated:
      case marketTradeSuccess:
      case marketSellSuccess:
      case withdrawInitiated:
      case directDepositPending:
      case bankAccountLinked:
      case approvingActivity:
        return AppTransition.reveal;
      case postComposer:
        return AppTransition.modal;
      default:
        return AppTransition.push;
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case onboarding:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case contactInput:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => ContactInputScreen(
            initialMode: settings.arguments == ContactInputMode.phone
                ? ContactInputMode.phone
                : ContactInputMode.email,
          ),
          settings: settings,
        );
      case login:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case loginOtpIntro:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => LoginOtpIntroScreen(
            initialMode: settings.arguments == ContactInputMode.phone
                ? ContactInputMode.phone
                : ContactInputMode.email,
          ),
          settings: settings,
        );
      case register:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case otpVerification:
        final dynamic rawArgs = settings.arguments;
        final OtpChannel channel;
        final String source;
        final String? contact;
        if (rawArgs is Map<String, dynamic>) {
          channel = rawArgs['channel'] == true
              ? OtpChannel.email
              : OtpChannel.phone;
          source = (rawArgs['source'] as String?) ?? 'signup';
          contact = rawArgs['contact'] as String?;
        } else {
          channel = rawArgs == true ? OtpChannel.email : OtpChannel.phone;
          source = 'signup';
          contact = null;
        }
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => OtpVerificationScreen(
            channel: channel,
            source: source,
            contact: contact,
          ),
          settings: settings,
        );
      case dateOfBirth:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DateOfBirthScreen(),
          settings: settings,
        );
      case interests:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => InterestsScreen(),
          settings: settings,
        );
      case accountCreated:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AccountCreatedScreen(),
          settings: settings,
        );
      case enableNotifications:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const EnableNotificationsScreen(),
          settings: settings,
        );
      case dashboardFeed:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DashboardFeedScreen(),
          settings: settings,
        );
      case dashboardMarketsHome:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DashboardMarketsHomeScreen(),
          settings: settings,
        );
      case dashboardSearch:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DashboardSearchScreen(),
          settings: settings,
        );
      case notifications:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );
      // Profile, settings and security all live on the Account screen.
      case account:
      case settingsRoute:
      case accountSecurity:
      case editProfile:
      case settingsNotifications:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AccountScreen(),
          settings: settings,
        );
      case wallet:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const WalletScreen(),
          settings: settings,
        );
      case walletSettings:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const WalletSettingsScreen(),
          settings: settings,
        );
      case directDebits:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DirectDebitsScreen(),
          settings: settings,
        );
      case addedBanks:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AddedBanksScreen(),
          settings: settings,
        );
      case getSupport:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const GetSupportScreen(),
          settings: settings,
        );
      case deposit:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DepositScreen(),
          settings: settings,
        );
      case directDeposit:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DirectDepositScreen(),
          settings: settings,
        );
      case directDepositReview:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) =>
              DirectDepositReviewScreen(amount: args['amount'] as int? ?? 1000),
          settings: settings,
        );
      case directDepositPending:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const DirectDepositPendingScreen(),
          settings: settings,
        );
      case addBankAccount:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AddBankAccountScreen(),
          settings: settings,
        );
      case bankAccountLinked:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => BankAccountLinkedScreen(
            bankName: args['bankName'] as String? ?? 'United Bank for Africa',
            accountNumber: args['accountNumber'] as String? ?? '2039639364',
            accountName: args['accountName'] as String? ?? 'ATABOH HAMID CHIDE',
          ),
          settings: settings,
        );
      case approvingActivity:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const ApprovingActivityScreen(),
          settings: settings,
        );
      case withdrawAmount:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const WithdrawAmountScreen(),
          settings: settings,
        );
      case withdrawReview:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) =>
              WithdrawReviewScreen(amount: args['amount'] as int? ?? 1000),
          settings: settings,
        );
      case withdrawInitiated:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) =>
              WithdrawInitiatedScreen(amount: args['amount'] as int? ?? 400),
          settings: settings,
        );
      case bankDetail:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => BankDetailScreen(
            source: args['source'] == 'directDebits'
                ? BankDetailSource.directDebits
                : BankDetailSource.addedBanks,
          ),
          settings: settings,
        );
      case marketPosition:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketPositionScreen(
            title:
                args['title'] as String? ??
                'Will Davido drop an album in 2026?',
            position: args['position'] as String? ?? 'Yes',
            avatar: args['avatar'] as String? ?? '👨🏾',
            avatarColor:
                args['avatarColor'] as Color? ?? const Color(0xFFD9D9D9),
            chance: args['chance'] as String? ?? '52%',
            cost: args['cost'] as String? ?? 'N100',
            value: args['value'] as String? ?? 'N301',
            change: args['change'] as String? ?? '+N11.2',
            payout: args['payout'] as String? ?? 'N1000',
            changeColor: args['changeColor'] as Color?,
            marketId: args['marketId'] as String?,
            outcomeId: args['outcomeId'] as String?,
            shares: (args['shares'] as num?)?.toDouble(),
            pricePerShare: args['pricePerShare'] as int?,
            tradable: args['tradable'] as bool? ?? false,
          ),
          settings: settings,
        );
      case marketDiscussion:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const MarketDiscussionScreen(),
          settings: settings,
        );
      case marketTrade:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const MarketPoliticsDetailsScreen(),
          settings: settings,
        );
      case marketPoliticsDetails:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const MarketPoliticsDetailsScreen(),
          settings: settings,
        );
      case marketInfo:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketInfoScreen(
            question:
                args['question'] as String? ??
                'Who will be the next Nigerian\nPresident?',
            thumbnail: args['thumbnail'] as String?,
            optionsCount: args['optionsCount'] as int? ?? 4,
            volume: args['volume'] as int? ?? 211096578,
            circulatingSupply: args['circulatingSupply'] as int? ?? 211096578,
            amountOfUsers: args['amountOfUsers'] as int? ?? 406000,
            numberOfBuys: args['numberOfBuys'] as int? ?? 1000,
            numberOfSells: args['numberOfSells'] as int? ?? 784,
          ),
          settings: settings,
        );
      case marketTradeInput:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketTradeInputScreen(
            candidateName:
                args['candidateName'] as String? ?? 'Bola Ahmed Tinubu',
            candidateInitials: args['candidateInitials'] as String? ?? 'BAT',
            candidateColor:
                args['candidateColor'] as Color? ?? const Color(0xFFCB3D59),
            pricePerShare: args['pricePerShare'] as int? ?? 59,
            walletBalance: args['walletBalance'] as int? ?? 59674,
            optionCount: args['optionCount'] as int? ?? 2,
            outcomeId: args['outcomeId'] as String?,
          ),
          settings: settings,
        );
      case marketTradeReview:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketTradeReviewScreen(
            amount: args['amount'] as int? ?? 649,
            candidateName:
                args['candidateName'] as String? ?? 'Bola Ahmed Tinubu',
            candidateInitials: args['candidateInitials'] as String? ?? 'BAT',
            candidateColor:
                args['candidateColor'] as Color? ?? const Color(0xFFCB3D59),
            pricePerShare: args['pricePerShare'] as int? ?? 59,
            amm: args['amm'] as AmmMarket?,
            ammIndex: args['ammIndex'] as int? ?? 0,
            outcomeId: args['outcomeId'] as String?,
          ),
          settings: settings,
        );
      case marketTradeSuccess:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketTradeSuccessScreen(
            candidateName: args['candidateName'] as String? ?? 'Peter Obi',
            amount: args['amount'] as int? ?? 649,
            totalKobo: args['totalKobo'] as int? ?? 66198,
            toWinKobo: args['toWinKobo'] as int? ?? 256168,
          ),
          settings: settings,
        );
      case marketSellInput:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketSellInputScreen(
            candidateName:
                args['candidateName'] as String? ?? 'Bola Ahmed Tinubu',
            candidateInitials: args['candidateInitials'] as String? ?? 'BAT',
            candidateColor:
                args['candidateColor'] as Color? ?? const Color(0xFFCB3D59),
            pricePerShare: args['pricePerShare'] as int? ?? 59,
            sharesOwned: args['sharesOwned'] as int? ?? 1100,
            walletBalance: args['walletBalance'] as int? ?? 59674,
            optionCount: args['optionCount'] as int? ?? 2,
            outcomeId: args['outcomeId'] as String?,
            liveShares: (args['liveShares'] as num?)?.toDouble(),
          ),
          settings: settings,
        );
      case marketSellReview:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketSellReviewScreen(
            amount: args['amount'] as int? ?? 47603,
            candidateName:
                args['candidateName'] as String? ?? 'Bola Ahmed Tinubu',
            candidateInitials: args['candidateInitials'] as String? ?? 'BAT',
            candidateColor:
                args['candidateColor'] as Color? ?? const Color(0xFFCB3D59),
            pricePerShare: args['pricePerShare'] as int? ?? 59,
            shares: (args['shares'] as num?)?.toDouble(),
            amm: args['amm'] as AmmMarket?,
            ammIndex: args['ammIndex'] as int? ?? 0,
            outcomeId: args['outcomeId'] as String?,
          ),
          settings: settings,
        );
      case marketSellSuccess:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketSellSuccessScreen(
            candidateName: args['candidateName'] as String? ?? 'Peter Obi',
            avgPriceKobo: args['avgPriceKobo'] as int? ?? 5900,
            cashedOutKobo: args['cashedOutKobo'] as int? ?? 4665100,
          ),
          settings: settings,
        );
      case notificationDetail:
        // Live notifications pass the kind and summary directly.
        if (settings.arguments case <String, dynamic>{
          'kind': final NotificationDetailKind kind,
          'notification': final TradeResultNotification notification,
        }) {
          return AppPageRoute<void>(
            transition: _transitionFor(settings.name),
            frame: _frameFor(settings.name),
            builder: (_) => NotificationDetailScreen(
              kind: kind,
              notification: notification,
            ),
            settings: settings,
          );
        }
        final String? tag = settings.arguments as String?;
        final NotificationDetailKind kind = switch (tag) {
          'won' => NotificationDetailKind.won,
          'lost' => NotificationDetailKind.lost,
          'bought' ||
          'bought2' ||
          'sold' ||
          'new-market' => NotificationDetailKind.bought,
          _ => NotificationDetailKind.won,
        };
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => NotificationDetailScreen(kind: kind),
          settings: settings,
        );
      case marketDetails:
        final Object? args = settings.arguments;
        if (args is LiveMarketRef) {
          return AppPageRoute<void>(
            transition: _transitionFor(settings.name),
            frame: _frameFor(settings.name),
            builder: (_) => MarketDetailsScreen(marketRef: args),
            settings: settings,
          );
        }
        MarketDetail? detail;
        if (args is MarketDetail) {
          detail = args;
        } else if (args is String) {
          detail = kMarketDetailDefaults[args];
        }
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketDetailsScreen(detail: detail),
          settings: settings,
        );
      case marketsTab:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => MarketsTabScreen(
            category: settings.arguments as MarketTabCategory,
          ),
          settings: settings,
        );
      case adminPanel:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminPanelScreen(),
          settings: settings,
        );
      case adminMarketCreate:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => AdminMarketCreateScreen(
            category: settings.arguments! as AdminCategory,
          ),
          settings: settings,
        );
      case adminCategories:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminCategoriesScreen(),
          settings: settings,
        );
      case adminCategoryDetail:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => AdminCategoryDetailScreen(
            category: settings.arguments! as AdminCategoryData,
          ),
          settings: settings,
        );
      case adminMarkets:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminMarketsScreen(),
          settings: settings,
        );
      case adminMarketCategorySelect:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminMarketCategoryScreen(),
          settings: settings,
        );
      case adminTopicsShelves:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminTopicsShelvesScreen(),
          settings: settings,
        );
      case adminTopicDetail:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) =>
              AdminTopicDetailScreen(topic: settings.arguments! as AdminTopic),
          settings: settings,
        );
      case adminCreateTopic:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminCreateTopicScreen(),
          settings: settings,
        );
      case adminCreateShelf:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminCreateShelfScreen(),
          settings: settings,
        );
      case adminBanners:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminBannersScreen(),
          settings: settings,
        );
      case adminUsers:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const AdminUsersScreen(),
          settings: settings,
        );
      case adminSection:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => AdminSectionScreen(
            title: args['title'] as String? ?? 'Admin Section',
          ),
          settings: settings,
        );
      case postDetail:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => PostDetailScreen(
            showTopSort: settings.arguments == true,
            postId: settings.arguments is String
                ? settings.arguments as String
                : null,
          ),
          settings: settings,
        );
      case postComposer:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => PostComposerScreen(
            initialText: settings.arguments as String? ?? '',
          ),
          settings: settings,
        );
      case userProfile:
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        // A signed-in user's own profile is always their real one; the
        // stock profile is only for demo users and other stock handles.
        if (args.isEmpty && SupabaseService.isSignedIn) {
          return AppPageRoute<void>(
            transition: _transitionFor(settings.name),
            frame: _frameFor(settings.name),
            builder: (_) => const LiveUserProfileScreen(),
            settings: settings,
          );
        }
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => DataSourceBuilder(
            live: (_) =>
                LiveUserProfileScreen(userId: args['userId'] as String?),
            stock: (_) => UserProfileScreen(
              handle: args['handle'] as String? ?? '@hamid',
              avatar: args['avatar'] as String? ?? 'P',
              avatarColor:
                  args['avatarColor'] as Color? ?? const Color(0xFFF9D4DC),
              volume: args['volume'] as String? ?? '\$400K',
              posts: args['posts'] as String? ?? '411',
              activity: args['activity'] as String? ?? '45',
              bio: args['bio'] as String? ?? 'Valar Morghulis',
              joinedDate: args['joinedDate'] as String? ?? 'Jan 16, 2025',
            ),
          ),
          settings: settings,
        );
      default:
        return AppPageRoute<void>(
          transition: _transitionFor(settings.name),
          frame: _frameFor(settings.name),
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
    }
  }
}
