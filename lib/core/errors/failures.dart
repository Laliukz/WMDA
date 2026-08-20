abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Error al conectar con el servidor o sitio web',
  ]);
}

class ScrapingFailure extends Failure {
  const ScrapingFailure([
    super.message = 'Error al obtener los archivos de la página',
  ]);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Error al almacenar el archivo']);
}

class InvalidUrlFailure extends Failure {
  const InvalidUrlFailure([super.message = 'URL no valida o no soportada']);
}
