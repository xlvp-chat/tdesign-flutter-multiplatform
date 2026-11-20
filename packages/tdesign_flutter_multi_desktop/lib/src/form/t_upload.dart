import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_icons/tdesign_flutter_icons.dart';
import 'package:tdesign_flutter_multi_core/tdesign_flutter_multi_core.dart';

import '../basic/t_button.dart';
import '../token/t_token_color.dart';

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
    this.error,
  });

  final String name;
  final int? size;
  final TUploadFileStatus status;
  final double? percent;
  final String? url;
  final String? error;

  TUploadFile copyWith({
    String? name,
    int? size,
    TUploadFileStatus? status,
    double? percent,
    String? url,
    String? error,
  }) {
    return TUploadFile(
      name: name ?? this.name,
      size: size ?? this.size,
      status: status ?? this.status,
      percent: percent ?? this.percent,
      url: url ?? this.url,
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

  /// Square tiles plus an add tile. Tiles show the file name, not image bytes.
  image,

  /// Name, size, and status rows.
  fileFlow,
}

/// Desktop upload — file rows or image tiles with an injectable picker.
///
/// [TUploadTheme.image] uses square tiles plus an add tile (`TIcons.add`) as
/// the pick trigger (no text button). Spec source: local tdesign-vue-next
/// `Upload`. No built-in HTTP or `file_picker`; pass [pickFiles] and optional
/// [request].
class TUpload extends StatefulWidget {
  const TUpload({
    super.key,
    required this.files,
    required this.pickFiles,
    this.onChanged,
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

  String _sizeLabel(TUploadFile file) {
    final size = file.size;
    if (size == null) return '—';
    if (size < 1024) return '$size B';
    return '${(size / 1024).toStringAsFixed(1)} KB';
  }

  String _statusLabel(TUploadFile file) {
    switch (file.status) {
      case TUploadFileStatus.waiting:
        return '待上传';
      case TUploadFileStatus.progress:
        final percent = file.percent;
        return percent == null ? '上传中' : '上传中 ${percent.round()}%';
      case TUploadFileStatus.success:
        return '上传成功';
      case TUploadFileStatus.fail:
        return file.error ?? '上传失败';
    }
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
            onPressed: widget.enabled && !_busy
                ? () {
                    _onTrigger();
                  }
                : null,
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
                _ImageTile(
                  file: widget.files[i],
                  enabled: widget.enabled,
                  onRemove: () => _removeAt(i),
                  tokens: tokens,
                ),
              _ImageTile(
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
                sizeLabel: _sizeLabel(widget.files[i]),
                statusLabel: _statusLabel(widget.files[i]),
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
    required this.sizeLabel,
    required this.statusLabel,
    required this.onRemove,
  });

  final TUploadFile file;
  final bool showSize;
  final bool enabled;
  final Color text;
  final Color muted;
  final Color fail;
  final String sizeLabel;
  final String statusLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(file.name, style: TextStyle(fontSize: 14, color: text)),
        ),
        if (showSize)
          SizedBox(
            width: 72,
            child: Text(
              sizeLabel,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ),
        Text(
          statusLabel,
          style: TextStyle(
            fontSize: 12,
            color: file.status == TUploadFileStatus.fail ? fail : muted,
          ),
        ),
        if (enabled) ...[
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: Icon(TIcons.close, size: 14, color: muted),
          ),
        ],
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    super.key,
    this.file,
    required this.enabled,
    required this.tokens,
    this.onRemove,
    this.onAdd,
  });

  final TUploadFile? file;
  final bool enabled;
  final TDesignTokenSet tokens;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final border = tTokenColorOf(tokens, 'componentBorder');
    final text = tTokenColorOf(tokens, 'textColorPrimary');
    return GestureDetector(
      onTap: enabled ? onAdd : null,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(tTokenRadius(tokens)),
        ),
        child: file == null
            ? IconTheme(
                data: IconThemeData(color: text, size: 20),
                child: const Icon(TIcons.add),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    file!.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: text),
                  ),
                  if (enabled && onRemove != null)
                    GestureDetector(
                      onTap: onRemove,
                      child: Icon(
                        TIcons.close,
                        size: 12,
                        color: tTokenColorOf(tokens, 'textColorPlaceholder'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
