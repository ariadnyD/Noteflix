import 'package:flutter/material.dart';
import 'assistivel.dart';
import 'mural.dart';

class MuralController extends ChangeNotifier {
  late Mural _mural;

  MuralController() {
    // Mural iniciando vazio e com o seu filtro de mais recentes!
    _mural = Mural(OrdenarPorMaisRecente());
  }

  List<Assistivel> get itens => _mural.itensOrdenados;

  void adicionar(Assistivel item) {
    _mural.adicionarItem(item);
    notifyListeners(); 
  }

  // NOVO: Método para fazer a ponte da exclusão
  void remover(Assistivel item) {
    _mural.removerItem(item);
    notifyListeners(); // Avisa a tela para apagar o cartão na mesma hora
  }

  void alterarFiltro(OrdenacaoStrategy novaEstrategia) {
    _mural.mudarOrdenacao(novaEstrategia);
    notifyListeners();
  }
}