import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_button.dart';
import '../basic/t_icon.dart';
import '../token/t_token_color.dart';

/// Image-theme card edge (logical px). Aligns with Vue Next upload card.
const double _kUploadImageCard = 110;

const Color _kUploadMask = Color(0x99000000);
const Color _kUploadMaskForeground = Color(0xFFFFFFFF);

/// Upload file status. Aligns with Vue Next `UploadFile.status`.
enum TUploadFileStatus { waiting, progress, success, fail }

/// One entry in [TUpload.files].
class TUploadFile {
  const TUploadFile({
    required this.name,
    this.size,
    this.status = TUploadFileStatus.waiting,
    this.percent,
    this.url,
    this.preview,
    this.error,
  });

  final String name;
  final int? size;
  final TUploadFileStatus status;
  final double? percent;
  final String? url;

  /// Optional injected thumbnail for [TUploadTheme.image].
  final ImageProvider? preview;
  final String? error;

  TUploadFile copyWith({
    String? name,
    int? size,
    TUploadFileStatus? status,
    double? percent,
    String? url,
    ImageProvider? preview,
    String? error,
  }) {
    return TUploadFile(
      name: name ?? this.name,
      size: size ?? this.size,
      status: status ?? this.status,
      percent: percent ?? this.percent,
      url: url ?? this.url,
      preview: preview ?? this.preview,
      error: error ?? this.error,
    );
  }
}

/// Picks files when the trigger is pressed. Empty list means cancel.
typedef TUploadPickFiles = Future<List<TUploadFile>> Function();

/// Uploads one waiting file. Return the updated file (status / url / error).
typedef TUploadRequest = Future<TUploadFile> Function(TUploadFile file);

/// Layout of [TUpload].
enum TUploadTheme {
  /// File name rows. Default.
  file,

  /// 110px image cards with optional [TUploadFile.preview] / [TUploadFile.url].
  image,

  /// Name, size, and status rows.
  fileFlow,
}

/// Desktop upload — file rows or image tiles with an injectable picker.
///
/// [TUploadTheme.image] uses 110px cards plus an add tile (`TIcons.add`) as
/// the pick trigger (no text button). Prefer [TUploadFile.preview], else [url].
/// Spec source: local tdesign-vue-next `Upload`. No built-in HTTP or
/// `file_picker`; pass [pickFiles] and optional [request].
class TUpload extends StatefulWidget {
  const TUpload({
    super.key,
    required this.files,
    required this.pickFiles,
    this.onChanged,
    this.onPreview,
    this.request,
    this.autoUpload = true,
    this.multiple = false,
    this.max = 0,
    this.enabled = true,
    this.triggerText = '选择文件',
    this.tips,
    this.theme = TUploadTheme.file,
  });

  final List<TUploadFile> files;
  final TUploadPickFiles pickFiles;
  final ValueChanged<List<TUploadFile>>? onChanged;

  /// Optional preview action for image-theme hover browse.
  final ValueChanged<TUploadFile>? onPreview;
  final TUploadRequest? request;
  final bool autoUpload;
  final bool multiple;
  final int max;
  final bool enabled;
  final String triggerText;
  final String? tips;
  final TUploadTheme theme;

  @override
  State<TUpload> createState() => _TUploadState();
}

class _TUploadState extends State<TUpload> {
  var _busy = false;

  bool get _showImageAdd {
    if (widget.max > 0 && widget.files.length >= widget.max) return false;
    if (!widget.multiple && widget.files.isNotEmpty) return false;
    return true;
  }

  Future<void> _onTrigger() async {
    if (!widget.enabled || _busy || widget.onChanged == null) return;
    setState(() => _busy = true);
    try {
      final picked = await widget.pickFiles();
      if (!mounted || picked.isEmpty) return;
      var next = widget.multiple
          ? [...widget.files, ...picked]
          : List<TUploadFile>.of(picked);
      if (widget.max > 0 && next.length > widget.max) {
        next = next.take(widget.max).toList(growable: false);
      }
      widget.onChanged!(next);
      if (widget.autoUpload && widget.request != null) {
        await _uploadWaiting(next);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _uploadWaiting(List<TUploadFile> current) async {
    final request = widget.request;
    if (request == null || widget.onChanged == null) return;
    var files = List<TUploadFile>.of(current);
    for (var i = 0; i < files.length; i++) {
      if (files[i].status != TUploadFileStatus.waiting) continue;
      files[i] = files[i].copyWith(status: TUploadFileStatus.progress);
      widget.onChanged!(List<TUploadFile>.of(files));
      final result = await request(files[i]);
      if (!mounted) return;
      files[i] = result;
      widget.onChanged!(List<TUploadFile>.of(files));
    }
  }

  void _removeAt(int index) {
    if (!widget.enabled || widget.onChanged == null) return;
    final next = [...widget.files]..removeAt(index);
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TDesignTokenScope.of(context);
    final text = tTokenColorOf(tokens, 'textColorPrimary');
    final muted = tTokenColorOf(tokens, 'textColorPlaceholder');
    final fail = tTokenColorOf(tokens, 'errorColor');
    final showSize = widget.theme == TUploadTheme.fileFlow;
    final imageTheme = widget.theme == TUploadTheme.image;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!imageTheme)
          TButton(
            onPressed: widget.enabled && !_busy ? () => _onTrigger() : null,
            child: Text(widget.triggerText),
          ),
        if (widget.tips != null) ...[
          if (!imageTheme) const SizedBox(height: 8),
          Text(widget.tips!, style: TextStyle(fontSize: 12, color: muted)),
        ],
        if (imageTheme) ...[
          if (widget.tips != null) const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < widget.files.length; i++)
                _ImageCard(
                  file: widget.files[i],
                  enabled: widget.enabled,
                  onRemove: () => _removeAt(i),
                  onPreview: widget.onPreview == null
                      ? null
                      : () => widget.onPreview!(widget.files[i]),
                  tokens: tokens,
                ),
              if (_showImageAdd)
                _ImageCard(
                  key: const ValueKey<String>('TUpload.add'),
                  enabled: widget.enabled && !_busy,
                  onAdd: _onTrigger,
                  tokens: tokens,
                ),
            ],
          ),
        ] else if (widget.files.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var i = 0; i < widget.files.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FileRow(
                file: widget.files[i],
                showSize: showSize,
                enabled: widget.enabled,
                text: text,
                muted: muted,
                fail: fail,
                onRemove: () => _removeAt(i),
              ),
            ),
        ],
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.file,
    required this.showSize,
    required this.enabled,
    required this.text,
    required this.muted,
    required this.fail,
    required this.onRemove,
  });

  final TUploadFile file;
  final bool showSize;
  final bool enabled;
  final Color text;
  final Color muted;
  final Color fail;
  final VoidCallback onRemove;

  String get _sizeLabel {
    final size = file.size;
    if (size == null) return '—';
    if (size < 1024) return '$size B';
    return '${(size / 1024).toStringAsFixed(1)} KB';
  }

  String get _statusLabel {
    switch (file.status) {
      case TUploadFileStatus.waiting:
        return '待上传';
      case TUploadFileStatus.progress:
        final percent = file.percent;
        if (percent == null) return '上传中';
        return '上传中 ${percent.round()}%';
      case TUploadFileStatus.success:
        return '上传成功';
      case TUploadFileStatus.fail:
        return file.error ?? '上传失败';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = file.status == TUploadFileStatus.fail ? fail : muted;
    return Row(
      children: [
        Expanded(
          child: Text(file.name, style: TextStyle(fontSize: 14, color: text)),
        ),
        if (showSize)
          SizedBox(
            width: 72,
            child: Text(
              _sizeLabel,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ),
        Text(_statusLabel, style: TextStyle(fontSize: 12, color: statusColor)),
        if (enabled) ...[
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: TIcon(TIcons.close, size: TIconSizes.input, color: muted),
          ),
        ],
      ],
    );
  }
}

class _ImageCard extends StatefulWidget {
  const _ImageCard({
    super.key,
    this.file,
    required this.enabled,
    required this.tokens,
    this.onRemove,
    this.onAdd,
    this.onPreview,
  });

  final TUploadFile? file;
  final bool enabled;
  final TDesignTokenSet tokens;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;
  final VoidCallback? onPreview;

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  var _hover = false;

  static bool _canPreview(TUploadFile file) =>
      file.status == TUploadFileStatus.waiting ||
      file.status == TUploadFileStatus.success;

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final tokens = widget.tokens;
    final border = tTokenColorOf(tokens, 'componentBorder');
    final text = tTokenColorOf(tokens, 'textColorPrimary');
    final muted = tTokenColorOf(tokens, 'textColorPlaceholder');
    final fail = tTokenColorOf(tokens, 'errorColor');
    final radius = tTokenRadius(tokens);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: _cardTap(file),
            child: Container(
              width: _kUploadImageCard,
              height: _kUploadImageCard,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(radius),
                color: tTokenColorOf(tokens, 'bgColorContainer'),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (file == null)
                    Center(
                      child: TIcon(
                        TIcons.add,
                        size: TIconSizes.uploadAdd,
                        color: text,
                      ),
                    )
                  else ...[
                    _thumbnail(file, muted),
                    if (_showsStatus(file)) _statusMask(file, fail),
                    if (_showsHoverActions(file)) _hoverActions(file),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (file != null) ...[const SizedBox(height: 4), _caption(file, muted)],
      ],
    );
  }

  VoidCallback? _cardTap(TUploadFile? file) {
    if (!widget.enabled) return null;
    if (file == null) return widget.onAdd;
    if (_showBrowse(file)) return widget.onPreview;
    return null;
  }

  bool _showBrowse(TUploadFile file) =>
      widget.onPreview != null && _canPreview(file);

  bool _showDelete(TUploadFile file) => widget.onRemove != null;

  bool _showsStatus(TUploadFile file) =>
      file.status == TUploadFileStatus.progress ||
      file.status == TUploadFileStatus.fail;

  bool _showsHoverActions(TUploadFile file) {
    if (!_hover || !widget.enabled) return false;
    if (file.status == TUploadFileStatus.progress) return false;
    return _showBrowse(file) || _showDelete(file);
  }

  Widget _statusMask(TUploadFile file, Color fail) {
    final Widget child;
    if (file.status == TUploadFileStatus.fail) {
      child = TIcon(
        TIcons.error_circle_filled,
        color: fail,
        size: TIconSizes.medium,
      );
    } else {
      final percent = file.percent;
      final label = percent == null ? '上传中' : '${percent.round()}%';
      child = Text(
        label,
        style: const TextStyle(color: _kUploadMaskForeground, fontSize: 12),
      );
    }
    return ColoredBox(
      color: _kUploadMask,
      child: Center(child: child),
    );
  }

  Widget _hoverActions(TUploadFile file) {
    final showBrowse = _showBrowse(file);
    final showDelete = _showDelete(file);
    return ColoredBox(
      color: _kUploadMask,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showBrowse)
            GestureDetector(
              onTap: widget.onPreview,
              child: const TIcon(
                TIcons.browse,
                color: _kUploadMaskForeground,
                size: TIconSizes.medium,
              ),
            ),
          if (showBrowse && showDelete) const SizedBox(width: 16),
          if (showDelete)
            GestureDetector(
              onTap: widget.onRemove,
              child: const TIcon(
                TIcons.delete,
                color: _kUploadMaskForeground,
                size: TIconSizes.medium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _caption(TUploadFile file, Color color) {
    return SizedBox(
      width: _kUploadImageCard,
      child: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Widget _thumbnail(TUploadFile file, Color placeholderColor) {
    final provider = file.preview;
    if (provider != null) {
      return Image(image: provider, fit: BoxFit.contain);
    }
    final url = file.url;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _imagePlaceholder(placeholderColor),
      );
    }
    return _imagePlaceholder(placeholderColor);
  }

  Widget _imagePlaceholder(Color color) {
    return Center(
      child: TIcon(TIcons.image, size: TIconSizes.uploadAdd, color: color),
    );
  }
}
