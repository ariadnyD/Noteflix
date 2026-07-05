import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/mural_controller.dart';
import 'models/mural.dart';
import 'models/assistivel.dart';

void main() {
  runApp(const NoteflixApp());
}

class NoteflixApp extends StatelessWidget {
  const NoteflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noteflix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const TelaLogin(),
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
        leading: IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 28),
          tooltip: 'Adicionar Novo',
          onPressed: () {
            // PEGANDO O CONTROLLER DA TELA PRINCIPAL:
            final controller = Provider.of<MuralController>(context, listen: false);
            
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              // EMPRESTANDO O CONTROLLER PARA A JANELINHA:
              builder: (ctx) => ChangeNotifierProvider.value(
                value: controller,
                child: const FormularioNoteflix(),
              ),
            );
          },
        ),
        
        title: const Text('Meu Noteflix', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list, size: 28),
            tooltip: 'Ordenar lista',
            onSelected: (int valorEscolhido) {
              final controller = Provider.of<MuralController>(context, listen: false);
              
              if (valorEscolhido == 1) {
                controller.alterarFiltro(OrdenarPorMaisRecente()); // O seu novo filtro!
              } else if (valorEscolhido == 2) {
                controller.alterarFiltro(OrdenarPorTitulo());
              } else if (valorEscolhido == 3) {
                controller.alterarFiltro(OrdenarPorNota());
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 1,
                child: Text('Mais Recentes'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('Ordem Alfabética'),
              ),
              const PopupMenuItem(
                value: 3,
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
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 4), 
                      Text(
                        item.nota?.toStringAsFixed(1) ?? '-',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                        onPressed: () {
                          final controller = Provider.of<MuralController>(context, listen: false);
                          
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            builder: (ctx) => ChangeNotifierProvider.value(
                              value: controller,
                              child: FormularioNoteflix(itemParaEditar: item),
                            ),
                          );
                        },
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          // Chama o Controller passando exatamente o item que foi clicado
                          Provider.of<MuralController>(context, listen: false).remover(item);
                        },
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

class FormularioNoteflix extends StatefulWidget {
  final Assistivel? itemParaEditar; // Se for nulo, é cadastro. Se vier preenchido, é edição!

  const FormularioNoteflix({super.key, this.itemParaEditar});

  @override
  State<FormularioNoteflix> createState() => _FormularioNoteflixState();
}

class _FormularioNoteflixState extends State<FormularioNoteflix> {
  bool _ehSerie = false;

  final _tituloCtrl = TextEditingController();
  final _duracaoCtrl = TextEditingController();
  final _notaCtrl = TextEditingController();
  final _resenhaCtrl = TextEditingController();

  final _tituloEpCtrl = TextEditingController();
  final _duracaoEpCtrl = TextEditingController();
  final List<Episodio> _episodiosAdicionados = [];

  @override
  void initState() {
    super.initState();
    // Se recebemos um item para editar, preenchemos os controladores com os dados dele!
    if (widget.itemParaEditar != null) {
      final item = widget.itemParaEditar!;
      _tituloCtrl.text = item.titulo;
      _notaCtrl.text = item.nota?.toString() ?? '';
      _resenhaCtrl.text = item.resenha ?? '';

      if (item is Serie) {
        _ehSerie = true;
        // Carrega os episódios existentes para a nossa lista temporária do forms
        for (var ep in item.episodios) {
          if (ep is Episodio) _episodiosAdicionados.add(ep);
        }
      } else if (item is Filme) {
        _ehSerie = false;
        _duracaoCtrl.text = item.duracaoMinutos.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24, left: 24, right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.itemParaEditar == null ? 'Adicionar ao Noteflix' : 'Editar no Noteflix', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),

            // Impede a troca entre filme/série durante a edição para não quebrar as classes
            if (widget.itemParaEditar == null)
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Filme'), icon: Icon(Icons.movie)),
                  ButtonSegment(value: true, label: Text('Série'), icon: Icon(Icons.tv)),
                ],
                selected: {_ehSerie},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _ehSerie = newSelection.first;
                  });
                },
              ),
            const SizedBox(height: 16),

            TextField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: _notaCtrl, decoration: const InputDecoration(labelText: 'Sua Nota (0 a 10)'), keyboardType: TextInputType.number),
            TextField(controller: _resenhaCtrl, decoration: const InputDecoration(labelText: 'Resenha rápida')),
            
            if (!_ehSerie) ...[
              TextField(controller: _duracaoCtrl, decoration: const InputDecoration(labelText: 'Duração Total (em minutos)'), keyboardType: TextInputType.number),
            ] else ...[
              const SizedBox(height: 16),
              const Divider(),
              const Text('Episódios', style: TextStyle(fontWeight: FontWeight.bold)),
              
              for (var ep in _episodiosAdicionados)
                ListTile(
                  dense: true,
                  title: Text(ep.titulo),
                  trailing: Text('${ep.duracaoMinutos} min'),
                ),
              
              Row(
                children: [
                  Expanded(child: TextField(controller: _tituloEpCtrl, decoration: const InputDecoration(labelText: 'Nome do Ep'))),
                  const SizedBox(width: 8),
                  SizedBox(width: 80, child: TextField(controller: _duracaoEpCtrl, decoration: const InputDecoration(labelText: 'Min'), keyboardType: TextInputType.number)),
                  IconButton(
                    icon: const Icon(Icons.add_box, color: Colors.deepPurpleAccent),
                    onPressed: () {
                      if (_tituloEpCtrl.text.isNotEmpty && _duracaoEpCtrl.text.isNotEmpty) {
                        setState(() {
                          _episodiosAdicionados.add(Episodio(
                            titulo: _tituloEpCtrl.text, 
                            duracao: int.parse(_duracaoEpCtrl.text)
                          ));
                          _tituloEpCtrl.clear();
                          _duracaoEpCtrl.clear();
                        });
                      }
                    },
                  )
                ],
              ),
              const Divider(),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                onPressed: () {
                  final titulo = _tituloCtrl.text;
                  final nota = double.tryParse(_notaCtrl.text) ?? 0.0;
                  final resenha = _resenhaCtrl.text;

                  Assistivel novoItem;

                  if (_ehSerie) {
                    var serie = Serie(titulo: titulo);
                    for (var ep in _episodiosAdicionados) {
                      serie.adicionarEpisodio(ep);
                    }
                    novoItem = serie;
                  } else {
                    final duracao = int.tryParse(_duracaoCtrl.text) ?? 0;
                    novoItem = Filme(titulo: titulo, duracao: duracao);
                  }

                  novoItem.avaliar(nota, resenha);
                  
                  final controller = Provider.of<MuralController>(context, listen: false);
                  
                  if (widget.itemParaEditar == null) {
                    // Modo Cadastro
                    controller.adicionar(novoItem);
                  } else {
                    // Modo Edição
                    controller.editar(widget.itemParaEditar!, novoItem);
                  }

                  Navigator.pop(context); 
                },
                child: Text(widget.itemParaEditar == null ? 'Salvar no Mural' : 'Salvar Alterações', style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _usuarioCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _mensagemErro = '';

  Future<void> _entrarOuCadastrar() async {
    final usuario = _usuarioCtrl.text.trim().toLowerCase();
    final senha = _senhaCtrl.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      setState(() => _mensagemErro = 'Preencha todos os campos!');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    // Puxa o "dicionário" de usuários cadastrados
    final stringUsuarios = prefs.getString('usuarios_cadastrados') ?? '{}';
    final Map<String, dynamic> usuarios = jsonDecode(stringUsuarios);

    if (usuarios.containsKey(usuario)) {
      // Usuário já existe, vamos checar a senha
      if (usuarios[usuario] == senha) {
        _irParaMural(usuario);
      } else {
        setState(() => _mensagemErro = 'Senha incorreta!');
      }
    } else {
      // Primeiro acesso: cadastra automaticamente e já entra!
      usuarios[usuario] = senha;
      await prefs.setString('usuarios_cadastrados', jsonEncode(usuarios));
      _irParaMural(usuario);
    }
  }

  void _irParaMural(String nomeUsuario) {
    // Redireciona para o mural e injeta o Controller específico desse usuário!
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => MuralController(nomeUsuario),
          child: const TelaMural(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          // A MÁGICA VISUAL AQUI: Limitamos a largura para 400 pixels!
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie_filter, size: 80, color: Colors.deepPurpleAccent),
                const SizedBox(height: 16),
                const Text('Noteflix', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Seu catálogo pessoal', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),
                
                TextField(
                  controller: _usuarioCtrl,
                  decoration: const InputDecoration(labelText: 'Usuário', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock)),
                ),
                const SizedBox(height: 16),
                
                if (_mensagemErro.isNotEmpty)
                  Text(_mensagemErro, style: const TextStyle(color: Colors.redAccent)),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                    onPressed: _entrarOuCadastrar,
                    child: const Text('Entrar', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}