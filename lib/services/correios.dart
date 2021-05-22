import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:via_cep_flutter/enum.dart';
import 'package:via_cep_flutter/error.dart';
import 'package:via_cep_flutter/models/cep.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

String? translateErrorMessage(Map<String, dynamic> errorResponse) {
  try {
    return errorResponse['soap:Envelope']['soap:Body']['soap:Fault']
        ['faultstring'];
  } catch (e) {
    throw SimpleError('Erro ao se conectar com o serviço Correios');
  }
}

Map<String, dynamic> analyzeAndParseResponse(http.Response response) {
  final Xml2Json xml2json = Xml2Json();

  xml2json.parse(response.body);
  final String content = xml2json.toParker();
  final result = json.decode(content);

  if (response.statusCode == 200) {
    return result;
  }

  final String? errorMessage = translateErrorMessage(result);

  throw SimpleError(errorMessage);
}

Cep extractValuesFromSuccessResponse(Map<String, dynamic> response) {
  try {
    final responseReturn = response['soap:Envelope']['soap:Body']
        ['ns2:consultaCEPResponse']['return'];

    return Cep(
      responseReturn['cep'],
      responseReturn['uf'],
      responseReturn['cidade'],
      responseReturn['end'],
      responseReturn['bairro'],
    );
  } catch (e) {
    throw SimpleError('Não foi possível interpretar a resposta.');
  }
}

Future<Cep> fetchCorreiosService(String cepWithLeftPad) async {
  final url = Uri.parse(
      'https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente');

  late Cep resposta;

  final httpresponse = await http.post(
    url,
    headers: {
      'Content-Type': 'text/xml;charset=UTF-8',
      'cache-control': 'no-cache',
    },
    body:
        '<?xml version="1.0"?>\n<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cli="http://cliente.bean.master.sigep.bsb.correios.com.br/">\n  <soapenv:Header />\n  <soapenv:Body>\n    <cli:consultaCEP>\n      <cep>$cepWithLeftPad</cep>\n    </cli:consultaCEP>\n  </soapenv:Body>\n</soapenv:Envelope>',
  );

  try {
    final analyze = analyzeAndParseResponse(httpresponse);

    resposta = extractValuesFromSuccessResponse(analyze);
  } catch (e) {
    final String? message = e is SimpleError
        ? e.message
        : 'Erro ao se conectar com o serviço Correios.';

    throw ServiceError(
      service: Service.Correios,
      message: message,
    );
  }

  return resposta;
}
