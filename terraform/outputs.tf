output "apigw_invoke_url_full" {
  value = "${aws_api_gateway_stage.this.invoke_url}/${aws_api_gateway_resource.calc.path_part}/"
}
