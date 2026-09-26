# Progetto: oii-solver (ADK 2.x, Python)
Rete di agenti che risolve problemi OII di training.olinfo.it in Python e insegna a
migliorare il codice. Gira sulla macchina host, nell'ambiente virtuale .venv già attivo:
google-adk>=2.9, requests, python-dotenv e pymupdf sono già installati. Non installare nulla.

## Due modalità, un grafo
- risolvi <task>: prima una v1 semplice e corretta, poi il Reviewer la migliora un passo alla volta.
- valuta <task> + codice dello studente (incollato o allegato .py): il codice dello
  studente è la v1; il sistema la verifica, la migliora a passi e scrive una guida.

## Grafo obiettivo
START → intake → download_task → reader → route_mode
route_mode: risolvi → (quick_solver ∥ test_author) → join → test_runner
            valuta  → test_author_v → test_runner
test_runner: rework → reviewer → test_runner
             done_solve → ask_approval → handle_approval: submit | stop
             done_teach → tutor → render_report
             give_up → give_up
submit e stop → render_report
Nodi LLM: reader, quick_solver, test_author, test_author_v, reviewer, tutor. Gli altri: codice.

## Versioni e file
- state["candidate"] = {title, why, complexity, code}: la versione in prova.
- state["history"] = tutte le prove, anche fallite: {v, title, why, complexity, esito,
  controesempio, tempi per subtask, punteggio stimato}.
- state["best"] = la versione corretta con il punteggio stimato più alto.
- work/<task>/: testo e allegati scaricati; work/<task>/testkit.json: test condivisi.
- work/<task>/<modalità>/: v<N>.py, tabellone.json, guida.md, report.html.
- work/<task>/meta.json: scritto solo dopo un download riuscito, con l'origine ("sito" o
  "fallback"); senza meta.json la cache non vale.
- fallback/<task>/: testo.pdf e meta.json preparati a mano, usati solo se il sito non
  risponde o il PDF scaricato non è valido.

## API ADK 2.x (verificate su 2.9.2)
- from google.adk import Agent, Event, Workflow
  from google.adk.workflow import JoinNode
  from google.adk.events import RequestInput
- NON usare le API 1.x (SequentialAgent, ParallelAgent, LoopAgent).
- Workflow(name=..., edges=[...]); ogni edge è una catena:
  ("START", a, b) · routing: (b, {"x": c, "y": d}) · ciclo: (c, b)
  · routing verso un fan-out: (b, {"x": (p, q)}), poi (p, j), (q, j), (j, z) con j = JoinNode(name="j")
- Un nodo con più archi in ingresso parte a ogni trigger; JoinNode aspetta tutti.
- Nodo funzione: funzione Python (anche generatore). Parametri: ctx, node_input.
  Emette Event(state={...}, message="...", output=..., route="..."). ctx.state è modificabile.
- Nodo LLM: Agent(name, model, instruction, output_schema=Pydantic, output_key="k").
  instruction può essere una funzione (ctx) -> str: usala quando inietti codice.
- Human-in-the-loop: yield RequestInput(message=...); il nodo dopo riceve la risposta.
- Il Workflow copia gli Agent: non modificarli dopo averlo creato.
- adk web: oii_solver/__init__.py con "from . import agent"; root_agent in agent.py.
  adk web --reload_agents ricarica gli agenti quando cambia il codice.
- Modelli da .env: FAST_MODEL, STRONG_MODEL (default gemini-3.5-flash).

## API training.olinfo.it (non documentata, dal client @olinfo/training-api)
POST JSON a https://training.olinfo.it/api/<endpoint> → {"success":1,...} o {"success":0,"error"}
- task {action:"get", name} → title, task_type, time_limit (s), memory_limit (byte),
  statements {lingua: digest}, attachments [[nome, digest]], submission_format, supported_languages
- File e allegati: https://training.olinfo.it/files/<digest>/<nome>
- Pagina pubblica https://training.olinfo.it/task/<nome>: titolo, limiti, input/output, allegati.
  Se l'API non risponde, leggi i dati da qui. I linguaggi ammessi si vedono solo dopo il login.
- user {action:"login", username, password, keep_signed:false} → cookie training_token
- submission {action:"new", task_name, files:{<formato>:{data:base64, filename, language}}} → id
- submission {action:"details", id} → compilation_outcome, evaluation_outcome, score, score_details

## Regole
- Gli LLM propongono, il codice giudica: test e misure sono nodi deterministici.
- Soluzioni, brute force e generatori: Python 3, input/output su stdin/stdout
  (sys.stdin.buffer per leggere in fretta).
- Esecuzione: pypy3 se installato e ammesso dal task, altrimenti python3; sempre in una
  cartella temporanea con limiti di tempo, memoria e dimensione file (resource.setrlimit). Mai come root.
- Task adatti: input/output su stdin/stdout, template .py tra gli allegati, nessun grader C/C++ obbligatorio.
- Confronto output a token (split()).
- OLINFO_DRY_RUN riguarda solo l'invio. Il download usa sempre dati reali: sito, poi fallback/<task>/.
- Mai dati finti o segnaposto fuori da tests/: le prove usano cartelle temporanee. Se mancano
  i dati veri, fermati e dillo.
- Ogni route emessa da un nodo deve avere il suo arco: una route senza arco ferma il ramo.
- Nelle fasi lunghe (stress test, benchmark, Reviewer) scrivi in chat messaggi di avanzamento.
- Ogni passo finisce con una verifica veloce.
- Tutto in italiano: messaggi, prompt, commenti.
