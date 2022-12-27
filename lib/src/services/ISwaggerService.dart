// Interface to perform Swagger registrations.
abstract class ISwaggerService {
  //Perform required Swagger registration steps.
  void registerOpenApiSpec(String? baseRoute, String? swaggerRoute);
}
