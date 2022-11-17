import 'package:gql_http_link/gql_http_link.dart';
import 'package:ferry/ferry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final clientProvider = Provider<Client>((ref) => clientCreator(ref));

Client clientCreator(Ref ref) {
  final cache = Cache(
    typePolicies: {
      'UnconventionalRootQuery': TypePolicy(
        queryType: false,
      ),
    },
  );

  final link = HttpLink("https://toll-server-project.herokuapp.com/graphql");
  return Client(link: link, cache: cache);
}
