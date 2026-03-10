import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(const MeuSistemaEstoque());
}

class MeuSistemaEstoque extends StatelessWidget {
  const MeuSistemaEstoque({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Estoque',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaEntrada(), 
    );
  }
}

class TelaEntrada extends StatefulWidget {
  const TelaEntrada({super.key});

  @override
  State<TelaEntrada> createState() => _TelaEntradaState();
}

class _TelaEntradaState extends State<TelaEntrada> {
  bool estaCarregando = false;
  bool modoManual = false;

  final FocusNode focoLeitor = FocusNode();
  final TextEditingController controladorLeitor = TextEditingController();

  final TextEditingController controladorCodigoManual = TextEditingController();
  final TextEditingController controladorQuantidadeManual = TextEditingController();

  @override
  void initState() {
    super.initState();
    focoLeitor.requestFocus();
  }

  Future<void> processarLeitura(String chave) async {
    String chaveLimpa = chave.trim();

    if (chaveLimpa.length != 44) {
      print("Erro: A chave precisa ter exatos 44 dígitos.");
      controladorLeitor.clear();
      focoLeitor.requestFocus();
      return;
    }

    setState(() {
      estaCarregando = true; 
    });

    var url = Uri.parse('http://127.0.0.1:8000/receber-nota');
    var resposta = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chave_acesso': chaveLimpa}),
    );

    if (resposta.statusCode == 200) {
      print("Nota fiscal processada com sucesso!");
    } else {
      print("Erro ao processar a nota fiscal: ${resposta.statusCode}");
    }

    setState(() {
      estaCarregando = false; 
      controladorLeitor.clear();
    });

    focoLeitor.requestFocus(); 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada de Nota Fiscal'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    modoManual = !modoManual;
                    if (!modoManual) focoLeitor.requestFocus();
                  });
                },
                icon: Icon(modoManual ? Icons.qr_code_scanner : Icons.keyboard),
                label: Text(modoManual ? 'Voltar para Leitor USB' : 'Digitar Manualmente'),
              ),
              
              const SizedBox(height: 40),

              
              if (estaCarregando)
                const CircularProgressIndicator() 
                
              else if (modoManual)
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: controladorCodigoManual,
                        decoration: const InputDecoration(
                          labelText: 'Código do Produto Interno',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: controladorQuantidadeManual,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          print("Salvando Manual - Cod: ${controladorCodigoManual.text} | Qtd: ${controladorQuantidadeManual.text}");
                        },
                        child: const Text('Adicionar à Nota'),
                      ),
                    ),
                  ],
                )
                
              else
              
                TextField(
                  controller: controladorLeitor,
                  focusNode: focoLeitor,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Bipe a DANFE aqui (Aguardando 44 dígitos...)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.document_scanner),
                  ),
                  onSubmitted: (valorLido) {
                    processarLeitura(valorLido);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}