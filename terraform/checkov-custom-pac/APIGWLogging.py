from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class APIGWLogging(BaseResourceCheck):
    def __init__(self):
        name = "aws_api_gateway_method_settings must have settings block with metrics_enabled, data_trace_enabled" \
               " and logging_level"
        id = "CKV_AWS_999"
        supported_resources = ['aws_api_gateway_method_settings']
        # CheckCategories are defined in models/enums.py
        categories = [CheckCategories.LOGGING]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
            Looks for logging configuration at aws_api_gateway_method_settings
        :param conf: aws_api_gateway_method_settings configuration
        :return: <CheckResult>
        """

        if 'settings' in conf.keys():
            conf_settings_block = conf['settings'][0]
            conf_settings_keys = conf_settings_block.keys()

            if not {"logging_level", "metrics_enabled", "data_trace_enabled"} <= conf_settings_keys:
                return CheckResult.FAILED

            if conf_settings_block['logging_level'][0] not in ["INFO"] \
                    or not conf_settings_block['metrics_enabled'][0] \
                    or not conf_settings_block['data_trace_enabled'][0]:
                return CheckResult.FAILED
            else:
                return CheckResult.PASSED

        return CheckResult.FAILED


scanner = APIGWLogging()
