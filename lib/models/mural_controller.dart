// lib/models/mural_controller.dart
import 'package:flutter/material.dart';
import 'assistivel.dart';
import 'mural.dart';

// Ele permite que a interface gráfica do Flutter "observe" essa classe.
class MuralController extends ChangeNotifier {
  // O Controller guarda a nossa regra de negócio (O Mural que já criamos)
  late Mural _mural;

  MuralController() {
    // Iniciamos o mural com os mais recentes por padrão, conforme solicitado
    _mural = Mural(OrdenarPorMaisRecente());

    // --- INJETANDO DADOS FALSOS PARA TESTAR O VISUAL ---
    var filme1 = Filme(titulo: 'O Auto da Compadecida', duracao: 104);
    filme1.avaliar(10.0, 'Uma obra prima brasileira!');

    var filme2 = Filme(titulo: 'Interestelar', duracao: 169);
    filme2.avaliar(9.5, 'Me fez chorar muito.');

    var serie = Serie(titulo: 'Breaking Bad');
    serie.adicionarEpisodio(Episodio(titulo: 'Piloto', duracao: 58));
    serie.adicionarEpisodio(Episodio(titulo: 'O Gato na Bolsa', duracao: 48));
    serie.avaliar(9.9, 'A melhor série já feita.');

    _mural.adicionarItem(filme1);
    _mural.adicionarItem(filme2);
    _mural.adicionarItem(serie);
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