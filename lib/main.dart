import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() => runApp(const SistemaEstoque());

class SistemaEstoque extends StatelessWidget {
  const SistemaEstoque({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MenuPrincipal(),
    );
  }
}

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});
  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _id = -1;

  void _confirmarLimpeza() {
    TextEditingController _s = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("SENHA REQUERIDA"),
      content: TextField(controller: _s, obscureText: true, decoration: const InputDecoration(labelText: "Senha admin")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(onPressed: () async {
          if (_s.text == "Hugo4000x") {
            await http.delete(Uri.parse('http://192.168.0.24:8000/api/reset'));
            Navigator.pop(context); setState(() => _id = -1);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Banco de dados reiniciado!"), backgroundColor: Colors.orange));
          }
        }, child: const Text("LIMPAR"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_id == -1 ? "Estoque" : ["Notas", "Estoque", "Histórico", "Ajuste"][_id])),
      drawer: Drawer(
        child: Column(children: [
          const DrawerHeader(decoration: BoxDecoration(color: Colors.blue), child: Center(child: Text('ESTOQUE', style: TextStyle(color: Colors.white, fontSize: 24)))),
          ListTile(leading: const Icon(Icons.add_box), title: const Text('Lançamentos'), onTap: () { setState(() => _id = 0); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.inventory), title: const Text('Ver Estoque'), onTap: () { setState(() => _id = 1); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.history), title: const Text('Histórico'), onTap: () { setState(() => _id = 2); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.build_circle), title: const Text('Ajuste Inicial'), onTap: () { setState(() => _id = 3); Navigator.pop(context); }),
          const Spacer(),
          ListTile(leading: const Icon(Icons.delete_forever, color: Colors.red), title: const Text('RESETAR'), onTap: () { Navigator.pop(context); _confirmarLimpeza(); }),
        ]),
      ),
      body: _id == -1 ? _welcome() : [const TelaEntrada(), const TelaEstoque(), const TelaHistorico(), const TelaAjuste()][_id],
    );
  }

  Widget _welcome() => const Center(child: Text("Bem-vindo! Selecione uma opção no menu."));
}

class TelaEntrada extends StatefulWidget {
  const TelaEntrada({super.key});
  @override
  State<TelaEntrada> createState() => _TelaEntradaState();
}

class _TelaEntradaState extends State<TelaEntrada> {
  String tipo = 'Entrada';
  final TextEditingController cN = TextEditingController(), cC = TextEditingController(), cT = TextEditingController(), cCod = TextEditingController(), cQ = TextEditingController();
  final FocusNode fN = FocusNode(), fC = FocusNode(), fT = FocusNode(), fCod = FocusNode(), fQ = FocusNode();
  List<dynamic> itens = [];
  bool _enviando = false;

  void add() {
    if (itens.any((i) => i['nome'] == cCod.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Código duplicado na nota!"), backgroundColor: Colors.orange));
      return;
    }
    if (cCod.text.isNotEmpty && cQ.text.isNotEmpty) {
      setState(() => itens.add({'nome': cCod.text, 'qtd': cQ.text}));
      cCod.clear(); cQ.clear(); FocusScope.of(context).requestFocus(fCod);
    }
  }

  Future<void> enviar() async {
    if (_enviando) return;
    setState(() => _enviando = true);

    try {
      var res = await http.post(Uri.parse('http://192.168.0.24:8000/api/notas'), headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tipo": tipo.toLowerCase(), "numero_nf": int.parse(cN.text), "cliente": cC.text, "quantidade": int.parse(cT.text), "itens": itens.map((i) => {"codigo": int.parse(i['nome']), "quantidade": int.parse(i['qtd'])}).toList()}));
      
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Nota enviada com sucesso!"), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
        
        setState(() {
          itens.clear(); cN.clear(); cC.clear(); cT.clear();
          _enviando = false;
        });
        FocusScope.of(context).requestFocus(fN);
      } else {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: ${jsonDecode(res.body)['detail']}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro de conexão!"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(15), child: Column(children: [
      Row(children: [
        DropdownButton<String>(value: tipo, items: ['Entrada', 'Saída'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => tipo = v!)),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: cN, focusNode: fN, decoration: const InputDecoration(labelText: 'NF'), onSubmitted: (_) => FocusScope.of(context).requestFocus(fC), keyboardType: TextInputType.number)),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: cC, focusNode: fC, decoration: const InputDecoration(labelText: 'Cliente'), onSubmitted: (_) => FocusScope.of(context).requestFocus(fT))),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: cT, focusNode: fT, decoration: const InputDecoration(labelText: 'Total'), onSubmitted: (_) => FocusScope.of(context).requestFocus(fCod), keyboardType: TextInputType.number)),
      ]),
      const Divider(height: 30),
      Row(children: [
        Expanded(flex: 2, child: TextField(controller: cCod, focusNode: fCod, decoration: const InputDecoration(labelText: 'Código'), onSubmitted: (_) => FocusScope.of(context).requestFocus(fQ), keyboardType: TextInputType.number)),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: cQ, focusNode: fQ, decoration: const InputDecoration(labelText: 'Qtd'), onSubmitted: (_) => add(), keyboardType: TextInputType.number)),
        ElevatedButton(onPressed: add, child: const Icon(Icons.add))
      ]),
      Expanded(child: ListView.builder(itemCount: itens.length, itemBuilder: (c, i) => ListTile(title: Text("Cód: ${itens[i]['nome']}"), trailing: Text("Qtd: ${itens[i]['qtd']}")))),
      if (itens.isNotEmpty) 
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(onPressed: _enviando ? null : enviar, icon: const Icon(Icons.save), label: const Text("SALVAR NOTA"))
        )
    ]));
  }
}

class TelaEstoque extends StatefulWidget {
  const TelaEstoque({super.key});
  @override
  State<TelaEstoque> createState() => _TelaEstoqueState();
}

class _TelaEstoqueState extends State<TelaEstoque> {
  String f = ""; bool cres = true;

  void _abrirEdicao(int codigo, int qtdAtual) {
    TextEditingController _cont = TextEditingController(text: qtdAtual.toString());
    showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Editar Cód $codigo"),
        content: TextField(controller: _cont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Nova Qtd")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () async {
              await http.post(Uri.parse('http://192.168.0.24:8000/api/estoque/editar'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"codigo": codigo, "quantidade": int.parse(_cont.text)}));
              Navigator.pop(context); setState(() {});
            }, child: const Text("Salvar"))
        ],
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(10), child: Row(children: [
        Expanded(child: TextField(decoration: const InputDecoration(hintText: "Filtrar por código...", prefixIcon: Icon(Icons.search)), onChanged: (v) => setState(() => f = v))),
        IconButton(icon: Icon(cres ? Icons.arrow_downward : Icons.arrow_upward), onPressed: () => setState(() => cres = !cres))
      ])),
      Expanded(child: FutureBuilder(
        future: http.get(Uri.parse('http://192.168.0.24:8000/api/estoque')),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          List d = jsonDecode(snap.data!.body);
          List filt = d.where((i) => i['codigo'].toString().contains(f)).toList();
          filt.sort((a, b) => cres ? a['quantidade'].compareTo(b['quantidade']) : b['quantidade'].compareTo(a['quantidade']));
          return ListView.builder(itemCount: filt.length, itemBuilder: (c, i) {
            int q = filt[i]['quantidade']; bool b = q <= 5;
            return ListTile(
              tileColor: b ? Colors.red[50] : null,
              leading: Icon(Icons.inventory, color: b ? Colors.red : Colors.blue),
              title: Text("Cód: ${filt[i]['codigo']}", style: TextStyle(fontWeight: b ? FontWeight.bold : FontWeight.normal, color: b ? Colors.red : Colors.black)),
              trailing: Text("$q un", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: b ? Colors.red : Colors.blue)),
              onTap: () => _abrirEdicao(filt[i]['codigo'], q),
            );
          });
        },
      ))
    ]);
  }
}

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});
  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  String fNota = ""; String fCliente = ""; String fProduto = ""; DateTime? fData;
  List<dynamic> todasNotas = []; bool carregando = true;

  @override
  void initState() { super.initState(); buscarDados(); }

  Future<void> buscarDados() async {
    try {
      final res = await http.get(Uri.parse('http://192.168.0.24:8000/api/historico'));
      if (res.statusCode == 200) setState(() { todasNotas = jsonDecode(res.body); carregando = false; });
    } catch (e) { setState(() => carregando = false); }
  }

  List<dynamic> filtrarNotas() {
    return todasNotas.where((nota) {
      final bn = fNota.isEmpty || nota['numero_nf'].toString().contains(fNota);
      final bc = fCliente.isEmpty || nota['cliente'].toString().toLowerCase().contains(fCliente.toLowerCase());
      bool bd = true;
      if (fData != null) {
        String df = "${fData!.day.toString().padLeft(2, '0')}/${fData!.month.toString().padLeft(2, '0')}/${fData!.year}";
        bd = nota['data'].toString().contains(df);
      }
      final bp = fProduto.isEmpty || (nota['itens'] as List).any((it) => it['codigo'].toString().contains(fProduto));
      return bn && bc && bd && bp;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List fil = filtrarNotas();
    return Column(children: [
      Container(padding: const EdgeInsets.all(10), color: Colors.grey[100], child: Column(children: [
          Row(children: [
            Expanded(child: TextField(decoration: const InputDecoration(labelText: "NF"), onChanged: (v) => setState(() => fNota = v))),
            const SizedBox(width: 10),
            Expanded(child: TextField(decoration: const InputDecoration(labelText: "Cliente"), onChanged: (v) => setState(() => fCliente = v))),
          ]),
          Row(children: [
            Expanded(child: TextField(decoration: const InputDecoration(labelText: "Cód Prod"), onChanged: (v) => setState(() => fProduto = v))),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_month, color: fData != null ? Colors.blue : Colors.grey),
              label: Text(fData == null ? "Data" : "${fData!.day}/${fData!.month}"),
              onPressed: () async {
                DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2025), lastDate: DateTime(2030));
                setState(() => fData = p);
              },
            ),
            if (fData != null) IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => fData = null)),
          ]),
        ])),
      Expanded(child: carregando ? const Center(child: CircularProgressIndicator()) : ListView.builder(
          itemCount: fil.length, itemBuilder: (c, i) => ExpansionTile(
            leading: Icon(fil[i]['tipo'] == 'entrada' ? Icons.login : Icons.logout, color: fil[i]['tipo'] == 'entrada' ? Colors.green : Colors.red),
            title: Text("NF: ${fil[i]['numero_nf']} - ${fil[i]['cliente']}"),
            subtitle: Text(fil[i]['data']),
            children: (fil[i]['itens'] as List).map((it) => ListTile(title: Text("Cód: ${it['codigo']}"), trailing: Text("${it['quantidade']} un"))).toList(),
          ))),
    ]);
  }
}

class TelaAjuste extends StatefulWidget {
  const TelaAjuste({super.key});
  @override
  State<TelaAjuste> createState() => _TelaAjusteState();
}

class _TelaAjusteState extends State<TelaAjuste> {
  final TextEditingController _c = TextEditingController(), _q = TextEditingController();
  final FocusNode _fc = FocusNode(), _fq = FocusNode();

  Future<void> ajustar() async {
    if (_c.text.isEmpty || _q.text.isEmpty) return;
    try {
      await http.post(Uri.parse('http://192.168.0.24:8000/api/ajuste'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"codigo": int.parse(_c.text), "quantidade": int.parse(_q.text)}));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Ajuste realizado!"), backgroundColor: Colors.blue));
      _c.clear(); _q.clear(); FocusScope.of(context).requestFocus(_fc);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao ajustar!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(30), child: Column(children: [
      TextField(controller: _c, focusNode: _fc, decoration: const InputDecoration(labelText: 'Código'), onSubmitted: (_) => FocusScope.of(context).requestFocus(_fq), keyboardType: TextInputType.number),
      const SizedBox(height: 10),
      TextField(controller: _q, focusNode: _fq, decoration: const InputDecoration(labelText: 'Quantidade'), onSubmitted: (_) => ajustar(), keyboardType: TextInputType.number),
      const SizedBox(height: 30),
      ElevatedButton(onPressed: ajustar, child: const Text("ENVIAR AJUSTE")),
    ]));
  }
}