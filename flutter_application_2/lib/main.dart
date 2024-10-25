import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _animationController.repeat(); // Inicia a animação
    });

    // Passo 4: Adicionar os dados ao Firestore
    try {
      await FirebaseFirestore.instance.collection('data').add({
        'text': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Após o envio, limpa o campo de texto e para a animação
      setState(() {
        _controller.clear();
        _isLoading = false;
        _animationController.stop(); // Para a animação
      });
    } catch (e) {
      // Tratar erros de Firestore aqui, se necessário
      setState(() {
        _isLoading = false;
        _animationController.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar Dados'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Digite algo'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitData, // Desabilita o botão durante o loading
                  child: Text('Enviar'),
                ),
                if (_isLoading)
                  RotationTransition(
                    turns: _animationController,
                    child: Icon(Icons.autorenew),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
