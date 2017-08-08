resource "aws_ecr_repository" "liveobs" {
  name = "liveobs"
}

output "liveobs-ecr_url" {
  value = "${aws_ecr_repository.liveobs.repository_url}"
}
