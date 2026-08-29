import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';

Future<void> showChatCallSheet({
  required BuildContext context,
  required ChatParticipant participant,
  required bool isVideo,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: true,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => ChatCallScreen(
        participant: participant,
        isVideo: isVideo,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class ChatCallScreen extends StatefulWidget {
  const ChatCallScreen({
    super.key,
    required this.participant,
    required this.isVideo,
  });

  final ChatParticipant participant;
  final bool isVideo;

  @override
  State<ChatCallScreen> createState() => _ChatCallScreenState();
}

class _ChatCallScreenState extends State<ChatCallScreen> {
  bool _micMuted = false;
  bool _speakerOn = true;
  bool _cameraOn = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.isVideo)
            _VideoCallBackground(participant: widget.participant)
          else
            _VoiceCallBackground(participant: widget.participant),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    color: Colors.white70,
                    iconSize: 32,
                    tooltip: 'Minimize',
                  ),
                ),
                Expanded(
                  child: widget.isVideo
                      ? _VideoCallCenter(participant: widget.participant)
                      : _VoiceCallCenter(participant: widget.participant),
                ),
                _CallControls(
                  isVideo: widget.isVideo,
                  micMuted: _micMuted,
                  speakerOn: _speakerOn,
                  cameraOn: _cameraOn,
                  onToggleMic: () => setState(() => _micMuted = !_micMuted),
                  onToggleSpeaker: () =>
                      setState(() => _speakerOn = !_speakerOn),
                  onToggleCamera: () =>
                      setState(() => _cameraOn = !_cameraOn),
                  onEndCall: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (widget.isVideo && _cameraOn)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 56,
              right: 16,
              child: _LocalPreviewBubble(name: widget.participant.fullName),
            ),
        ],
      ),
    );
  }
}

class _VoiceCallBackground extends StatelessWidget {
  const _VoiceCallBackground({required this.participant});

  final ChatParticipant participant;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF12212B),
            Color(0xFF0B141A),
            Color(0xFF060A0E),
          ],
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.15),
        child: UserAvatar(
          name: participant.fullName,
          imageUrl: participant.avatarUrl,
          radius: 72,
        ),
      ),
    );
  }
}

class _VideoCallBackground extends StatelessWidget {
  const _VideoCallBackground({required this.participant});

  final ChatParticipant participant;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty
          ? Image.network(
              participant.avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
            )
          : null,
    );
  }
}

class _VoiceCallCenter extends StatelessWidget {
  const _VoiceCallCenter({required this.participant});

  final ChatParticipant participant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          participant.fullName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.chatCalling,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

class _VideoCallCenter extends StatelessWidget {
  const _VideoCallCenter({required this.participant});

  final ChatParticipant participant;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!hasPhoto) ...[
          UserAvatar(
            name: participant.fullName,
            imageUrl: participant.avatarUrl,
            radius: 64,
          ),
          const SizedBox(height: 20),
        ],
        Text(
          participant.fullName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.chatVideoCalling,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _LocalPreviewBubble extends StatelessWidget {
  const _LocalPreviewBubble({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 136,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: UserAvatar(name: name, radius: 28),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'You',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.isVideo,
    required this.micMuted,
    required this.speakerOn,
    required this.cameraOn,
    required this.onToggleMic,
    required this.onToggleSpeaker,
    required this.onToggleCamera,
    required this.onEndCall,
  });

  final bool isVideo;
  final bool micMuted;
  final bool speakerOn;
  final bool cameraOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleCamera;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (isVideo)
            _ControlButton(
              icon: Icons.flip_camera_ios_outlined,
              label: 'Flip',
              onTap: () {},
            ),
          _ControlButton(
            icon: micMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: micMuted ? 'Unmute' : 'Mute',
            onTap: onToggleMic,
            active: micMuted,
          ),
          _EndCallButton(onTap: onEndCall),
          _ControlButton(
            icon: speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            label: 'Speaker',
            onTap: onToggleSpeaker,
            active: !speakerOn,
          ),
          if (isVideo)
            _ControlButton(
              icon: cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              label: 'Camera',
              onTap: onToggleCamera,
              active: !cameraOn,
            ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: active
              ? Colors.white.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.16),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(
                icon,
                color: active ? Colors.black87 : Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EndCallButton extends StatelessWidget {
  const _EndCallButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.error,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: 64,
              height: 64,
              child: Icon(Icons.call_end_rounded, color: Colors.white, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.chatEndCall,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
