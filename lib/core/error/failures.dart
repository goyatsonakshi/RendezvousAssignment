    // Define abstract class for failures
    abstract class Failure {
      final String message;
      Failure(this.message);
    }

    // Implementations of Failure
    class ServerFailure extends Failure {
      ServerFailure(String message) : super(message);
    }

    class CacheFailure extends Failure {
      CacheFailure(String message) : super(message);
    }

    class InvalidInputFailure extends Failure {
      InvalidInputFailure(String message) : super(message);
    }
    