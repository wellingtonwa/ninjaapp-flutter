class NinjaappConfiguracao {
  int? id;
  String? postgresUrl;
  String? postgresPort;
  String? postgresUser;
  String? postgresPassword;
  String? taskFolder;
  String? backupFolder;
  String? bitrixUrl;
  bool? isPostgresOnDocker;
  String? postgresContainerName;

  NinjaappConfiguracao(
      {this.id,
      this.postgresUrl,
      this.postgresPort,
      this.postgresUser,
      this.postgresPassword,
      this.taskFolder,
      this.backupFolder,
      this.bitrixUrl,
      this.isPostgresOnDocker,
      this.postgresContainerName});

  NinjaappConfiguracao.empty();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'postgres_url': postgresUrl,
      'postgres_port': postgresPort ?? '5432',
      'postgres_user': postgresUser,
      'postgres_password': postgresPassword,
      'task_folder': taskFolder,
      'backup_folder': backupFolder,
      'bitrix_url': bitrixUrl,
      'postgres_container': isPostgresOnDocker! ? 1 : 0,
      'postgres_container_name': postgresContainerName
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  NinjaappConfiguracao.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'] as int?;
    postgresUrl = map['postgres_url'] as String?;
    postgresPort = map['postgres_port'] as String?;
    postgresUser = map['postgres_user'] as String?;
    postgresPassword = map['postgres_password'] as String?;
    taskFolder = map['task_folder'] as String?;
    backupFolder = map['backup_folder'] as String?;
    bitrixUrl = map['bitrix_url'] as String?;
    isPostgresOnDocker = map['postgres_container'] == 1;
    postgresContainerName = map['postgres_container_name'] as String?;
  }

  void copyWith(
      {int? id,
      String? postgresUrl,
      String? postgresPort,
      String? postgresUser,
      String? postgresPassword,
      String? taskFolder,
      String? backupFolder,
      String? bitrixUrl,
      bool? isPostgresOnDocker,
      String? postgresContainerName}) {
    this.id = id ?? this.id;
    this.postgresUrl = postgresUrl ?? this.postgresUrl;
    this.postgresPort = postgresPort ?? this.postgresPort;
    this.postgresUser = postgresUser ?? this.postgresUser;
    this.postgresPassword = postgresPassword ?? this.postgresPassword;
    this.taskFolder = taskFolder ?? this.taskFolder;
    this.backupFolder = backupFolder ?? this.backupFolder;
    this.isPostgresOnDocker = isPostgresOnDocker ?? this.isPostgresOnDocker;
    this.postgresContainerName =
        postgresContainerName ?? this.postgresContainerName;
    this.bitrixUrl = bitrixUrl ?? this.bitrixUrl;
  }
}
