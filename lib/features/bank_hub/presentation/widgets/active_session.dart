import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/models/bank.dart';

class ActiveSessionWidget extends StatefulWidget {
  const ActiveSessionWidget({
    super.key,
    required this.bank,
    required this.onClose,
  });

  final Bank bank;
  final VoidCallback onClose;

  @override
  State<ActiveSessionWidget> createState() => _ActiveSessionWidgetState();
}

class _ActiveSessionWidgetState extends State<ActiveSessionWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _iframeKey = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.bank.url));
  }

  void _handleReload() {
    setState(() {
      _isLoading = true;
      _iframeKey++;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-950
      body: Column(
        children: [
          // Internal Browser Header
          Container(
            color: const Color(0xFF1E293B), // slate-900
            child: Column(
              children: [
                // Top Status Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: widget.onClose,
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF94A3B8), // slate-400
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.bank.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFCBD5E1), // slate-300
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          // Open in external browser
                        },
                        icon: const Icon(
                          Icons.open_in_new,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Address Bar Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      const IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: Color(0xFF64748B), // slate-500
                        ),
                      ),
                      const IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B), // slate-800
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF334155).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.bank.url,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCBD5E1),
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: _handleReload,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Loading Progress Bar
          if (_isLoading)
            Container(
              height: 2,
              color: const Color(0xFF0F172A),
              child: const LinearProgressIndicator(
                backgroundColor: Color(0xFF0F172A),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          // Main Viewport
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: widget.bank.theme.gradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                widget.bank.logoText,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: widget.bank.theme.textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Establishing secure connection...',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
