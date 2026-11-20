import 'package:flutter/widgets.dart';
import 'package:tdesign_flutter_multi_desktop/tdesign_flutter_multi_desktop.dart';

import '../scaffold.dart';

class UploadDemoPage extends StatefulWidget {
  const UploadDemoPage({super.key});

  @override
  State<UploadDemoPage> createState() => _UploadDemoPageState();
}

class _UploadDemoPageState extends State<UploadDemoPage> {
  var _files = <TUploadFile>[];
  var _manual = <TUploadFile>[];
  var _counter = 0;

  Future<List<TUploadFile>> _mockPick({bool multiple = false}) async {
    _counter += 1;
    if (!multiple) {
      return [TUploadFile(name: 'demo-$_counter.txt', size: 1024)];
    }
    return [
      TUploadFile(name: 'demo-$_counter-a.txt', size: 1024),
      TUploadFile(name: 'demo-$_counter-b.txt', size: 2048),
    ];
  }

  Future<TUploadFile> _mockRequest(TUploadFile file) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return file.copyWith(status: TUploadFileStatus.success, percent: 100);
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Upload 上传',
      source: 'components/upload',
      children: [
        DemoSection(
          title: '基础文件上传',
          child: TUpload(
            files: _files,
            tips: 'Gallery 使用模拟选择与上传，不打开系统文件框',
            pickFiles: _mockPick,
            request: _mockRequest,
            onChanged: (value) => setState(() => _files = value),
          ),
        ),
        DemoSection(
          title: '手动上传',
          child: TUpload(
            files: _manual,
            autoUpload: false,
            multiple: true,
            max: 3,
            tips: '选择后保持待上传，可点 × 移除',
            pickFiles: () => _mockPick(multiple: true),
            onChanged: (value) => setState(() => _manual = value),
          ),
        ),
      ],
    );
  }
}
