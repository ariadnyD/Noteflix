// lib/models/mural_controller.dart
import 'package:flutter/material.dart';
import 'assistivel.dart';
import 'mural.dart';

// Ele permite que a interface gráfica do Flutter "observe" essa classe.
class MuralController extends ChangeNotifier {
  // O Controller guarda a nossa regra de negócio (O Mural que já criamos)
  late Mural _mural;

  MuralController() {
    // Iniciamos o mural com a ordem alfabética por padrão
    _mural = Mural(OrdenarPorTitulo());
  }

  // A interface vai pedir essa lista para desenhar na tela
  List<Assistivel> get itens => _mural.itensOrdenados;

  // Método para adicionar um novo filme/série pela tela do app
  void adicionar(Assistivel item) {
    _mural.adicionarItem(item);
    
    // A mágica do Observer: Avisa todos os Widgets que a lista mudou!
    notifyListeners(); 
  }

  // Método para o botão de filtro da tela
  void alterarFiltro(OrdenacaoStrategy novaEstrategia) {
    _mural.mudarOrdenacao(novaEstrategia);
    
    // Avisa a tela para se redesenhar com a nova ordem!
    notifyListeners();
  }
}