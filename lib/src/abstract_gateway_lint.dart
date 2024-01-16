import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_lints_test/src/helpers/gateway_checker.dart';

class AbstractGatewayLint extends DartLintRule {
  AbstractGatewayLint() : super(code: _code);

  final GatewayChecker gatewayChecker = GatewayChecker();

  static const _code = LintCode(
    name: 'gateway_abstract_declaration',
    problemMessage: 'Gateway should be declared as abstract',
    correctionMessage: 'Add abstract declaration',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final bool isValidGateway = gatewayChecker.isValidGateway(node, ['Fake']);
      final Token? abstractToken = node.abstractKeyword;

      // Return if class is Base, class has abstract token, or not Gateway class
      if (abstractToken != null || !isValidGateway) return;

      reporter.reportErrorForToken(_code, node.name);
    });
  }

  @override
  List<Fix> getFixes() => [_AbstractGatewayFix()];
}

class _AbstractGatewayFix extends DartFix {
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
        message: 'Make Gateway abstract',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        final Token classToken = node.classKeyword;
        final bool? isAbstract = node.declaredElement?.isAbstract;

        if (isAbstract == true) return;

        builder.addSimpleInsertion(classToken.offset, 'abstract ');
      });
    });
  }
}
