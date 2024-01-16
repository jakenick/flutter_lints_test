import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'helpers/gateway_checker.dart';

class ExtendHttpGatewayLint extends DartLintRule {
  ExtendHttpGatewayLint() : super(code: _code);

  final GatewayChecker gatewayChecker = GatewayChecker();

  static const _code = LintCode(
    name: 'extend_http_gateway',
    problemMessage: 'Gateway Implementation should extend HttpGateway',
    correctionMessage: 'Extend HttpGateway',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final bool isValidGatewayImpl = gatewayChecker.isValidGatewayImpl(node, ['HttpGateway', 'Fake']);
      if (!isValidGatewayImpl) return;

      reporter.reportErrorForToken(_code, node.name);
    });
  }

  @override
  List<Fix> getFixes() => [_ExtendHttpGatewayFix()];
}

class _ExtendHttpGatewayFix extends DartFix {
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
        message: 'Extend HttpGateway',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        final ClassElement? classOffset = node.declaredElement;
        final ClassElement? element = node.declaredElement;

        if (element == null || classOffset == null) return;

        builder.addSimpleInsertion(classOffset.nameOffset + classOffset.nameLength, ' extends HttpGateway');
        builder.addSimpleInsertion(node.beginToken.offset, 'final ');
        builder.importLibrary(
          Uri.parse('package:flutter_smb_platform/core/base_classes/http_gateway.dart'),
        );
      });
    });
  }
}
