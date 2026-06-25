# MCPs disponíveis nesta sessão

MCPs ativos no ambiente de desenvolvimento do **myide**. Úteis para acelerar trabalho em Flutter/Dart e gestão de docs.

## dart-server — Flutter/Dart ⭐ (mais relevante)
Servidor de desenvolvimento Flutter/Dart conectado ao projeto. Recursos:
- `analyze_files` — análise estática com quick-fixes automáticos.
- `pub` — `pub get/add/remove/upgrade`, busca no pub.dev (`pub_dev_search`).
- `lsp` — hover, signature help, `resolveWorkspaceSymbol` (busca de símbolos).
- `read_package_uris` / `rip_grep_packages` — **inspecionar dependências** (`package:` e `package-root:` URIs). Ideal para aprender a API de um pacote (foi assim que confirmamos a API do `hux`).
- `dtd` — conectar a apps Dart em execução (hot reload/restart, widget inspector, flutter driver, erros de runtime).

> Dica: para entender a API de qualquer dependência (ex.: `hux`), use `rip_grep_packages` + `read_package_uris` em vez de adivinhar.

## vaultforge — gestão deste vault ⭐
Notas estilo Obsidian para documentar o projeto (este vault). Recursos:
- `write_note` / `read_note` / `edit_note` / `delete_note`
- `smart_search` / `search_content` / `search_vault` (BM25 + índice)
- `frontmatter`, `batch`, `update_links`, `backlinks`
- `canvas_create` / `canvas_patch` (diagramas), `vault_themes`, `vault_suggest`
- `daily_note` para captura rápida

## filesystem
Operações de arquivo (create/read/edit/move/tree/search). Alternativa ao `Read`/`Write` do harness para manipular arquivos do projeto.

## plugin:context7:context7
Documentação atualizada de bibliotecas/frameworks. Útil para conferir APIs (ex.: Flutter, hux) com fontes recentes. Fluxo: `resolve-library-id` → `query-docs`.

## zread
Ler/explorar repositórios GitHub (`get_repo_structure`, `read_file`, `search_doc`). Útil para estudar o código-fonte de libs (ex.: `lofidesigner/hux`).

## server-fetch / web-reader / web-search-prime / web_reader
Acesso à web: buscar, ler páginas como markdown, buscar no pub.dev.

## zai-mcp-server
Visão: análise de imagens, vídeo, UI (mockup→código), diff de UI, OCR, diagnóstico de erros em screenshot, diagramas técnicos.

## sequential-thinking
Raciocínio estruturado em etapas (chain-of-thought) para problemas complexos.

## Veja também
- [[visao-geral]] · [[ambiente-desenvolvimento]]
