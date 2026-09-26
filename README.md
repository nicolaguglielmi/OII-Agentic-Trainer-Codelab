# OII Agentic Trainer — Codelab «Il concorrente artificiale»

**▶ Segui il codelab:** [PAGES_URL](PAGES_URL)

## Contenuto

| Percorso | Cosa contiene |
|---|---|
| `codelab/concorrente-artificiale.md` | il codelab in formato [claat](https://github.com/googlecodelabs/tools) |
| `codelab/img/` | diagrammi e grafiche |
| `docs/` | il codelab già generato, pubblicato con GitHub Pages |

Per rigenerare il sito dopo una modifica:

```console
cd codelab
claat export concorrente-artificiale.md
rm -rf ../docs/* && cp -r concorrente-artificiale-adk2/. ../docs/ && touch ../docs/.nojekyll
```

## Licenza

Apache License 2.0
