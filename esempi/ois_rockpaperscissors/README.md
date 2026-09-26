# Soluzioni di partenza per `ois_rockpaperscissors`

Servono a provare la modalità `valuta` del codelab: `valuta ois_rockpaperscissors` con uno dei due file allegato.

* **`lenta.py`**: backtracking che assegna le scelte ai giocatori uno alla volta e scarta subito quelle incompatibili con le partite già giocate. È corretta ma esponenziale: conta le configurazioni valide una per una, quindi rallenta quando sono tante.
* **`lenta_con_bug.py`**: la stessa soluzione, con un bug realistico sul caso limite di un solo giocatore (stampa 1 invece di 5). Passa gli esempi del testo; lo stress test lo scopre con l'input `1 / 1`.

Verifiche fatte: gli esempi del testo danno 20 e 30; su 200 input casuali con N ≤ 7 `lenta.py` coincide con una forza bruta che prova tutte le 5ᴺ combinazioni.

Il testo del problema appartiene agli organizzatori delle Olimpiadi e non è incluso: lo trovi sulla pagina del task su training.olinfo.it.
