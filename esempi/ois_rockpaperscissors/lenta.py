# Sasso Carta Forbici... (ois_rockpaperscissors) - soluzione base
# Idea: assegno le scelte ai giocatori uno alla volta (backtracking) e scarto
# subito ogni scelta incompatibile con le partite contro i giocatori precedenti.
# Corretta ma esponenziale: regge solo N piccoli (subtask 1 e 2).
import sys


def batte(x, y):
    # x batte y se y = x+1 oppure y = x+2 (mod 5)
    return (y - x) % 5 in (1, 2)


def main():
    sys.setrecursionlimit(10000)
    dati = sys.stdin.read().split()
    t = int(dati[0])
    pos = 1
    risposte = []
    for _ in range(t):
        n = int(dati[pos])
        pos += 1
        s = dati[pos:pos + n - 1]
        pos += n - 1
        # vince[i][j] = True se il giocatore i ha battuto j (indici da 0)
        vince = [[False] * n for _ in range(n)]
        for i in range(n - 1):
            for k, c in enumerate(s[i]):
                j = i + 1 + k
                vince[i][j] = (c == "1")
                vince[j][i] = (c == "0")
        x = [0] * n

        def conta(j):
            if j == n:
                return 1
            totale = 0
            for v in range(5):
                ok = True
                for i in range(j):
                    # scelte diverse: il risultato deve rispettare le regole
                    if x[i] != v and batte(x[i], v) != vince[i][j]:
                        ok = False
                        break
                if ok:
                    x[j] = v
                    totale += conta(j + 1)
            return totale

        risposte.append(conta(0))
    print("\n".join(map(str, risposte)))


main()
