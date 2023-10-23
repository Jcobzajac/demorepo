module "batchskippr" {
source = "./batchskippr"
vpc_id = "vpc-0bc17936d18b65c6c"
pipeline_name = "skippr-enriched-v3"
skippr_api_key_secret_arn = "41151515151"
include_optional_statement = true
}