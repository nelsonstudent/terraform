# Módulo Terraform - AWS DynamoDB

Este módulo cria e gerencia tabelas DynamoDB na AWS com recursos avançados de índices, streams, backup e auto scaling.

## Recursos Criados

- ✅ Tabela DynamoDB com configuração completa
- ✅ Global Secondary Indexes (GSI)
- ✅ Local Secondary Indexes (LSI)
- ✅ DynamoDB Streams
- ✅ Point-in-Time Recovery (PITR)
- ✅ Time To Live (TTL)
- ✅ Auto Scaling (para modo PROVISIONED)
- ✅ Global Tables (replicação multi-região)
- ✅ Criptografia server-side com KMS
- ✅ CloudWatch Alarms para throttling

## Billing Modes

| Modo                | Uso Recomendado                      | Custo                            | Escalabilidade         |
|---------------------|--------------------------------------|----------------------------------|------------------------|
| **PAY_PER_REQUEST** | Tráfego imprevisível ou intermitente | Pago por requisição              | Automática             |
| **PROVISIONED**     | Tráfego previsível e constante       | Pago por capacidade provisionada | Manual ou Auto Scaling |

## Tipos de Atributos

- **S** - String
- **N** - Number
- **B** - Binary

## Exemplos de Uso

### Exemplo 1: Tabela Básica (On-Demand)

```hcl
module "dynamodb_basic" {
  source = "./modules/dynamodb"

  table_name   = "usuarios"
  hash_key     = "user_id"
  billing_mode = "PAY_PER_REQUEST"
  
  attributes = [
    {
      name = "user_id"
      type = "S"
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 2: Tabela com Hash e Range Key

```hcl
module "dynamodb_hash_range" {
  source = "./modules/dynamodb"

  table_name   = "pedidos"
  hash_key     = "user_id"
  range_key    = "order_date"
  billing_mode = "PAY_PER_REQUEST"
  
  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "order_date"
      type = "N"
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 3: Tabela com Global Secondary Index

```hcl
module "dynamodb_with_gsi" {
  source = "./modules/dynamodb"

  table_name   = "produtos"
  hash_key     = "product_id"
  billing_mode = "PAY_PER_REQUEST"
  
  attributes = [
    {
      name = "product_id"
      type = "S"
    },
    {
      name = "category"
      type = "S"
    },
    {
      name = "price"
      type = "N"
    }
  ]
  
  # Global Secondary Index para consultar por categoria
  global_secondary_indexes = [
    {
      name            = "category-price-index"
      hash_key        = "category"
      range_key       = "price"
      projection_type = "ALL"
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 4: Tabela Provisioned com Auto Scaling

```hcl
module "dynamodb_provisioned" {
  source = "./modules/dynamodb"

  table_name   = "sessoes"
  hash_key     = "session_id"
  billing_mode = "PROVISIONED"
  
  # Capacidade base
  read_capacity  = 5
  write_capacity = 5
  
  attributes = [
    {
      name = "session_id"
      type = "S"
    }
  ]
  
  # Auto Scaling
  autoscaling_enabled           = true
  autoscaling_read_max_capacity = 100
  autoscaling_write_max_capacity = 100
  autoscaling_read_target_value  = 70
  autoscaling_write_target_value = 70
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 5: Tabela com DynamoDB Streams e TTL

```hcl
module "dynamodb_with_streams" {
  source = "./modules/dynamodb"

  table_name   = "eventos"
  hash_key     = "event_id"
  range_key    = "timestamp"
  billing_mode = "PAY_PER_REQUEST"
  
  attributes = [
    {
      name = "event_id"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    }
  ]
  
  # DynamoDB Streams (para processar com Lambda)
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  # TTL para expirar registros automaticamente
  ttl_enabled        = true
  ttl_attribute_name = "expire_at"
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 6: Tabela com GSI e LSI

```hcl
module "dynamodb_complex" {
  source = "./modules/dynamodb"

  table_name   = "transacoes"
  hash_key     = "account_id"
  range_key    = "transaction_date"
  billing_mode = "PAY_PER_REQUEST"
  
  attributes = [
    {
      name = "account_id"
      type = "S"
    },
    {
      name = "transaction_date"
      type = "N"
    },
    {
      name = "transaction_type"
      type = "S"
    },
    {
      name = "amount"
      type = "N"
    }
  ]
  
  # Global Secondary Index (queries em outra partition key)
  global_secondary_indexes = [
    {
      name            = "type-amount-index"
      hash_key        = "transaction_type"
      range_key       = "amount"
      projection_type = "ALL"
    }
  ]
  
  # Local Secondary Index (queries na mesma partition key)
  local_secondary_indexes = [
    {
      name            = "amount-index"
      range_key       = "amount"
      projection_type = "KEYS_ONLY"
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 7: Global Table (Multi-Região)

```hcl
module "dynamodb_global" {
  source = "./modules/dynamodb"

  table_name   = "usuarios-global"
  hash_key     = "user_id"
  billing_mode = "PAY_PER_REQUEST"
  
  attributes = [
    {
      name = "user_id"
      type = "S"
    }
  ]
  
  # Replicação para múltiplas regiões
  replica_regions = ["us-west-2", "eu-west-1"]
  
  replica_kms_key_arns = {
    "us-west-2" = "arn:aws:kms:us-west-2:123456789012:key/abc123"
    "eu-west-1" = "arn:aws:kms:eu-west-1:123456789012:key/def456"
  }
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 8: Tabela Completa com Todos os Recursos

```hcl
module "dynamodb_full" {
  source = "./modules/dynamodb"

  table_name   = "aplicacao-principal"
  hash_key     = "id"
  range_key    = "created_at"
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD"
  
  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "created_at"
      type = "N"
    },
    {
      name = "user_email"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    }
  ]
  
  # Global Secondary Indexes
  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "user_email"
      projection_type = "ALL"
    },
    {
      name            = "status-created-index"
      hash_key        = "status"
      range_key       = "created_at"
      projection_type = "INCLUDE"
      non_key_attributes = ["id", "user_email"]
    }
  ]
  
  # Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  # TTL
  ttl_enabled        = true
  ttl_attribute_name = "expire_at"
  
  # Backup
  point_in_time_recovery_enabled = true
  
  # Criptografia
  encryption_enabled = true
  kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  
  # CloudWatch Alarms
  enable_cloudwatch_alarms       = true
  read_throttle_alarm_threshold  = 10
  write_throttle_alarm_threshold = 10
  
  project_name = "meu-projeto"
  environment  = "prod"
  
  additional_tags = {
    Application = "Core"
    CostCenter  = "Engineering"
    Compliance  = "GDPR"
  }
}
```

## Variáveis Principais

### Obrigatórias
- `table_name` - Nome da tabela
- `hash_key` - Chave de partição (partition key)
- `project_name` - Nome do projeto
- `environment` - Ambiente (dev, staging, prod)

### Opcionais Importantes
- `range_key` - Chave de ordenação (sort key)
- `billing_mode` - PAY_PER_REQUEST ou PROVISIONED (padrão: PAY_PER_REQUEST)
- `attributes` - Lista de atributos da tabela
- `global_secondary_indexes` - Lista de GSIs
- `local_secondary_indexes` - Lista de LSIs
- `stream_enabled` - Habilitar DynamoDB Streams
- `ttl_enabled` - Habilitar Time To Live
- `point_in_time_recovery_enabled` - Habilitar PITR (padrão: true)
- `autoscaling_enabled` - Habilitar auto scaling (modo PROVISIONED)

## Outputs

### Informações da Tabela
- `table_id` - ID da tabela
- `table_name` - Nome da tabela
- `table_arn` - ARN da tabela
- `table_stream_arn` - ARN do stream (se habilitado)

### Configuração
- `hash_key` - Nome da partition key
- `range_key` - Nome da sort key
- `billing_mode` - Modo de billing
- `read_capacity` - Capacidade de leitura
- `write_capacity` - Capacidade de escrita

### Índices
- `global_secondary_indexes` - Informações dos GSIs
- `local_secondary_indexes` - Informações dos LSIs

### Auto Scaling
- `autoscaling_read_target_arn` - ARN do target de auto scaling de leitura
- `autoscaling_write_target_arn` - ARN do target de auto scaling de escrita

### Alarmes
- `read_throttle_alarm_arn` - ARN do alarme de throttle de leitura
- `write_throttle_alarm_arn` - ARN do alarme de throttle de escrita

## Projection Types para Índices

| Tipo          | Descrição                    | Uso                                 |
|---------------|------------------------------|-------------------------------------|
| **ALL**       | Projeta todos os atributos   | Queries mais flexíveis, maior custo |
| **KEYS_ONLY** | Apenas as keys               | Menor custo, queries limitadas      |
| **INCLUDE**   | Keys + atributos específicos | Balanceado                          |

## Stream View Types

| Tipo                   | Conteúdo                             |
|------------------------|--------------------------------------|
| **KEYS_ONLY**          | Apenas as keys dos itens modificados |
| **NEW_IMAGE**          | Estado completo após a modificação   |
| **OLD_IMAGE**          | Estado completo antes da modificação |
| **NEW_AND_OLD_IMAGES** | Ambos os estados (recomendado)       |

## Notas Importantes

1. **Billing Mode**:
   - `PAY_PER_REQUEST`: Ideal para workloads imprevisíveis, sem gerenciamento de capacidade
   - `PROVISIONED`: Mais econômico para workloads previsíveis, requer gerenciamento

2. **Global Secondary Indexes (GSI)**:
   - Permitem queries em atributos que não são a partition key principal
   - Podem ter partition e sort keys diferentes da tabela principal
   - Suportam eventual consistency

3. **Local Secondary Indexes (LSI)**:
   - Devem ter a mesma partition key da tabela
   - Apenas a sort key pode ser diferente
   - Devem ser criados na criação da tabela (não podem ser adicionados depois)
   - Limitado a 5 LSIs por tabela

4. **DynamoDB Streams**:
   - Captura modificações na tabela em tempo real
   - Útil para integrar com AWS Lambda para processamento de eventos
   - Retenção de 24 horas

5. **TTL (Time To Live)**:
   - Deleta automaticamente itens expirados
   - Atributo deve ser timestamp Unix (em segundos)
   - Processo de deleção pode levar até 48 horas

6. **Point-in-Time Recovery**:
   - Permite restaurar tabela para qualquer ponto nos últimos 35 dias
   - Recomendado habilitar para produção

7. **Auto Scaling**:
   - Só funciona no modo PROVISIONED
   - Ajusta automaticamente read/write capacity baseado na utilização
   - Economiza custos ajustando capacidade dinamicamente

8. **Global Tables**:
   - Replicação multi-região para baixa latência global
   - Requer DynamoDB Streams habilitado
   - Eventual consistency entre regiões

## Limites do DynamoDB

- Tamanho máximo do item: 400 KB
- Partition key: até 2048 bytes
- Sort key: até 1024 bytes
- GSIs: até 20 por tabela
- LSIs: até 5 por tabela (criados na criação da tabela)
- Atributos projetados em índice: até 100

## Boas Práticas

1. **Design de Chaves**:
   - Use UUIDs ou hashes para partition keys para distribuição uniforme
   - Evite "hot partitions" (muitas requisições na mesma partition key)

2. **Índices**:
   - Crie apenas índices necessários (cada índice tem custo)
   - Use projection type adequado (KEYS_ONLY para economia)

3. **Billing**:
   - Use PAY_PER_REQUEST para desenvolvimento e workloads imprevisíveis
   - Use PROVISIONED com auto scaling para produção com tráfego constante

4. **Backup**:
   - Sempre habilite Point-in-Time Recovery em produção
   - Configure CloudWatch Alarms para monitorar throttling

5. **Segurança**:
   - Sempre habilite criptografia (server-side encryption)
   - Use KMS para controle fino de chaves de criptografia
