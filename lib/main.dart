import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/providers/scan_provider.dart';

void main() {
  // Riverpod requiere ProviderScope en la raíz
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del escáner en tiempo real
    final scanState = ref.watch(scanProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('WMDA - Test Provider')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Probar Escaneo con Riverpod'),
                onPressed: scanState.status == ScanStatus.loading
                    ? null
                    : () {
                        ref
                            .read(scanProvider.notifier)
                            .scan('https://flutter.dev');
                      },
              ),
              const SizedBox(height: 20),

              // 1. Estado Cargando
              if (scanState.status == ScanStatus.loading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                const Text('Escaneando página web...'),
              ],

              // 2. Estado de Error
              if (scanState.status == ScanStatus.error) ...[
                Text(
                  '❌ ${scanState.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              // 3. Estado de Éxito: Lista de resultados
              if (scanState.status == ScanStatus.success) ...[
                Text(
                  '✅ ¡Se encontraron ${scanState.items.length} elementos!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: scanState.items.length,
                    itemBuilder: (context, index) {
                      final item = scanState.items[index];
                      return ListTile(
                        leading: Icon(
                          item.type.name == 'video'
                              ? Icons.videocam
                              : Icons.image,
                        ),
                        title: Text(
                          item.title ?? 'Sin título',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(item.extension ?? ''),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
