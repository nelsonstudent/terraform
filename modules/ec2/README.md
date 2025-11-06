# Módulo Terraform - AWS EC2

Este módulo cria e gerencia instâncias EC2 na AWS com configuração completa de volumes, monitoramento e segurança.

## Recursos Criados

- ✅ Instância EC2 configurável
- ✅ Volume root customizável
- ✅ Volumes EBS adicionais (opcional)
- ✅ Elastic IP (opcional)
- ✅ CloudWatch Alarms (opcional)
- ✅ IMDSv2 habilitado por padrão
- ✅ Detailed Monitoring (opcional)
- ✅ User Data para bootstrap

## Exemplos de Uso

### Exemplo 1: Instância EC2 Básica

```hcl
module "ec2_basic" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 2: Instância com Key Pair para SSH

```hcl
module "ec2_with_ssh" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.small"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  key_name               = "minha-chave-ssh"
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 3: Instância com Volume Root Customizado

```hcl
module "ec2_custom_root" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  
  # Volume root customizado
  root_volume_type      = "gp3"
  root_volume_size      = 50
  root_volume_encrypted = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 4: Instância com Volumes EBS Adicionais

```hcl
module "ec2_with_ebs" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.large"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  
  # Volumes EBS adicionais
  ebs_block_devices = [
    {
      device_name = "/dev/sdf"
      volume_size = 100
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
      encrypted   = true
    },
    {
      device_name = "/dev/sdg"
      volume_size = 200
      volume_type = "gp3"
      encrypted   = true
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 5: Instância com User Data

```hcl
module "ec2_with_userdata" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.small"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  
  # User Data para bootstrap
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
  EOF
  
  user_data_replace_on_change = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 6: Instância com Elastic IP

```hcl
module "ec2_with_eip" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.small"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  
  # Associar Elastic IP
  associate_elastic_ip = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 7: Instância com CloudWatch Alarms

```hcl
module "ec2_monitored" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  
  # Monitoring
  enable_detailed_monitoring = true
  enable_cloudwatch_alarms   = true
  cpu_alarm_threshold        = 80
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 8: Instância T3 com CPU Credits Unlimited

```hcl
module "ec2_t3_unlimited" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  
  # CPU Credits unlimited para t3
  cpu_credits = "unlimited"
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 9: Instância de Produção Completa

```hcl
module "ec2_production" {
  source = "./modules/ec2"

  ami_id                 = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.large"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.app_server.id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  key_name               = "prod-key"
  
  # Root Volume
  root_volume_type      = "gp3"
  root_volume_size      = 100
  root_volume_encrypted = true
  
  # Additional EBS Volumes
  ebs_block_devices = [
    {
      device_name = "/dev/sdf"
      volume_size = 500
      volume_type = "gp3"
      iops        = 5000
      throughput  = 250
      encrypted   = true
    }
  ]
  
  # User Data
  user_data = file("${path.module}/scripts/bootstrap.sh")
  user_data_replace_on_change = false
  
  # Security
  require_imdsv2              = true
  disable_api_termination     = true
  ebs_optimized               = true
  
  # Monitoring
  enable_detailed_monitoring = true
  enable_cloudwatch_alarms   = true
  cpu_alarm_threshold        = 75
  
  project_name = "meu-projeto"
  environment  = "prod"
  
  additional_tags = {
    Application = "WebServer"
    CostCenter  = "Engineering"
    Backup      = "Daily"
  }
}
```

## Variáveis Principais

### Obrigatórias
- `ami_id` - AMI ID da instância
- `instance_type` - Tipo da instância (t3.micro, t3.small, etc)
- `subnet_id` - ID da subnet onde criar
- `vpc_security_group_ids` - Lista de security groups
- `iam_instance_profile` - Nome do instance profile IAM
- `project_name` - Nome do projeto
- `environment` - Ambiente (dev, staging, prod)

### Volume Root
- `root_volume_type` - Tipo do volume (gp2, gp3, io1, io2)
- `root_volume_size` - Tamanho em GB (padrão: 20)
- `root_volume_encrypted` - Criptografar volume (padrão: true)

### Volumes Adicionais
- `ebs_block_devices` - Lista de volumes EBS extras

### Networking
- `key_name` - Key pair para SSH
- `associate_elastic_ip` - Criar e associar Elastic IP

### Security
- `require_imdsv2` - Requer IMDSv2 (padrão: true)
- `disable_api_termination` - Proteção contra deleção
- `ebs_optimized` - Habilitar EBS optimized

### Monitoring
- `enable_detailed_monitoring` - Monitoring a cada 1 minuto
- `enable_cloudwatch_alarms` - Criar alarmes
- `cpu_alarm_threshold` - Threshold de CPU para alarme

### User Data
- `user_data` - Script de bootstrap
- `user_data_replace_on_change` - Recriar instância se user data mudar

## Outputs

### Instance Info
- `instance_id` - ID da instância
- `instance_arn` - ARN da instância
- `instance_state` - Estado da instância

### Networking
- `public_ip` - IP público
- `private_ip` - IP privado
- `public_dns` - DNS público
- `private_dns` - DNS privado
- `elastic_ip` - Elastic IP (se criado)

### Volume
- `root_block_device_volume_id` - ID do volume root

### Monitoring
- `cpu_alarm_arn` - ARN do alarme de CPU
- `status_check_alarm_arn` - ARN do alarme de status check

## Tipos de Instância Comuns

### Propósito Geral (T-family)
| Tipo | vCPU | RAM | Uso |
|------|------|-----|-----|
| t3.micro | 2 | 1 GB | Dev, testes |
| t3.small | 2 | 2 GB | Apps leves |
| t3.medium | 2 | 4 GB | Apps médios |
| t3.large | 2 | 8 GB | Apps pesados |

### Computação Otimizada (C-family)
| Tipo | vCPU | RAM | Uso |
|------|------|-----|-----|
| c6i.large | 2 | 4 GB | CPU intensivo |
| c6i.xlarge | 4 | 8 GB | Processamento |
| c6i.2xlarge | 8 | 16 GB | Alto desempenho |

### Memória Otimizada (R-family)
| Tipo | vCPU | RAM | Uso |
|------|------|-----|-----|
| r6i.large | 2 | 16 GB | Databases em memória |
| r6i.xlarge | 4 | 32 GB | Cache, analytics |
| r6i.2xlarge | 8 | 64 GB | Big data |

## User Data Examples

### Instalar Docker
```bash
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
```

### Instalar Node.js
```bash
#!/bin/bash
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs
npm install -g pm2
```

### Instalar Nginx
```bash
#!/bin/bash
amazon-linux-extras install -y nginx1
systemctl start nginx
systemctl enable nginx
```

## IMDSv2 (Instance Metadata Service v2)

O módulo habilita IMDSv2 por padrão para segurança aprimorada:

```hcl
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"  # IMDSv2
  http_put_response_hop_limit = 1
}
```

Para acessar metadata com IMDSv2:
```bash
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/
```

## Boas Práticas

1. **AMI**: Use AMIs oficiais e atualizadas
2. **Volumes**: Sempre criptografe volumes em produção
3. **Key Pairs**: Use AWS Systems Manager Session Manager ao invés de SSH
4. **IMDSv2**: Mantenha habilitado para segurança
5. **Termination Protection**: Habilite em produção
6. **Monitoring**: Use detailed monitoring em produção
7. **Tags**: Tag adequadamente para gestão e custos
8. **Backup**: Configure AWS Backup ou snapshots automáticos

## Notas Importantes

1. **T-family Credits**: 
   - `standard`: CPU burst baseado em credits
   - `unlimited`: Performance consistente, custo adicional

2. **EBS Optimized**: Automaticamente habilitado para instâncias modernas

3. **User Data**: Executado apenas no primeiro boot, a menos que `user_data_replace_on_change = true`

4. **Elastic IP**: Cobrado quando não associado a uma instância em execução

5. **Detailed Monitoring**: CloudWatch metrics a cada 1 minuto (vs 5 minutos padrão) - custo adicional
