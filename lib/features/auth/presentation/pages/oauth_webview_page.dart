import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/config/app_env.dart';
import 'package:kdh_mobile/core/router/router_path.dart';
import 'package:kdh_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebViewPage extends ConsumerStatefulWidget {
  const OAuthWebViewPage({super.key, required this.authUrl});

  final String authUrl;

  @override
  ConsumerState<OAuthWebViewPage> createState() => _OAuthWebViewPageState();
}

class _OAuthWebViewPageState extends ConsumerState<OAuthWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _handled = false;

  static final _httpSuccessPath =
      '${AppEnv.baseUrl.replaceAll(RegExp(r'/$'), '')}/oauth2/success';
  static final _httpFailurePath =
      '${AppEnv.baseUrl.replaceAll(RegExp(r'/$'), '')}/oauth2/failure';
  static const _customScheme = 'kdhmobile';

  @override
  void initState() {
    super.initState();

    final userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
              'AppleWebKit/605.1.15 (KHTML, like Gecko) '
              'Version/17.0 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 14) '
              'AppleWebKit/537.36 (KHTML, like Gecko) '
              'Chrome/124.0.0.0 Mobile Safari/537.36';

    _controller = WebViewController()
      ..setUserAgent(userAgent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_tryHandleUrl(url)) return;
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (url) async {
            if (_tryHandleUrl(url)) return;
            if (url.startsWith(_httpSuccessPath) ||
                url.contains('/oauth2/success')) {
              await _tryHandleBodyJson();
              return;
            }
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) =>
              setState(() => _errorMessage = '페이지를 불러오지 못했습니다.'),
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;
            if (uri.scheme == _customScheme) {
              _tryHandleUrl(request.url);
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(_httpSuccessPath)) {
              _tryHandleUrl(request.url);
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(_httpFailurePath)) {
              _tryHandleUrl(request.url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  bool _tryHandleUrl(String rawUrl) {
    if (_handled) return true;

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return false;

    final isHttpSuccess = rawUrl.startsWith(_httpSuccessPath);
    final isCustomSuccess =
        uri.scheme == _customScheme && uri.path.contains('callback');
    final isHttpFailure = rawUrl.startsWith(_httpFailurePath);
    final isCustomFailure =
        uri.scheme == _customScheme && uri.path.contains('failure');

    if (isHttpSuccess || isCustomSuccess) {
      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (accessToken == null || refreshToken == null) return false;

      _handled = true;
      ref
          .read(authProvider.notifier)
          .handleLoginSuccess(accessToken, refreshToken);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RouterPath.home);
      });
      return true;
    }

    if (isHttpFailure || isCustomFailure) {
      final error = uri.queryParameters['error'] ?? 'access_denied';
      setState(() => _errorMessage = '로그인에 실패했습니다: $error');
      return true;
    }

    return false;
  }

  Future<void> _tryHandleBodyJson() async {
    if (_handled) return;
    try {
      final raw = await _controller.runJavaScriptReturningResult(
        'document.body.innerText',
      );
      final str = raw.toString();
      final jsonStr = str.startsWith('"') ? jsonDecode(str) as String : str;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final accessToken = map['accessToken'] as String?;
      final refreshToken = map['refreshToken'] as String?;
      if (accessToken == null || refreshToken == null) {
        setState(() => _isLoading = false);
        return;
      }
      _handled = true;
      ref
          .read(authProvider.notifier)
          .handleLoginSuccess(accessToken, refreshToken);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RouterPath.home);
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KdhColor.background,
      appBar: AppBar(
        backgroundColor: KdhColor.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.close, color: KdhColor.gray800),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Google 로그인',
          style: KdhTextStyle.body6.copyWith(color: KdhColor.gray800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Symbols.error_outline,
                      color: KdhColor.red400,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: KdhTextStyle.body6.copyWith(
                        color: KdhColor.gray800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        _handled = false;
                        _controller.loadRequest(Uri.parse(widget.authUrl));
                      },
                      child: Text(
                        '다시 시도',
                        style: KdhTextStyle.body6.copyWith(
                          color: KdhColor.red400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),

          if (_isLoading && _errorMessage == null)
            const Center(
              child: CircularProgressIndicator(color: KdhColor.red400),
            ),
        ],
      ),
    );
  }
}
