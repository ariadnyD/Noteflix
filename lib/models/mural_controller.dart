// lib/models/mural_controller.dart

import 'dart:convert'; // Para o jsonEncode e jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // O pacote que acabamos de instalar
import 'assistivel.dart';
import 'mural.dart';

class MuralController extends ChangeNotifier {
  late Mural _mural;

  MuralController() {
    _mural = Mural(OrdenarPorMaisRecente());
    _carregarDadosLocais(); // Assim que o app inicia, ele procura o arquivo no disco!
  }

  List<Assistivel> get itens => _mural.itensOrdenados;

  void adicionar(Assistivel item) {
    _mural.adicionarItem(item);
    _salvarDadosLocais(); // Salva no disco após adicionar
    notifyListeners();
  }

  void remover(Assistivel item) {
    _mural.removerItem(item);
    _salvarDadosLocais(); // Salva no disco após remover
    notifyListeners();
  }

  void editar(Assistivel antigo, Assistivel novo) {
    _mural.atualizarItem(antigo, novo);
    _salvarDadosLocais(); // Salva no disco após editar
    notifyListeners();
  }

  void alterarFiltro(OrdenacaoStrategy novaEstrategia) {
    _mural.mudarOrdenacao(novaEstrategia);
    notifyListeners();
  }

  // --- MÉTODOS DE ARQUIVO (PERSISTÊNCIA) ---

  Future<void> _salvarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Transforma a nossa lista de Objetos em uma lista de Dicionários JSON
    final listaDeDicionarios = _mural.meusItens.map((item) => item.toJson()).toList();
    
    // Transforma tudo num texto gigantesco e salva no disco
    final stringJson = jsonEncode(listaDeDicionarios);
    await prefs.setString('noteflix_bd', stringJson);
  }

  Future<void> _carregarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    final stringJson = prefs.getString('noteflix_bd');
    
    if (stringJson != null) {
      // Pega o texto do disco e converte de volta pra Lista
      final List listaDecodificada = jsonDecode(stringJson);
      
      // Usa a nossa Fábrica Inteligente para reconstruir as classes
      for (var itemMap in listaDecodificada) {
        _mural.adicionarItem(Assistivel.fromJson(itemMap));
      }
      notifyListeners(); // Avisa a tela que os dados chegaram!
    }
  }
}