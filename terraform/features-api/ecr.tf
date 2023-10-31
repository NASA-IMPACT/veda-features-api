module "ecr_registry_wfs" {
  source                   = "github.com/developmentseed/tf-seed/modules/aws_ecr"
  environment              = var.env
  registry_name            = var.project_name
  enable_registry_scanning = true
  mutable_image_tags       = true
  enable_deploy_user       = false
  iam_deploy_username = null
  tags                     = var.tags
}

module "ecr_registry_db" {
  source                   = "github.com/developmentseed/tf-seed/modules/aws_ecr"
  environment              = var.env
  registry_name            = "${var.project_name}-db"
  enable_registry_scanning = true
  mutable_image_tags       = true
  enable_deploy_user       = false
  iam_deploy_username = null
  tags                     = var.tags
}

resource "null_resource" "build_ecr_image_wfs" {
  triggers = {
    folder_path = sha1(join("", [for f in fileset("../../wfs3-app", "**") : filesha1("../../wfs3-app/${f}")]))
    # handler_file_path = filemd5("../../wfs3-app/fast_api_main.py")
    # docker_file_path  = filemd5("../../wfs3-app/Dockerfile")
  }

  provisioner "local-exec" {
    command = <<EOF
          cd ../../wfs3-app
          aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${module.ecr_registry_wfs.repository_url}
          docker build -t ${module.ecr_registry_wfs.repository_url}:latest .
          docker push ${module.ecr_registry_wfs.repository_url}:latest
          cd -
       EOF
  }
}

resource "null_resource" "build_ecr_image_db_init" {
  triggers = {
    folder_path = sha1(join("", [for f in fileset("../../db", "**") : filesha1("../../db/${f}")]))
    # handler_file_path = filemd5("../../db/handler.py")
    # docker_file_path  = filemd5("../../db/Dockerfile")
  }

  provisioner "local-exec" {
    command = <<EOF
          cd ../../db
          aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${module.ecr_registry_db.repository_url}
          docker build -t ${module.ecr_registry_db.repository_url}:latest .
          docker push ${module.ecr_registry_db.repository_url}:latest
          cd -
       EOF
  }
}