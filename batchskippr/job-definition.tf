resource "aws_batch_job_definition" "test" {
  name = "skippr-job-definition"
  type = "container"
  container_properties = jsonencode({
    command = ["ls", "-la"],
    image   = "busybox"

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "252"
      },
      {
        type  = "MEMORY"
        value = "512"
      }
    ]

    volumes = [
      {
        host = {
          sourcePath = "/tmp"
        }
        name = "tmp"
      }
    ]

    environment = [
      {
        name  = "VARNAME"
        value = "VARVAL"
      }
    ]

    mountPoints = [
      {
        sourceVolume  = "tmp"
        containerPath = "/tmp"
        readOnly      = false
      }
    ]

    ulimits = [
      {
        hardLimit = 1024
        name      = "nofile"
        softLimit = 50000
      }
    ]
  })
}


resource "aws_cloudwatch_log_group" "log_group" {
  name       = "data-warehouse-${var.pipeline_name}"
  retention_in_days = 14
  skip_destroy = false
}

resource "aws_cloudwatch_log_stream" "skippr_ingest_stream" {
  name           = "${var.pipeline_name}-skippr-ingest-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}