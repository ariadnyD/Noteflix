// lib/models/assistivel.dart

// 1. O Componente Base
// Esta interface diz o que qualquer item do mural precisa ter.
abstract class Assistivel {
  String get titulo;
  int get duracaoMinutos;
  
  double? nota;
  String? resenha;

  void avaliar(double valor, String texto) {
    nota = valor;
    resenha = texto;
  }
}

// 2. A "Folha" (Leaf)
// Representa um item único que não pode ser dividido.
class Filme extends Assistivel {
  @override
  final String titulo;
  final int duracao; // Duração em minutos

  Filme({required this.titulo, required this.duracao});

  @override
  int get duracaoMinutos => duracao;
}

// 3. O "Composite" (Composto)
// Representa um item que contém uma coleção de outros itens.
class Serie extends Assistivel {
  @override
  final String titulo;
  
  // A magia do Composite está aqui: uma lista do tipo da interface base!
  // Pode guardar tanto episódios soltos, quanto temporadas inteiras (se criássemos a classe).
  final List<Assistivel> _episodios = [];

  Serie({required this.titulo});

  void adicionarEpisodio(Assistivel episodio) {
    _episodios.add(episodio);
  }

  @override
  int get duracaoMinutos {
    // Calcula o tempo total somando a duração de todos os filhos
    return _episodios.fold(0, (total, ep) => total + ep.duracaoMinutos);
  }
  // Adicione esta linha dentro da class Serie para podermos ler os episódios na edição:
  List<Assistivel> get episodios => _episodios;
}

// Criando o Episódio (que também é uma Folha)
class Episodio extends Assistivel {
  @override
  final String titulo;
  final int duracao;

  Episodio({required this.titulo, required this.duracao});

  @override
  int get duracaoMinutos => duracao;
}