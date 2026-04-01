# Security group for Prometheus and Grafana
# Allows access from bastion only for SSH
# Allows access from private instances for scraping
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Allow access to Prometheus and Grafana"
  vpc_id      = module.vpc.vpc_id

  # SSH from bastion only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Prometheus port - from private instances
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  # Grafana port - from vpc

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Node exporter port - from monitoring server
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# Prometheus and Grafana EC2 instance in private subnet
resource "aws_instance" "monitoring" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  
  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
    #!/bin/bash
    # Install Prometheus
    useradd --no-create-home --shell /bin/false prometheus
    mkdir /etc/prometheus
    mkdir /var/lib/prometheus
    wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
    tar xvf prometheus-2.45.0.linux-amd64.tar.gz
    cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
    cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/

    # Prometheus config - scrape all private instances
    cat > /etc/prometheus/prometheus.yml << 'PROMEOF'
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'node_exporter'
        static_configs:
          - targets:
            - '10.0.2.54:9100'
            - '10.0.2.228:9100'
            - '10.0.2.124:9100'
            - '10.0.2.64:9100'
            - '10.0.2.206:9100'
            - '10.0.2.128:9100'
    PROMEOF

    # Prometheus service
    cat > /etc/systemd/system/prometheus.service << 'SVCEOF'
    [Unit]
    Description=Prometheus
    After=network.target
    [Service]
    User=prometheus
    ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus
    [Install]
    WantedBy=multi-user.target
    SVCEOF

    chown prometheus:prometheus /usr/local/bin/prometheus
    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
    systemctl daemon-reload
    systemctl enable prometheus
    systemctl start prometheus

    # Install Grafana
    cat > /etc/yum.repos.d/grafana.repo << 'REPOEOF'
    [grafana]
    name=grafana
    baseurl=https://rpm.grafana.com
    repo_gpgcheck=1
    enabled=1
    gpgcheck=1
    gpgkey=https://rpm.grafana.com/gpg.key
    sslverify=1
    sslcacert=/etc/pki/tls/certs/ca-bundle.crt
    REPOEOF

    dnf install -y grafana
    systemctl daemon-reload
    systemctl enable grafana-server
    systemctl start grafana-server
  EOF

  tags = {
    Name = "monitoring-server"
  }
}

# Output the monitoring server private IP
output "monitoring_private_ip" {
  description = "Private IP of the monitoring server"
  value       = aws_instance.monitoring.private_ip
}
