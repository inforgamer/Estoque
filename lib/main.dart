import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const SistemaEstoque());
}

class SistemaEstoque extends StatelessWidget {
  const SistemaEstoque({super.key});

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
  String tipoMovimentacao = 'Entrada';
  final TextEditingController controladorNumeroNota = TextEditingController();
  final TextEditingController controladorNomeCliente = TextEditingController();
  final TextEditingController controladorTotal = TextEditingController();

  final TextEditingController controladorCodigo = TextEditingController();
  final TextEditingController controladorQuantidade = TextEditingController();
  
  List<dynamic> listaProdutos = []; 

  void adicionarItemNaTabela() {
    String codigo = controladorCodigo.text.trim();
    String qtd = controladorQuantidade.text.trim();

    if (codigo.isNotEmpty && qtd.isNotEmpty) {
      setState(() {
        listaProdutos.add({
          'nome': codigo,
          'qtd': qtd,
        });
      });

      controladorCodigo.clear();
      controladorQuantidade.clear();
    }
  }

  Future<void> salvarNotaNoBanco() async {
    int totalDeclarado = int.tryParse(controladorTotal.text) ?? 0;

    int totalCalculado = 0;
    for(var item in listaProdutos) {
      totalCalculado += int.parse(item['qtd']);
    }

    if (totalDeclarado != totalCalculado) {
      print("Erro de validação: Total declarado ($totalDeclarado) não corresponde ao total calculado ($totalCalculado).");
      return;
    }
    print("SUCESSO: As quantidades batem! Enviando para o servidor...");
    print("Tipo: $tipoMovimentacao | Nota: ${controladorNumeroNota.text}");
    print("Itens: $listaProdutos");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamento de Nota (Manual)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
 
            const Text("Dados da Nota", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                DropdownButton<String>(
                  value: tipoMovimentacao,
                  items: <String>['Entrada', 'Saída'].map((String valor) {
                    return DropdownMenuItem<String>(
                      value: valor,
                      child: Text(valor, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (String? novoValor) {
                    setState(() {
                      tipoMovimentacao = novoValor!;
                    });
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: controladorNumeroNota,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(labelText: 'Número da Nota', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controladorNomeCliente,
                     keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.singleLineFormatter,
                    ],
                    decoration: const InputDecoration(labelText: 'Cliente / Fornecedor', border: OutlineInputBorder()),
                  ),
                ),
                 const SizedBox(width: 10),
                  Expanded(
                  flex: 1,
                  child: TextField(
                    controller: controladorTotal,
                     keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(labelText: 'Total de Peças', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 50, thickness: 2),

            const Text("Adicionar Produtos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3, 
                  child: TextField(
                    controller: controladorCodigo, 
                     keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: const InputDecoration(labelText: 'Código', border: OutlineInputBorder())
                  )
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1, 
                  child: TextField(
                    controller: controladorQuantidade,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],  
                    decoration: const InputDecoration(labelText: 'Qtd', border: OutlineInputBorder())
                  )
                ),
                const SizedBox(width: 10),
                const SizedBox(width: 10),
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: adicionarItemNaTabela,
                    icon: const Icon(Icons.add),
                    label: const Text('Inserir'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

        
            Expanded(
              child: listaProdutos.isEmpty
                  ? const Center(child: Text("Nenhum item adicionado ainda.", style: TextStyle(color: Colors.grey)))
                  : SingleChildScrollView( 
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[200]),
                          columns: const [
                            DataColumn(label: Text('Produto', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Quantidade', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: listaProdutos.asMap().entries.map((entrada) {
                            int indice = entrada.key;
                            var item = entrada.value; 

                            return DataRow(cells: [
                              DataCell(Text(item['nome'].toString())),
                              DataCell(Text(item['qtd'].toString())),
                              
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        controladorCodigo.text = item['nome'].toString();
                                        controladorQuantidade.text = item['qtd'].toString();
                                        
                                        setState(() {
                                          listaProdutos.removeAt(indice);
                                        });
                                      },
                                    ),
                                    
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          listaProdutos.removeAt(indice); 
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),   
            ),           

            if (listaProdutos.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton.icon(
                    onPressed: salvarNotaNoBanco,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Nota no Banco', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}