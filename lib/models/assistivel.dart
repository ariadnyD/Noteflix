// lib/models/assistivel.dart

abstract class Assistivel {
  String get titulo;
  int get duracaoMinutos;
  double? nota;
  String? resenha;

  void avaliar(double nota, String resenha) {
    this.nota = nota;
    this.resenha = resenha;
  }

  // OBRIGATÓRIO: Todo assistível precisa saber virar um "dicionário" (Map)
  Map<String, dynamic> toJson();

  // FÁBRICA INTELIGENTE: Lê o dicionário do arquivo e recria o objeto certo
  static Assistivel fromJson(Map<String, dynamic> json) {
    if (json['tipo'] == 'filme') {
      var filme = Filme(titulo: json['titulo'], duracao: json['duracao']);
      if (json['nota'] != null) filme.avaliar(json['nota'], json['resenha']);
      return filme;
    } else {
      var serie = Serie(titulo: json['titulo']);
      if (json['nota'] != null) serie.avaliar(json['nota'], json['resenha']);
      
      // Se for série, temos que recriar os episódios também!
      if (json['episodios'] != null) {
        for (var epJson in json['episodios']) {
          serie.adicionarEpisodio(Episodio(titulo: epJson['titulo'], duracao: epJson['duracao']));
        }
      }
      return serie;
    }
  }
}

class Filme extends Assistivel {
  final String _titulo;
  final int _duracao;

  Filme({required String titulo, required int duracao})
      : _titulo = titulo,
        _duracao = duracao;

  @override
  String get titulo => _titulo;

  @override
  int get duracaoMinutos => _duracao;

  @override
  Map<String, dynamic> toJson() {
    return {
      'tipo': 'filme', // Essa tag é o segredo para sabermos o que recriar depois!
      'titulo': titulo,
      'duracao': duracaoMinutos,
      'nota': nota,
      'resenha': resenha,
    };
  }
}

class Episodio extends Assistivel {
  final String _titulo;
  final int _duracao;

  Episodio({required String titulo, required int duracao})
      : _titulo = titulo,
        _duracao = duracao;

  @override
  String get titulo => _titulo;

  @override
  int get duracaoMinutos => _duracao;

  @override
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'duracao': duracaoMinutos,
    };
  }
}

class Serie extends Assistivel {
  final String _titulo;
  final List<Assistivel> _episodios = [];

  Serie({required String titulo}) : _titulo = titulo;

  @override
  String get titulo => _titulo;

  List<Assistivel> get episodios => _episodios;

  void adicionarEpisodio(Assistivel episodio) {
    _episodios.add(episodio);
  }

  @override
  int get duracaoMinutos {
    int total = 0;
    for (var episodio in _episodios) {
      total += episodio.duracaoMinutos;
    }
    return total;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tipo': 'serie',
      'titulo': titulo,
      'nota': nota,
      'resenha': resenha,
      // Pega todos os objetos de episódios e transforma em uma lista de dicionários
      'episodios': _episodios.map((ep) => (ep as Episodio).toJson()).toList(),
    };
  }
}