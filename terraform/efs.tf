resource "aws_efs_file_system" "efs" {
  creation_token = var.EFS_TOKEN
  #  encrypted      = false
  tags = {
    Name = "EFS"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id  = aws_efs_file_system.efs.id
  count           = length(aws_subnet.aws_s23_subnet_az.*.id)
  subnet_id       = element(aws_subnet.aws_s23_subnet_az.*.id, count.index)
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs.id
}
