import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/mural_controller.dart';
import 'models/mural.dart';

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
        // 1. Botão de Adicionar na Esquerda (leading)
        leading: IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 28),
          tooltip: 'Adicionar Novo',
          onPressed: () {
            // Aqui vai entrar a chamada para a janelinha de cadastro
            print("Clicou em adicionar!");
          },
        ),
        
        title: const Text('Meu Noteflix', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        
        // 2. Botão de Filtrar na Direita (actions)
        // 2. Menu de Filtrar na Direita (actions)
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list, size: 28),
            tooltip: 'Ordenar lista',
            // Quando uma opção for clicada, o onSelected é acionado
            onSelected: (int valorEscolhido) {
              // Pegamos a "antena" do Controller, mas sem ficar escutando (listen: false)
              // porque aqui queremos apenas dar uma ordem, e não redesenhar o botão.
              final controller = Provider.of<MuralController>(context, listen: false);
              
              if (valorEscolhido == 1) {
                // Pluga o cartucho de Ordem Alfabética
                controller.alterarFiltro(OrdenarPorTitulo());
              } else if (valorEscolhido == 2) {
                // Pluga o cartucho de Maior Nota
                controller.alterarFiltro(OrdenarPorNota());
              }
            },
            // Constrói os botões do menu
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 1,
                child: Text('Ordem Alfabética'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('Maior Nota'),
              ),
            ],
          ),
        ],
      ),
      
      body: Consumer<MuralController>(
        builder: (context, controller, child) {
          final itens = controller.itens;

          return ListView.builder(
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Impede que a linha empurre o texto para o lado
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 4), // Dá um espacinho charmoso entre a estrela e o número
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