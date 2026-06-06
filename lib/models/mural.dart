// lib/models/mural.dart
import 'assistivel.dart';

// 1. A Interface da Estratégia (O Contrato)
abstract class OrdenacaoStrategy {
  List<Assistivel> ordenar(List<Assistivel> itens);
}

// 2. Estratégia Concreta A: Ordem Alfabética
class OrdenarPorTitulo implements OrdenacaoStrategy {
  @override
  List<Assistivel> ordenar(List<Assistivel> itens) {
    // Criamos uma cópia da lista para não bagunçar a lista original em memória
    var listaOrdenada = List<Assistivel>.from(itens);
    listaOrdenada.sort((a, b) => a.titulo.compareTo(b.titulo));
    return listaOrdenada;
  }
}

// 3. Estratégia Concreta B: Melhores Avaliados (Maior nota)
class OrdenarPorNota implements OrdenacaoStrategy {
  @override
  List<Assistivel> ordenar(List<Assistivel> itens) {
    var listaOrdenada = List<Assistivel>.from(itens);
    // Ordena da maior nota para a menor. Se não tiver nota, considera 0.
    listaOrdenada.sort((a, b) {
      double notaA = a.nota ?? 0.0;
      double notaB = b.nota ?? 0.0;
      return notaB.compareTo(notaA); 
    });
    return listaOrdenada;
  }
}

// 4. Estratégia Concreta C: Mais Recentes (Últimos adicionados primeiro)
class OrdenarPorMaisRecente implements OrdenacaoStrategy {
  @override
  List<Assistivel> ordenar(List<Assistivel> itens) {
    // Retorna a lista de trás pra frente (reversed)
    return List<Assistivel>.from(itens.reversed);
  }
}

// 4. O Contexto (O Mural que usa a estratégia)
class Mural {
  List<Assistivel> meusItens = [];
  
  // O Mural guarda a estratégia atual, mas não sabe qual é exatamente
  OrdenacaoStrategy estrategiaAtual;

  // Ao criar o mural, definimos uma estratégia padrão inicial
  Mural(this.estrategiaAtual);

  void adicionarItem(Assistivel item) {
    meusItens.add(item);
  }

  // O botão da interface vai chamar esse método para trocar o filtro na hora!
  void mudarOrdenacao(OrdenacaoStrategy novaEstrategia) {
    estrategiaAtual = novaEstrategia;
  }

  // Quando a tela pedir os itens para desenhar, eles já saem ordenados
  List<Assistivel> get itensOrdenados {
    return estrategiaAtual.ordenar(meusItens);
  }
}