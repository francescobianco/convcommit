#!/bin/bash

# Verifica se ci sono modifiche non ancora commesse
if [[ -n $(git status --porcelain) ]]; then
  echo "Ci sono modifiche non commesse. Si consiglia di fare un commit o di fare un backup prima di proseguire."
  exit 1
fi

# Usa rebase interattivo per fare il flatten dei commit
echo "Appiattendo i commit nella branch corrente..."
git reset $(git commit-tree HEAD^{tree} -m "Unico commit con tutto il codice")

# Commit unificato
git commit --amend --no-edit --date "$(date)"

# Aggiungi un messaggio finale
echo "Tutti i commit sono stati appiattiti in un unico commit!"
