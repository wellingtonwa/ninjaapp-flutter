class InformacaoBitrix {
  String? id;
  String? idEtapa;
  List<String>? tag;
  String? titulo;
  String? descricao;
  String? prioridade;
  String? createdDate;
  String? codigoCliente;

  InformacaoBitrix.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    tag = (json['tag'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    titulo = json['title'] as String?;
    descricao = json['description'] as String?;
    prioridade = json['priority'] as String?;
    createdDate = json['createdDate'] as String?;
    codigoCliente = json['ufAuto675766807491'] as String?;
    idEtapa = json['stageId'] as String?;
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'InformacaoBitrix{id: $id, titulo: $titulo}';
  }
}