packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  region        = "us-east-1"
  instance_type = "t2.micro"
  ami_name      = "devops-assignment8-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.amazon-linux"]

  provisioner "shell" {
    inline = [
      "sudo dnf install -y docker",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",
      "mkdir -p /home/ec2-user/.ssh",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKcsfr+jebFaGYNvXtnNwj5o7c9JOiW/MKHRg4K0uIoKS/a/lDVVFIAk+uuekTZ1yrGdRJreq6T/v4VGnbKIFfFZgCBj11oopeXZeS2a8vRTbLsBwykCh31CAiEoaInd8CxZwChGCdZdc/nnBM4o9sanKgepsBdVEkHcE04Ud+z6XzmrG9OXpqAKmWA0CsMFlIPqQuhlYv8SEAX4n0EHXNgBuCpA1J5qKmj8x/Y4RB7mRRyS2fkODgQ3SlGD2Y52H3TJFK/ciMmmnETI3WM6sAuIWlpW/Qz7YURPreb+B/qPGMTS+KEuXoeeex0RtTn2+uKD0YQd3vbO+FZRQX1mQ20DgRHbNh9lKksGAoktOq4nPxacX1S3n1vlPiIYiGxg9EyZ/HNPpU+q1Qe5AqJpzouGekvXOxvfBcoS3sOFpZz/dAx/Qzcl3eaP0AIi5Ao/Sf6Ts1/u5nXv/G92CVnnsxBK0NaJarok4+ALp/1VqbEXO1DVstEcF4hFH6CEV7pbXdwrDC2L0E5/tS7luVcPejwThYLPA7UvhzVk5hb6vUe3/PL/Utqp515HLqjEoHrFdWznD7kWV+6/sWx6gWMhzlabQJczAOnG0qsk73HQFyJQPyBP/aIpZSP1YMc0MSiCKPk5JGPrknG7Ai4o1h4EFqvMx4u05jWRfjzO53W4U4yw== maryamtendo@MacBook-Pro-6.local' >> /home/ec2-user/.ssh/authorized_keys",
      "chmod 700 /home/ec2-user/.ssh",
      "chmod 600 /home/ec2-user/.ssh/authorized_keys"
    ]
  }
}
