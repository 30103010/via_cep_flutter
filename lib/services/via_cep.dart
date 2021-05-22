import 'dart:async';
import 'dart:convert';

import 'package:via_cep_flutter/enum.dart';
import 'package:via_cep_flutter/error.dart';
import 'package:via_cep_flutter/models/cep.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic> analyzeAndParseResponse(http.Response response) {
  if (response.statusCode == 200) return json.decode(response.body);

  throw SimpleError('Erro ao se conectar com o serviço ViaCEP');
}

Map<String, dynamic> checkForViaCepError(Map<String, dynamic> responseObject) {
  if (responseObject['erro'] == true) {
    throw SimpleError('CEP não encontrado na base do ViaCEP.');
  }

  return responseObject;
}

Cep extractCepValuesFromResponse(Map<String, dynamic> responseObject) {
  return Cep(
    responseObject['cep'].replaceFirst('-', ''),
    responseObject['uf'],
    responseObject['localidade'],
    responseObject['logradouro'],
    responseObject['bairro'],
  );
}

Future<Cep> fetchViaCepService(String cepWithLeftPad) async {
  final url = Uri.parse('https://viacep.com.br/ws/$cepWithLeftPad/json/');
  late Cep resposta;
  try {
    final httpresponse = await http.get(
      url,
      headers: {
        'content-type': 'application/json;charset=utf-8',
      },
    );
    final analyze = analyzeAndParseResponse(httpresponse);
    resposta = extractCepValuesFromResponse(analyze);
  } catch (e) {
    final String? message = e is SimpleError
        ? e.message
        : 'Erro ao se conectar com o serviço ViaCEP.';

    throw ServiceError(
      service: Service.ViaCEP,
      message: message,
    );
  }

  return resposta;
}
