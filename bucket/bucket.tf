provider "aws" {
  region = "eu-central-1"
}

output "key_id" {
  value = aws_iam_access_key.backup_user_key.id
}

output "secret" {
  value = aws_iam_access_key.backup_user_key.secret
}


output "arn" {
  value = aws_s3_bucket.wp_migrations.arn
}

resource "aws_iam_user" "backup_user" {
  name = "backup_user"
}

resource "aws_s3_bucket" "wp_migrations" {
  bucket = "lamamind-wp-migrations"
}

resource "aws_iam_access_key" "backup_user_key" {
    user = aws_iam_user.backup_user.name
}

resource "aws_iam_user_policy" "rw_policy" {
  name = "rw_policy"
  user = aws_iam_user.backup_user.name
  policy = templatefile("${path.module}/policy.json.tpl",
    {
      arn = aws_s3_bucket.wp_migrations.arn
    })
}
