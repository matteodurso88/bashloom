# Compatibilità

Bashloom è Linux-first e richiede Bash **4.3 o successivo**.

## Ambienti supportati

| Ambiente | Stato | Note |
| --- | --- | --- |
| Linux | primario | baseline di sviluppo e CI |
| WSL | supportato | comportamento atteso equivalente allo userspace Linux corrispondente |
| macOS | best effort | vanno considerate versione Bash e differenze utility BSD/GNU |
| POSIX `sh` / `dash` / `ash` | non supportato | l'uso di feature specifiche Bash è intenzionale |

## Requisiti shell

Bashloom usa feature Bash come array, nameref e `[[ ... ]]`. I consumer devono invocare Bash esplicitamente oppure usare uno shebang Bash.

Gli entrypoint runtime sono source-safe: fare source di Bashloom non abilita intenzionalmente strict mode, non sostituisce trap del caller, non modifica `IFS`, non invoca `sudo` e non produce output.

## Modello delle dipendenze runtime

Bash è l'unica dipendenza obbligatoria per fare source del core runtime e del loader. Le singole feature possono richiedere utility standard del sistema operativo quando vengono invocate.

Utility feature-specific attualmente utilizzate:

- risorse temporanee: `mktemp`;
- helper directory: `mkdir`, opzionalmente `chmod`;
- helper symlink: `ln`, `readlink`;
- sostituzione atomica: `mv`, `chmod`, cleanup tramite `rm`;
- retry/wait/timeout: `sleep`;
- tooling installer/vendoring: `mkdir`, `cp`, `mv`, `rm`.

Bashloom controlla le dipendenze delle singole feature nel punto d'uso o vicino ad esso quando praticabile. Fare source del runtime completo non deve richiedere che tali comandi vengano eseguiti con successo.

## Comportamenti specifici GNU/Linux

`blm_atomic_write` preserva attualmente i permessi di una destinazione esistente tramite GNU `chmod --reference`. Questo fa parte dell'implementazione Linux-first e non è ancora portabile al `chmod` BSD fornito da macOS.

Il contratto attuale di atomic write copre la sostituzione atomica sullo stesso filesystem. Non promette durabilità in caso di perdita di alimentazione tramite `fsync` espliciti su file e directory.

## Comportamento terminale

L'output di stato degrada correttamente quando il colore non è disponibile. Bashloom considera `NO_COLOR`, `TERM=dumb` e output non-TTY. L'output machine-readable non deve dipendere da styling del terminale o supporto emoji.

## Stato compatibilità CI

Prima della v0.1.0 il progetto deve ancora introdurre una matrice CI formale per versioni Bash e distribuzioni. Fino a quel momento la baseline continuamente verificata resta il runner Ubuntu di GitHub Actions usato dalla CI del repository.
