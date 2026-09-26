# CONTINUA.md: completa oii-solver da dove è arrivato

Copia questo file nella cartella del progetto e scrivi ad agy: «Segui CONTINUA.md». Se si interrompe, ripeti la stessa frase.

Segui AGENTS.md. Lavora in autonomia e in fretta: niente conferme tra un passo e l'altro, messaggi brevi, solo esito e problemi.

## 0. Orientati (sempre, anche se riparti)
1. Leggi PROGRESS.md; se non esiste, crealo con la checklist qui sotto, tutta non spuntata.
2. Controlla lo stato reale del codice con queste prove e allinea PROGRESS.md:
   - P1 intake: nodo intake; `python -c "from oii_solver.agent import root_agent"` funziona.
   - P2 download: olinfo.py e download_task; cache solo con work/<task>/meta.json; controllo del PDF; fallback/<task>/; suggerimento dei prefissi; nessun dato finto.
   - P3 reader: agente reader con TaskSpec e nodo route_mode.
   - P4 fan-out: quick_solver e test_author in parallelo con JoinNode.
   - P5 test runner: judge.py, test_runner con esempi e stress test parallelo, testkit.json riusato, messaggi di avanzamento.
   - P6 tabellone: benchmark per subtask, history e best, "stima non disponibile" se non ci sono subtask.
   - P7 reviewer: ciclo test_runner --rework--> reviewer --> test_runner; route done_solve e give_up.
   - P8 invio: ask_approval (RequestInput), handle_approval, submit, stop.
   - P9 valuta: route "valuta" → test_author_v → test_runner; done_teach → tutor → render_report con guida.md.
   - P10 report: report.html; submit e stop collegati a render_report.
   - P11 collaudo: tests/smoke_test.py passa.
3. Se in work/ ci sono dati finti (PDF segnaposto, allegati "dato di esempio"), cancellali. Se nel codice c'è un ramo che fornisce task finti fuori da tests/, rimuovilo: OLINFO_DRY_RUN riguarda solo l'invio.
4. Riparti dal primo passo non spuntato. Non riscrivere ciò che è già fatto e funziona.

## Regole per ogni passo
- Implementa, poi verifica: almeno l'import di root_agent, più i test indicati.
- Se la verifica passa, spunta il passo in PROGRESS.md con una riga di nota e prosegui.
- Dopo 3 tentativi falliti sullo stesso passo, fermati e riassumi il problema.
- La tua sandbox può non avere rete: non provare training.olinfo.it né Gemini da qui e non inventare dati per compensare. Le prove usano cartelle temporanee e dati costruiti nei test.
- Nomi di nodi, chiavi di stato, route e cartelle esattamente come in AGENTS.md. Ogni route emessa deve avere il suo arco.

## Specifiche dei passi
**P2 · Download.** Prima l'API JSON, poi la pagina pubblica https://training.olinfo.it/task/<task> (titolo, limiti, input/output, punteggio, allegati https://training.olinfo.it/files/<digest>/<nome>, link al PDF o JSON incorporato), infine fallback/<task>/testo.pdf e meta.json (chiavi titolo, time_limit in secondi, memory_limit_mb, io). testo.pdf deve iniziare con %PDF e avere almeno una pagina. Cache solo con work/<task>/meta.json con l'origine ("sito" o "fallback"). Python ammesso se c'è un template .py, altrimenti "da verificare all'invio". Stop solo se l'I/O non è stdin/stdout o serve un grader C/C++ senza grader.py. Task inesistente: prova i prefissi ois_, oii_, preoii_ e rispondi "Forse intendevi ...?".

**P3 · Reader.** reader (FAST_MODEL), TaskSpec: summary, io_format, constraints, subtasks [{punti, vincoli, n_max}], target_complexity, edge_cases, examples [{input, output}]. Estrae, non risolve. route_mode: salva la spec, mostra la tabella dei subtask, route "risolvi" o "valuta".

**P4 · Fan-out.** route_mode "risolvi" → (quick_solver, test_author) → JoinNode → test_runner. quick_solver (FAST_MODEL): Candidate {title, why, complexity, code}, output_key "candidate", la soluzione Python più semplice sicuramente corretta. test_author (FAST_MODEL): TestKit {brute_code, gen_code, subtask_gen_code}, output_key "testkit"; non vede mai la soluzione.

**P5 · Test runner.** judge.py senza LLM: Python in cartella temporanea con limiti, confronto a token. test_runner: esempi, poi STRESS_ITERS input contro la brute (se passa gli esempi), in parallelo fino a 4 processi, timeout pari al time limit, avanzamento in chat. testkit.json riusato. Se sbaglia: controesempio più corto in history, rework_reason "fix", route "rework". Se è corretta: work/<task>/<modalità>/v<N>.py.

**P6 · Tabellone.** Input massimo per ogni subtask, tempo contro il time limit, stima = somma dei punti nel limite. history e best nello stato; tabellone in chat; "stima non disponibile" se non ci sono subtask.

**P7 · Reviewer.** reviewer (STRONG_MODEL), Step {review, title, why, complexity, code}, output_key "candidate", istruzione come funzione con spec, codice, tabellone, controesempio. Un miglioramento per passo; con un controesempio corregge solo il bug. rework "improve" finché la stima non è piena e i passi sono meno di MAX_STEPS; dopo MAX_FIX correzioni fallite di fila riparte da best. Fine: "done_solve" (o "done_teach" in valuta); nessuna versione corretta: "give_up". Salva tabellone.json.

**P8 · Invio.** done_solve → ask_approval (RequestInput, chiede «invia») → handle_approval → submit o stop. submit: con OLINFO_DRY_RUN=1 simula; altrimenti login, verifica di Python tra i linguaggi, invio di best (PyPy se ammesso), esito per subtask accanto alla stima.

**P9 · Valuta.** route_mode "valuta" → test_author_v → test_runner; la v1 è il codice dello studente. tutor (STRONG_MODEL), Guide: review, steps [{v, obiettivo, perche, suggerimento, come_verificare}], chiusura; ogni step è una versione che ha superato i test; confronto con work/<task>/risolvi/tabellone.json se esiste. tutor → render_report (senza LLM) → guida.md.

**P10 · Report.** render_report scrive anche report.html: stime iniziale e finale, grafico SVG dei tempi con la linea del limite, diff affiancati con difflib.HtmlDiff, controesempi, soluzione finale in un <details>. submit e stop → render_report.

**P11 · Collaudo.** tests/smoke_test.py: Scripted(BaseLlm) con LlmResponse scriptate; sostituzione di node.model sui nodi di root_agent.graph.nodes; Runner(app_name="oii", node=root_agent, session_service=InMemorySessionService()); ripresa con create_request_input_response(interrupt_id, {"result": "invia"}) da google.adk.workflow.utils._workflow_hitl_utils; somma di N numeri con un bug nella v1; poi un giro in valuta con guida.md e report.html. Nessun file in work/.

## Alla fine
Riepilogo di 5 righe in chat e le prove da fare in adk web: `risolvi <task>` e `valuta <task>` con una soluzione allegata.
