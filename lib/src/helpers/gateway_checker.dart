import 'package:analyzer/dart/ast/ast.dart';

class GatewayChecker {
  final String _gatewayClassSuffix = 'Gateway';
  final String _gatewayClassImplSuffix = 'GatewayImpl';

  bool isValidGateway(ClassDeclaration node, List<String> ignoreDeclarations) {
    if (_isBase(node) || !_isValidClass(node, _gatewayClassSuffix) || _isIgnored(node, ignoreDeclarations)) {
      return false;
    }

    return true;
  }

  bool isValidGatewayImpl(ClassDeclaration node, List<String> ignoreDeclarations) {
    if (_isBase(node) || !_isValidClass(node, _gatewayClassImplSuffix) || _isIgnored(node, ignoreDeclarations)) {
      return false;
    }

    return true;
  }

  bool _isValidClass(ClassDeclaration node, String suffix) => node.name.lexeme.endsWith(suffix);
  bool _isBase(ClassDeclaration node) => node.baseKeyword == null ? false : true;
  String _extendsDisplayName(ClassDeclaration node) => node.extendsClause?.superclass.element?.displayName ?? '';
  bool _isIgnored(ClassDeclaration node, List<String> ignoreDeclarations) =>
      ignoreDeclarations.contains(_extendsDisplayName(node));
}

/// Return false if is base class, contains ignored declaration names
// bool _validGateway(ClassDeclaration node) {
//   // Ignore if HttpGateway already exists, or is test Fake
//   final List<String> ignoreDeclarations = ['HttpGateway', 'Fake'];
//   final bool isGatewayImplClass = node.name.lexeme.endsWith('GatewayImpl');
//   final Token? isBase = node.baseKeyword;
//   final String? extendsDisplayName = node.extendsClause?.superclass.element?.displayName;
//   final bool isIgnored = ignoreDeclarations.contains(extendsDisplayName.toString());
//
//   if (isBase != null || !isGatewayImplClass || isIgnored) {
//     return false;
//   }
//
//   return true;
// }
