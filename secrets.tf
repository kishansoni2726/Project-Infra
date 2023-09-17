resource "aws_secretsmanager_secret" "database_username" {
  name                                = "Username"
}

data "template_file" "username" {
    template                           = file("secret_username.json")
}

resource "aws_secretsmanager_secret_version" "database_username_version" {
    secret_id                           = aws_secretsmanager_secret.database_username.id
    secret_string                       = data.template_file.username.rendered
}

resource "aws_secretsmanager_secret" "database_password" {
    name                                = "password"
}

data "template_file" "password" {
    template                            = file("secret_password.json")
}

resource "aws_secretsmanager_secret_version" "database_password_version" {
    secret_id                           = aws_secretsmanager_secret.database_password.id
    secret_string                       = data.template_file.password.rendered
}