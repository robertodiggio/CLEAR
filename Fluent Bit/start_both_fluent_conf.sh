#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/environment_variables.env"
ENV_STRING=$(grep -v '^#' "$ENV_FILE" | tr -d '\r' | tr '\n' ' ' | xargs)
# Carica le variabili d'ambiente
set -a
export $ENV_STRING
set +a

echo "Avvio di fluent1.conf in corso..."
# Avvia il primo processo in background
fluent-bit -c "$FLUENT_BIT_PATH/Fluent1/fluent1.conf" &

echo "In attesa di 20 secondi prima di avviare il secondo..."
# Aspetta 20 secondi
sleep 20

echo "Avvio di fluent2.conf in corso..."
# Avvia il secondo processo
fluent-bit -c "$FLUENT_BIT_PATH/Fluent2/fluent2.conf"