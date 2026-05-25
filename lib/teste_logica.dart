// lib/teste_logica.dart
import 'models/assistivel.dart';
import 'models/mural.dart';

void main() {
  print('--- INICIANDO TESTES DO NOTEFLIX ---\n');

  // 1. Criando os itens (Testando o domínio)
  var filme1 = Filme(titulo: 'O Auto da Compadecida', duracao: 104);
  filme1.avaliar(10.0, 'Uma obra prima brasileira!');

  var filme2 = Filme(titulo: 'Interestelar', duracao: 169);
  filme2.avaliar(9.5, 'Me fez chorar muito.');

  // 2. Criando uma Série e adicionando episódios (Testando o COMPOSITE)
  var serie = Serie(titulo: 'Breaking Bad');
  serie.adicionarEpisodio(Episodio(titulo: 'Piloto', duracao: 58));
  serie.adicionarEpisodio(Episodio(titulo: 'O Gato na Bolsa', duracao: 48));
  serie.avaliar(9.9, 'A melhor série já feita.');

  print('>> TESTE DO COMPOSITE:');
  print('Duração do filme ${filme1.titulo}: ${filme1.duracaoMinutos} min');
  print('Duração TOTAL da série ${serie.titulo}: ${serie.duracaoMinutos} min (Somou sozinho!)\n');

  // 3. Criando o Mural e adicionando tudo lá (Testando o STRATEGY)
  // Iniciamos o videogame com o "cartucho" de Ordem Alfabética
  var meuMural = Mural(OrdenarPorTitulo());
  meuMural.adicionarItem(filme2); // Interestelar
  meuMural.adicionarItem(serie);  // Breaking Bad
  meuMural.adicionarItem(filme1); // Auto da Compadecida

  print('>> TESTE DO STRATEGY (Ordem Alfabética):');
  for (var item in meuMural.itensOrdenados) {
    print('- ${item.titulo} (Nota: ${item.nota})');
  }

  // 4. Trocando a estratégia em tempo real! 
  print('\n>> TESTE DO STRATEGY (Trocando para Melhores Avaliados):');
  meuMural.mudarOrdenacao(OrdenarPorNota()); // Trocamos o "cartucho"
  
  for (var item in meuMural.itensOrdenados) {
    print('- ${item.titulo} (Nota: ${item.nota})');
  }
}