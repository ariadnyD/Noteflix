import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/mural_controller.dart';

void main() {
  // O runApp inicia o aplicativo. 
  // Envolvemos ele no ChangeNotifierProvider para ativar o padrão Observer na interface!
  runApp(
    ChangeNotifierProvider(
      create: (context) => MuralController(),
      child: const NoteflixApp(),
    ),
  );
}

class NoteflixApp extends StatelessWidget {
  const NoteflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noteflix',
      debugShowCheckedModeBanner: false, // Tira aquela faixa vermelha de "Debug" da tela
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // A cor principal do seu app
          brightness: Brightness.dark,  // Tema escuro combina muito mais com cinema!
        ),
        useMaterial3: true,
      ),
      home: const TelaMural(),
    );
  }
}

// A nossa tela principal em branco
class TelaMural extends StatelessWidget {
  const TelaMural({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Noteflix', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // O Consumer é a "antena" do nosso padrão Observer!
      // Ele escuta o MuralController e redesenha a lista sempre que algo mudar.
      body: Consumer<MuralController>(
        builder: (context, controller, child) {
          final itens = controller.itens;

          return ListView.builder(
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              
              // O Card é o "poster" do nosso filme
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.movie, size: 40, color: Colors.deepPurpleAccent),
                  title: Text(item.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Duração: ${item.duracaoMinutos} min\nResenha: ${item.resenha}',
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      Text(
                        item.nota?.toStringAsFixed(1) ?? '-',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}