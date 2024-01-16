import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_lints_test/src/helpers/gateway_checker.dart';

class ImplementAbstractGatewayLint extends DartLintRule {
  ImplementAbstractGatewayLint() : super(code: _code);

  final GatewayChecker gatewayChecker = GatewayChecker();

  static const _code = LintCode(
    name: 'implement_abstract_gateway',
    problemMessage: 'GatewayImpl should implement Gateway',
    correctionMessage: 'Implement Gateway class',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final bool isValidGatewayImpl = gatewayChecker.isValidGatewayImpl(node, ['Fake']);
      if (!isValidGatewayImpl) return;

      final String gatewayImplName = node.name.lexeme;
      final String gatewayName = gatewayImplName.replaceAll('Impl', '');
      final bool gatewayImplementationExists =
          node.implementsClause?.childEntities.firstWhere((element) => element.toString() == gatewayName) == null;

      if (gatewayImplementationExists) {
        reporter.reportErrorForToken(_code, node.name);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_ImplementAbstractGatewayFix()];
}

class _ImplementAbstractGatewayFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Implement Abstract Gateway class',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        final ImplementsClause? implementClause = node.implementsClause;
        final String gatewayImplName = node.name.lexeme;
        final String gatewayName = gatewayImplName.replaceAll('Impl', '');
        final String gatewayPath = gatewayName.replaceAll('Gateway', '');

        if (implementClause != null) return;

        builder.addSimpleInsertion(node.leftBracket.offset - 1, ' implements $gatewayName ');
        builder.importLibrary(
          Uri.parse('${gatewayPath.toLowerCase()}_gateway.dart'),
        );
      });
    });
  }
}
