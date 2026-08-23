import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/providers/download_provider.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/scan_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final downloadState = ref.watch(downloadProvider);
    final historyAsync = ref.watch(historyProvider);

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('WMDA Tester'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.search), text: 'Escanear y Descargar'),
                Tab(icon: Icon(Icons.history), text: 'Historial Guardado'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // PESTAÑA 1: Escanear y Descargar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Escanear flutter.dev'),
                      onPressed: scanState.status == ScanStatus.loading
                          ? null
                          : () => ref
                                .read(scanProvider.notifier)
                                .scan('https://flutter.dev'),
                    ),
                    const SizedBox(height: 10),
                    if (scanState.status == ScanStatus.loading)
                      const CircularProgressIndicator(),
                    if (scanState.status == ScanStatus.error)
                      Text(
                        '❌ ${scanState.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (scanState.status == ScanStatus.success)
                      Expanded(
                        child: ListView.builder(
                          itemCount: scanState.items.length,
                          itemBuilder: (context, index) {
                            final item = scanState.items[index];
                            final isDownloading = downloadState.downloadingIds
                                .contains(item.id);
                            final progress =
                                downloadState.progressMap[item.id] ?? 0.0;

                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  item.type.name == 'video'
                                      ? Icons.videocam
                                      : Icons.image,
                                ),
                                title: Text(
                                  item.title ?? 'Sin título',
                                  maxLines: 1,
                                ),
                                subtitle: isDownloading
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          LinearProgressIndicator(
                                            value: progress > 0
                                                ? progress
                                                : null,
                                          ),
                                          Text(
                                            '${(progress * 100).toStringAsFixed(0)}% descargado',
                                          ),
                                        ],
                                      )
                                    : Text(
                                        item.url,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                trailing: IconButton(
                                  icon: isDownloading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.download),
                                  onPressed: isDownloading
                                      ? null
                                      : () {
                                          ref
                                              .read(downloadProvider.notifier)
                                              .download(item);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Descargando archivo...',
                                                  ),
                                                ),
                                              );
                                        },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // PESTAÑA 2: Historial Guardado
              historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (historyItems) {
                  if (historyItems.isEmpty) {
                    return const Center(
                      child: Text('Aún no has descargado ningún archivo.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: historyItems.length,
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(item.title ?? 'Archivo descargado'),
                        subtitle: Text(item.localPath ?? 'Ruta desconocida'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(historyProvider.notifier)
                                .deleteItem(item.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
