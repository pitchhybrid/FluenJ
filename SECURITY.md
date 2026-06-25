# Política de Segurança

## Versões suportadas

O FluenJ está em fase **alpha**. Manutenção de segurança é aplicada à última versão `main`.

| Versão | Suportada |
|--------|-----------|
| 0.1.x  | ✅        |

## Reportando uma vulnerabilidade

Encontrou uma vulnerabilidade de segurança? **Por favor, não abra uma issue pública.**

Reporte de forma responsável:

1. Envie um e-mail para os mantenedores (veja o perfil do owner do repositório) **ou**
   use o recurso de _Security Advisories_ do GitHub
   ([Report a vulnerability](https://github.com/pitchhybrid/FluenJ/security/advisories/new)).
2. Inclua, sempre que possível:
   - Descrição do problema e impacto
   - Passos para reproduzir (ou PoC)
   - Versão afetada e plataforma
   - Sugestão de mitigação/correção (opcional)

### O que esperar
- **Confirmação** do recebimento em até **72h**.
- **Avaliação** e comunicação do impacto em até **7 dias**.
- **Correção** lançada o mais rápido possível, com crédito ao relator (se desejar).

## Escopo

O FluenJ é uma aplicação desktop que **executa código arbitrário por design** (é uma IDE:
roda builds, depura JVMs, abre terminais). Isso **não é** uma vulnerabilidade. São
considerados problemas de segurança: falhas que permitem execução/escalada **além** do
esperado para uma IDE, vazamento de dados sensíveis, ou quebras de isolamento.

Obrigado por ajudar a manter o FluenJ seguro. 🛡️
