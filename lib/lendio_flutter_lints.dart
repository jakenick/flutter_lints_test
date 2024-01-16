import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_lints_test/src/abstract_gateway_lint.dart';
import 'package:flutter_lints_test/src/extend_http_gateway_lint.dart';
import 'package:flutter_lints_test/src/implement_abstract_gateway_lint.dart';

PluginBase createPlugin() => _MyLintsPlugin();

class _MyLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs _) => [
        AbstractGatewayLint(),
        ExtendHttpGatewayLint(),
        ImplementAbstractGatewayLint(),
      ];
}
