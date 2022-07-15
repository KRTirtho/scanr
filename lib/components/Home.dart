import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:scanr/components/PDFViewPage.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final permission = useMemoized(
        () => Permission.camera.request().then((value) async => [
              await Permission.storage.request(),
              value,
            ]),
        []);

    return Scaffold(
      appBar: AppBar(title: const Text("Scanr")),
      body: FutureBuilder<List<PermissionStatus>>(
          future: permission,
          builder: (context, snapshot) {
            final allowed = [
              PermissionStatus.denied,
              PermissionStatus.permanentlyDenied,
              PermissionStatus.restricted,
            ];
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (allowed.contains(snapshot.data?.first) &&
                allowed.contains(snapshot.data?.last)) {
              return const Center(
                child: Text(
                  "F**k off! Give permissions or don't use the stupid app",
                ),
              );
            }
            final scaffold = ScaffoldMessenger.of(context);
            return Center(
              child: OutlinedButton(
                child: Column(
                  children: [
                    const Icon(Icons.camera_alt_rounded, size: 26),
                    Text(
                      "Take a Picture of Document",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
                onPressed: () async {
                  try {
                    final imagePath =
                        File(await EdgeDetection.detectEdge ?? "");
                    if (!imagePath.existsSync()) return;
                    final imageBytes = await imagePath.readAsBytes();
                    final doc = pdf.Document()
                      ..addPage(
                        pdf.Page(build: (context) {
                          return pdf.Center(
                            child: pdf.Image(pdf.MemoryImage(imageBytes)),
                          );
                        }),
                      );

                    final outputFile = File(path.join(
                      '/storage/emulated/0/Download',
                      "${path.basenameWithoutExtension(imagePath.path)}.pdf",
                    ));

                    await outputFile.writeAsBytes(await doc.save());

                    scaffold.showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: "Open",
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PDFViewPage(path: outputFile.path),
                              ),
                            );
                          },
                        ),
                        content: Text("File saved to ${outputFile.path}"),
                      ),
                    );
                  } on PlatformException catch (e) {
                    print("[EdgeDetection] $e");
                  }
                },
              ),
            );
          }),
    );
  }
}
