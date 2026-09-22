#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/environment_variables.env"
ENV_STRING=$(grep -v '^#' "$ENV_FILE" | tr -d '\r' | tr '\n' ' ' | xargs)
set -a
export $ENV_STRING
set +a
echo "Scegli quale file .conf vuoi eseguire:"
echo "  1) fluent1.conf"
echo "  2) fluent2.conf"
read -p "Opzione (1/2): " scelta

if [ "$scelta" = "1" ]; then
    fluent-bit -c "$FLUENT_BIT_PATH/Fluent1/fluent1.conf"
elif [ "$scelta" = "2" ]; then
    fluent-bit -c "$FLUENT_BIT_PATH/Fluent2/fluent2.conf"
else
    echo "Opzione non valida. Inserisci 1 o 2."
    exit 1
fi