// Dart core libraries
export 'dart:async';
export 'dart:convert';
export 'dart:developer' hide Flow;
export 'dart:io';
export 'dart:ui'
    hide
        Codec,
        decodeImageFromList,
        TextStyle,
        ImageDecoderCallback,
        Gradient,
        Image,
        StrutStyle;

// External packages
export 'package:connectivity_plus/connectivity_plus.dart';
// Common widgets
export 'package:cric_live/common_widgets/app_header.dart';
export 'package:cric_live/common_widgets/custom_dialog.dart';
export 'package:cric_live/common_widgets/custom_snackbar.dart';
export 'package:cric_live/common_widgets/custom_text_form_field.dart';
export 'package:cric_live/common_widgets/loader.dart';
export 'package:cric_live/common_widgets/match_tournament_card.dart';
export 'package:cric_live/common_widgets/player_selector.dart';
export 'package:cric_live/common_widgets/result/scorboard_tab.dart';
export 'package:cric_live/common_widgets/search_result_tile.dart';
// Team Selection Components
export 'package:cric_live/common_widgets/team_selection/models/team_selection_model.dart';
export 'package:cric_live/common_widgets/team_selection/team_selection.dart';
export 'package:cric_live/common_widgets/team_selection/team_selection_widget.dart';
export 'package:cric_live/common_widgets/team_selection/widgets/team_card.dart';
export 'package:cric_live/common_widgets/universal_match_tile.dart';
// Features - Authentication
export 'package:cric_live/features/auth_features/forgot_password_email_view/forgot_password_email_controller.dart';
export 'package:cric_live/features/auth_features/forgot_password_email_view/forgot_password_email_view.dart';
export 'package:cric_live/features/auth_features/login_view/login_controller.dart';
export 'package:cric_live/features/auth_features/login_view/login_model.dart';
export 'package:cric_live/features/auth_features/login_view/login_view.dart';
export 'package:cric_live/features/auth_features/otp_screen/otp_screen_controller.dart';
export 'package:cric_live/features/auth_features/otp_screen/otp_screen_model.dart';
export 'package:cric_live/features/auth_features/otp_screen/otp_screen_view.dart';
export 'package:cric_live/features/auth_features/reset_password_view/reset_password_controller.dart';
export 'package:cric_live/features/auth_features/reset_password_view/reset_password_view.dart';
export 'package:cric_live/features/auth_features/signup_view/signup_controller.dart';
export 'package:cric_live/features/auth_features/signup_view/signup_model.dart';
export 'package:cric_live/features/auth_features/signup_view/signup_view.dart';
// Features - Choose Player
export 'package:cric_live/features/choose_player_view/choose_player_controller.dart';
export 'package:cric_live/features/choose_player_view/choose_player_model.dart';
export 'package:cric_live/features/choose_player_view/choose_player_view.dart';
export 'package:cric_live/features/choose_player_view/repo/choose_player_repo.dart';
export 'package:cric_live/features/choose_player_view/repo/i_choose_player.dart';
export 'package:cric_live/features/create_match_view/create_match_controller.dart';
export 'package:cric_live/features/create_match_view/create_match_repo.dart';
export 'package:cric_live/features/create_match_view/create_match_view.dart';
export 'package:cric_live/features/create_match_view/match_model.dart';
export 'package:cric_live/features/create_match_view/toss_decision_view.dart';
export 'package:cric_live/features/create_match_view/widgets/step_progress_indicator.dart';
export 'package:cric_live/features/create_team_view/create_team_controller.dart';
export 'package:cric_live/features/create_team_view/create_team_repo.dart';
export 'package:cric_live/features/create_team_view/create_team_view.dart';
// Features - Create Tournament
export 'package:cric_live/features/create_tournament_view/create_tournament_controller.dart';
export 'package:cric_live/features/create_tournament_view/create_tournament_model.dart';
export 'package:cric_live/features/create_tournament_view/create_tournament_repo.dart';
export 'package:cric_live/features/create_tournament_view/create_tournament_view.dart';
// Features - Dashboard
export 'package:cric_live/features/dashboard_view/dashboard_controller.dart';
export 'package:cric_live/features/dashboard_view/dashboard_model.dart';
export 'package:cric_live/features/dashboard_view/dashboard_repo.dart';
export 'package:cric_live/features/dashboard_view/dashboard_view.dart';
export 'package:cric_live/features/dashboard_view/display_live_matches/display_live_match_controller.dart';
export 'package:cric_live/features/dashboard_view/display_live_matches/display_live_match_model.dart';
export 'package:cric_live/features/dashboard_view/display_live_matches/display_live_match_view.dart';
export 'package:cric_live/features/dashboard_view/history_view/history_controller.dart';
export 'package:cric_live/features/dashboard_view/history_view/history_model.dart';
export 'package:cric_live/features/dashboard_view/history_view/history_view.dart';
export 'package:cric_live/features/dashboard_view/models/match_display_model.dart';
export 'package:cric_live/features/dashboard_view/models/team_model.dart';
// Features - Match
export 'package:cric_live/features/match_view/match_controller.dart';
export 'package:cric_live/features/match_view/match_view.dart';
export 'package:cric_live/features/match_view/match_view_repo.dart';
export 'package:cric_live/features/players_view/players_controller.dart';
export 'package:cric_live/features/players_view/players_model.dart';
export 'package:cric_live/features/players_view/players_view.dart';
export 'package:cric_live/features/players_view/repo/players_repo.dart';
// Features - Result
export 'package:cric_live/features/result_view/models/ball_detail_model.dart';
export 'package:cric_live/features/result_view/models/complete_match_result_model.dart';
export 'package:cric_live/features/result_view/models/index.dart';
export 'package:cric_live/features/result_view/models/over_summary_model.dart';
export 'package:cric_live/features/result_view/models/player_batting_result_model.dart';
export 'package:cric_live/features/result_view/models/player_bowling_result_model.dart';
export 'package:cric_live/features/result_view/models/team_innings_result_model.dart';
export 'package:cric_live/features/result_view/result_controller.dart';
export 'package:cric_live/features/result_view/result_model.dart';
export 'package:cric_live/features/result_view/result_repo.dart';
export 'package:cric_live/features/result_view/result_view.dart';
export 'package:cric_live/features/result_view/services/result_service.dart';
// Features - Scoreboard
export 'package:cric_live/features/scoreboard_view/scoreboard_controller.dart';
export 'package:cric_live/features/scoreboard_view/scoreboard_model.dart';
export 'package:cric_live/features/scoreboard_view/scoreboard_queries.dart';
export 'package:cric_live/features/scoreboard_view/scoreboard_repo.dart';
export 'package:cric_live/features/scoreboard_view/scoreboard_view.dart';
export 'package:cric_live/features/search_view/data/models/search_models.dart';
export 'package:cric_live/features/search_view/data/repositories/search_repository_impl.dart';
export 'package:cric_live/features/search_view/domain/repositories/i_search_repository.dart';
export 'package:cric_live/features/search_view/presentation/controllers/search_controller.dart';
export 'package:cric_live/features/search_view/presentation/views/search_view.dart';
// Features - Search Utils
export 'package:cric_live/features/search_view/utils/search_utils.dart';
// Features - Select Team
export 'package:cric_live/features/select_team_view/repo/iselect_team.dart';
export 'package:cric_live/features/select_team_view/repo/select_team_repo.dart';
export 'package:cric_live/features/select_team_view/select_team_controller.dart';
export 'package:cric_live/features/select_team_view/select_team_model.dart';
export 'package:cric_live/features/select_team_view/select_team_view.dart';
// Features - Shift Inning
export 'package:cric_live/features/shift_inning_view/repo/shift_inning_repo.dart';
export 'package:cric_live/features/shift_inning_view/shift_inning_controller.dart';
export 'package:cric_live/features/shift_inning_view/shift_inning_model.dart';
export 'package:cric_live/features/shift_inning_view/shift_inning_view.dart';
// Features - Splash Screen
export 'package:cric_live/features/splash_screen/splash_screen_controller.dart';
export 'package:cric_live/features/splash_screen/splash_screen_view.dart';
// Features - Tournament
export 'package:cric_live/features/tournament_view/tournament_controller.dart';
export 'package:cric_live/features/tournament_view/tournament_model.dart';
export 'package:cric_live/features/tournament_view/tournament_repo.dart';
export 'package:cric_live/features/tournament_view/tournament_view.dart';
export 'package:cric_live/features/tournament_view/widgets/tournament_widgets.dart';
// Services
export 'package:cric_live/services/api_services/api_services.dart';
export 'package:cric_live/services/auth/auth_service.dart';
export 'package:cric_live/services/auth/token_model.dart';
export 'package:cric_live/services/connectivity/connectivity_service.dart';
export 'package:cric_live/services/connectivity/internet_required_service.dart';
export 'package:cric_live/services/matches_display/matches_display.dart';
export 'package:cric_live/services/polling/polling_service.dart';
export 'package:cric_live/services/preload_service.dart';
export 'package:cric_live/services/sync/database/my_database.dart';
export 'package:cric_live/services/sync/sync_feature.dart';
// All Bindings
// Features - Choose Player
export 'package:cric_live/utils/bindings/choose_player_binding.dart';
// Features - Create Match
export 'package:cric_live/utils/bindings/create_match_binding.dart';
// Features - Create Team
export 'package:cric_live/utils/bindings/create_team_binding.dart';
// Features - Create Tournament
export 'package:cric_live/utils/bindings/create_tournament_binding.dart';
// Features - Dashboard
export 'package:cric_live/utils/bindings/dashboard_binding.dart';
// Features - Display Live Matches
export 'package:cric_live/utils/bindings/display_live_match_binding.dart';
// Features - Forgot Password Email
export 'package:cric_live/utils/bindings/forgot_password_email_binding.dart';
// Features - History
export 'package:cric_live/utils/bindings/history_binding.dart';
// Features - Login
export 'package:cric_live/utils/bindings/login_binding.dart';
// Features - Match
export 'package:cric_live/utils/bindings/match_binding.dart';
// Features - OTP Screen
export 'package:cric_live/utils/bindings/otp_screen_binding.dart';
// Features - Players
export 'package:cric_live/utils/bindings/players_binding.dart';
// Features - Reset Password
export 'package:cric_live/utils/bindings/reset_password_binding.dart';
// Features - Result
export 'package:cric_live/utils/bindings/result_binding.dart';
// Features - Scoreboard
export 'package:cric_live/utils/bindings/scoreboard_binding.dart';
// Features - Search
export 'package:cric_live/utils/bindings/search_screen_binding.dart';
// Features - Select Team
// export 'package:cric_live/utils/bindings/select_team_binding.dart';
// Features - Shift Inning
export 'package:cric_live/utils/bindings/shift_inning_binding.dart';
// Features - Signup
export 'package:cric_live/utils/bindings/signup_binding.dart';
// Features - Splash Screen
export 'package:cric_live/utils/bindings/splash_screen_binding.dart';
// Features - Tournament
export 'package:cric_live/utils/bindings/tournament_binding.dart';
// Utils
export 'package:cric_live/utils/debouncing/debouncing_mixin.dart';
export 'package:cric_live/utils/responsive_utils.dart';
export 'package:cric_live/utils/strings.dart';
export 'package:cupertino_icons/cupertino_icons.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:get/get.dart' hide MultipartFile, Response, HeaderValue;
export 'package:google_fonts/google_fonts.dart';
export 'package:http/http.dart';
export 'package:http/io_client.dart';
export 'package:image_picker/image_picker.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:jwt_decoder/jwt_decoder.dart';
export 'package:path/path.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:shimmer/shimmer.dart';
export 'package:sqflite/sqflite.dart';
